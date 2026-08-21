-- ==============================================================================
-- FYP Expo Hub - FYPMS Seed Data
-- 20260817000006_fypms_seed.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Academic semesters
-- -----------------------------------------------------------------------------
insert into public.academic_semesters (code, label, status, start_date, end_date, created_at, updated_at)
values (
  '2026_1',
  'Semester March - August 2026',
  'active',
  '2026-03-01',
  '2026-08-31',
  now(),
  now()
)
on conflict (code) do update set
  status = 'active',
  updated_at = now();

-- -----------------------------------------------------------------------------
-- Academic courses
-- -----------------------------------------------------------------------------
insert into public.academic_courses (code, name, stage, credit_hours, is_active, created_at, updated_at)
values
  ('CSP600', 'Final Year Project (Formulation)', 'formulation', 1, true, now(), now()),
  ('CSP650', 'Final Year Project', 'project', 4, true, now(), now())
on conflict (code) do update set
  name = excluded.name,
  stage = excluded.stage,
  credit_hours = excluded.credit_hours,
  is_active = true,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- Default course offering for active semester (CSP600; lecturer assigned later)
-- -----------------------------------------------------------------------------
insert into public.fyp_course_offerings (
  academic_semester_id, course_code, is_active, created_at, updated_at
)
select
  s.id, 'CSP600', true, now(), now()
from public.academic_semesters s
where s.code = '2026_1'
on conflict (academic_semester_id, course_code) do update set
  is_active = true,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- Default rubric templates
-- -----------------------------------------------------------------------------
insert into public.fyp_rubric_templates (
  rubric_code, rubric_name, form_code, criteria, version, is_active, created_at, updated_at
) values
  (
    'PROPOSAL_SUPERVISOR',
    'Proposal Supervisor Assessment (F7)',
    'F7',
    '[
      {"key": "problem_definition", "label": "Problem Definition & Scope", "weight": 20, "max": 100},
      {"key": "literature_review", "label": "Literature Review", "weight": 20, "max": 100},
      {"key": "methodology", "label": "Methodology", "weight": 30, "max": 100},
      {"key": "feasibility", "label": "Feasibility & Planning", "weight": 20, "max": 100},
      {"key": "writing_quality", "label": "Report Writing Quality", "weight": 10, "max": 100}
    ]'::jsonb,
    1,
    true,
    now(),
    now()
  ),
  (
    'PROPOSAL_EXAMINER',
    'Proposal Examiner Assessment (F8)',
    'F8',
    '[
      {"key": "problem_definition", "label": "Problem Definition & Scope", "weight": 20, "max": 100},
      {"key": "literature_review", "label": "Literature Review", "weight": 20, "max": 100},
      {"key": "methodology", "label": "Methodology", "weight": 30, "max": 100},
      {"key": "presentation", "label": "Presentation & Defence", "weight": 20, "max": 100},
      {"key": "writing_quality", "label": "Report Writing Quality", "weight": 10, "max": 100}
    ]'::jsonb,
    1,
    true,
    now(),
    now()
  )
on conflict (rubric_code, version) do update set
  rubric_name = excluded.rubric_name,
  form_code = excluded.form_code,
  criteria = excluded.criteria,
  is_active = true,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- FYPMS feature-flag settings (F14-F16 gated)
-- -----------------------------------------------------------------------------
insert into public.settings (key, value, updated_at)
values (
  'fypms_features',
  '{
    "special_evaluation_enabled": false
  }'::jsonb,
  now()
)
on conflict (key) do update set
  value = excluded.value,
  updated_at = now();
