-- DEF-7: Seed co_supervisor test account (Record B assignment)
DO $$
DECLARE
  v_co_sup uuid := '10000000-0000-0000-0000-00000000000b';
  v_record_b uuid := '20000000-0000-0000-0000-000000000002';
  v_now timestamptz := clock_timestamp();
  v_instance uuid := '00000000-0000-0000-0000-000000000000';
BEGIN
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, is_super_admin, is_sso_user, is_anonymous,
    created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current, reauthentication_token
  ) VALUES (
    v_instance, v_co_sup, 'authenticated', 'authenticated', 'cosupervisor@fypms.test', crypt('Password123!', gen_salt('bf')), v_now,
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false,
    v_now, v_now, '', '', '', '', '', ''
  ) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
  VALUES (
    gen_random_uuid(), v_co_sup,
    jsonb_build_object('sub', v_co_sup::text, 'email', 'cosupervisor@fypms.test', 'email_verified', true, 'phone_verified', false),
    'email', 'cosupervisor@fypms.test', NULL, v_now, v_now
  ) ON CONFLICT (provider, provider_id) DO NOTHING;

  INSERT INTO public.profiles (id, email, display_name, role, is_active, created_at, updated_at)
  VALUES (v_co_sup, 'cosupervisor@fypms.test', 'CO SUPERVISOR', 'lecturer', true, v_now, v_now)
  ON CONFLICT (id) DO UPDATE SET email=EXCLUDED.email, display_name=EXCLUDED.display_name, role=EXCLUDED.role, is_active=true, updated_at=v_now;

  INSERT INTO public.profile_academic_roles (profile_id, role_code, programme_code, is_active, created_at, updated_at)
  VALUES (v_co_sup, 'co_supervisor', '', true, v_now, v_now)
  ON CONFLICT (profile_id, role_code, programme_code) DO UPDATE SET is_active=true, updated_at=v_now;

  INSERT INTO public.fyp_record_assignments (fyp_record_id, lecturer_id, academic_role, is_active, assigned_by, assigned_at, created_at, updated_at)
  VALUES (v_record_b, v_co_sup, 'co_supervisor', true, v_co_sup, v_now, v_now, v_now)
  ON CONFLICT (fyp_record_id, lecturer_id, academic_role) DO UPDATE SET is_active=true, updated_at=v_now;
END $$;
