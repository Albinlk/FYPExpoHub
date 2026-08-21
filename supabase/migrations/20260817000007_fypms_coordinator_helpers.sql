-- ==============================================================================
-- FYP Expo Hub - FYPMS Coordinator Helper RPCs
-- 20260817000007_fypms_coordinator_helpers.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. list_fyp_students
--    Returns active student profiles (role_code = 'student') with their
--    programme code(s). SECURITY DEFINER because coordinators cannot read the
--    profiles table via RLS (only admins + own profile).
-- -----------------------------------------------------------------------------
create or replace function public.list_fyp_students()
returns table (
  id uuid,
  display_name text,
  email text,
  matric_id text,
  programme_code text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    p.display_name,
    p.email,
    nullif(p.email, '') as matric_id,
    r.programme_code
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code = 'student'
    and r.is_active = true
  order by p.id, p.display_name;
$$;

-- -----------------------------------------------------------------------------
-- 2. list_fyp_staff
--    Returns active profiles holding one of the given academic roles
--    (e.g. supervisor, co_supervisor, examiner, fyp_coordinator). Used by the
--    coordinator's assignment pickers.
-- -----------------------------------------------------------------------------
create or replace function public.list_fyp_staff(p_role_codes text[] default array['supervisor','co_supervisor','examiner'])
returns table (
  id uuid,
  display_name text,
  email text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    p.display_name,
    p.email
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code = any(p_role_codes)
    and r.is_active = true
  order by p.id, p.display_name;
$$;

-- -----------------------------------------------------------------------------
-- 3. list_fyp_coordinators
--    Convenience wrapper used by audit/requests pages to attribute decisions.
-- -----------------------------------------------------------------------------
create or replace function public.list_fyp_coordinators()
returns table (
  id uuid,
  display_name text,
  email text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    p.display_name,
    p.email
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code in ('fyp_coordinator')
    and r.is_active = true
  order by p.id, p.display_name;
$$;
