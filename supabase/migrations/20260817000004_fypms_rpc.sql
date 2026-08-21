-- ==============================================================================
-- FYP Expo Hub - FYPMS PostgreSQL Functions / RPC for Sensitive Operations
-- 20260817000004_fypms_rpc.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. create_fyp_record
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

  if not (public.is_admin() or public.is_fyp_coordinator()) then
    raise exception 'permission-denied: Only coordinators or administrators can create FYP records.'
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
      'semester_id', p_academic_semester_id
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 2. submit_supervision_request (F1)
-- -----------------------------------------------------------------------------
create or replace function public.submit_supervision_request(
  p_fyp_record_id uuid,
  p_preferred_supervisor_id uuid default null,
  p_rationale text default null
)
returns public.fyp_supervision_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_supervision_requests%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit a supervision request.'
      using errcode = '42501';
  end if;

  if p_preferred_supervisor_id is not null and not exists (
    select 1 from public.profiles where id = p_preferred_supervisor_id and is_active = true
  ) then
    raise exception 'not-found: Preferred supervisor profile not found.'
      using errcode = 'P0002';
  end if;

  insert into public.fyp_supervision_requests (
    fyp_record_id, preferred_supervisor_id, rationale, status, created_at, updated_at
  ) values (
    p_fyp_record_id, p_preferred_supervisor_id, p_rationale, 'pending', v_now, v_now
  )
  returning * into v_result;

  update public.fyp_records
  set workflow_status = 'supervision_requested', updated_at = v_now
  where id = p_fyp_record_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'supervision_request_submitted', 'fyp_supervision_requests', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 3. decide_supervision_request
-- -----------------------------------------------------------------------------
create or replace function public.decide_supervision_request(
  p_request_id uuid,
  p_decision text,
  p_supervisor_id uuid default null,
  p_decision_reason text default null
)
returns public.fyp_supervision_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles%rowtype;
  v_request public.fyp_supervision_requests%rowtype;
  v_result public.fyp_supervision_requests%rowtype;
  v_record public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_decision not in ('approved', 'rejected') then
    raise exception 'invalid-argument: Decision must be approved or rejected.'
      using errcode = '22023';
  end if;

  select * into v_profile from public.profiles where id = v_uid and is_active = true;
  if not found then
    raise exception 'permission-denied: Active user profile not found.'
      using errcode = '42501';
  end if;

  select * into v_request from public.fyp_supervision_requests where id = p_request_id;
  if not found then
    raise exception 'not-found: Supervision request not found.'
      using errcode = 'P0002';
  end if;

  select * into v_record from public.fyp_records where id = v_request.fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  if not public.is_csp_lecturer(v_record.current_course_code) and not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can decide supervision requests.'
      using errcode = '42501';
  end if;

  if v_request.status <> 'pending' then
    raise exception 'failed-precondition: Request has already been decided.'
      using errcode = '55000';
  end if;

  update public.fyp_supervision_requests
  set
    status = p_decision,
    decided_by = v_uid,
    decided_at = v_now,
    decision_reason = p_decision_reason,
    updated_at = v_now
  where id = p_request_id
  returning * into v_result;

  if p_decision = 'approved' then
    if p_supervisor_id is null then
      p_supervisor_id := coalesce(v_request.preferred_supervisor_id, v_uid);
    end if;

    update public.fyp_records
    set
      main_supervisor_id = p_supervisor_id,
      workflow_status = 'supervision_approved',
      updated_at = v_now
    where id = v_request.fyp_record_id;

    insert into public.fyp_record_assignments (
      fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at,
      created_at, updated_at
    ) values (
      v_request.fyp_record_id, 'supervisor', p_supervisor_id, true, v_uid, v_now, v_now, v_now
    )
    on conflict (fyp_record_id, academic_role, lecturer_id)
    do update set is_active = true, updated_at = v_now;
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, v_profile.role, 'supervision_request_' || p_decision,
    'fyp_supervision_requests', v_result.id,
    jsonb_build_object('fyp_record_id', v_request.fyp_record_id, 'supervisor_id', p_supervisor_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 4. update_fyp_record_field (student editable project fields)
-- -----------------------------------------------------------------------------
create or replace function public.update_fyp_record_field(
  p_fyp_record_id uuid,
  p_field text,
  p_value text
)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
  v_allowed constant text[] := array[
    'project_title', 'project_description', 'project_type',
    'external_industry_partner'
  ];
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.can_edit_fyp_record(p_fyp_record_id) then
    raise exception 'permission-denied: You do not have permission to edit this record.'
      using errcode = '42501';
  end if;

  if p_field is null or not (p_field = any (v_allowed)) then
    raise exception 'invalid-argument: Field % is not editable.', p_field
      using errcode = '22023';
  end if;

  execute format(
    'update public.fyp_records set %I = $1, updated_at = $2 where id = $3 returning *',
    p_field
  ) using p_value, v_now, p_fyp_record_id into v_result;

  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_record_field_updated', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('field', p_field),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 4b. admin_override_fyp_record_field (coordinator / admin, mandatory reason)
-- -----------------------------------------------------------------------------
create or replace function public.admin_override_fyp_record_field(
  p_fyp_record_id uuid,
  p_field text,
  p_value text,
  p_reason text
)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
  v_allowed constant text[] := array[
    'project_title', 'project_description', 'project_type',
    'external_industry_partner', 'matric_id', 'programme_code',
    'main_supervisor_id', 'co_supervisor_id', 'examiner_id'
  ];
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not (public.is_admin() or public.is_fyp_coordinator()) then
    raise exception 'permission-denied: Only the coordinator or administrator can override record fields.'
      using errcode = '42501';
  end if;

  if trim(coalesce(p_reason, '')) = '' then
    raise exception 'invalid-argument: A mandatory reason is required for an override.'
      using errcode = '22023';
  end if;

  if p_field is null or not (p_field = any (v_allowed)) then
    raise exception 'invalid-argument: Field % is not supported for override.', p_field
      using errcode = '22023';
  end if;

  execute format(
    'update public.fyp_records set %I = $1, updated_at = $2 where id = $3 returning *',
    p_field
  ) using p_value, v_now, p_fyp_record_id into v_result;

  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_record_field_overridden', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('field', p_field, 'reason', p_reason),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 5. submit_progress_log (F5)
-- -----------------------------------------------------------------------------
create or replace function public.submit_progress_log(
  p_fyp_record_id uuid,
  p_week_number integer,
  p_summary text,
  p_challenges text default null,
  p_next_plan text default null,
  p_progress_date date default null
)
returns public.fyp_progress_logs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_progress_logs%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_week_number is null or p_week_number <= 0 then
    raise exception 'invalid-argument: A positive week number is required.'
      using errcode = '22023';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit progress logs.'
      using errcode = '42501';
  end if;

  insert into public.fyp_progress_logs (
    fyp_record_id, week_number, progress_date, summary, challenges, next_plan,
    status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_week_number, coalesce(p_progress_date, current_date), p_summary,
    p_challenges, p_next_plan, 'submitted', v_uid, v_now, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'progress_log_submitted', 'fyp_progress_logs', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'week_number', p_week_number),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 6. submit_fyp_form (F2, F3, F4, F6a, F7, F8, F9, F10, F11, F13, F14, F15, F16)
-- -----------------------------------------------------------------------------
create or replace function public.submit_fyp_form(
  p_fyp_record_id uuid,
  p_form_code text,
  p_payload jsonb,
  p_file_url text default null,
  p_similarity_index numeric default null
)
returns public.fyp_form_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_form public.fyp_form_submissions%rowtype;
  v_version integer;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_form_code not in ('F2', 'F3', 'F4', 'F6a', 'F7', 'F8', 'F9', 'F10', 'F11', 'F13', 'F14', 'F15', 'F16') then
    raise exception 'invalid-argument: Unsupported form code.'
      using errcode = '22023';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit forms.'
      using errcode = '42501';
  end if;

  select coalesce(max(form_version), 0) + 1 into v_version
  from public.fyp_form_submissions
  where fyp_record_id = p_fyp_record_id and form_code = p_form_code;

  insert into public.fyp_form_submissions (
    fyp_record_id, form_code, form_version, payload, status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_form_code, v_version, coalesce(p_payload, '{}'::jsonb), 'submitted',
    v_uid, v_now, v_now, v_now
  )
  returning * into v_form;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_form_submitted', 'fyp_form_submissions', v_form.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'form_code', p_form_code, 'form_version', v_version, 'file_url', p_file_url),
    'database_rpc', v_now
  );

  return v_form;
end;
$$;

-- -----------------------------------------------------------------------------
-- 7. submit_report_version (F6a / F6b)
-- -----------------------------------------------------------------------------
create or replace function public.submit_report_version(
  p_fyp_record_id uuid,
  p_report_type text,
  p_file_url text,
  p_similarity_index numeric default null
)
returns public.fyp_report_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_report_submissions%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_report_type not in ('proposal', 'final') then
    raise exception 'invalid-argument: Report type must be proposal or final.'
      using errcode = '22023';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit report versions.'
      using errcode = '42501';
  end if;

  insert into public.fyp_report_submissions (
    fyp_record_id, report_type, file_url, similarity_index, status,
    submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_report_type, p_file_url, p_similarity_index, 'submitted',
    v_uid, v_now, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'report_version_submitted', 'fyp_report_submissions', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'report_type', p_report_type),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 8. submit_form_evaluation (F7, F8, F10, F11)
-- -----------------------------------------------------------------------------
create or replace function public.submit_form_evaluation(
  p_form_submission_id uuid,
  p_scores jsonb,
  p_comments text default null
)
returns public.fyp_form_evaluations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_form public.fyp_form_submissions%rowtype;
  v_result public.fyp_form_evaluations%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_form from public.fyp_form_submissions where id = p_form_submission_id;
  if not found then
    raise exception 'not-found: Form submission not found.'
      using errcode = 'P0002';
  end if;

  if not (
    public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'examiner')
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only assigned supervisors or examiners can evaluate forms.'
      using errcode = '42501';
  end if;

  insert into public.fyp_form_evaluations (
    form_submission_id, evaluator_id, scores, comments, status, evaluated_at, created_at, updated_at
  ) values (
    p_form_submission_id, v_uid, coalesce(p_scores, '{}'::jsonb), p_comments,
    'completed', v_now, v_now, v_now
  )
  returning * into v_result;

  update public.fyp_form_submissions
  set status = 'completed', updated_at = v_now
  where id = p_form_submission_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'form_evaluated', 'fyp_form_evaluations', v_result.id,
    jsonb_build_object('form_submission_id', p_form_submission_id, 'scores', p_scores),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 9. assign_supervisor_to_fyp_record
-- -----------------------------------------------------------------------------
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
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_csp_lecturer(
    (select current_course_code from public.fyp_records r where r.id = p_fyp_record_id)
  ) and not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can assign supervisors.'
      using errcode = '42501';
  end if;

  if p_role not in ('supervisor', 'co_supervisor', 'examiner') then
    raise exception 'invalid-argument: Role must be supervisor, co_supervisor, or examiner.'
      using errcode = '22023';
  end if;

  update public.fyp_records
  set main_supervisor_id = case when p_role = 'supervisor' then p_supervisor_id else fyp_records.main_supervisor_id end,
      examiner_id = case when p_role = 'examiner' then p_supervisor_id else fyp_records.examiner_id end,
      workflow_status = case when p_role = 'supervisor' then 'supervision_approved' else fyp_records.workflow_status end,
      updated_at = v_now
  where id = p_fyp_record_id
  returning * into v_result;

  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  insert into public.fyp_record_assignments (
    fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_role, p_supervisor_id, true, v_uid, v_now, v_now, v_now
  )
  on conflict (fyp_record_id, academic_role, lecturer_id)
  do update set is_active = true, updated_at = v_now;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_record_assignment', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('supervisor_id', p_supervisor_id, 'role', p_role),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 10. review_progress_log (F5 validation)
-- -----------------------------------------------------------------------------
create or replace function public.review_progress_log(
  p_progress_log_id uuid,
  p_decision text,
  p_validation_comment text default null
)
returns public.fyp_progress_logs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_log public.fyp_progress_logs%rowtype;
  v_result public.fyp_progress_logs%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_decision not in ('validated', 'rejected') then
    raise exception 'invalid-argument: Decision must be validated or rejected.'
      using errcode = '22023';
  end if;

  select * into v_log from public.fyp_progress_logs where id = p_progress_log_id;
  if not found then
    raise exception 'not-found: Progress log not found.'
      using errcode = 'P0002';
  end if;

  if not (
    public.is_assigned_to_fyp_record(v_log.fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_log.fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only assigned supervisors can validate progress logs.'
      using errcode = '42501';
  end if;

  update public.fyp_progress_logs
  set status = p_decision, validation_comment = p_decision_comment, updated_at = v_now
  where id = p_progress_log_id
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'progress_log_' || p_decision, 'fyp_progress_logs', p_progress_log_id,
    jsonb_build_object('fyp_record_id', v_log.fyp_record_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 11. create_or_update_milestone
-- -----------------------------------------------------------------------------
create or replace function public.create_or_update_milestone(
  p_fyp_record_id uuid,
  p_milestone_code text,
  p_milestone_title text,
  p_description text default null,
  p_target_date date default null,
  p_status text default 'pending'
)
returns public.fyp_milestones
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_milestones%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_status not in ('pending', 'in_progress', 'completed', 'overdue') then
    raise exception 'invalid-argument: Unsupported milestone status.'
      using errcode = '22023';
  end if;

  if not (
    public.is_csp_lecturer((select current_course_code from public.fyp_records r where r.id = p_fyp_record_id))
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can manage milestones.'
      using errcode = '42501';
  end if;

  insert into public.fyp_milestones (
    fyp_record_id, milestone_code, milestone_title, description, target_date, status, created_at, updated_at
  ) values (
    p_fyp_record_id, p_milestone_code, p_milestone_title, p_description, p_target_date, p_status, v_now, v_now
  )
  on conflict (fyp_record_id, milestone_code)
  do update set
    milestone_title = excluded.milestone_title,
    description = coalesce(excluded.description, fyp_milestones.description),
    target_date = coalesce(excluded.target_date, fyp_milestones.target_date),
    status = excluded.status,
    completed_at = case when excluded.status = 'completed' then v_now else fyp_milestones.completed_at end,
    updated_at = v_now
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'milestone_upserted', 'fyp_milestones', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'milestone_code', p_milestone_code),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 12. grant_milestone_extension
-- -----------------------------------------------------------------------------
create or replace function public.grant_milestone_extension(
  p_milestone_id uuid,
  p_requested_by uuid default null,
  p_reason text default null,
  p_requested_due_date date default null,
  p_decision text default 'pending'
)
returns public.fyp_milestone_extensions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_milestone public.fyp_milestones%rowtype;
  v_result public.fyp_milestone_extensions%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_milestone from public.fyp_milestones where id = p_milestone_id;
  if not found then
    raise exception 'not-found: Milestone not found.'
      using errcode = 'P0002';
  end if;

  if p_decision not in ('pending', 'approved', 'rejected') then
    raise exception 'invalid-argument: Unsupported decision.'
      using errcode = '22023';
  end if;

  if p_decision = 'pending' and not public.is_active_fyp_student(v_milestone.fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can request an extension.'
      using errcode = '42501';
  end if;

  if p_decision in ('approved', 'rejected') and not (
    public.is_csp_lecturer((select current_course_code from public.fyp_records r where r.id = v_milestone.fyp_record_id))
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can decide extensions.'
      using errcode = '42501';
  end if;

  insert into public.fyp_milestone_extensions (
    milestone_id, requested_by, reason, requested_due_date, status, decided_by, decided_at,
    created_at, updated_at
  ) values (
    p_milestone_id, coalesce(p_requested_by, v_uid), p_reason, p_requested_due_date,
    p_decision, case when p_decision = 'pending' then null else v_uid end,
    case when p_decision = 'pending' then null else v_now end,
    v_now, v_now
  )
  returning * into v_result;

  if p_decision = 'approved' then
    update public.fyp_milestones
    set target_date = p_requested_due_date, status = 'in_progress', updated_at = v_now
    where id = p_milestone_id;
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'milestone_extension_' || p_decision, 'fyp_milestone_extensions', v_result.id,
    jsonb_build_object('milestone_id', p_milestone_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;


-- -----------------------------------------------------------------------------
-- 13. schedule_presentation_slot
-- -----------------------------------------------------------------------------
create or replace function public.schedule_presentation_slot(
  p_session_id uuid,
  p_fyp_record_id uuid,
  p_slot_number integer,
  p_room text default null
)
returns public.fyp_presentation_slots
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_session public.fyp_presentation_sessions%rowtype;
  v_result public.fyp_presentation_slots%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_session from public.fyp_presentation_sessions where id = p_session_id;
  if not found then
    raise exception 'not-found: Presentation session not found.'
      using errcode = 'P0002';
  end if;

  if not (
    public.is_csp_lecturer((select course_code from public.fyp_course_offerings o where o.id = v_session.offering_id))
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can schedule slots.'
      using errcode = '42501';
  end if;

  insert into public.fyp_presentation_slots (
    session_id, fyp_record_id, slot_number, room, created_at, updated_at
  ) values (
    p_session_id, p_fyp_record_id, p_slot_number, p_room, v_now, v_now
  )
  returning * into v_result;

  update public.fyp_records
  set workflow_status = 'project_pending_presentation', updated_at = v_now
  where id = p_fyp_record_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'presentation_slot_scheduled', 'fyp_presentation_slots', v_result.id,
    jsonb_build_object('session_id', p_session_id, 'fyp_record_id', p_fyp_record_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 13. finalize_course_marks (export-ready, no external RES integration)
-- -----------------------------------------------------------------------------
create or replace function public.finalize_course_marks(
  p_fyp_record_id uuid,
  p_academic_semester_id uuid,
  p_course_code text,
  p_marks jsonb,
  p_grade text default null
)
returns public.fyp_marks_summaries
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_marks_summaries%rowtype;
  v_now timestamptz := clock_timestamp();
  v_weighted_total numeric := 0;
  v_key text;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_csp_lecturer(p_course_code) and not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can finalize marks.'
      using errcode = '42501';
  end if;

  if p_course_code not in ('CSP600', 'CSP650') then
    raise exception 'invalid-argument: Unsupported course code.'
      using errcode = '22023';
  end if;

  select coalesce(sum((v.value)::numeric), 0) into v_weighted_total
  from jsonb_each(coalesce(p_marks, '{}'::jsonb)) as v;

  insert into public.fyp_marks_summaries (
    fyp_record_id, academic_semester_id, course_code, marks, weighted_total, grade,
    is_finalized, finalized_by, finalized_at, export_payload, created_at, updated_at
  ) values (
    p_fyp_record_id, p_academic_semester_id, p_course_code, coalesce(p_marks, '{}'::jsonb),
    v_weighted_total, p_grade, true, v_uid, v_now,
    jsonb_build_object(
      'fyp_record_id', p_fyp_record_id,
      'course_code', p_course_code,
      'weighted_total', v_weighted_total,
      'grade', p_grade,
      'exported_at', v_now
    ),
    v_now, v_now
  )
  returning * into v_result;

  update public.fyp_records
  set workflow_status = case when p_course_code = 'CSP600' and workflow_status = 'formulation_completed' then 'project_registered' else workflow_status end,
      updated_at = v_now
  where id = p_fyp_record_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'course_marks_finalized', 'fyp_marks_summaries', v_result.id,
    jsonb_build_object('course_code', p_course_code, 'weighted_total', v_weighted_total),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 15. assign_examiner_to_fyp_record
-- -----------------------------------------------------------------------------
create or replace function public.assign_examiner_to_fyp_record(
  p_fyp_record_id uuid,
  p_examiner_id uuid
)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not (
    public.is_csp_lecturer((select current_course_code from public.fyp_records r where r.id = p_fyp_record_id))
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can assign examiners.'
      using errcode = '42501';
  end if;

  update public.fyp_records
  set examiner_id = p_examiner_id, updated_at = v_now
  where id = p_fyp_record_id
  returning * into v_result;

  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  insert into public.fyp_record_assignments (
    fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at, created_at, updated_at
  ) values (
    p_fyp_record_id, 'examiner', p_examiner_id, true, v_uid, v_now, v_now, v_now
  )
  on conflict (fyp_record_id, academic_role, lecturer_id)
  do update set is_active = true, updated_at = v_now;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'examiner_assigned', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('examiner_id', p_examiner_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 16. create_correction_item (F12)
-- -----------------------------------------------------------------------------
create or replace function public.create_correction_item(
  p_fyp_record_id uuid,
  p_item_code text,
  p_description text,
  p_severity text default 'minor'
)
returns public.fyp_correction_items
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_correction_items%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_severity not in ('minor', 'major') then
    raise exception 'invalid-argument: Severity must be minor or major.'
      using errcode = '22023';
  end if;

  if not (
    public.is_assigned_to_fyp_record(p_fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(p_fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(p_fyp_record_id, 'examiner')
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only assigned supervisors or examiners can create corrections.'
      using errcode = '42501';
  end if;

  insert into public.fyp_correction_items (
    fyp_record_id, item_code, description, severity, status, created_by, created_at, updated_at
  ) values (
    p_fyp_record_id, p_item_code, p_description, p_severity, 'open', v_uid, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'correction_item_created', 'fyp_correction_items', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'severity', p_severity),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 17. confirm_fyp_corrections (F12)
-- -----------------------------------------------------------------------------
create or replace function public.confirm_fyp_corrections(
  p_correction_item_id uuid,
  p_comment text default null
)
returns public.fyp_correction_confirmations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_item public.fyp_correction_items%rowtype;
  v_result public.fyp_correction_confirmations%rowtype;
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

  insert into public.fyp_correction_confirmations (
    correction_item_id, confirmed_by, confirmed_at, comment, created_at, updated_at
  ) values (
    p_correction_item_id, v_uid, v_now, p_comment, v_now, v_now
  )
  returning * into v_result;

  update public.fyp_correction_items
  set status = case when v_item.status = 'open' then 'in_progress' else v_item.status end,
      updated_at = v_now
  where id = p_correction_item_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'correction_confirmed', 'fyp_correction_confirmations', v_result.id,
    jsonb_build_object('correction_item_id', p_correction_item_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 18. prepare_expo_publication (coordinator builds public-safe payload)
-- -----------------------------------------------------------------------------
create or replace function public.prepare_expo_publication(
  p_fyp_record_id uuid,
  p_event_id uuid
)
returns public.fyp_expo_publications
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_record public.fyp_records%rowtype;
  v_event_ok boolean;
  v_student_profile public.profiles%rowtype;
  v_supervisor_name text;
  v_payload jsonb;
  v_result public.fyp_expo_publications%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.can_publish_fyp_record_to_expo(p_fyp_record_id) then
    raise exception 'permission-denied: Only the coordinator or administrator can prepare publications.'
      using errcode = '42501';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  select exists (
    select 1 from public.events where id = p_event_id and publication_status = 'published'
  ) into v_event_ok;
  if not v_event_ok then
    raise exception 'not-found: Published event not found.'
      using errcode = 'P0002';
  end if;

  select * into v_student_profile from public.profiles where id = v_record.student_id;
  select display_name into v_supervisor_name from public.profiles where id = v_record.main_supervisor_id;

  v_payload := jsonb_build_object(
    'title', coalesce(v_record.project_title, ''),
    'matric_id', v_record.matric_id,
    'programme_code', v_record.programme_code,
    'short_description', left(coalesce(v_record.project_description, ''), 500),
    'abstract', v_record.project_description,
    'category', coalesce(v_record.project_type, ''),
    'student_team', jsonb_build_array(
      jsonb_build_object(
        'name', v_student_profile.display_name,
        'matric_id', v_record.matric_id,
        'programme_code', v_record.programme_code
      )
    ),
    'supervisor_display_name', v_supervisor_name,
    'publication_status', 'draft'
  );

  insert into public.fyp_expo_publications (
    fyp_record_id, event_id, status, payload, prepared_by, prepared_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_event_id, 'ready', v_payload, v_uid, v_now, v_now, v_now
  )
  on conflict (fyp_record_id, event_id)
  do update set
    payload = excluded.payload,
    status = 'ready',
    prepared_by = v_uid,
    prepared_at = v_now,
    updated_at = v_now
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'expo_publication_prepared', 'fyp_expo_publications', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'event_id', p_event_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 19. publish_fyp_record_to_expo (transactional; writes projects + audit log)
-- -----------------------------------------------------------------------------
create or replace function public.publish_fyp_record_to_expo(
  p_publication_id uuid
)
returns public.fyp_expo_publications
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_pub public.fyp_expo_publications%rowtype;
  v_event public.events%rowtype;
  v_result public.fyp_expo_publications%rowtype;
  v_project_id uuid;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_pub from public.fyp_expo_publications where id = p_publication_id;
  if not found then
    raise exception 'not-found: Publication record not found.'
      using errcode = 'P0002';
  end if;

  if not public.can_publish_fyp_record_to_expo(v_pub.fyp_record_id) then
    raise exception 'permission-denied: Only the coordinator or administrator can publish to the expo.'
      using errcode = '42501';
  end if;

  if v_pub.status <> 'ready' then
    raise exception 'failed-precondition: Publication must be in ready state before publishing.'
      using errcode = '55000';
  end if;

  select * into v_event from public.events where id = v_pub.event_id;
  if not found then
    raise exception 'not-found: Event not found.'
      using errcode = 'P0002';
  end if;

  insert into public.projects (
    event_id,
    slug,
    title,
    matric_id,
    programme_code,
    short_description,
    abstract,
    category,
    student_team,
    supervisor_display_name,
    publication_status,
    created_at,
    updated_at
  ) values (
    v_pub.event_id,
    lower(coalesce((v_pub.payload->>'matric_id')::text, 'fyp-record-' || substr(v_pub.fyp_record_id::text, 1, 8))),
    coalesce(v_pub.payload->>'title', 'Untitled Project'),
    v_pub.payload->>'matric_id',
    v_pub.payload->>'programme_code',
    v_pub.payload->>'short_description',
    v_pub.payload->>'abstract',
    v_pub.payload->>'category',
    coalesce(v_pub.payload->'student_team', '[]'::jsonb),
    v_pub.payload->>'supervisor_display_name',
    'published',
    v_now,
    v_now
  )
  on conflict (event_id, slug)
  do update set
    title = excluded.title,
    matric_id = excluded.matric_id,
    programme_code = excluded.programme_code,
    short_description = excluded.short_description,
    abstract = excluded.abstract,
    category = excluded.category,
    student_team = excluded.student_team,
    supervisor_display_name = excluded.supervisor_display_name,
    publication_status = 'published',
    updated_at = v_now
  returning id into v_project_id;

  update public.fyp_expo_publications
  set status = 'published', published_project_id = v_project_id, published_by = v_uid,
      published_at = v_now, updated_at = v_now
  where id = p_publication_id
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'expo_publication_published', 'fyp_expo_publications', v_result.id,
    jsonb_build_object('project_id', v_project_id, 'event_id', v_pub.event_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 20. archive_fyp_record
-- -----------------------------------------------------------------------------
create or replace function public.archive_fyp_record(
  p_fyp_record_id uuid,
  p_reason text default null
)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not (public.is_admin() or public.is_fyp_coordinator()) then
    raise exception 'permission-denied: Only the coordinator or administrator can archive records.'
      using errcode = '42501';
  end if;

  update public.fyp_records
  set workflow_status = 'project_archived', updated_at = v_now
  where id = p_fyp_record_id
  returning * into v_result;

  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_record_archived', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('reason', p_reason),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 21. create_student_account_profile (provisioning)
-- -----------------------------------------------------------------------------
create or replace function public.create_student_account_profile(
  p_user_id uuid,
  p_email text,
  p_display_name text,
  p_programme_code text,
  p_matric_id text default null
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.profiles%rowtype;
  v_now timestamptz := clock_timestamp();
  v_email_norm text := lower(trim(p_email));
  v_name_norm text := upper(trim(p_display_name));
begin
  v_uid := auth.uid();
  if v_uid is null or not public.is_admin() then
    raise exception 'permission-denied: Only administrators can create student profiles.'
      using errcode = '42501';
  end if;

  insert into public.profiles (
    id, email, display_name, role, is_active, created_at, updated_at
  ) values (
    p_user_id, v_email_norm, v_name_norm, 'student', true, v_now, v_now
  )
  on conflict (id) do update set
    email = v_email_norm,
    display_name = v_name_norm,
    role = 'student',
    is_active = true,
    updated_at = v_now
  returning * into v_result;

  insert into public.profile_academic_roles (
    profile_id, role_code, programme_code, is_active, created_at, updated_at
  ) values (
    p_user_id, 'student', p_programme_code, true, v_now, v_now
  )
  on conflict (profile_id, role_code, programme_code)
  do update set is_active = true, updated_at = v_now;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, 'admin', 'student_profile_created', 'profiles', p_user_id,
    jsonb_build_object('email', v_email_norm, 'programme_code', p_programme_code, 'matric_id', p_matric_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

