-- ==============================================================================
-- FYP Expo Hub - Row Level Security Policies & Helper SQL Functions
-- 20260814000002_rls_policies.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Helper SQL Functions
-- -----------------------------------------------------------------------------

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles
  where id = auth.uid() and is_active = true
  limit 1;
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin' and is_active = true
  );
$$;

create or replace function public.is_lecturer()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'lecturer' and is_active = true
  );
$$;

create or replace function public.current_event_is_public(p_event_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.events
    where id = p_event_id and publication_status = 'published'
  );
$$;

create or replace function public.can_read_project(p_project_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.projects p
    where p.id = p_project_id
    and (
      p.publication_status = 'published'
      or public.is_admin()
      or exists (
        select 1 from public.lecturer_assignments la
        where la.project_id = p_project_id
        and la.lecturer_id = auth.uid()
        and la.status = 'active'
      )
    )
  );
$$;

create or replace function public.can_read_assignment(p_assignment_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.lecturer_assignments la
    where la.id = p_assignment_id
    and (
      public.is_admin()
      or (la.lecturer_id = auth.uid() and la.status = 'active')
    )
  );
$$;

-- -----------------------------------------------------------------------------
-- Enable RLS on all tables
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.events enable row level security;
alter table public.projects enable row level security;
alter table public.booths enable row level security;
alter table public.schedule_items enable row level security;
alter table public.announcements enable row level security;
alter table public.award_categories enable row level security;
alter table public.award_winners enable row level security;
alter table public.lecturer_assignments enable row level security;
alter table public.student_project_visits enable row level security;
alter table public.feedback_entries enable row level security;
alter table public.imports enable row level security;
alter table public.import_schedule_candidates enable row level security;
alter table public.import_award_candidates enable row level security;
alter table public.import_validation_issues enable row level security;
alter table public.import_privacy_skips enable row level security;
alter table public.import_review_decisions enable row level security;
alter table public.settings enable row level security;
alter table public.audit_logs enable row level security;

-- -----------------------------------------------------------------------------
-- 1. profiles Policies
-- -----------------------------------------------------------------------------
create policy "Admins have full access to profiles"
  on public.profiles for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

-- -----------------------------------------------------------------------------
-- 2. events Policies
-- -----------------------------------------------------------------------------
create policy "Public can read published events"
  on public.events for select
  using (publication_status = 'published' or public.is_admin());

create policy "Admins manage events"
  on public.events for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 3. projects Policies (matric_id is allowed for public exhibition)
-- -----------------------------------------------------------------------------
create policy "Public can read published projects"
  on public.projects for select
  using (
    publication_status = 'published'
    or public.is_admin()
    or exists (
      select 1 from public.lecturer_assignments la
      where la.project_id = projects.id
      and la.lecturer_id = auth.uid()
      and la.status = 'active'
    )
  );

create policy "Admins manage projects"
  on public.projects for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 4. booths Policies
-- -----------------------------------------------------------------------------
create policy "Public can read active booths"
  on public.booths for select
  using (publication_status = 'published' or public.is_admin());

create policy "Admins manage booths"
  on public.booths for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 5. schedule_items Policies
-- -----------------------------------------------------------------------------
create policy "Public can read public schedule items"
  on public.schedule_items for select
  using (
    (publication_status = 'published' and access_type = 'public')
    or public.is_admin()
    or (auth.role() = 'authenticated' and publication_status = 'published')
  );

create policy "Admins manage schedule items"
  on public.schedule_items for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 6. announcements Policies
-- -----------------------------------------------------------------------------
create policy "Public can read published announcements"
  on public.announcements for select
  using (publication_status = 'published' or public.is_admin());

create policy "Admins manage announcements"
  on public.announcements for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 7. award_categories Policies
-- -----------------------------------------------------------------------------
create policy "Public can read active award categories"
  on public.award_categories for select
  using (status = 'active' or public.is_admin());

create policy "Admins manage award categories"
  on public.award_categories for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 8. award_winners Policies
-- -----------------------------------------------------------------------------
create policy "Public can read published award winners"
  on public.award_winners for select
  using (publication_status = 'published' or public.is_admin());

create policy "Admins manage award winners"
  on public.award_winners for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 9. lecturer_assignments Policies
-- -----------------------------------------------------------------------------
create policy "Admins manage lecturer assignments"
  on public.lecturer_assignments for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Lecturers read own assignments"
  on public.lecturer_assignments for select
  using (lecturer_id = auth.uid() and status = 'active');

-- -----------------------------------------------------------------------------
-- 10. student_project_visits Policies
-- -----------------------------------------------------------------------------
create policy "Admins manage visits"
  on public.student_project_visits for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Lecturers read own visits"
  on public.student_project_visits for select
  using (lecturer_id = auth.uid());

-- Direct inserts/updates are disabled for non-admins (must use RPC functions)
create policy "Prevent direct visit mutations by non-admins"
  on public.student_project_visits for insert
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 11. feedback_entries Policies
-- -----------------------------------------------------------------------------
create policy "Public can insert feedback"
  on public.feedback_entries for insert
  with check (
    length(subject) > 0 and length(subject) <= 200
    and length(message) > 0 and length(message) <= 2000
    and (rating is null or (rating >= 1 and rating <= 5))
  );

create policy "Users read own feedback"
  on public.feedback_entries for select
  using (
    public.is_admin()
    or (auth.uid() is not null and submitted_by = auth.uid())
  );

create policy "Admins manage feedback"
  on public.feedback_entries for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 12-17. imports and candidate sub-tables Policies
-- -----------------------------------------------------------------------------
create policy "Admins manage imports"
  on public.imports for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins manage schedule candidates"
  on public.import_schedule_candidates for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins manage award candidates"
  on public.import_award_candidates for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins manage validation issues"
  on public.import_validation_issues for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins manage privacy skips"
  on public.import_privacy_skips for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins manage review decisions"
  on public.import_review_decisions for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 18. settings Policies
-- -----------------------------------------------------------------------------
create policy "Authenticated users read settings"
  on public.settings for select
  using (auth.role() = 'authenticated');

create policy "Admins manage settings"
  on public.settings for all
  using (public.is_admin())
  with check (public.is_admin());

-- -----------------------------------------------------------------------------
-- 19. audit_logs Policies (Read-only for admins, writes strictly from RPC)
-- -----------------------------------------------------------------------------
create policy "Admins read audit logs"
  on public.audit_logs for select
  using (public.is_admin());
