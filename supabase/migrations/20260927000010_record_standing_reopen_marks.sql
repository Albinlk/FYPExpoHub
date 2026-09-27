-- =============================================================================
-- Withdrawn / incomplete records and reopening finalized marks (backlog F3, F4)
--
-- F4  set_fyp_record_standing (coordinator): mark a record 'withdrawn' (the
--     student left the course) or 'incomplete' (TL — the course carries over).
--     The status it had is kept in status_before_hold so
--     reinstate_fyp_record can put it back. Both need a reason; audited.
-- F3  reopen_fyp_course_marks (coordinator): unlock a finalized course mark
--     so evaluations can be corrected and the lecturer finalizes again. The
--     reason and the previous total / grade are kept in the audit log and in
--     export_payload.reopened. CSP600 marks of a record already promoted to
--     CSP650 stay locked (the promotion relied on them).
-- =============================================================================

alter table public.fyp_records drop constraint if exists fyp_records_workflow_status_check;
alter table public.fyp_records add constraint fyp_records_workflow_status_check check (workflow_status in (
  'awaiting_supervisor_assignment', 'supervision_requested', 'supervision_approved', 'formulation_in_progress',
  'proposal_submitted', 'proposal_under_review', 'proposal_revision_required', 'proposal_approved',
  'formulation_completed', 'project_registered', 'project_ongoing', 'final_report_submitted',
  'final_report_under_review', 'final_report_approved', 'project_completed', 'project_archived',
  'project_pending_presentation', 'withdrawn', 'incomplete'
));

alter table public.fyp_records add column if not exists status_before_hold text;
alter table public.fyp_records add column if not exists status_reason text;

create or replace function public.set_fyp_record_standing(p_fyp_record_id uuid, p_status text, p_reason text)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_record public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator changes a record''s standing.' using errcode = '42501';
  end if;
  if p_status not in ('withdrawn', 'incomplete') then
    raise exception 'invalid-argument: Standing must be withdrawn or incomplete.' using errcode = '22023';
  end if;
  if char_length(btrim(coalesce(p_reason, ''))) < 5 then
    raise exception 'invalid-argument: Give a reason (at least 5 characters).' using errcode = '22023';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id for update;
  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;
  if v_record.workflow_status in ('withdrawn', 'incomplete', 'project_archived', 'project_completed') then
    raise exception 'failed-precondition: The record is % and cannot become %.',
      replace(v_record.workflow_status, '_', ' '), p_status using errcode = '55000';
  end if;

  update public.fyp_records
  set status_before_hold = workflow_status,
      workflow_status = p_status,
      status_reason = btrim(p_reason),
      updated_at = v_now
  where id = p_fyp_record_id
  returning * into v_record;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'record_' || p_status, 'fyp_records', p_fyp_record_id,
          jsonb_build_object('from', v_record.status_before_hold, 'reason', btrim(p_reason)), 'database_rpc', v_now);
  perform public.fyp_notify(v_record.student_id, 'record_' || p_status,
    case p_status when 'withdrawn' then 'Your FYP record was marked withdrawn' else 'Your FYP record was marked incomplete (TL)' end,
    btrim(p_reason), '/fypms/student', p_fyp_record_id);
  return v_record;
end;
$$;

revoke execute on function public.set_fyp_record_standing(uuid, text, text) from public, anon;
grant execute on function public.set_fyp_record_standing(uuid, text, text) to authenticated;

create or replace function public.reinstate_fyp_record(p_fyp_record_id uuid, p_reason text)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_record public.fyp_records%rowtype;
  v_was text;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator reinstates records.' using errcode = '42501';
  end if;
  if char_length(btrim(coalesce(p_reason, ''))) < 5 then
    raise exception 'invalid-argument: Give a reason (at least 5 characters).' using errcode = '22023';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id for update;
  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;
  if v_record.workflow_status not in ('withdrawn', 'incomplete') then
    raise exception 'failed-precondition: Only withdrawn or incomplete records can be reinstated.' using errcode = '55000';
  end if;
  v_was := v_record.workflow_status;

  update public.fyp_records
  set workflow_status = coalesce(status_before_hold, 'project_registered'),
      status_before_hold = null,
      status_reason = null,
      updated_at = v_now
  where id = p_fyp_record_id
  returning * into v_record;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'record_reinstated', 'fyp_records', p_fyp_record_id,
          jsonb_build_object('from', v_was, 'to', v_record.workflow_status, 'reason', btrim(p_reason)), 'database_rpc', v_now);
  perform public.fyp_notify(v_record.student_id, 'record_reinstated', 'Your FYP record was reinstated',
    btrim(p_reason), '/fypms/student', p_fyp_record_id);
  return v_record;
end;
$$;

revoke execute on function public.reinstate_fyp_record(uuid, text) from public, anon;
grant execute on function public.reinstate_fyp_record(uuid, text) to authenticated;

create or replace function public.reopen_fyp_course_marks(p_fyp_record_id uuid, p_course_code text, p_reason text)
returns public.fyp_marks_summaries
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_summary public.fyp_marks_summaries%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator reopens finalized marks.' using errcode = '42501';
  end if;
  if char_length(btrim(coalesce(p_reason, ''))) < 10 then
    raise exception 'invalid-argument: Explain why the marks are reopened (at least 10 characters).' using errcode = '22023';
  end if;

  select * into v_summary from public.fyp_marks_summaries
  where fyp_record_id = p_fyp_record_id and course_code = upper(btrim(p_course_code)) and is_finalized
  order by finalized_at desc nulls last
  limit 1
  for update;
  if not found then
    raise exception 'failed-precondition: There are no finalized % marks on this record.', upper(btrim(p_course_code)) using errcode = '55000';
  end if;
  if v_summary.course_code = 'CSP600'
     and exists (select 1 from public.fyp_records where previous_record_id = p_fyp_record_id) then
    raise exception 'failed-precondition: This record was already promoted to CSP650 on these CSP600 marks; they stay locked.' using errcode = '55000';
  end if;

  update public.fyp_marks_summaries
  set is_finalized = false,
      finalized_by = null,
      finalized_at = null,
      export_payload = coalesce(export_payload, '{}'::jsonb) || jsonb_build_object('reopened',
        coalesce(export_payload->'reopened', '[]'::jsonb) || jsonb_build_array(jsonb_build_object(
          'at', v_now, 'by', v_uid, 'reason', btrim(p_reason),
          'previous_total', v_summary.weighted_total, 'previous_grade', v_summary.grade,
          'previous_finalized_at', v_summary.finalized_at))),
      updated_at = v_now
  where id = v_summary.id
  returning * into v_summary;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'course_marks_reopened', 'fyp_marks_summaries', v_summary.id,
          jsonb_build_object('fyp_record_id', p_fyp_record_id, 'course_code', v_summary.course_code,
                             'previous_total', v_summary.weighted_total, 'previous_grade', v_summary.grade,
                             'reason', btrim(p_reason)), 'database_rpc', v_now);
  perform public.fyp_notify(o.lecturer_id, 'marks_reopened', v_summary.course_code || ' marks reopened — finalize again when corrected',
    public.fyp_record_label(p_fyp_record_id), '/fypms/csp/marks', p_fyp_record_id)
  from public.fyp_course_offerings o
  where o.academic_semester_id = v_summary.academic_semester_id and o.course_code = v_summary.course_code and o.is_active;
  return v_summary;
end;
$$;

revoke execute on function public.reopen_fyp_course_marks(uuid, text, text) from public, anon;
grant execute on function public.reopen_fyp_course_marks(uuid, text, text) to authenticated;
