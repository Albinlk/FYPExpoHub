-- =============================================================================
-- MFA for privileged roles (backlog F8, G-32 remainder)
--
-- Users can turn on an authenticator app (TOTP) from My Account. Once an
-- account has a verified factor, its admin and FYP-coordinator powers only
-- work in a session that passed the second step (JWT aal = 'aal2'): a stolen
-- password alone can no longer call admin / coordinator RPCs or pass the
-- admin RLS policies. Accounts without MFA behave exactly as before.
--
-- Lockout: repeated wrong passwords are throttled by Supabase Auth's
-- per-IP sign-in rate limit (Dashboard → Authentication → Rate Limits);
-- there is no separate per-account lockout.
-- =============================================================================

create or replace function public.mfa_satisfied()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(auth.jwt()->>'aal', 'aal1') = 'aal2'
      or not exists (
        select 1 from auth.mfa_factors f
        where f.user_id = auth.uid() and f.status = 'verified'
      );
$$;

revoke execute on function public.mfa_satisfied() from public, anon;
grant execute on function public.mfa_satisfied() to authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin' and is_active = true)
     and public.mfa_satisfied();
$$;

create or replace function public.is_fyp_coordinator()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_academic_role('fyp_coordinator') and public.mfa_satisfied();
$$;
