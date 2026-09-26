-- =============================================================================
-- FYPMS rubrics from the FSKM FYP Text Book
-- ("Essentials of Computing Sciences: Project Administration", 4th ed., 2022)
--
-- The v1 seed (20260817000006) had F7 as a report rubric and F8 with a
-- "Presentation & Defence" criterion, both on a 0-100 scale; no other form
-- had a rubric, so their evaluations scored 0. This migration:
--   1. adds fyp_rubric_templates.evaluator_shares — each evaluator's share of
--      the course grade for that form (read by the marks computation);
--   2. retires the v1 rubrics (kept for history; evaluations reference them);
--   3. seeds the textbook rubrics: every criterion is scored 0-10 with the
--      book's weight, and Marks = Weight x Score;
--   4. makes submit_form_evaluation store the form's percentage
--      (100 * sum(W*S) / sum(W*10)), leave supervisor-only criteria out of
--      an examiner's score, and reject scores outside 0..max.
--
-- evaluator_shares shape:
--   {"lecturer": 10, "supervisor": 10, "examiner": 5}         -- whole form
--   {"CLO1": {"supervisor": 25, "examiner": 20},
--    "CLO4": {"supervisor": 5,  "examiner": 5}}               -- per CLO group
--   {}                                                        -- not stated in the book (F2-F4)
-- =============================================================================

alter table public.fyp_rubric_templates
  add column if not exists evaluator_shares jsonb not null default '{}'::jsonb;

comment on column public.fyp_rubric_templates.evaluator_shares is
  'Percent of the course grade each evaluator''s score on this form contributes (textbook mark allocation). Keys: lecturer / supervisor / examiner, optionally nested per criterion "clo" group.';

-- 2. Retire the v1 rubrics.
update public.fyp_rubric_templates
set is_active = false, updated_at = now()
where rubric_code in ('PROPOSAL_SUPERVISOR', 'PROPOSAL_EXAMINER');

-- 3. Textbook rubrics.
insert into public.fyp_rubric_templates (
  rubric_code, rubric_name, form_code, criteria, evaluator_shares, version, is_active, created_at, updated_at
) values
  (
    'F2_PROJECT_MOTIVATION', 'F2 - Project Motivation Evaluation', 'F2',
    '[
      {"key": "problem_identification", "label": "Problem identification", "weight": 3, "max": 10},
      {"key": "evidences", "label": "Evidences", "weight": 5, "max": 10},
      {"key": "solutions", "label": "Solutions", "weight": 2, "max": 10}
    ]'::jsonb,
    '{}'::jsonb, 1, true, now(), now()
  ),
  (
    'F3_LITERATURE_REVIEW', 'F3 - Literature Review Evaluation', 'F3',
    '[
      {"key": "relevance_context", "label": "Relevance and context", "weight": 2, "max": 10},
      {"key": "knowledge_of_field", "label": "Knowledge of the field/sources", "weight": 4, "max": 10},
      {"key": "writing", "label": "Writing", "weight": 4, "max": 10}
    ]'::jsonb,
    '{}'::jsonb, 1, true, now(), now()
  ),
  (
    'F4_METHODOLOGY', 'F4 - Methodology Evaluation', 'F4',
    '[
      {"key": "methodology_design", "label": "Design of the methodology", "weight": 3, "max": 10},
      {"key": "description", "label": "Description", "weight": 3, "max": 10},
      {"key": "model_technique_method", "label": "Model/Technique/Method", "weight": 4, "max": 10}
    ]'::jsonb,
    '{}'::jsonb, 1, true, now(), now()
  ),
  (
    'F7_FORMULATION_PRESENTATION', 'F7 - Project Formulation Presentation', 'F7',
    '[
      {"key": "depth_of_knowledge", "label": "Depth of knowledge", "weight": 3, "max": 10},
      {"key": "overall_organization", "label": "Overall organization of the presentation", "weight": 2, "max": 10},
      {"key": "presentation_materials", "label": "Quality of presentation materials", "weight": 2, "max": 10},
      {"key": "delivery_skills", "label": "Delivery skills", "weight": 3, "max": 10}
    ]'::jsonb,
    '{"lecturer": 10, "supervisor": 10, "examiner": 5}'::jsonb, 1, true, now(), now()
  ),
  (
    'F8_FORMULATION_REPORT', 'F8 - Project Formulation Report Evaluation', 'F8',
    '[
      {"key": "background_problem", "label": "Project background and problem", "weight": 3, "max": 10},
      {"key": "objectives", "label": "Objectives", "weight": 2, "max": 10},
      {"key": "significance", "label": "Significance of the study", "weight": 1, "max": 10},
      {"key": "literature_review", "label": "Literature review", "weight": 5, "max": 10},
      {"key": "methodology", "label": "Project methodology", "weight": 6, "max": 10},
      {"key": "report_presentation", "label": "Presentation of the report", "weight": 3, "max": 10},
      {"key": "progress_evaluation", "label": "Progress evaluation (supervisor only)", "weight": 2, "max": 10, "supervisor_only": true}
    ]'::jsonb,
    '{"supervisor": 30, "examiner": 15}'::jsonb, 1, true, now(), now()
  ),
  (
    'F9_PROGRESS_PRESENTATION', 'F9 - Progress Project Presentation', 'F9',
    '[
      {"key": "depth_of_knowledge", "label": "Depth of knowledge", "weight": 3, "max": 10},
      {"key": "overall_organization", "label": "Overall organization of the presentation", "weight": 1, "max": 10},
      {"key": "progress", "label": "Progress (against Gantt chart / milestones)", "weight": 4, "max": 10},
      {"key": "delivery_skills", "label": "Delivery skills", "weight": 2, "max": 10}
    ]'::jsonb,
    '{"lecturer": 10}'::jsonb, 1, true, now(), now()
  ),
  (
    'F10_FINAL_PRESENTATION', 'F10 - Final Project Presentation', 'F10',
    '[
      {"key": "depth_of_knowledge", "label": "Depth of knowledge", "weight": 3, "max": 10},
      {"key": "overall_organization", "label": "Overall organization of the presentation", "weight": 1, "max": 10},
      {"key": "poster_organization", "label": "Poster organization", "weight": 1, "max": 10},
      {"key": "complexity", "label": "Research/project complexity", "weight": 2, "max": 10},
      {"key": "completeness", "label": "Research/project completeness", "weight": 2, "max": 10},
      {"key": "delivery_skills", "label": "Delivery skills", "weight": 1, "max": 10}
    ]'::jsonb,
    '{"supervisor": 15, "examiner": 15}'::jsonb, 1, true, now(), now()
  ),
  (
    'F11_PROJECT_REPORT', 'F11 - Project Report Evaluation', 'F11',
    '[
      {"key": "abstract", "label": "Abstract", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "introduction", "label": "Introduction", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "literature_review", "label": "Literature review", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "methodology", "label": "Methodology", "weight": 2, "max": 10, "clo": "CLO1"},
      {"key": "conclusion", "label": "Conclusion and recommendations", "weight": 2, "max": 10, "clo": "CLO1"},
      {"key": "report_presentation", "label": "Report presentation", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "references", "label": "References and citations", "weight": 2, "max": 10, "clo": "CLO1"},
      {"key": "progress_evaluation", "label": "Progress evaluation (supervisor only)", "weight": 1, "max": 10, "clo": "CLO1", "supervisor_only": true},
      {"key": "development", "label": "Development", "weight": 5, "max": 10, "clo": "CLO4"},
      {"key": "findings_discussion", "label": "Findings / discussion", "weight": 5, "max": 10, "clo": "CLO4"}
    ]'::jsonb,
    '{"CLO1": {"supervisor": 25, "examiner": 20}, "CLO4": {"supervisor": 5, "examiner": 5}}'::jsonb, 1, true, now(), now()
  ),
  (
    'F13_LEAN_CANVAS', 'F13 - Lean Canvas Model Evaluation', 'F13',
    '[
      {"key": "problem", "label": "Problem", "weight": 2, "max": 10},
      {"key": "solution", "label": "Solution", "weight": 1, "max": 10},
      {"key": "key_metrics", "label": "Key metrics", "weight": 1, "max": 10},
      {"key": "unique_value_proposition", "label": "Unique value proposition", "weight": 1, "max": 10},
      {"key": "unfair_advantage", "label": "Unfair advantage", "weight": 1, "max": 10},
      {"key": "channels", "label": "Channels", "weight": 1, "max": 10},
      {"key": "customer_segments", "label": "Customer segments", "weight": 1, "max": 10},
      {"key": "cost_structure", "label": "Cost structure", "weight": 1, "max": 10},
      {"key": "revenue_streams", "label": "Revenue streams", "weight": 1, "max": 10}
    ]'::jsonb,
    '{"lecturer": 5}'::jsonb, 1, true, now(), now()
  ),
  (
    'F15_SPECIAL_PRESENTATION', 'F15 - Special Evaluation Presentation', 'F15',
    '[
      {"key": "depth_of_knowledge", "label": "Depth of knowledge", "weight": 3, "max": 10},
      {"key": "overall_organization", "label": "Overall organization of the presentation", "weight": 1, "max": 10},
      {"key": "poster_organization", "label": "Poster organization", "weight": 1, "max": 10},
      {"key": "complexity", "label": "Research/project complexity", "weight": 2, "max": 10},
      {"key": "completeness", "label": "Research/project completeness", "weight": 2, "max": 10},
      {"key": "delivery_skills", "label": "Delivery skills", "weight": 1, "max": 10}
    ]'::jsonb,
    '{"supervisor": 15, "examiner": 15}'::jsonb, 1, true, now(), now()
  ),
  (
    'F16_SPECIAL_REPORT', 'F16 - Special Evaluation Report Evaluation', 'F16',
    '[
      {"key": "abstract", "label": "Abstract", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "introduction", "label": "Introduction", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "literature_review", "label": "Literature review", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "methodology", "label": "Methodology", "weight": 2, "max": 10, "clo": "CLO1"},
      {"key": "conclusion", "label": "Conclusion and recommendations", "weight": 2, "max": 10, "clo": "CLO1"},
      {"key": "report_presentation", "label": "Report presentation", "weight": 1, "max": 10, "clo": "CLO1"},
      {"key": "references", "label": "References and citations", "weight": 2, "max": 10, "clo": "CLO1"},
      {"key": "progress_evaluation", "label": "Progress evaluation (supervisor only)", "weight": 1, "max": 10, "clo": "CLO1", "supervisor_only": true},
      {"key": "development", "label": "Development", "weight": 5, "max": 10, "clo": "CLO4"},
      {"key": "findings_discussion", "label": "Findings / discussion", "weight": 5, "max": 10, "clo": "CLO4"}
    ]'::jsonb,
    '{"CLO1": {"supervisor": 25, "examiner": 20}, "CLO4": {"supervisor": 5, "examiner": 5}}'::jsonb, 1, true, now(), now()
  )
on conflict (rubric_code, version) do update set
  rubric_name = excluded.rubric_name,
  form_code = excluded.form_code,
  criteria = excluded.criteria,
  evaluator_shares = excluded.evaluator_shares,
  is_active = true,
  updated_at = now();

-- 4. Score an evaluation as a percentage of the form's maximum.
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
  v_is_supervisor boolean;
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

  v_is_supervisor :=
    public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_form.fyp_record_id, 'co_supervisor');

  if not (
    v_is_supervisor
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
      -- Supervisor-only criteria (e.g. F8/F11 progress evaluation) are not
      -- part of an examiner's score.
      if coalesce((v_criterion->>'supervisor_only')::boolean, false) and not v_is_supervisor then
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
    form_submission_id, rubric_template_id, evaluator_id, scores, weighted_total,
    comments, status, evaluated_at, created_at, updated_at
  ) values (
    p_form_submission_id,
    v_rubric.id,
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
