-- DEF-1: Restore GoTrue access via permissive policies (RLS remains enabled but allows supabase_auth_admin)
-- Using policies instead of DISABLE RLS (requires owner) — CREATE POLICY works as postgres
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.users'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.users FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.identities'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.identities FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.sessions'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.sessions FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.refresh_tokens'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.refresh_tokens FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.instances'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.instances FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.audit_log_entries'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.audit_log_entries FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.flow_state'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.flow_state FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname='allow_auth_admin_all' AND polrelid='auth.one_time_tokens'::regclass) THEN
    CREATE POLICY allow_auth_admin_all ON auth.one_time_tokens FOR ALL TO supabase_auth_admin USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Rewrite legacy handle_new_user to target FYPMS profiles
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, role, is_active, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    'student',
    true,
    now(),
    now()
  ) ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

GRANT EXECUTE ON FUNCTION public.handle_new_user() TO supabase_auth_admin, postgres, service_role, anon, authenticated;

-- Ensure instance row exists for seeded 000...0 users
INSERT INTO auth.instances (id, uuid, raw_base_config, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', '{"site_url":"https://siedglubjcedkbrpdzgi.supabase.co","jwt_exp":3600}', now(), now())
ON CONFLICT (id) DO NOTHING;
