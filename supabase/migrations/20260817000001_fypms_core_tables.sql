-- ==============================================================================
-- FYP Expo Hub - FYPMS Core Tables Migration
-- 20260817000001_fypms_core_tables.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Shared updated_at trigger (new pattern mandated by FYPMS spec)
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at := clock_timestamp();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Extend legacy profiles.role additively to allow students
-- (admin / lecturer values and all existing behaviour unchanged)
-- -----------------------------------------------------------------------------
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles
  add constraint profiles_role_check check (role in ('admin', 'lecturer', 'student'));

-- -----------------------------------------------------------------------------
-- Extend audit_logs.actor_role additively for FYPMS actor roles
-- -----------------------------------------------------------------------------
alter table public.audit_logs drop constraint if exists audit_logs_actor_role_check;
alter table public.audit_logs
  add constraint audit_logs_actor_role_check check (actor_role in (
    'admin', 'lecturer', 'system', 'student', 'supervisor', 'co_supervisor',
    'examiner', 'csp600_lecturer', 'csp650_lecturer', 'fyp_coordinator'
  ));

-- -----------------------------------------------------------------------------
-- 1. profile_academic_roles
-- -----------------------------------------------------------------------------
create table if not exists public.profile_academic_roles (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role_code text not null check (role_code in (
    'student',
    'supervisor',
    'co_supervisor',
    'examiner',
    'csp600_lecturer',
    'csp650_lecturer',
    'fyp_coordinator'
  )),
  programme_code text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (profile_id, role_code, programme_code)
);

-- -----------------------------------------------------------------------------
-- 2. academic_semesters
-- -----------------------------------------------------------------------------
create table if not exists public.academic_semesters (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  label text not null,
  status text not null default 'planned' check (status in ('planned', 'active', 'completed', 'archived')),
  start_date date not null,
  end_date date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_academic_semesters_time_order check (end_date >= start_date)
);

-- -----------------------------------------------------------------------------
-- 3. academic_courses
-- -----------------------------------------------------------------------------
create table if not exists public.academic_courses (
  code text primary key,
  name text not null,
  stage text not null check (stage in ('formulation', 'project')),
  credit_hours integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 4. fyp_course_offerings
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_course_offerings (
  id uuid primary key default gen_random_uuid(),
  academic_semester_id uuid not null references public.academic_semesters(id) on delete cascade,
  course_code text not null references public.academic_courses(code),
  lecturer_id uuid references public.profiles(id) on delete set null,
  is_active boolean not null default true,
  max_students integer check (max_students is null or max_students > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (academic_semester_id, course_code)
);

-- -----------------------------------------------------------------------------
-- 5. fyp_records (canonical private FYP record; projects stays the public catalogue)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_records (
  id uuid primary key default gen_random_uuid(),
  academic_semester_id uuid not null references public.academic_semesters(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  current_course_code text not null references public.academic_courses(code),
  programme_code text not null,
  matric_id text,
  project_title text,
  project_description text,
  project_type text,
  external_industry_partner text,
  main_supervisor_id uuid references public.profiles(id) on delete set null,
  co_supervisor_id uuid references public.profiles(id) on delete set null,
  examiner_id uuid references public.profiles(id) on delete set null,
  previous_record_id uuid references public.fyp_records(id) on delete set null,
  workflow_status text not null default 'awaiting_supervisor_assignment' check (workflow_status in (
    'awaiting_supervisor_assignment',
    'supervision_requested',
    'supervision_approved',
    'formulation_in_progress',
    'proposal_submitted',
    'proposal_under_review',
    'proposal_revision_required',
    'proposal_approved',
    'formulation_completed',
    'project_registered',
    'project_ongoing',
    'final_report_submitted',
    'final_report_under_review',
    'final_report_approved',
    'project_completed',
    'project_archived',
    'project_pending_presentation'
  )),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (academic_semester_id, student_id, current_course_code)
);

-- -----------------------------------------------------------------------------
-- 6. fyp_record_assignments
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_record_assignments (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  academic_role text not null check (academic_role in ('supervisor', 'co_supervisor', 'examiner')),
  lecturer_id uuid not null references public.profiles(id) on delete cascade,
  is_active boolean not null default true,
  assigned_by uuid references public.profiles(id),
  assigned_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, academic_role, lecturer_id)
);

-- -----------------------------------------------------------------------------
-- 7. fyp_milestones
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_milestones (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  milestone_code text not null,
  milestone_title text not null,
  description text,
  target_date date,
  status text not null default 'pending' check (status in ('pending', 'in_progress', 'completed', 'overdue')),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, milestone_code)
);

-- -----------------------------------------------------------------------------
-- 8. fyp_milestone_extensions
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_milestone_extensions (
  id uuid primary key default gen_random_uuid(),
  milestone_id uuid not null references public.fyp_milestones(id) on delete cascade,
  requested_by uuid not null references public.profiles(id),
  reason text not null,
  requested_due_date date not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  decided_by uuid references public.profiles(id),
  decided_at timestamptz,
  decision_comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 9. fyp_supervision_requests (F1)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_supervision_requests (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  preferred_supervisor_id uuid references public.profiles(id) on delete set null,
  rationale text,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'withdrawn')),
  decided_by uuid references public.profiles(id),
  decided_at timestamptz,
  decision_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 10. fyp_progress_logs (F5)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_progress_logs (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  week_number integer not null check (week_number > 0),
  progress_date date not null,
  summary text not null,
  challenges text,
  next_plan text,
  status text not null default 'draft' check (status in ('draft', 'submitted', 'validated', 'rejected')),
  submitted_by uuid references public.profiles(id),
  submitted_at timestamptz,
  validated_by uuid references public.profiles(id),
  validated_at timestamptz,
  validation_comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, week_number)
);

-- -----------------------------------------------------------------------------
-- 11. fyp_form_submissions (F1 - F16)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_form_submissions (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  form_code text not null check (form_code in (
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6a', 'F6b', 'F7', 'F8',
    'F9', 'F10', 'F11', 'F12', 'F13', 'F14', 'F15', 'F16'
  )),
  form_version integer not null default 1,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'draft' check (status in ('draft', 'submitted', 'under_review', 'approved', 'rejected', 'resubmission_required')),
  submitted_by uuid references public.profiles(id),
  submitted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, form_code, form_version)
);

-- -----------------------------------------------------------------------------
-- 12. fyp_rubric_templates
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_rubric_templates (
  id uuid primary key default gen_random_uuid(),
  rubric_code text not null,
  rubric_name text not null,
  form_code text not null check (form_code in (
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6a', 'F6b', 'F7', 'F8',
    'F9', 'F10', 'F11', 'F12', 'F13', 'F14', 'F15', 'F16'
  )),
  criteria jsonb not null default '[]'::jsonb,
  version integer not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (rubric_code, version)
);

-- -----------------------------------------------------------------------------
-- 13. fyp_form_evaluations
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_form_evaluations (
  id uuid primary key default gen_random_uuid(),
  form_submission_id uuid not null references public.fyp_form_submissions(id) on delete cascade,
  rubric_template_id uuid references public.fyp_rubric_templates(id) on delete set null,
  evaluator_id uuid not null references public.profiles(id),
  scores jsonb not null default '{}'::jsonb,
  weighted_total numeric(5, 2) not null default 0,
  comments text,
  status text not null default 'draft' check (status in ('draft', 'submitted')),
  evaluated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (form_submission_id, evaluator_id)
);

-- -----------------------------------------------------------------------------
-- 14. fyp_report_submissions (F6a proposal / F6b final)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_report_submissions (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  report_type text not null check (report_type in ('proposal', 'final')),
  version integer not null default 1,
  file_url text not null,
  similarity_index numeric(5, 2),
  status text not null default 'submitted' check (status in ('submitted', 'under_review', 'approved', 'rejected')),
  submitted_by uuid references public.profiles(id),
  submitted_at timestamptz not null default now(),
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  review_comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, report_type, version)
);

-- -----------------------------------------------------------------------------
-- 15. fyp_deliverables
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_deliverables (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  deliverable_type text not null,
  title text not null,
  description text,
  file_url text,
  version integer not null default 1,
  is_required boolean not null default false,
  submitted_by uuid references public.profiles(id),
  submitted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 16. fyp_lean_canvases (F13)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_lean_canvases (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  canvas_version integer not null default 1,
  blocks jsonb not null default '{}'::jsonb,
  is_latest boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, canvas_version)
);

-- -----------------------------------------------------------------------------
-- 17. fyp_correction_items (F12)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_correction_items (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  item_code text not null,
  description text not null,
  severity text not null check (severity in ('minor', 'major')),
  status text not null default 'open' check (status in ('open', 'in_progress', 'evidence_submitted', 'confirmed', 'closed')),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 18. fyp_correction_confirmations (F12)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_correction_confirmations (
  id uuid primary key default gen_random_uuid(),
  correction_item_id uuid not null references public.fyp_correction_items(id) on delete cascade,
  confirmed_by uuid not null references public.profiles(id),
  confirmed_at timestamptz not null default now(),
  comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 19. fyp_presentation_sessions
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_presentation_sessions (
  id uuid primary key default gen_random_uuid(),
  offering_id uuid not null references public.fyp_course_offerings(id) on delete cascade,
  session_code text not null,
  session_title text not null,
  event_date date not null,
  start_at timestamptz not null,
  end_at timestamptz not null,
  venue text,
  session_type text not null default 'defence' check (session_type in ('defence', 'expo')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (offering_id, session_code),
  constraint chk_fyp_sessions_time_order check (end_at > start_at)
);

-- -----------------------------------------------------------------------------
-- 20. fyp_presentation_slots
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_presentation_slots (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.fyp_presentation_sessions(id) on delete cascade,
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  slot_number integer not null check (slot_number > 0),
  start_at timestamptz not null,
  end_at timestamptz not null,
  room text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (session_id, fyp_record_id),
  constraint chk_fyp_slots_time_order check (end_at > start_at)
);

-- -----------------------------------------------------------------------------
-- 21. fyp_marks_summaries
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_marks_summaries (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  academic_semester_id uuid not null references public.academic_semesters(id) on delete cascade,
  course_code text not null references public.academic_courses(code),
  marks jsonb not null default '{}'::jsonb,
  weighted_total numeric(5, 2) not null default 0,
  grade text,
  is_finalized boolean not null default false,
  finalized_by uuid references public.profiles(id),
  finalized_at timestamptz,
  export_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, academic_semester_id, course_code)
);

-- -----------------------------------------------------------------------------
-- 22. fyp_expo_publications (publication bridge to public.projects)
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_expo_publications (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  event_id uuid not null references public.events(id) on delete cascade,
  status text not null default 'draft' check (status in ('draft', 'ready', 'published', 'failed')),
  payload jsonb not null default '{}'::jsonb,
  published_project_id uuid references public.projects(id) on delete set null,
  prepared_by uuid references public.profiles(id),
  prepared_at timestamptz,
  published_by uuid references public.profiles(id),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fyp_record_id, event_id)
);

-- -----------------------------------------------------------------------------
-- 23. fyp_audit_logs
-- -----------------------------------------------------------------------------
create table if not exists public.fyp_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_uid uuid references public.profiles(id),
  actor_role text,
  action text not null,
  target_type text not null,
  target_id uuid,
  metadata_safe jsonb not null default '{}'::jsonb,
  source text not null default 'database_rpc',
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Indices for Query Performance & Low-Bandwidth Lookups
-- -----------------------------------------------------------------------------
create index if not exists idx_fyp_academic_roles_profile on public.profile_academic_roles(profile_id, is_active);
create index if not exists idx_fyp_offering_semester on public.fyp_course_offerings(academic_semester_id, course_code);
create index if not exists idx_fyp_records_student on public.fyp_records(student_id, academic_semester_id);
create index if not exists idx_fyp_records_supervisor on public.fyp_records(main_supervisor_id, workflow_status);
create index if not exists idx_fyp_records_examiner on public.fyp_records(examiner_id, workflow_status);
create index if not exists idx_fyp_records_status on public.fyp_records(workflow_status, academic_semester_id);
create index if not exists idx_fyp_assignments_record on public.fyp_record_assignments(fyp_record_id, academic_role, is_active);
create index if not exists idx_fyp_assignments_lecturer on public.fyp_record_assignments(lecturer_id, is_active);
create index if not exists idx_fyp_milestones_record on public.fyp_milestones(fyp_record_id, status, target_date);
create index if not exists idx_fyp_progress_record on public.fyp_progress_logs(fyp_record_id, week_number desc);
create index if not exists idx_fyp_forms_record on public.fyp_form_submissions(fyp_record_id, form_code, status);
create index if not exists idx_fyp_evaluations_submission on public.fyp_form_evaluations(form_submission_id, evaluator_id);
create index if not exists idx_fyp_corrections_record on public.fyp_correction_items(fyp_record_id, status);
create index if not exists idx_fyp_marks_record on public.fyp_marks_summaries(fyp_record_id, is_finalized);
create index if not exists idx_fyp_publications_status on public.fyp_expo_publications(event_id, status);
create index if not exists idx_fyp_audit_target on public.fyp_audit_logs(target_type, target_id, created_at desc);

-- -----------------------------------------------------------------------------
-- updated_at triggers on all new tables
-- -----------------------------------------------------------------------------
create trigger trg_profile_academic_roles_updated_at
  before update on public.profile_academic_roles
  for each row execute function public.set_updated_at();
create trigger trg_academic_semesters_updated_at
  before update on public.academic_semesters
  for each row execute function public.set_updated_at();
create trigger trg_academic_courses_updated_at
  before update on public.academic_courses
  for each row execute function public.set_updated_at();
create trigger trg_fyp_course_offerings_updated_at
  before update on public.fyp_course_offerings
  for each row execute function public.set_updated_at();
create trigger trg_fyp_records_updated_at
  before update on public.fyp_records
  for each row execute function public.set_updated_at();
create trigger trg_fyp_record_assignments_updated_at
  before update on public.fyp_record_assignments
  for each row execute function public.set_updated_at();
create trigger trg_fyp_milestones_updated_at
  before update on public.fyp_milestones
  for each row execute function public.set_updated_at();
create trigger trg_fyp_milestone_extensions_updated_at
  before update on public.fyp_milestone_extensions
  for each row execute function public.set_updated_at();
create trigger trg_fyp_supervision_requests_updated_at
  before update on public.fyp_supervision_requests
  for each row execute function public.set_updated_at();
create trigger trg_fyp_progress_logs_updated_at
  before update on public.fyp_progress_logs
  for each row execute function public.set_updated_at();
create trigger trg_fyp_form_submissions_updated_at
  before update on public.fyp_form_submissions
  for each row execute function public.set_updated_at();
create trigger trg_fyp_form_evaluations_updated_at
  before update on public.fyp_form_evaluations
  for each row execute function public.set_updated_at();
create trigger trg_fyp_rubric_templates_updated_at
  before update on public.fyp_rubric_templates
  for each row execute function public.set_updated_at();
create trigger trg_fyp_report_submissions_updated_at
  before update on public.fyp_report_submissions
  for each row execute function public.set_updated_at();
create trigger trg_fyp_deliverables_updated_at
  before update on public.fyp_deliverables
  for each row execute function public.set_updated_at();
create trigger trg_fyp_lean_canvases_updated_at
  before update on public.fyp_lean_canvases
  for each row execute function public.set_updated_at();
create trigger trg_fyp_correction_items_updated_at
  before update on public.fyp_correction_items
  for each row execute function public.set_updated_at();
create trigger trg_fyp_correction_confirmations_updated_at
  before update on public.fyp_correction_confirmations
  for each row execute function public.set_updated_at();
create trigger trg_fyp_presentation_sessions_updated_at
  before update on public.fyp_presentation_sessions
  for each row execute function public.set_updated_at();
create trigger trg_fyp_presentation_slots_updated_at
  before update on public.fyp_presentation_slots
  for each row execute function public.set_updated_at();
create trigger trg_fyp_marks_summaries_updated_at
  before update on public.fyp_marks_summaries
  for each row execute function public.set_updated_at();
create trigger trg_fyp_expo_publications_updated_at
  before update on public.fyp_expo_publications
  for each row execute function public.set_updated_at();