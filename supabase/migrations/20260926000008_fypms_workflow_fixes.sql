-- =============================================================================
-- FYPMS workflow fixes (known-gaps register G-23, G-26)
--
-- G-23  Correction evidence (F12) was only written into the audit log's
--       metadata, so staff confirming a correction never saw it. It is now
--       stored on the correction item (note, file, time), must name a file in
--       the record's own folder, and a submitted evidence file can't be
--       overwritten by the student.
-- G-26  assign_supervisor_to_fyp_record reset the workflow to
--       supervision_approved whatever stage the record was at, never set
--       co_supervisor_id, and left the previous holder of the role active.
--       Now each role has one active holder, the record's id columns follow,
--       the workflow only advances from the pre-supervision stages, and one
--       person can't be both a supervisor and the examiner of a record.
-- =============================================================================

alter table public.fyp_correction_items
  add column if not exists evidence_note text,
  add column if not exists evidence_url text,
  add column if not exists evidence_submitted_at timestamptz;

create or replace function public.submit_correction_evidence(
  p_correction_item_id uuid,
  p_note text default null,
  p_file_url text default null
)
returns public.fyp_correction_items
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_item public.fyp_correction_items%rowtype;
  v_previous_status text;
  v_note text := nullif(btrim(coalesce(p_note, '')), '');
  v_url text := nullif(btrim(coalesce(p_file_url, '')), '');
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_item from public.fyp_correction_items where id = p_correction_item_id;
  if not found then
    raise exception 'not-found: Correction item not found.'
      using errcode = 'P0002';
  end if;

  if not public.is_active_fyp_student(v_item.fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit correction evidence.'
      using errcode = '42501';
  end if;

  v_previous_status := v_item.status;
  if v_previous_status not in ('open', 'in_progress') then
    raise exception 'failed-precondition: Evidence can only be submitted for open or in-progress corrections.'
      using errcode = '55000';
  end if;

  if v_note is null and v_url is null then
    raise exception 'invalid-argument: Describe the amendment or attach the corrected file.'
      using errcode = '22023';
  end if;
  if length(coalesce(v_note, '')) > 2000 then
    raise exception 'invalid-argument: The note is limited to 2000 characters.'
      using errcode = '22023';
  end if;
  if v_url is not null and v_url not like '%/' || v_item.fyp_record_id::text || '/%' then
    raise exception 'invalid-argument: Files must be uploaded to this record''s folder.'
      using errcode = '22023';
  end if;

  update public.fyp_correction_items
  set status = 'evidence_submitted',
      evidence_note = v_note,
      evidence_url = v_url,
      evidence_submitted_at = v_now,
      updated_at = v_now
  where id = p_correction_item_id
  returning * into v_item;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'correction_evidence_submitted', 'fyp_correction_items', v_item.id,
    jsonb_build_object(
      'correction_item_id', p_correction_item_id,
      'previous_status', v_previous_status,
      'has_note', v_note is not null,
      'has_file', v_url is not null
    ),
    'database_rpc', v_now
  );

  return v_item;
end;
$$;

-- Submitted correction evidence joins reports / deliverables in the
-- no-overwrite rule.
create or replace function public.fyp_storage_object_is_submitted(p_path text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.fyp_report_submissions s
    where s.file_url = p_path or s.file_url like '%/' || p_path
       or s.plagiarism_report_url = p_path or s.plagiarism_report_url like '%/' || p_path
  ) or exists (
    select 1 from public.fyp_deliverables d
    where d.file_url = p_path or d.file_url like '%/' || p_path
  ) or exists (
    select 1 from public.fyp_correction_items c
    where c.evidence_url = p_path or c.evidence_url like '%/' || p_path
  );
$$;

create or replace function public.assign_supervisor_to_fyp_record(
  p_fyp_record_id uuid,
  p_supervisor_id uuid,
  p_role text default 'supervisor'
)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_record public.fyp_records%rowtype;
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_role not in ('supervisor', 'co_supervisor', 'examiner') then
    raise exception 'invalid-argument: Role must be supervisor, co_supervisor, or examiner.'
      using errcode = '22023';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id for update;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  if not public.is_csp_lecturer(v_record.current_course_code) and not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can assign supervisors.'
      using errcode = '42501';
  end if;

  if not exists (select 1 from public.profiles where id = p_supervisor_id and is_active) then
    raise exception 'not-found: Staff profile not found or inactive.'
      using errcode = 'P0002';
  end if;

  -- Impartiality: the examiner must not also supervise the record.
  if exists (
    select 1 from public.fyp_record_assignments a
    where a.fyp_record_id = p_fyp_record_id and a.is_active and a.lecturer_id = p_supervisor_id
      and ((p_role = 'examiner' and a.academic_role in ('supervisor', 'co_supervisor'))
        or (p_role <> 'examiner' and a.academic_role = 'examiner'))
  ) then
    raise exception 'invalid-argument: The same person cannot both supervise and examine a record.'
      using errcode = '22023';
  end if;

  -- One active holder per role: the new assignment replaces the previous one.
  update public.fyp_record_assignments
  set is_active = false, updated_at = v_now
  where fyp_record_id = p_fyp_record_id
    and academic_role = p_role
    and lecturer_id <> p_supervisor_id
    and is_active;

  insert into public.fyp_record_assignments (
    fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_role, p_supervisor_id, true, v_uid, v_now, v_now, v_now
  )
  on conflict (fyp_record_id, academic_role, lecturer_id)
  do update set is_active = true, assigned_by = v_uid, assigned_at = v_now, updated_at = v_now;

  update public.fyp_records
  set main_supervisor_id = case when p_role = 'supervisor' then p_supervisor_id else main_supervisor_id end,
      co_supervisor_id = case when p_role = 'co_supervisor' then p_supervisor_id else co_supervisor_id end,
      examiner_id = case when p_role = 'examiner' then p_supervisor_id else examiner_id end,
      -- Only a record still waiting for a supervisor moves on; a record that
      -- is further along keeps its stage when its supervisor changes.
      workflow_status = case
        when p_role = 'supervisor' and workflow_status in ('awaiting_supervisor_assignment', 'supervision_requested')
          then 'supervision_approved'
        else workflow_status
      end,
      updated_at = v_now
  where id = p_fyp_record_id
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_record_assignment', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('supervisor_id', p_supervisor_id, 'role', p_role,
                       'previous_status', v_record.workflow_status, 'status', v_result.workflow_status),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.submit_correction_evidence(uuid, text, text) from public, anon;
revoke execute on function public.fyp_storage_object_is_submitted(text) from public, anon;
revoke execute on function public.assign_supervisor_to_fyp_record(uuid, uuid, text) from public, anon;
grant execute on function public.submit_correction_evidence(uuid, text, text) to authenticated;
grant execute on function public.fyp_storage_object_is_submitted(text) to authenticated;
grant execute on function public.assign_supervisor_to_fyp_record(uuid, uuid, text) to authenticated;

-- assign_examiner had the same gaps; it now shares the rules above.
create or replace function public.assign_examiner(
  p_fyp_record_id uuid,
  p_examiner_id uuid
)
returns public.fyp_records
language sql
security definer
set search_path = public
as $$
  select public.assign_supervisor_to_fyp_record(p_fyp_record_id, p_examiner_id, 'examiner');
$$;

revoke execute on function public.assign_examiner(uuid, uuid) from public, anon;
grant execute on function public.assign_examiner(uuid, uuid) to authenticated;
