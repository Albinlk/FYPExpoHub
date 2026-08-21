-- ==============================================================================
-- FYP Expo Hub - FYPMS Helper SQL Functions
-- 20260817000002_fypms_helpers.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Active profile check (any role, including student)
-- -----------------------------------------------------------------------------
create or replace function public.is_active_profile()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and is_active = true
  );
$$;

-- -----------------------------------------------------------------------------
-- has_academic_role: current user holds the given academic role (any programme)
-- -----------------------------------------------------------------------------
create or replace function public.has_academic_role(p_role_code text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or exists (
      select 1 from public.profile_academic_roles
      where profile_id = auth.uid()
        and role_code = p_role_code
        and is_active = true
    );
$$;

-- -----------------------------------------------------------------------------
-- has_academic_role_for_programme: role scoped to a specific programme
-- -----------------------------------------------------------------------------
create or replace function public.has_academic_role_for_programme(p_role_code text, p_programme_code text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or exists (
      select 1 from public.profile_academic_roles
      where profile_id = auth.uid()
        and role_code = p_role_code
        and programme_code = p_programme_code
        and is_active = true
    );
$$;

-- -----------------------------------------------------------------------------
-- is_fyp_coordinator
-- -----------------------------------------------------------------------------
create or replace function public.is_fyp_coordinator()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_academic_role('fyp_coordinator');
$$;

-- -----------------------------------------------------------------------------
-- is_csp_lecturer: current user is the CSP lecturer for the given course code
-- -----------------------------------------------------------------------------
create or replace function public.is_csp_lecturer(p_course_code text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or exists (
      select 1 from public.profile_academic_roles
      where profile_id = auth.uid()
        and role_code = case upper(p_course_code)
          when 'CSP600' then 'csp600_lecturer'
          when 'CSP650' then 'csp650_lecturer'
          else 'csp600_lecturer'
        end
        and is_active = true
    );
$$;

-- -----------------------------------------------------------------------------
-- is_active_fyp_student: current user is an active student on the given record
-- (admin / coordinator implicitly pass to allow support and previews)
-- -----------------------------------------------------------------------------
create or replace function public.is_active_fyp_student(p_fyp_record_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_records r
      where r.id = p_fyp_record_id
        and r.student_id = auth.uid()
    );
$$;

-- -----------------------------------------------------------------------------
-- is_assigned_to_fyp_record: current user is an active assignment on the record
-- in the given academic role ('supervisor', 'co_supervisor', 'examiner')
-- -----------------------------------------------------------------------------
create or replace function public.is_assigned_to_fyp_record(p_fyp_record_id uuid, p_role text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or exists (
      select 1 from public.fyp_record_assignments a
      where a.fyp_record_id = p_fyp_record_id
        and a.lecturer_id = auth.uid()
        and a.academic_role = p_role
        and a.is_active = true
    );
$$;

-- -----------------------------------------------------------------------------
-- can_read_fyp_record: student owner, assigned staff, CSP lecturer, coordinator,
-- admin
-- -----------------------------------------------------------------------------
create or replace function public.can_read_fyp_record(p_fyp_record_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or exists (
      select 1 from public.fyp_records r
      where r.id = p_fyp_record_id
      and (
        r.student_id = auth.uid()
        or r.main_supervisor_id = auth.uid()
        or r.co_supervisor_id = auth.uid()
        or r.examiner_id = auth.uid()
        or exists (
          select 1 from public.fyp_record_assignments a
          where a.fyp_record_id = r.id
            and a.lecturer_id = auth.uid()
            and a.is_active = true
        )
        or exists (
          select 1 from public.fyp_course_offerings o
          where o.academic_semester_id = r.academic_semester_id
            and o.course_code = r.current_course_code
            and o.lecturer_id = auth.uid()
            and o.is_active = true
        )
      )
    )
    or public.is_fyp_coordinator();
$$;

-- -----------------------------------------------------------------------------
-- can_edit_fyp_record: student may edit own project fields; coordinator/admin
-- have full access
-- -----------------------------------------------------------------------------
create or replace function public.can_edit_fyp_record(p_fyp_record_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_records r
      where r.id = p_fyp_record_id and r.student_id = auth.uid()
    );
$$;

-- -----------------------------------------------------------------------------
-- can_manage_fyp_offering: CSP lecturer of the offering, coordinator, admin
-- -----------------------------------------------------------------------------
create or replace function public.can_manage_fyp_offering(p_offering_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_course_offerings o
      where o.id = p_offering_id
        and o.lecturer_id = auth.uid()
        and o.is_active = true
    );
$$;

-- -----------------------------------------------------------------------------
-- can_publish_fyp_record_to_expo: coordinator or admin only
-- -----------------------------------------------------------------------------
create or replace function public.can_publish_fyp_record_to_expo(p_fyp_record_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_admin() or public.is_fyp_coordinator();
$$;