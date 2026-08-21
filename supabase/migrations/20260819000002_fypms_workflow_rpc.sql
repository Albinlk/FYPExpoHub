-- ==============================================================================
-- FYP Expo Hub - FYPMS Workflow RPCs
-- 20260819000002_fypms_workflow_rpc.sql
-- ==============================================================================
-- Implements the 10 protected (SECURITY DEFINER) workflow RPCs used by the
-- supervisor / examiner / csp / coordinator pages. Each function validates
-- auth.uid(), enforces a role gate, writes an fyp_audit_logs entry, and only
-- mutates through audited paths.
--
--  1. decide_supervision_request      (replaced signature; gate: supervisor/co-supervisor + coordinator)
--  2. validate_progress_log           (replaces buggy review_progress_log)
--  3. assign_examiner                 (replaces assign_examiner_to_fyp_record)
--  4. submit_form_evaluation          (replaced signature; computes weighted_total from rubric)
--  5. create_correction_item          (replaced signature; auto item_code, links form submission)
--  6. confirm_correction              (replaces confirm_fyp_corrections staff flow)
--  7. finalize_marks                  (replaces finalize_course_marks)
--  8. schedule_presentation_slot      (replaced signature; adds start_at/end_at)
--  9. prepare_expo_publication        (replaced signature; whitelists public-safe payload keys)
-- 10. publish_fyp_record_to_expo      (unchanged - already matches spec)
--
-- Also adds:
--  - fyp_correction_items.form_submission_id column + index
--  - RLS policy so assigned supervisors can decide supervision requests
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 0. Drop old-signature / renamed functions so no ambiguous overloads remain.
--    (confirm_fyp_corrections is KEPT for the student self-service slice.)
-- -----------------------------------------------------------------------------
drop function if exists public.decide_supervision_request(uuid, text, uuid, text);
drop function if exists public.submit_form_evaluation(uuid, jsonb, text);
drop function if exists public.create_correction_item(uuid, text, text, text);
drop function if exists public.schedule_presentation_slot(uuid, uuid, integer, text);
drop function if exists public.prepare_expo_publication(uuid, uuid);
drop function if exists public.assign_examiner_to_fyp_record(uuid, uuid);
drop function if exists public.finalize_course_marks(uuid, uuid, text, jsonb, text);
drop function if exists public.review_progress_log(uuid, text, text);

-- -----------------------------------------------------------------------------
-- 0b. fyp_correction_items.form_submission_id
-- -----------------------------------------------------------------------------
alter table public.fyp_correction_items
  add column if not exists form_submission_id uuid
  references public.fyp_form_submissions(id) on delete set null;

create index if not exists idx_fyp_corrections_submission
  on public.fyp_correction_items(form_submission_id);

-- -----------------------------------------------------------------------------
-- 1. decide_supervision_request(request_id, decision, decision_reason)
--    Gate: assigned main/co-supervisor OR coordinator OR admin.
--    On approval the supervisor is resolved as: the decider when the decider is
--    themselves an assigned supervisor, otherwise the request's
--    preferred_supervisor_id (error when none was chosen).
-- -----------------------------------------------------------------------------
create or replace function public.decide_supervision_request(
  p_request_id uuid,
  p_decision text,
  p_decision_reason text default null
)
returns public.fyp_supervision_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_request public.fyp_supervision_requests%rowtype;
  v_record public.fyp_records%rowtype;
  v_result public.fyp_supervision_requests%rowtype;
  v_supervisor_id uuid;
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

  if not (
    public.is_assigned_to_fyp_record(v_record.id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_record.id, 'co_supervisor')
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the assigned supervisor or coordinator can decide supervision requests.'
      using errcode = '42501';
  end if;

  if v_request.status <> 'pending' then
    raise exception 'failed-precondition: Request has already been decided.'
      using errcode = '55000';
  end if;

  update public.fyp_supervision_requests
  set status = p_decision,
      decided_by = v_uid,
      decided_at = v_now,
      decision_reason = p_decision_reason,
      updated_at = v_now
  where id = p_request_id
  returning * into v_result;

  if p_decision = 'approved' then
    if public.is_assigned_to_fyp_record(v_record.id, 'supervisor')
       or public.is_assigned_to_fyp_record(v_record.id, 'co_supervisor') then
      v_supervisor_id := v_uid;
    else
      v_supervisor_id := v_request.preferred_supervisor_id;
    end if;

    if v_supervisor_id is null then
      raise exception 'invalid-argument: No supervisor selected for this request.'
        using errcode = '22023';
    end if;

    update public.fyp_records
    set main_supervisor_id = v_supervisor_id,
        workflow_status = 'supervision_approved',
        updated_at = v_now
    where id = v_request.fyp_record_id;

    insert into public.fyp_record_assignments (
      fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at,
      created_at, updated_at
    ) values (
      v_request.fyp_record_id, 'supervisor', v_supervisor_id, true, v_uid, v_now, v_now, v_now
    )
    on conflict (fyp_record_id, academic_role, lecturer_id)
    do update set is_active = true, updated_at = v_now;
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'supervision_request_' || p_decision, 'fyp_supervision_requests', v_result.id,
    jsonb_build_object('fyp_record_id', v_request.fyp_record_id, 'supervisor_id', v_supervisor_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 2. validate_progress_log(log_id, status, validation_comment)
--    Gate: assigned main supervisor OR co-supervisor OR coordinator (RLS parity).
--    Only 'submitted' logs can be validated.
-- -----------------------------------------------------------------------------
create or replace function public.validate_progress_log(
  p_progress_log_id uuid,
  p_status text,
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

  if p_status not in ('validated', 'rejected') then
    raise exception 'invalid-argument: Status must be validated or rejected.'
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

  if v_log.status <> 'submitted' then
    raise exception 'failed-precondition: Only submitted progress logs can be validated.'
      using errcode = '55000';
  end if;

  update public.fyp_progress_logs
  set status = p_status,
      validated_by = v_uid,
      validated_at = v_now,
      validation_comment = p_validation_comment,
      updated_at = v_now
  where id = p_progress_log_id
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'progress_log_' || p_status, 'fyp_progress_logs', p_progress_log_id,
    jsonb_build_object('fyp_record_id', v_log.fyp_record_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 2b. review_progress_log is kept as a thin wrapper for backward compatibility.
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
begin
  return public.validate_progress_log(p_progress_log_id, p_decision, p_validation_comment);
end;
$$;

-- -----------------------------------------------------------------------------
-- 3. assign_examiner(fyp_record_id, examiner_id)
--    Gate: CSP lecturer for the record's course OR coordinator OR admin.
--    (Coordinator retained so the coordinator assignments page keeps working.)
-- -----------------------------------------------------------------------------
create or replace function public.assign_examiner(
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
    public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = p_fyp_record_id)
    )
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
-- 4. submit_form_evaluation(form_submission_id, criteria_scores, comments, decision)
--    Gate: assigned supervisor / co-supervisor / examiner.
--    weighted_total is derived from the active rubric template for the
--    submission's form_code: sum(score/max * weight).
--    Upserts on (form_submission_id, evaluator_id) and updates the submission
--    status per decision (approved | rejected | resubmission_required).
-- -----------------------------------------------------------------------------
create or replace function public.submit_form_evaluation(
  p_form_submission_id uuid,
  p_criteria_scores jsonb,
  p_comments text default null,
  p_decision text default 'approved'
)
returns public.fyp_form_evaluations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_form public.fyp_form_submissions%rowtype;
  v_rubric public.fyp_rubric_templates%rowtype;
  v_result public.fyp_form_evaluations%rowtype;
  v_weighted_total numeric := 0;
  v_criterion jsonb;
  v_key text;
  v_weight numeric;
  v_max numeric;
  v_score numeric;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_decision not in ('approved', 'rejected', 'resubmission_required') then
    raise exception 'invalid-argument: Decision must be approved, rejected, or resubmission_required.'
      using errcode = '22023';
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
  ) then
    raise exception 'permission-denied: Only assigned supervisors or examiners can evaluate forms.'
      using errcode = '42501';
  end if;

  select * into v_rubric
  from public.fyp_rubric_templates
  where form_code = v_form.form_code and is_active = true
  order by version desc
  limit 1;

  if found then
    for v_criterion in select * from jsonb_array_elements(v_rubric.criteria)
    loop
      v_key := v_criterion->>'key';
      v_weight := coalesce((v_criterion->>'weight')::numeric, 0);
      v_max := coalesce((v_criterion->>'max')::numeric, 100);
      v_score := coalesce((p_criteria_scores->>v_key)::numeric, 0);
      v_weighted_total := v_weighted_total
        + least(v_score, v_max) * v_weight / nullif(v_max, 0);
    end loop;
  end if;

  insert into public.fyp_form_evaluations (
    form_submission_id, rubric_template_id, evaluator_id, scores, weighted_total,
    comments, status, evaluated_at, created_at, updated_at
  ) values (
    p_form_submission_id,
    case when v_rubric.id is null then null else v_rubric.id end,
    v_uid, coalesce(p_criteria_scores, '{}'::jsonb), round(v_weighted_total, 2),
    p_comments, 'submitted', v_now, v_now, v_now
  )
  on conflict (form_submission_id, evaluator_id)
  do update set
    rubric_template_id = excluded.rubric_template_id,
    scores = excluded.scores,
    weighted_total = excluded.weighted_total,
    comments = coalesce(excluded.comments, fyp_form_evaluations.comments),
    status = 'submitted',
    evaluated_at = v_now,
    updated_at = v_now
  returning * into v_result;

  update public.fyp_form_submissions
  set status = p_decision, updated_at = v_now
  where id = p_form_submission_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'form_evaluated', 'fyp_form_evaluations', v_result.id,
    jsonb_build_object(
      'form_submission_id', p_form_submission_id,
      'decision', p_decision,
      'weighted_total', v_weighted_total
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 5. create_correction_item(fyp_record_id, form_submission_id, correction_text, severity)
--    Gate: assigned supervisor / co-supervisor / examiner.
--    item_code is auto-generated; description is the correction text.
-- -----------------------------------------------------------------------------
create or replace function public.create_correction_item(
  p_fyp_record_id uuid,
  p_form_submission_id uuid,
  p_correction_text text,
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
  ) then
    raise exception 'permission-denied: Only assigned supervisors or examiners can create corrections.'
      using errcode = '42501';
  end if;

  if p_form_submission_id is not null and not exists (
    select 1 from public.fyp_form_submissions
    where id = p_form_submission_id and fyp_record_id = p_fyp_record_id
  ) then
    raise exception 'invalid-argument: Form submission does not belong to this record.'
      using errcode = '22023';
  end if;

  insert into public.fyp_correction_items (
    fyp_record_id, item_code, description, severity, status, form_submission_id,
    created_by, created_at, updated_at
  ) values (
    p_fyp_record_id,
    'CORR-' || substr(gen_random_uuid()::text, 1, 8),
    p_correction_text,
    p_severity,
    'open',
    p_form_submission_id,
    v_uid, v_now, v_now
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
-- 6. confirm_correction(correction_item_id, confirmation_status, notes)
--    Gate: assigned supervisor / co-supervisor / examiner.
--    Writes an fyp_correction_confirmations row and advances the item status.
-- -----------------------------------------------------------------------------
create or replace function public.confirm_correction(
  p_correction_item_id uuid,
  p_confirmation_status text,
  p_notes text default null
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

  if p_confirmation_status not in ('confirmed', 'closed') then
    raise exception 'invalid-argument: Confirmation status must be confirmed or closed.'
      using errcode = '22023';
  end if;

  select * into v_item from public.fyp_correction_items where id = p_correction_item_id;
  if not found then
    raise exception 'not-found: Correction item not found.'
      using errcode = 'P0002';
  end if;

  if not (
    public.is_assigned_to_fyp_record(v_item.fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_item.fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(v_item.fyp_record_id, 'examiner')
  ) then
    raise exception 'permission-denied: Only assigned supervisors or examiners can confirm corrections.'
      using errcode = '42501';
  end if;

  insert into public.fyp_correction_confirmations (
    correction_item_id, confirmed_by, confirmed_at, comment, created_at, updated_at
  ) values (
    p_correction_item_id, v_uid, v_now, p_notes, v_now, v_now
  )
  returning * into v_result;

  update public.fyp_correction_items
  set status = p_confirmation_status, updated_at = v_now
  where id = p_correction_item_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'correction_' || p_confirmation_status, 'fyp_correction_confirmations', v_result.id,
    jsonb_build_object('correction_item_id', p_correction_item_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 7. finalize_marks(fyp_record_id, course_code, component_breakdown)
--    Gate: CSP lecturer for the course OR admin.
--    Derives the academic semester from the record, sums numeric breakdown
--    values into weighted_total, and locks the summary once finalized.
-- -----------------------------------------------------------------------------
create or replace function public.finalize_marks(
  p_fyp_record_id uuid,
  p_course_code text,
  p_component_breakdown jsonb
)
returns public.fyp_marks_summaries
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_record public.fyp_records%rowtype;
  v_result public.fyp_marks_summaries%rowtype;
  v_weighted_total numeric := 0;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_csp_lecturer(p_course_code) then
    raise exception 'permission-denied: Only the CSP lecturer can finalize marks.'
      using errcode = '42501';
  end if;

  if p_course_code not in ('CSP600', 'CSP650') then
    raise exception 'invalid-argument: Unsupported course code.'
      using errcode = '22023';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  select coalesce(sum((v.value)::numeric), 0) into v_weighted_total
  from jsonb_each(coalesce(p_component_breakdown, '{}'::jsonb)) as v;

  if exists (
    select 1 from public.fyp_marks_summaries
    where fyp_record_id = p_fyp_record_id
      and academic_semester_id = v_record.academic_semester_id
      and course_code = p_course_code
      and is_finalized = true
  ) then
    raise exception 'failed-precondition: Marks are already finalized for this course.'
      using errcode = '55000';
  end if;

  insert into public.fyp_marks_summaries (
    fyp_record_id, academic_semester_id, course_code, marks, weighted_total, grade,
    is_finalized, finalized_by, finalized_at, export_payload, created_at, updated_at
  ) values (
    p_fyp_record_id, v_record.academic_semester_id, p_course_code,
    coalesce(p_component_breakdown, '{}'::jsonb),
    v_weighted_total, null, true, v_uid, v_now,
    jsonb_build_object(
      'fyp_record_id', p_fyp_record_id,
      'course_code', p_course_code,
      'weighted_total', v_weighted_total,
      'exported_at', v_now
    ),
    v_now, v_now
  )
  on conflict (fyp_record_id, academic_semester_id, course_code)
  do update set
    marks = excluded.marks,
    weighted_total = excluded.weighted_total,
    grade = excluded.grade,
    is_finalized = true,
    finalized_by = v_uid,
    finalized_at = v_now,
    export_payload = excluded.export_payload,
    updated_at = v_now
  returning * into v_result;

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
-- 8. schedule_presentation_slot(session_id, fyp_record_id, slot_number,
--                               start_at, end_at, room)
--    Gate: CSP lecturer of the session's offering OR coordinator OR admin.
--    start_at/end_at are NOT NULL on the table, so the previous function that
--    omitted them was broken; they are now part of the signature.
-- -----------------------------------------------------------------------------
create or replace function public.schedule_presentation_slot(
  p_session_id uuid,
  p_fyp_record_id uuid,
  p_slot_number integer,
  p_start_at timestamptz,
  p_end_at timestamptz,
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

  if p_slot_number is null or p_slot_number <= 0 then
    raise exception 'invalid-argument: A positive slot number is required.'
      using errcode = '22023';
  end if;

  if p_start_at is null or p_end_at is null or p_end_at <= p_start_at then
    raise exception 'invalid-argument: A valid start/end window is required.'
      using errcode = '22023';
  end if;

  select * into v_session from public.fyp_presentation_sessions where id = p_session_id;
  if not found then
    raise exception 'not-found: Presentation session not found.'
      using errcode = 'P0002';
  end if;

  if not (
    public.is_csp_lecturer(
      (select course_code from public.fyp_course_offerings o where o.id = v_session.offering_id)
    )
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can schedule slots.'
      using errcode = '42501';
  end if;

  insert into public.fyp_presentation_slots (
    session_id, fyp_record_id, slot_number, start_at, end_at, room, created_at, updated_at
  ) values (
    p_session_id, p_fyp_record_id, p_slot_number, p_start_at, p_end_at, p_room, v_now, v_now
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
-- 9. prepare_expo_publication(fyp_record_id, event_id, payload)
--    Gate: coordinator / admin.
--    When a payload is supplied only the public-safe whitelist keys are kept;
--    private FYP fields are always stripped.
-- -----------------------------------------------------------------------------
create or replace function public.prepare_expo_publication(
  p_fyp_record_id uuid,
  p_event_id uuid,
  p_payload jsonb default null
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
  v_safe jsonb;
  v_result public.fyp_expo_publications%rowtype;
  v_now timestamptz := clock_timestamp();
  v_public_keys constant text[] := array[
    'title', 'matric_id', 'programme_code', 'short_description', 'abstract',
    'category', 'student_team', 'supervisor_display_name', 'publication_status',
    'demo_url', 'video_url', 'repository_url', 'cover_image_url', 'booth_number'
  ];
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

  if p_payload is not null then
    select coalesce(jsonb_object_agg(k, v), '{}'::jsonb) into v_safe
    from jsonb_each(p_payload)
    where k = any (v_public_keys);
    v_payload := v_payload || v_safe;
  end if;

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
-- 10. publish_fyp_record_to_expo is unchanged (already matches the spec).
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- RLS: assigned supervisors may also decide supervision requests
-- -----------------------------------------------------------------------------
drop policy if exists "Requests decided by assigned supervisor"
  on public.fyp_supervision_requests;

create policy "Requests decided by assigned supervisor"
  on public.fyp_supervision_requests for update
  using (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
  )
  with check (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
  );