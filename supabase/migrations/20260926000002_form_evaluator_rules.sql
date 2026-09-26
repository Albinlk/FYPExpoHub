-- =============================================================================
-- FYPMS: who evaluates which form (FSKM FYP Text Book, 4th ed., Table 2.1/2.2)
--
-- submit_form_evaluation let any assigned supervisor, co-supervisor or
-- examiner score any form, and never the course (CSP) lecturer or the
-- coordinator. The textbook names the evaluators per form:
--
--   F2, F3, F4, F14      course lecturer
--   F7                   course lecturer, supervisor, examiner
--   F8, F10, F11,
--   F15, F16             supervisor, examiner
--   F9                   course lecturer, or the FYP coordinator
--   F13                  course lecturer, supervisor
--   F1, F5, F6a, F6b,    not rubric-scored (acceptance, logbook, report
--   F12                  submission and correction confirmation have their
--                        own flows)
--
-- The evaluator's role is resolved from the caller and stored on the
-- evaluation, so the marks computation can apply that role's grade share
-- (fyp_rubric_templates.evaluator_shares). When a caller holds several roles
-- on the record, the first allowed one in this order wins:
-- supervisor (incl. co-supervisor), examiner, lecturer, coordinator.
-- =============================================================================

alter table public.fyp_form_evaluations
  add column if not exists evaluator_role text
    check (evaluator_role in ('lecturer', 'supervisor', 'examiner', 'coordinator'));

comment on column public.fyp_form_evaluations.evaluator_role is
  'Role the evaluator scored this form in (textbook evaluator for the form code).';

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
    when 'F14' then array['lecturer']
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

revoke execute on function public.fyp_form_evaluator_roles(text) from public, anon;
grant execute on function public.fyp_form_evaluator_roles(text) to authenticated;

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
