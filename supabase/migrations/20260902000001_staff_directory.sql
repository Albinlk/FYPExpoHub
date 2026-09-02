-- ==============================================================================
-- FYP Expo Hub - Public staff directory for student supervision requests
-- 20260902000001_staff_directory.sql
--
-- The student supervision-request page previously used a free-text
-- "Preferred Supervisor" field, but submit_supervision_request expects a
-- supervisor UUID -> every submission failed with "invalid input syntax for
-- type uuid". Students cannot read profiles directly (RLS), and
-- list_fyp_staff is gated to coordinator/CSP/admin, so this adds a
-- student-facing directory RPC returning only public-safe fields
-- (id + display name, no emails) of active supervisors/co-supervisors.
-- ==============================================================================

create or replace function public.list_supervisors_public()
returns table (
  id uuid,
  display_name text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    coalesce(nullif(p.display_name, ''), split_part(p.email, '@', 1)) as display_name
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code in ('supervisor', 'co_supervisor')
    and r.is_active = true
  order by p.id, coalesce(nullif(p.display_name, ''), split_part(p.email, '@', 1));
$$;

-- Any authenticated user may list supervisor names (display names are already
-- shown publicly on project pages); revoke anon.
revoke execute on function public.list_supervisors_public() from public, anon;
