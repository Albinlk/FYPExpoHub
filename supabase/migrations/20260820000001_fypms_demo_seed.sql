-- ==============================================================================
-- FYP Expo Hub - FYPMS Demo/QA Seed  (DEVELOPMENT / DEMO ONLY - do NOT deploy)
-- 20260820000001_fypms_demo_seed.sql
-- ==============================================================================
-- Creates three linked FYP records that exercise the full academic workflow,
-- using the fixed-UUID test accounts provisioned by `fypms_workflow_seed`.
--
--   Record A  student1  CSP600  pending F1 request; F2/F3/F4 drafts (early stage)
--   Record B  student2  CSP600  supervisor approved, F5 logs validated,
--                               proposal report, examiner assigned, F7/F8 pending
--   Record C  student3  CSP650  F13 Lean Canvas, proposal+final reports,
--                               deliverables, correction items + confirmations,
--                               presentation session/slot, marks-ready summary,
--                               Expo publication DRAFT (ready to be prepared+published)
--
-- Idempotent: every insert uses a fixed UUID and ON CONFLICT DO NOTHING. Safe to
-- re-run against a staged/dev database. Never run this migration in production.
--
-- Reference rows resolved at runtime (no hardcoded ids for existing data):
--   event      fskm-fyp-2026 (must be published)
--   semester   2026_1 (active)
--   CSP600 offering (existing, linked to csp600 lecturer)
--   CSP650 offering (created here - required so CSP650 sessions/slots resolve)
-- ==============================================================================

do $$
declare
  -- accounts (from 20260819000001_fypms_workflow_seed)
  v_admin       uuid := '10000000-0000-0000-0000-000000000001';
  v_csp600      uuid := '10000000-0000-0000-0000-000000000002';
  v_csp650      uuid := '10000000-0000-0000-0000-000000000003';
  v_coordinator uuid := '10000000-0000-0000-0000-000000000004';
  v_sup1        uuid := '10000000-0000-0000-0000-000000000005';
  v_sup2        uuid := '10000000-0000-0000-0000-000000000006';
  v_examiner    uuid := '10000000-0000-0000-0000-000000000007';
  v_stu1        uuid := '10000000-0000-0000-0000-000000000008';
  v_stu2        uuid := '10000000-0000-0000-0000-000000000009';
  v_stu3        uuid := '10000000-0000-0000-0000-00000000000a';

  -- fixed seed ids
  v_rec_a  uuid := '20000000-0000-0000-0000-000000000001';
  v_rec_b  uuid := '20000000-0000-0000-0000-000000000002';
  v_rec_c  uuid := '20000000-0000-0000-0000-000000000003';
  v_offering_csp650 uuid := '20000000-0000-0000-0000-000000000004';
  v_session_csp600  uuid := '20000000-0000-0000-0000-00000000000b';
  v_session_csp650  uuid := '20000000-0000-0000-0000-00000000000c';

  v_date  date := date_trunc('month', clock_timestamp())::date;
  v_now   timestamptz := clock_timestamp();

  v_event_id uuid;
  v_sem_id   uuid;
  v_offering_csp600 uuid;
begin
  -- ---------------------------------------------------------------------------
  -- Resolve reference rows
  -- ---------------------------------------------------------------------------
  select id into v_event_id from public.events
    where slug = 'fskm-fyp-2026' and publication_status = 'published'
    order by created_at limit 1;
  if v_event_id is null then
    raise exception 'demo-seed: published event fskm-fyp-2026 not found';
  end if;

  select id into v_sem_id from public.academic_semesters
    where code = '2026_1' and status = 'active'
    order by created_at limit 1;
  if v_sem_id is null then
    raise exception 'demo-seed: active semester 2026_1 not found';
  end if;

  select id into v_offering_csp600 from public.fyp_course_offerings
    where academic_semester_id = v_sem_id and course_code = 'CSP600'
    order by created_at limit 1;

  -- CSP650 offering (created once; demo data only)
  insert into public.fyp_course_offerings (
    id, academic_semester_id, course_code, lecturer_id, is_active, created_at, updated_at
  ) values (
    v_offering_csp650, v_sem_id, 'CSP650', v_csp650, true, v_now, v_now
  )
  on conflict (academic_semester_id, course_code) do nothing;

  -- ---------------------------------------------------------------------------
  -- Records
  -- ---------------------------------------------------------------------------
  insert into public.fyp_records (
    id, academic_semester_id, student_id, current_course_code, programme_code,
    matric_id, project_title, project_description, project_type,
    external_industry_partner, main_supervisor_id, co_supervisor_id, examiner_id,
    workflow_status, created_at, updated_at
  ) values
    (v_rec_a, v_sem_id, v_stu1, 'CSP600', 'CS266', 'DP071266',
     'AI-Assisted Rehabilitation Monitoring', 'A CSP600 formulation-stage project exploring computer-vision rehabilitation tracking.',
     'Mobile Application', null, null, null, null,
     'supervision_requested', v_now, v_now),
    (v_rec_b, v_sem_id, v_stu2, 'CSP600', 'CS266', 'DP071267',
     'Campus Safety Incident Predictor', 'A CSP600 project that predicts campus safety incidents from IoT sensor streams.',
     'Web Application', 'JKSN Safety Sdn Bhd', v_sup1, null, v_examiner,
     'proposal_under_review', v_now, v_now),
    (v_rec_c, v_sem_id, v_stu3, 'CSP650', 'CS266', 'DP071268',
     'Smart Classroom Energy Optimiser', 'A CSP650 project that optimises classroom HVAC and lighting energy consumption.',
     'IoT System', 'GreenCampus Solutions', v_sup2, null, v_examiner,
     'project_pending_presentation', v_now, v_now)
  on conflict (academic_semester_id, student_id, current_course_code)
  do update set
    project_title = excluded.project_title,
    project_description = excluded.project_description,
    project_type = excluded.project_type,
    main_supervisor_id = coalesce(fyp_records.main_supervisor_id, excluded.main_supervisor_id),
    co_supervisor_id = coalesce(fyp_records.co_supervisor_id, excluded.co_supervisor_id),
    examiner_id = coalesce(fyp_records.examiner_id, excluded.examiner_id),
    updated_at = v_now;

  -- ---------------------------------------------------------------------------
  -- Assignments (Record B: supervisor + examiner; Record C: supervisor + examiner)
  -- ---------------------------------------------------------------------------
  insert into public.fyp_record_assignments (
    fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at, created_at, updated_at
  ) values
    (v_rec_b, 'supervisor', v_sup1, true, v_coordinator, v_now, v_now, v_now),
    (v_rec_b, 'examiner',   v_examiner, true, v_csp600, v_now, v_now, v_now),
    (v_rec_c, 'supervisor', v_sup2, true, v_coordinator, v_now, v_now, v_now),
    (v_rec_c, 'examiner',   v_examiner, true, v_csp650, v_now, v_now, v_now)
  on conflict (fyp_record_id, academic_role, lecturer_id)
  do update set is_active = true, updated_at = v_now;

  -- ---------------------------------------------------------------------------
  -- Record A - F1 supervision request (PENDING) + draft F2/F3/F4
  -- ---------------------------------------------------------------------------
  insert into public.fyp_supervision_requests (
    id, fyp_record_id, preferred_supervisor_id, rationale, status,
    created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-000000000011', v_rec_a, v_sup1,
    'I would prefer to be supervised by Supervisor 1 based on their IoT research.',
    'pending', v_now, v_now
  )
  on conflict (id) do nothing;

  insert into public.fyp_form_submissions (
    id, fyp_record_id, form_code, form_version, payload, status, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-000000000021', v_rec_a, 'F2', 1,
     '{"project_scope":"AI-Assisted Rehabilitation Monitoring"}'::jsonb, 'draft', v_now, v_now),
    ('20000000-0000-0000-0000-000000000022', v_rec_a, 'F3', 1,
     '{"literature_summary":"to be completed"}'::jsonb, 'draft', v_now, v_now),
    ('20000000-0000-0000-0000-000000000023', v_rec_a, 'F4', 1,
     '{"ethics_checklist":"not started"}'::jsonb, 'draft', v_now, v_now)
  on conflict (id) do nothing;

  -- ---------------------------------------------------------------------------
  -- Record B - approved F1, validated F5 logs, proposal report, F7/F8 pending
  -- ---------------------------------------------------------------------------
  insert into public.fyp_supervision_requests (
    id, fyp_record_id, preferred_supervisor_id, rationale, status,
    decided_by, decided_at, decision_reason, created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-000000000012', v_rec_b, v_sup1,
    'Supervisor 1 approved during intake.', 'approved',
    v_sup1, v_now - interval '30 days', 'Assigned supervised student.', v_now, v_now
  )
  on conflict (id) do nothing;

  insert into public.fyp_progress_logs (
    id, fyp_record_id, week_number, progress_date, summary, challenges, next_plan,
    status, submitted_by, submitted_at, validated_by, validated_at, validation_comment,
    created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-000000000031', v_rec_b, 1, v_date - 42,
     'Completed literature survey on campus IoT sensing.',
     'Limited open datasets for campus safety.', 'Draft methodology section.',
     'validated', v_stu2, v_now - interval '42 days', v_sup1, v_now - interval '41 days',
     'Good progress. Expand the literature review depth.', v_now, v_now),
    ('20000000-0000-0000-0000-000000000032', v_rec_b, 2, v_date - 35,
     'Designed the incident-prediction pipeline.',
     'Sensor calibration differences across buildings.', 'Prototype the ingestion layer.',
     'validated', v_stu2, v_now - interval '35 days', v_sup1, v_now - interval '34 days',
     'Approved. Keep the calibration notes.', v_now, v_now),
    ('20000000-0000-0000-0000-000000000033', v_rec_b, 3, v_date - 28,
     'Proposal draft assembled and submitted for supervisor review.',
     'Awaiting rubric feedback on F7.', 'Respond to F7 feedback.',
     'validated', v_stu2, v_now - interval '28 days', v_sup1, v_now - interval '27 days',
     'Proposal draft accepted.', v_now, v_now)
  on conflict (id) do nothing;

  insert into public.fyp_report_submissions (
    id, fyp_record_id, report_type, version, file_url, similarity_index, status,
    submitted_by, submitted_at, created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-000000000041', v_rec_b, 'proposal', 1,
    'https://demo.fypms.test/f6a-proposal-recB-v1.pdf', 18.5, 'under_review',
    v_stu2, v_now - interval '21 days', v_now, v_now
  )
  on conflict (id) do nothing;

  insert into public.fyp_form_submissions (
    id, fyp_record_id, form_code, form_version, payload, status,
    submitted_by, submitted_at, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-000000000051', v_rec_b, 'F7', 1,
     '{"problem_definition":"Campus safety incident prediction","literature_review":"completed"}'::jsonb,
     'under_review', v_stu2, v_now - interval '21 days', v_now, v_now),
    ('20000000-0000-0000-0000-000000000052', v_rec_b, 'F8', 1,
     '{"presentation":"scheduled","methodology":"pipeline design described"}'::jsonb,
     'under_review', v_stu2, v_now - interval '20 days', v_now, v_now)
  on conflict (id) do nothing;

  insert into public.fyp_milestones (
    id, fyp_record_id, milestone_code, milestone_title, description, target_date,
    status, completed_at, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-000000000061', v_rec_b, 'M1', 'Literature Review',
     'Complete the literature survey.', v_date - 40, 'completed', v_now - interval '40 days', v_now, v_now),
    ('20000000-0000-0000-0000-000000000062', v_rec_b, 'M2', 'Proposal Submission',
     'Submit the proposal draft (F6a).', v_date - 21, 'completed', v_now - interval '21 days', v_now, v_now)
  on conflict (id) do nothing;

  -- ---------------------------------------------------------------------------
  -- Record C - CSP650 deep state
  -- ---------------------------------------------------------------------------
  insert into public.fyp_lean_canvases (
    id, fyp_record_id, canvas_version, blocks, is_latest, created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-000000000070', v_rec_c, 1,
    '{"problem":"High classroom energy waste","solution":"Adaptive HVAC/lighting controls","customerSegments":"Facility managers","keyMetrics":"Energy use kWh/m2","uniqueValueProposition":"Cut energy cost 30%"}'::jsonb,
    true, v_now, v_now
  )
  on conflict (id) do nothing;

  insert into public.fyp_report_submissions (
    id, fyp_record_id, report_type, version, file_url, similarity_index, status,
    submitted_by, submitted_at, reviewed_by, reviewed_at, review_comment, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-000000000081', v_rec_c, 'proposal', 1,
     'https://demo.fypms.test/f6a-proposal-recC-v1.pdf', 12.0, 'approved',
     v_stu3, v_now - interval '80 days', v_sup2, v_now - interval '75 days',
     'Proposal approved.', v_now, v_now),
    ('20000000-0000-0000-0000-000000000082', v_rec_c, 'final', 1,
     'https://demo.fypms.test/f6b-final-recC-v1.pdf', 9.5, 'submitted',
     v_stu3, v_now - interval '6 days', null, null, null, v_now, v_now)
  on conflict (id) do nothing;

  insert into public.fyp_form_submissions (
    id, fyp_record_id, form_code, form_version, payload, status,
    submitted_by, submitted_at, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-0000000000c1', v_rec_c, 'F7', 1,
     '{"problem_definition":"Energy optimisation","literature_review":"completed"}'::jsonb,
     'approved', v_stu3, v_now - interval '75 days', v_now, v_now),
    ('20000000-0000-0000-0000-0000000000c2', v_rec_c, 'F8', 1,
     '{"presentation":"completed","methodology":"simulation validated"}'::jsonb,
     'approved', v_stu3, v_now - interval '70 days', v_now, v_now)
  on conflict (id) do nothing;

  insert into public.fyp_form_evaluations (
    id, form_submission_id, rubric_template_id, evaluator_id, scores, weighted_total,
    comments, status, evaluated_at, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-0000000000d1',
     '20000000-0000-0000-0000-0000000000c1',
     (select id from public.fyp_rubric_templates
       where form_code = 'F7' and is_active = true order by version desc limit 1),
     v_sup2,
     '{"problem_definition":85,"literature_review":80,"methodology":82,"feasibility":88,"writing_quality":90}'::jsonb,
     84.00, 'Strong proposal.', 'submitted', v_now - interval '75 days', v_now, v_now),
    ('20000000-0000-0000-0000-0000000000d2',
     '20000000-0000-0000-0000-0000000000c2',
     (select id from public.fyp_rubric_templates
       where form_code = 'F8' and is_active = true order by version desc limit 1),
     v_examiner,
     '{"problem_definition":84,"literature_review":82,"methodology":86,"presentation":90,"writing_quality":88}'::jsonb,
     86.00, 'Well prepared defence.', 'submitted', v_now - interval '70 days', v_now, v_now)
  on conflict (id) do nothing;

  insert into public.fyp_deliverables (
    id, fyp_record_id, deliverable_type, title, description, file_url, version,
    is_required, submitted_by, submitted_at, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-000000000091', v_rec_c, 'demo', 'Interactive Demo',
     'Deployed live demo of the energy optimiser.', 'https://demo.fypms.test/demo-recC',
     1, true, v_stu3, v_now - interval '9 days', v_now, v_now),
    ('20000000-0000-0000-0000-000000000092', v_rec_c, 'poster', 'Expo Poster',
     'Poster for the exhibition booth.', 'https://demo.fypms.test/poster-recC.pdf',
     1, true, v_stu3, v_now - interval '5 days', v_now, v_now),
    ('20000000-0000-0000-0000-000000000093', v_rec_c, 'video', 'Demo Video',
     'Two-minute walkthrough video.', 'https://demo.fypms.test/video-recC.mp4',
     1, false, v_stu3, v_now - interval '3 days', v_now, v_now)
  on conflict (id) do nothing;

  insert into public.fyp_correction_items (
    id, fyp_record_id, item_code, description, severity, status, form_submission_id,
    created_by, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-0000000000a1', v_rec_c, 'CORR-DEMO-0001',
     'Add a system architecture diagram to Section 4.', 'minor', 'open',
     '20000000-0000-0000-0000-0000000000c2', v_examiner, v_now - interval '10 days', v_now),
    ('20000000-0000-0000-0000-0000000000a2', v_rec_c, 'CORR-DEMO-0002',
     'Clarify the energy model validation dataset.', 'major', 'in_progress',
     '20000000-0000-0000-0000-0000000000c2', v_examiner, v_now - interval '8 days', v_now)
  on conflict (id) do nothing;

  insert into public.fyp_correction_confirmations (
    id, correction_item_id, confirmed_by, confirmed_at, comment, created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-0000000000b1', '20000000-0000-0000-0000-0000000000a2',
    v_stu3, v_now - interval '2 days', 'Evidence added to Section 4 draft.', v_now, v_now
  )
  on conflict (id) do nothing;

  insert into public.fyp_milestones (
    id, fyp_record_id, milestone_code, milestone_title, description, target_date,
    status, completed_at, created_at, updated_at
  ) values
    ('20000000-0000-0000-0000-000000000063', v_rec_c, 'M1', 'Proposal Approved',
     'Proposal F6a approved.', v_date - 75, 'completed', v_now - interval '75 days', v_now, v_now),
    ('20000000-0000-0000-0000-000000000064', v_rec_c, 'M2', 'Final Report Submitted',
     'F6b final report submitted.', v_date - 6, 'completed', v_now - interval '6 days', v_now, v_now),
    ('20000000-0000-0000-0000-000000000065', v_rec_c, 'M3', 'Expo Presentation',
     'Viva / Expo defence.', v_date + 14, 'in_progress', null, v_now, v_now)
  on conflict (id) do nothing;

  -- Sessions + slot (representative presentation records)
  insert into public.fyp_presentation_sessions (
    id, offering_id, session_code, session_title, event_date, start_at, end_at,
    venue, session_type, created_at, updated_at
  ) values
    (v_session_csp600, v_offering_csp600, 'DEF-CSP600-S1', 'CSP600 Defence Round 1',
     v_date + 14, v_now + interval '14 days', v_now + interval '15 days',
     'DK1', 'defence', v_now, v_now),
    (v_session_csp650, v_offering_csp650, 'DEF-CSP650-S1', 'CSP650 Defence Round 1',
     v_date + 21, v_now + interval '21 days', v_now + interval '22 days',
     'DK2', 'defence', v_now, v_now)
  on conflict (id) do nothing;

  insert into public.fyp_presentation_slots (
    id, session_id, fyp_record_id, slot_number, start_at, end_at, room,
    created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-0000000000f1', v_session_csp650, v_rec_c, 1,
    v_now + interval '21 days', v_now + interval '21 days' + interval '30 minutes',
    'DK2-A', v_now, v_now
  )
  on conflict (id) do nothing;

  -- Marks summary: marks-ready, NOT yet finalized (CSP650 lecturer finalizes in QA)
  insert into public.fyp_marks_summaries (
    id, fyp_record_id, academic_semester_id, course_code, marks, weighted_total,
    grade, is_finalized, finalized_by, finalized_at, export_payload, created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-000000000101', v_rec_c, v_sem_id, 'CSP650',
    '{"proposal":30,"progress_logs":20,"final_report":30,"presentation_viva":20}'::jsonb,
    0.00, null, false, null, null, null, v_now, v_now
  )
  on conflict (id) do nothing;

  -- Expo publication DRAFT with an Expo-safe public payload (prepared but not published)
  insert into public.fyp_expo_publications (
    id, fyp_record_id, event_id, status, payload, prepared_by, prepared_at,
    created_at, updated_at
  ) values (
    '20000000-0000-0000-0000-000000000111', v_rec_c, v_event_id, 'draft',
    jsonb_build_object(
      'title', 'Smart Classroom Energy Optimiser',
      'matric_id', 'DP071268',
      'programme_code', 'CS266',
      'short_description', left('A CSP650 project that optimises classroom HVAC and lighting energy consumption.', 500),
      'abstract', 'A CSP650 project that optimises classroom HVAC and lighting energy consumption.',
      'category', 'IoT System',
      'student_team', jsonb_build_array(jsonb_build_object(
        'name', 'STUDENT 3', 'matric_id', 'DP071268', 'programme_code', 'CS266')),
      'supervisor_display_name', 'SUPERVISOR 2',
      'publication_status', 'draft'
    ),
    v_coordinator, v_now - interval '1 day', v_now, v_now
  )
  on conflict (id) do nothing;
end;
$$;