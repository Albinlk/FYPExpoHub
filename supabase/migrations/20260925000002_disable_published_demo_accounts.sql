-- ==============================================================================
-- FYP Expo Hub - Disable the demo accounts whose password is public
-- 20260925000002_disable_published_demo_accounts.sql
--
-- The seed migrations (20260819000001, 20260822142935) create 11
-- `@fypms.test` accounts — including an ADMIN — that all share one password,
-- and that password is written in this public repository (and its history,
-- so deleting it from the files doesn't help). Anyone can sign in as admin.
--
-- On any database that has at least one REAL active admin (an admin whose
-- email is not @fypms.test), this:
--   * bans every @fypms.test auth user (they can no longer sign in),
--   * replaces their password with a random one (the public one stops
--     working even if the ban is lifted),
--   * ends their existing sessions,
--   * marks their profiles inactive.
--
-- On a database where the demo admin is the ONLY admin (a fresh local
-- `supabase db reset` for development / the E2E runbook) it changes
-- nothing, so it can never lock the last admin out. Re-enable a single
-- account from the dashboard (Authentication -> Users -> unban, reset
-- password) if one is ever needed again.
-- ==============================================================================

do $$
declare
  v_real_admins integer;
  v_banned integer;
begin
  select count(*) into v_real_admins
  from public.profiles p
  where p.role = 'admin'
    and p.is_active
    and p.email not ilike '%@fypms.test';

  if v_real_admins = 0 then
    raise notice 'Demo accounts left enabled: no non-demo active admin exists, and disabling them would lock every admin out. Create a real admin, then re-run this migration''s block.';
    return;
  end if;

  update auth.users
  set banned_until = now() + interval '100 years',
      encrypted_password = crypt(gen_random_uuid()::text, gen_salt('bf')),
      updated_at = now()
  where email ilike '%@fypms.test';
  get diagnostics v_banned = row_count;

  delete from auth.sessions
  where user_id in (select id from auth.users where email ilike '%@fypms.test');

  update public.profiles
  set is_active = false,
      updated_at = now()
  where email ilike '%@fypms.test';

  raise notice 'Disabled % published demo account(s).', v_banned;
end;
$$;
