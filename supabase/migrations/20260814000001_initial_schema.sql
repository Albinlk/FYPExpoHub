-- ==============================================================================
-- FYP Expo Hub - Supabase PostgreSQL Schema Migration
-- 20260814000001_initial_schema.sql
-- ==============================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. profiles
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  display_name text not null,
  role text not null check (role in ('admin', 'lecturer')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 2. events
-- -----------------------------------------------------------------------------
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  session_label text,
  start_at timestamptz not null,
  end_at timestamptz not null,
  daily_hours text,
  venue text,
  location_details text,
  map_url text,
  description text,
  objectives jsonb not null default '[]'::jsonb,
  status text not null default 'active' check (status in ('draft', 'upcoming', 'active', 'completed', 'archived')),
  publication_status text not null default 'published' check (publication_status in ('draft', 'published', 'archived')),
  hero_image_url text,
  poster_url text,
  public_contact_email text,
  faq_items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid references public.profiles(id),
  constraint chk_events_time_order check (end_at > start_at)
);

-- -----------------------------------------------------------------------------
-- 3. projects
-- -----------------------------------------------------------------------------
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  slug text not null,
  title text not null,
  matric_id text, -- Approved public exhibition information
  team_display_name text,
  programme_code text,
  programme_name text,
  short_description text,
  abstract text,
  category text,
  tech_tags jsonb not null default '[]'::jsonb,
  student_team jsonb not null default '[]'::jsonb,
  supervisor_display_name text,
  examiner_display_name text,
  booth_id uuid,
  booth_number text,
  booth_zone text,
  presentation_day text,
  demo_url text,
  video_url text,
  repository_url text,
  cover_image_url text,
  featured boolean not null default false,
  industry_candidate boolean not null default false,
  publication_status text not null default 'published' check (publication_status in ('draft', 'published', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, slug)
);

-- -----------------------------------------------------------------------------
-- 4. booths
-- -----------------------------------------------------------------------------
create table if not exists public.booths (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  booth_number text not null,
  zone text,
  venue text,
  location_note text,
  floor_plan_url text,
  linked_project_id uuid references public.projects(id) on delete set null,
  presentation_day text,
  status text not null default 'active' check (status in ('active', 'vacant', 'inactive')),
  publication_status text not null default 'published' check (publication_status in ('draft', 'published', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, booth_number)
);

-- Add foreign key constraint for projects.booth_id -> booths.id if required
alter table public.projects
  add constraint fk_projects_booth
  foreign key (booth_id) references public.booths(id) on delete set null;

-- -----------------------------------------------------------------------------
-- 5. schedule_items
-- -----------------------------------------------------------------------------
create table if not exists public.schedule_items (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  day_label text,
  event_date date not null,
  start_at timestamptz not null,
  end_at timestamptz not null,
  title text not null,
  description text,
  venue text,
  audience text,
  access_type text not null default 'public' check (access_type in ('public', 'internal')),
  publication_status text not null default 'published' check (publication_status in ('draft', 'published', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_schedule_time_order check (end_at > start_at)
);

-- -----------------------------------------------------------------------------
-- 6. announcements
-- -----------------------------------------------------------------------------
create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  title text not null,
  body text not null,
  category text,
  is_pinned boolean not null default false,
  publication_status text not null default 'published' check (publication_status in ('draft', 'published', 'archived')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 7. award_categories
-- -----------------------------------------------------------------------------
create table if not exists public.award_categories (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  title text not null,
  description text,
  sort_order integer not null default 0,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 8. award_winners
-- -----------------------------------------------------------------------------
create table if not exists public.award_winners (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  category_id uuid references public.award_categories(id) on delete set null,
  project_id uuid references public.projects(id) on delete set null,
  title text not null,
  sponsor text,
  description text,
  team_display_name text,
  supervisor_display_name text,
  programme_code text,
  publication_status text not null default 'published' check (publication_status in ('draft', 'published', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 9. lecturer_assignments
-- -----------------------------------------------------------------------------
create table if not exists public.lecturer_assignments (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  lecturer_id uuid not null references public.profiles(id) on delete cascade,
  lecturer_display_name text,
  lecturer_email text,
  role text not null check (role in ('supervisor', 'examiner')),
  status text not null default 'active' check (status in ('active', 'removed')),
  assigned_at timestamptz not null default now(),
  assigned_by uuid references public.profiles(id),
  updated_at timestamptz not null default now(),
  unique (event_id, project_id, lecturer_id, role)
);

-- -----------------------------------------------------------------------------
-- 10. student_project_visits
-- -----------------------------------------------------------------------------
create table if not exists public.student_project_visits (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  assignment_id uuid not null references public.lecturer_assignments(id) on delete cascade,
  lecturer_id uuid not null references public.profiles(id),
  visit_role text not null check (visit_role in ('supervisor', 'examiner')),
  status text not null default 'completed' check (status in ('completed', 'voided')),
  visited_at timestamptz not null default now(),
  visit_note text,
  source text not null default 'lecturer',
  voided_at timestamptz,
  voided_by uuid references public.profiles(id),
  voided_by_role text check (voided_by_role in ('admin', 'lecturer')),
  void_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, project_id, lecturer_id, visit_role)
);

-- -----------------------------------------------------------------------------
-- 11. feedback_entries
-- -----------------------------------------------------------------------------
create table if not exists public.feedback_entries (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references public.events(id) on delete set null,
  subject text not null,
  message text not null,
  rating integer check (rating between 1 and 5),
  status text not null default 'new' check (status in ('new', 'reviewed', 'resolved', 'archived')),
  admin_note text,
  submitted_by uuid references public.profiles(id) on delete set null,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 12. imports
-- -----------------------------------------------------------------------------
create table if not exists public.imports (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references public.events(id) on delete set null,
  file_name text not null,
  file_size_bytes bigint not null default 0,
  uploaded_by uuid not null references public.profiles(id),
  status text not null default 'pending_review' check (status in (
    'processing',
    'pending_review',
    'partially_published',
    'published',
    'completed_with_warnings',
    'failed'
  )),
  summary jsonb not null default '{}'::jsonb,
  warnings_count integer not null default 0,
  candidates_count integer not null default 0,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 13. import_schedule_candidates
-- -----------------------------------------------------------------------------
create table if not exists public.import_schedule_candidates (
  id uuid primary key default gen_random_uuid(),
  import_id uuid not null references public.imports(id) on delete cascade,
  row_number integer not null,
  day_label text,
  event_date date,
  start_at timestamptz,
  end_at timestamptz,
  raw_start_str text,
  raw_end_str text,
  title text not null,
  description text,
  venue text,
  audience text,
  access_type text not null default 'public',
  comparison_status text not null default 'new',
  is_duplicate boolean not null default false,
  is_overlapping boolean not null default false,
  overlap_details text,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 14. import_award_candidates
-- -----------------------------------------------------------------------------
create table if not exists public.import_award_candidates (
  id uuid primary key default gen_random_uuid(),
  import_id uuid not null references public.imports(id) on delete cascade,
  row_number integer not null,
  award_category text not null,
  project_title text not null,
  team_display_name text,
  supervisor_display_name text,
  programme_code text,
  comparison_status text not null default 'new',
  is_skip boolean not null default false,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 15. import_validation_issues
-- -----------------------------------------------------------------------------
create table if not exists public.import_validation_issues (
  id uuid primary key default gen_random_uuid(),
  import_id uuid not null references public.imports(id) on delete cascade,
  worksheet_name text not null,
  row_number integer not null,
  issue_type text not null,
  severity text not null check (severity in ('warning', 'error', 'info')),
  message text not null,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 16. import_privacy_skips
-- -----------------------------------------------------------------------------
create table if not exists public.import_privacy_skips (
  id uuid primary key default gen_random_uuid(),
  import_id uuid not null references public.imports(id) on delete cascade,
  sheet_name text not null,
  row_number integer not null,
  field_name text not null,
  reason text not null,
  category text not null,
  masked_preview text,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 17. import_review_decisions
-- -----------------------------------------------------------------------------
create table if not exists public.import_review_decisions (
  id uuid primary key default gen_random_uuid(),
  import_id uuid not null references public.imports(id) on delete cascade,
  candidate_id text not null,
  candidate_type text not null check (candidate_type in ('event_metadata', 'schedule', 'award')),
  action text not null check (action in ('publish', 'save_draft', 'skip', 'mark_internal', 'replace_existing', 'retain_existing')),
  edited_public_data jsonb,
  target_public_record_id uuid,
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz default now(),
  notes text,
  decision_version integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 18. settings
-- -----------------------------------------------------------------------------
create table if not exists public.settings (
  key text primary key,
  value jsonb not null,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 19. audit_logs
-- -----------------------------------------------------------------------------
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_uid uuid references public.profiles(id),
  actor_role text check (actor_role in ('admin', 'lecturer', 'system')),
  action text not null,
  target_type text not null,
  target_id uuid,
  event_id uuid references public.events(id),
  import_id uuid references public.imports(id),
  metadata_safe jsonb not null default '{}'::jsonb,
  source text not null default 'database_rpc',
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Indices for Query Performance & Low-Bandwidth Lookups
-- -----------------------------------------------------------------------------
create index if not exists idx_projects_event_publication on public.projects(event_id, publication_status);
create index if not exists idx_projects_slug on public.projects(slug);
create index if not exists idx_booths_event on public.booths(event_id, status);
create index if not exists idx_schedule_event_date on public.schedule_items(event_id, event_date, start_at);
create index if not exists idx_announcements_event on public.announcements(event_id, is_pinned, created_at desc);
create index if not exists idx_award_winners_event on public.award_winners(event_id, publication_status);
create index if not exists idx_lecturer_assignments_lecturer on public.lecturer_assignments(lecturer_id, status);
create index if not exists idx_lecturer_assignments_project on public.lecturer_assignments(project_id, role);
create index if not exists idx_visits_event_project on public.student_project_visits(event_id, project_id);
create index if not exists idx_visits_lecturer on public.student_project_visits(lecturer_id, status);
create index if not exists idx_feedback_event on public.feedback_entries(event_id, status, created_at desc);
create index if not exists idx_imports_uploaded_by on public.imports(uploaded_by, created_at desc);
create index if not exists idx_audit_logs_event_created on public.audit_logs(event_id, created_at desc);
