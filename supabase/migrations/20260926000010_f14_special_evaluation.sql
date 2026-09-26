-- =============================================================================
-- FYPMS: F14 special-evaluation qualification per student (textbook R8)
--
-- F14-F16 were gated by one global flag (fypms_features.special_evaluation_
-- enabled). The textbook qualifies each student separately — the CSP650
-- lecturer checks all four on F14:
--
--   1. continuous assessment: Progress (F9, 10 %) + LMC (F13, 5 %) >= 7.5 %
--   2. complete chapters 1-5 submitted (the final report)
--   3. presented at the exhibition
--   4. in the final semester with all other courses passed
--
-- Check 1 is computed from the evaluations; 2 and 3 are suggested from the
-- final report and the exhibition visits, and the lecturer confirms 2-4.
-- F15/F16 are then open for that student only:
--   * submit_fyp_form: F14 still follows the global flag (the student's
--     application); F15/F16 need the record to be qualified.
--   * submit_form_evaluation: F15/F16 need the record to be qualified.
--   * F14 is no longer rubric-scored (it has no rubric); it is decided here.
-- =============================================================================

create table if not exists public.fyp_special_evaluations (
  fyp_record_id uuid primary key references public.fyp_records(id) on delete cascade,
  progress_lmc_marks numeric(5, 2) not null default 0,
  chapters_complete boolean not null default false,
  presented_at_exhibition boolean not null default false,
  final_semester_courses_passed boolean not null default false,
  eligible boolean not null default false,
  note text,
  assessed_by uuid references public.profiles(id),
  assessed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.fyp_special_evaluations is
  'F14 special-evaluation qualification (FYP Text Book 4th ed.), one row per record; written by assess_special_evaluation only.';

alter table public.fyp_special_evaluations enable row level security;

drop policy if exists "Special evaluations read by record participants" on public.fyp_special_evaluations;
create policy "Special evaluations read by record participants"
  on public.fyp_special_evaluations for select
  to authenticated
  using (public.can_read_fyp_record(fyp_record_id));

revoke all on public.fyp_special_evaluations from anon;
revoke insert, update, delete, truncate on public.fyp_special_evaluations from authenticated;
grant select on public.fyp_special_evaluations to authenticated;

-- Whether the record has qualified for special evaluation (F15/F16).
create or replace function public.fyp_is_special_evaluation_eligible(p_fyp_record_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select eligible from public.fyp_special_evaluations where fyp_record_id = p_fyp_record_id),
    false
  );
$$;

revoke execute on function public.fyp_is_special_evaluation_eligible(uuid) from public, anon;
grant execute on function public.fyp_is_special_evaluation_eligible(uuid) to authenticated;

-- The four F14 checks for a record, as far as the system can tell, plus the
-- current assessment. CSP650 lecturer or coordinator.
create or replace function public.get_special_evaluation_checks(p_fyp_record_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_record public.fyp_records%rowtype;
  v_marks jsonb;
  v_progress numeric := 0;
  v_progress_complete boolean;
  v_final_report boolean;
  v_presented boolean;
  v_row public.fyp_special_evaluations%rowtype;
begin
  if auth.uid() is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  if not (public.is_csp_lecturer('CSP650') or public.is_fyp_coordinator()) then
    raise exception 'permission-denied: Only the CSP650 lecturer or coordinator checks F14 eligibility.'
      using errcode = '42501';
  end if;

  if v_record.current_course_code <> 'CSP650' then
    raise exception 'failed-precondition: Special evaluation is for CSP650 students.'
      using errcode = '55000';
  end if;

  v_marks := public.compute_fyp_course_marks(p_fyp_record_id);
  select coalesce(sum((c->>'contribution')::numeric), 0) into v_progress
  from jsonb_array_elements(v_marks->'components') as c
  where c->>'form_code' in ('F9', 'F13');
  v_progress_complete := not exists (
    select 1 from jsonb_array_elements(v_marks->'missing') as c
    where c->>'form_code' in ('F9', 'F13')
  );

  v_final_report := exists (
    select 1 from public.fyp_report_submissions
    where fyp_record_id = p_fyp_record_id and report_type = 'final' and status <> 'rejected'
  );

  v_presented := exists (
    select 1
    from public.fyp_expo_publications p
    join public.student_project_visits v on v.project_id = p.published_project_id
    where p.fyp_record_id = p_fyp_record_id and v.status = 'completed'
  );

  select * into v_row from public.fyp_special_evaluations where fyp_record_id = p_fyp_record_id;

  return jsonb_build_object(
    'fyp_record_id', p_fyp_record_id,
    'progress_lmc_marks', round(v_progress, 2),
    'progress_lmc_required', 7.5,
    'progress_lmc_complete', v_progress_complete,
    'final_report_submitted', v_final_report,
    'exhibition_visit_recorded', v_presented,
    'assessment', case when v_row.fyp_record_id is null then null else to_jsonb(v_row) end
  );
end;
$$;

revoke execute on function public.get_special_evaluation_checks(uuid) from public, anon;
grant execute on function public.get_special_evaluation_checks(uuid) to authenticated;

-- The CSP650 lecturer (or coordinator) records the F14 decision. The
-- Progress + LMC figure is always recomputed here, never taken from the
-- client; eligible = all four checks pass.
create or replace function public.assess_special_evaluation(
  p_fyp_record_id uuid,
  p_chapters_complete boolean,
  p_presented_at_exhibition boolean,
  p_final_semester_courses_passed boolean,
  p_note text default null
)
returns public.fyp_special_evaluations
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_checks jsonb;
  v_progress numeric;
  v_eligible boolean;
  v_result public.fyp_special_evaluations%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  -- Authorisation, record and course checks.
  v_checks := public.get_special_evaluation_checks(p_fyp_record_id);
  v_progress := (v_checks->>'progress_lmc_marks')::numeric;

  v_eligible := v_progress >= 7.5
    and coalesce(p_chapters_complete, false)
    and coalesce(p_presented_at_exhibition, false)
    and coalesce(p_final_semester_courses_passed, false);

  insert into public.fyp_special_evaluations (
    fyp_record_id, progress_lmc_marks, chapters_complete, presented_at_exhibition,
    final_semester_courses_passed, eligible, note, assessed_by, assessed_at, created_at, updated_at
  ) values (
    p_fyp_record_id, v_progress, coalesce(p_chapters_complete, false),
    coalesce(p_presented_at_exhibition, false), coalesce(p_final_semester_courses_passed, false),
    v_eligible, nullif(btrim(p_note), ''), v_uid, v_now, v_now, v_now
  )
  on conflict (fyp_record_id) do update set
    progress_lmc_marks = excluded.progress_lmc_marks,
    chapters_complete = excluded.chapters_complete,
    presented_at_exhibition = excluded.presented_at_exhibition,
    final_semester_courses_passed = excluded.final_semester_courses_passed,
    eligible = excluded.eligible,
    note = excluded.note,
    assessed_by = excluded.assessed_by,
    assessed_at = excluded.assessed_at,
    updated_at = excluded.updated_at
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'special_evaluation_assessed', 'fyp_records', p_fyp_record_id,
    jsonb_build_object(
      'progress_lmc_marks', v_progress,
      'chapters_complete', v_result.chapters_complete,
      'presented_at_exhibition', v_result.presented_at_exhibition,
      'final_semester_courses_passed', v_result.final_semester_courses_passed,
      'eligible', v_eligible
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.assess_special_evaluation(uuid, boolean, boolean, boolean, text) from public, anon;
grant execute on function public.assess_special_evaluation(uuid, boolean, boolean, boolean, text) to authenticated;

-- F14 is decided by assess_special_evaluation, not scored with a rubric.
create or replace function public.fyp_form_evaluator_roles(p_form_code text)
returns text[]
language sql
immutable
set search_path = public
as $$
  select case p_form_code
    when 'F2'  then array['lecturer']
    when 'F3'  then array['lecturer']
    when 'F4'  then array['lecturer']
    when 'F7'  then array['supervisor', 'examiner', 'lecturer']
    when 'F8'  then array['supervisor', 'examiner']
    when 'F10' then array['supervisor', 'examiner']
    when 'F11' then array['supervisor', 'examiner']
    when 'F15' then array['supervisor', 'examiner']
    when 'F16' then array['supervisor', 'examiner']
    when 'F9'  then array['lecturer', 'coordinator']
    when 'F13' then array['supervisor', 'lecturer']
    else array[]::text[]
  end;
$$;

-- submit_form_evaluation, unchanged except: F15/F16 need a qualified record.
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
  v_course text;
  v_rubric public.fyp_rubric_templates%rowtype;
  v_result public.fyp_form_evaluations%rowtype;
  v_allowed text[];
  v_role text;
  v_earned numeric := 0;
  v_possible numeric := 0;
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

  v_allowed := public.fyp_form_evaluator_roles(v_form.form_code);
  if cardinality(v_allowed) = 0 then
    raise exception 'invalid-argument: % is not scored with a rubric.', v_form.form_code
      using errcode = '22023';
  end if;

  select current_course_code into v_course from public.fyp_records where id = v_form.fyp_record_id;

  v_role := case
    when 'supervisor' = any(v_allowed) and (
      public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'supervisor')
      or public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'co_supervisor')
    ) then 'supervisor'
    when 'examiner' = any(v_allowed)
      and public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'examiner') then 'examiner'
    when 'lecturer' = any(v_allowed) and public.is_csp_lecturer(v_course) then 'lecturer'
    when 'coordinator' = any(v_allowed) and public.is_fyp_coordinator() then 'coordinator'
  end;

  if v_role is null then
    raise exception 'permission-denied: % is evaluated by the %.', v_form.form_code,
      replace(array_to_string(v_allowed, ' / '), 'lecturer', 'course lecturer')
      using errcode = '42501';
  end if;

  if v_form.form_code in ('F15', 'F16')
    and not public.fyp_is_special_evaluation_eligible(v_form.fyp_record_id) then
    raise exception 'failed-precondition: This student has not qualified for special evaluation (F14).'
      using errcode = '55000';
  end if;

  select * into v_rubric
  from public.fyp_rubric_templates
  where form_code = v_form.form_code and is_active = true
  order by version desc
  limit 1;

  if found then
    for v_criterion in select * from jsonb_array_elements(v_rubric.criteria)
    loop
      -- Supervisor-only criteria (F8/F11/F16 progress evaluation) are not
      -- part of any other evaluator's score.
      if coalesce((v_criterion->>'supervisor_only')::boolean, false) and v_role <> 'supervisor' then
        continue;
      end if;
      v_key := v_criterion->>'key';
      v_weight := coalesce((v_criterion->>'weight')::numeric, 0);
      v_max := coalesce((v_criterion->>'max')::numeric, 10);
      v_score := coalesce((p_criteria_scores->>v_key)::numeric, 0);
      if v_score < 0 or v_score > v_max then
        raise exception 'invalid-argument: Score for % must be between 0 and %.', v_key, v_max
          using errcode = '22023';
      end if;
      v_earned := v_earned + v_score * v_weight;
      v_possible := v_possible + v_max * v_weight;
    end loop;
    if v_possible > 0 then
      v_weighted_total := 100 * v_earned / v_possible;
    end if;
  end if;

  insert into public.fyp_form_evaluations (
    form_submission_id, rubric_template_id, evaluator_id, evaluator_role, scores,
    weighted_total, comments, status, evaluated_at, created_at, updated_at
  ) values (
    p_form_submission_id,
    v_rubric.id,
    v_uid, v_role, coalesce(p_criteria_scores, '{}'::jsonb),
    round(v_weighted_total, 2), p_comments, 'submitted', v_now, v_now, v_now
  )
  on conflict (form_submission_id, evaluator_id)
  do update set
    rubric_template_id = excluded.rubric_template_id,
    evaluator_role = excluded.evaluator_role,
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
      'form_code', v_form.form_code,
      'evaluator_role', v_role,
      'decision', p_decision,
      'rubric_code', v_rubric.rubric_code,
      'weighted_total', round(v_weighted_total, 2)
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.submit_form_evaluation(uuid, jsonb, text, text) from public, anon;
grant execute on function public.submit_form_evaluation(uuid, jsonb, text, text) to authenticated;

-- submit_fyp_form: F14 (the application) follows the global flag; F15/F16
-- follow the record's F14 qualification.
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
  v_special_eval_enabled boolean;
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

  if p_form_code = 'F14' then
    select coalesce((s.value ->> 'special_evaluation_enabled')::boolean, false)
      into v_special_eval_enabled
      from public.settings s
      where s.key = 'fypms_features';
    if not coalesce(v_special_eval_enabled, false) then
      raise exception 'permission-denied: Special evaluation applications (F14) are not open.'
        using errcode = '42501';
    end if;
  end if;

  if p_form_code in ('F15', 'F16') and not public.fyp_is_special_evaluation_eligible(p_fyp_record_id) then
    raise exception 'failed-precondition: You have not qualified for special evaluation (F14).'
      using errcode = '55000';
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

revoke execute on function public.submit_fyp_form(uuid, text, jsonb, text, numeric) from public, anon;
grant execute on function public.submit_fyp_form(uuid, text, jsonb, text, numeric) to authenticated;
