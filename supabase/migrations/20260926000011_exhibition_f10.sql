-- =============================================================================
-- FYPMS: score F10 at the exhibition (textbook R9)
--
-- The textbook has the supervisor and examiner evaluate the final
-- presentation, report and poster with F10 at the exhibition — exactly when
-- they open the Expo "My Visits" page for the project. F10 is an evaluator's
-- form (the student fills nothing in), so it can be opened from the visit:
--
--   get_exhibition_evaluation(project, create)
--     resolves the Expo project to its FYPMS record (fyp_expo_publications),
--     the caller's role on that record (supervisor / co-supervisor, then
--     examiner), and the record's latest F10 — or F15 when the student
--     qualified for special evaluation (F14). With p_create it opens that
--     form when the record has none yet, so the evaluator can score it with
--     submit_form_evaluation (which applies the usual rubric rules).
--
-- Projects not published from FYPMS return linked = false.
-- =============================================================================

create or replace function public.get_exhibition_evaluation(
  p_project_id uuid,
  p_create boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_record public.fyp_records%rowtype;
  v_role text;
  v_form_code text;
  v_submission public.fyp_form_submissions%rowtype;
  v_mine numeric;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select r.* into v_record
  from public.fyp_expo_publications p
  join public.fyp_records r on r.id = p.fyp_record_id
  where p.published_project_id = p_project_id
  order by p.published_at desc nulls last, p.updated_at desc
  limit 1;
  if not found then
    return jsonb_build_object('linked', false);
  end if;

  v_role := case
    when public.is_assigned_to_fyp_record(v_record.id, 'supervisor')
      or public.is_assigned_to_fyp_record(v_record.id, 'co_supervisor') then 'supervisor'
    when public.is_assigned_to_fyp_record(v_record.id, 'examiner') then 'examiner'
  end;
  if v_role is null then
    -- Not an evaluator of this record: reveal nothing about it.
    return jsonb_build_object('linked', true, 'evaluator_role', null);
  end if;

  v_form_code := case when public.fyp_is_special_evaluation_eligible(v_record.id) then 'F15' else 'F10' end;

  select * into v_submission
  from public.fyp_form_submissions
  where fyp_record_id = v_record.id and form_code = v_form_code
  order by form_version desc, created_at desc
  limit 1;

  if v_submission.id is null and p_create then
    insert into public.fyp_form_submissions (
      fyp_record_id, form_code, form_version, payload, status, submitted_by, submitted_at, created_at, updated_at
    ) values (
      v_record.id, v_form_code, 1,
      jsonb_build_object('source', 'exhibition', 'project_id', p_project_id),
      'submitted', v_record.student_id, v_now, v_now, v_now
    )
    returning * into v_submission;

    insert into public.fyp_audit_logs (
      actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
    ) values (
      v_uid, (select role from public.profiles where id = v_uid),
      'exhibition_form_opened', 'fyp_form_submissions', v_submission.id,
      jsonb_build_object('fyp_record_id', v_record.id, 'form_code', v_form_code, 'project_id', p_project_id),
      'database_rpc', v_now
    );
  end if;

  if v_submission.id is not null then
    select weighted_total into v_mine
    from public.fyp_form_evaluations
    where form_submission_id = v_submission.id and evaluator_id = v_uid and status = 'submitted';
  end if;

  return jsonb_build_object(
    'linked', true,
    'fyp_record_id', v_record.id,
    'evaluator_role', v_role,
    'form_code', v_form_code,
    'submission', case when v_submission.id is null then null else to_jsonb(v_submission) end,
    'my_weighted_total', v_mine
  );
end;
$$;

revoke execute on function public.get_exhibition_evaluation(uuid, boolean) from public, anon;
grant execute on function public.get_exhibition_evaluation(uuid, boolean) to authenticated;
