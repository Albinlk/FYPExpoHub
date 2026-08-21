-- ==============================================================================
-- FYP Expo Hub - FYPMS Student Self-Service Slice
-- 20260818000001_fypms_student_slice.sql
-- ==============================================================================
-- Adds:
--  1. Student self-registration on create_fyp_record (student may create their
--     own record; coordinator/admin behaviour unchanged).
--  2. save_lean_canvas (F13 Lean Canvas) RPC with versioned history.
--  3. submit_deliverable RPC (deliverables checklist submission).
-- All mutations remain SECURITY DEFINER and audited via fyp_audit_logs.
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. create_fyp_record: allow the active student to self-register their own
--    record. The student role is resolved from profile_academic_roles, and the
--    request must be for the caller themselves.
-- -----------------------------------------------------------------------------
create or replace function public.create_fyp_record(
  p_academic_semester_id uuid,
  p_student_id uuid,
  p_current_course_code text,
  p_programme_code text,
  p_matric_id text default null,
  p_project_title text default null,
  p_project_description text default null,
  p_project_type text default null,
  p_external_industry_partner text default null,
  p_previous_record_id uuid default null
)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles%rowtype;
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_profile from public.profiles where id = v_uid and is_active = true;
  if not found then
    raise exception 'permission-denied: Active user profile not found.'
      using errcode = '42501';
  end if;

  -- Coordinators and admins may create records for any active student.
  -- Students may create a record only for themselves.
  if not (
    public.is_admin()
    or public.is_fyp_coordinator()
    or (p_student_id = v_uid and public.has_academic_role('student'))
  ) then
    raise exception 'permission-denied: Only coordinators, administrators, or the student themselves can create FYP records.'
      using errcode = '42501';
  end if;

  if p_current_course_code not in ('CSP600', 'CSP650') then
    raise exception 'invalid-argument: Unsupported course code.'
      using errcode = '22023';
  end if;

  if not exists (
    select 1 from public.academic_semesters where id = p_academic_semester_id
  ) then
    raise exception 'not-found: Academic semester not found.'
      using errcode = 'P0002';
  end if;

  if not exists (
    select 1 from public.profiles where id = p_student_id and is_active = true
  ) then
    raise exception 'not-found: Student profile not found or inactive.'
      using errcode = 'P0002';
  end if;

  if p_previous_record_id is not null and not exists (
    select 1 from public.fyp_records where id = p_previous_record_id
  ) then
    raise exception 'not-found: Previous FYP record not found.'
      using errcode = 'P0002';
  end if;

  insert into public.fyp_records (
    academic_semester_id,
    student_id,
    current_course_code,
    programme_code,
    matric_id,
    project_title,
    project_description,
    project_type,
    external_industry_partner,
    previous_record_id,
    workflow_status,
    created_at,
    updated_at
  ) values (
    p_academic_semester_id,
    p_student_id,
    upper(p_current_course_code),
    p_programme_code,
    p_matric_id,
    p_project_title,
    p_project_description,
    p_project_type,
    p_external_industry_partner,
    p_previous_record_id,
    case when upper(p_current_course_code) = 'CSP600' then 'awaiting_supervisor_assignment' else 'project_registered' end,
    v_now,
    v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, v_profile.role, 'fyp_record_created', 'fyp_records', v_result.id,
    jsonb_build_object(
      'student_id', p_student_id,
      'course_code', upper(p_current_course_code),
      'semester_id', p_academic_semester_id,
      'self_registered', (p_student_id = v_uid)
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 2. save_lean_canvas (F13): persists the latest Lean Canvas revision. Each
--    save creates a new versioned row and demotes the previous latest.
--    Allowed for the student owner, assigned supervisors, coordinator, admin.
-- -----------------------------------------------------------------------------
create or replace function public.save_lean_canvas(
  p_fyp_record_id uuid,
  p_blocks jsonb default '{}'::jsonb
)
returns public.fyp_lean_canvases
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_lean_canvases%rowtype;
  v_version integer;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.can_edit_fyp_record(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner, supervisor, or coordinator can save the lean canvas.'
      using errcode = '42501';
  end if;

  select coalesce(max(canvas_version), 0) + 1 into v_version
  from public.fyp_lean_canvases
  where fyp_record_id = p_fyp_record_id;

  update public.fyp_lean_canvases
  set is_latest = false
  where fyp_record_id = p_fyp_record_id and is_latest = true;

  insert into public.fyp_lean_canvases (
    fyp_record_id,
    canvas_version,
    blocks,
    is_latest,
    created_at,
    updated_at
  ) values (
    p_fyp_record_id,
    v_version,
    coalesce(p_blocks, '{}'::jsonb),
    true,
    v_now,
    v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_lean_canvas_saved', 'fyp_lean_canvases', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'canvas_version', v_version),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 3. submit_deliverable: student owner submits / updates a deliverable for the
--    record. Re-submitting the same deliverable_type bumps the version.
-- -----------------------------------------------------------------------------
create or replace function public.submit_deliverable(
  p_fyp_record_id uuid,
  p_deliverable_type text,
  p_title text,
  p_description text default null,
  p_file_url text default null
)
returns public.fyp_deliverables
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_deliverables%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit deliverables.'
      using errcode = '42501';
  end if;

  if btrim(p_deliverable_type) = '' then
    raise exception 'invalid-argument: Deliverable type is required.'
      using errcode = '22023';
  end if;

  if btrim(p_title) = '' then
    raise exception 'invalid-argument: Deliverable title is required.'
      using errcode = '22023';
  end if;

  update public.fyp_deliverables
  set version = version + 1,
      title = p_title,
      description = p_description,
      file_url = p_file_url,
      submitted_by = v_uid,
      submitted_at = v_now,
      updated_at = v_now
  where fyp_record_id = p_fyp_record_id
    and deliverable_type = p_deliverable_type
  returning * into v_result;

  if not found then
    insert into public.fyp_deliverables (
      fyp_record_id,
      deliverable_type,
      title,
      description,
      file_url,
      version,
      is_required,
      submitted_by,
      submitted_at,
      created_at,
      updated_at
    ) values (
      p_fyp_record_id,
      p_deliverable_type,
      p_title,
      p_description,
      p_file_url,
      1,
      false,
      v_uid,
      v_now,
      v_now,
      v_now
    )
    returning * into v_result;
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_deliverable_submitted', 'fyp_deliverables', v_result.id,
    jsonb_build_object(
      'fyp_record_id', p_fyp_record_id,
      'deliverable_type', p_deliverable_type,
      'version', v_result.version
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;
