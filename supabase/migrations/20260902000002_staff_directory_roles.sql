-- ==============================================================================
-- FYP Expo Hub - Staff directory extension: include examiners + role code
-- 20260902000002_staff_directory_roles.sql
--
-- Extends list_supervisors_public() to also return examiner names and each
-- staff member's role code. The student supervision-request picker filters
-- to supervisors; the FYPMS record detail page resolves supervisor /
-- co-supervisor / examiner display names (previously raw UUIDs were shown).
-- Still public-safe: id + display name + role code only, no emails.
-- ==============================================================================

create or replace function public.list_supervisors_public()
returns table (
  id uuid,
  display_name text,
  role_code text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    coalesce(nullif(p.display_name, ''), split_part(p.email, '@', 1)) as display_name,
    r.role_code
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code in ('supervisor', 'co_supervisor', 'examiner')
    and r.is_active = true
  order by p.id, coalesce(nullif(p.display_name, ''), split_part(p.email, '@', 1));
$$;

revoke execute on function public.list_supervisors_public() from public, anon;
