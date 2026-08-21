-- ==============================================================================
-- FYP Expo Hub - FYPMS Workflow Test-Data Seed
-- 20260819000001_fypms_workflow_seed.sql
-- ==============================================================================
-- Provisions the 10 accounts used to exercise the supervisor / examiner / csp /
-- coordinator workflows. Each user is created with a fixed UUID so migrations,
-- RPCs and test fixtures can reference them deterministically.
--
--   Role              email                        UUID suffix
--   admin             admin@fypms.test                    ...0001
--   csp600_lecturer   csp600.lecturer@fypms.test          ...0002
--   csp650_lecturer   csp650.lecturer@fypms.test          ...0003
--   fyp_coordinator   coordinator@fypms.test              ...0004
--   supervisor 1      supervisor1@fypms.test              ...0005
--   supervisor 2      supervisor2@fypms.test              ...0006
--   examiner          examiner@fypms.test                 ...0007
--   student 1         student1@fypms.test                 ...0008
--   student 2         student2@fypms.test                 ...0009
--   student 3         student3@fypms.test                 ...000a
--
-- All accounts use password: Password123!
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Fixed UUIDs (10000000-0000-0000-0000-00000000000{1..a})
-- -----------------------------------------------------------------------------
do $$
declare
  v_admin       uuid := '10000000-0000-0000-0000-000000000001';
  v_csp600      uuid := '10000000-0000-0000-0000-000000000002';
  v_csp650      uuid := '10000000-0000-0000-0000-000000000003';
  v_coordinator uuid := '10000000-0000-0000-0000-000000000004';
  v_sup1        uuid := '10000000-0000-0000-0000-000000000005';
  v_sup2        uuid := '10000000-0000-0000-0000-000000000006';
  v_examiner    uuid := '10000000-0000-0000-0000-000000000007';
  v_stu1        uuid := '10000000-0000-0000-0000-000000000008';
  v_stu2        uuid := '10000000-0000-0000-0000-000000000009';
  v_stu3        uuid := '10000000-0000-0000-0000-00000000000a';
  v_now         timestamptz := clock_timestamp();
begin
  -- ---------------------------------------------------------------------------
  -- auth.users (fixed UUIDs; confirmed; shared password)
  -- ---------------------------------------------------------------------------
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, is_super_admin, is_sso_user, is_anonymous,
    created_at, updated_at
  ) values
    ('00000000-0000-0000-0000-000000000000', v_admin,       'authenticated', 'authenticated', 'admin@fypms.test',             crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_csp600,      'authenticated', 'authenticated', 'csp600.lecturer@fypms.test',   crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_csp650,      'authenticated', 'authenticated', 'csp650.lecturer@fypms.test',   crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_coordinator, 'authenticated', 'authenticated', 'coordinator@fypms.test',       crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_sup1,        'authenticated', 'authenticated', 'supervisor1@fypms.test',        crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_sup2,        'authenticated', 'authenticated', 'supervisor2@fypms.test',        crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_examiner,    'authenticated', 'authenticated', 'examiner@fypms.test',           crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_stu1,        'authenticated', 'authenticated', 'student1@fypms.test',           crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_stu2,        'authenticated', 'authenticated', 'student2@fypms.test',           crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now),
    ('00000000-0000-0000-0000-000000000000', v_stu3,        'authenticated', 'authenticated', 'student3@fypms.test',           crypt('Password123!', gen_salt('bf')), v_now, '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, false, false, false, v_now, v_now)
  on conflict (id) do nothing;

  -- ---------------------------------------------------------------------------
  -- profiles (coarse role must be consistent with profile_academic_roles)
  -- ---------------------------------------------------------------------------
  insert into public.profiles (id, email, display_name, role, is_active, created_at, updated_at)
  values
    (v_admin,       'admin@fypms.test',             'ADMIN',             'admin',    true, v_now, v_now),
    (v_csp600,      'csp600.lecturer@fypms.test',   'CSP600 LECTURER',   'lecturer', true, v_now, v_now),
    (v_csp650,      'csp650.lecturer@fypms.test',   'CSP650 LECTURER',   'lecturer', true, v_now, v_now),
    (v_coordinator, 'coordinator@fypms.test',       'FYP COORDINATOR',   'lecturer', true, v_now, v_now),
    (v_sup1,        'supervisor1@fypms.test',       'SUPERVISOR 1',      'lecturer', true, v_now, v_now),
    (v_sup2,        'supervisor2@fypms.test',       'SUPERVISOR 2',      'lecturer', true, v_now, v_now),
    (v_examiner,    'examiner@fypms.test',          'EXAMINER',          'lecturer', true, v_now, v_now),
    (v_stu1,        'student1@fypms.test',          'STUDENT 1',         'student',  true, v_now, v_now),
    (v_stu2,        'student2@fypms.test',          'STUDENT 2',         'student',  true, v_now, v_now),
    (v_stu3,        'student3@fypms.test',          'STUDENT 3',         'student',  true, v_now, v_now)
  on conflict (id) do update set
    email = excluded.email,
    display_name = excluded.display_name,
    role = excluded.role,
    is_active = true,
    updated_at = v_now;

  -- ---------------------------------------------------------------------------
  -- profile_academic_roles (fine-grained FYPMS roles)
  -- ---------------------------------------------------------------------------
  insert into public.profile_academic_roles (
    profile_id, role_code, programme_code, is_active, created_at, updated_at
  ) values
    (v_csp600,      'csp600_lecturer', '', true, v_now, v_now),
    (v_csp650,      'csp650_lecturer', '', true, v_now, v_now),
    (v_coordinator, 'fyp_coordinator', '', true, v_now, v_now),
    (v_sup1,        'supervisor',      '', true, v_now, v_now),
    (v_sup2,        'supervisor',      '', true, v_now, v_now),
    (v_examiner,    'examiner',        '', true, v_now, v_now),
    (v_stu1,        'student',         'CS266', true, v_now, v_now),
    (v_stu2,        'student',         'CS266', true, v_now, v_now),
    (v_stu3,        'student',         'CS266', true, v_now, v_now)
  on conflict (profile_id, role_code, programme_code) do update set
    is_active = true,
    updated_at = v_now;

  -- ---------------------------------------------------------------------------
  -- Link the CSP600 offering to the csp600 lecturer so can_manage_fyp_offering
  -- and record workflow checks resolve correctly.
  -- ---------------------------------------------------------------------------
  update public.fyp_course_offerings o
  set lecturer_id = v_csp600, updated_at = v_now
  from public.academic_semesters s
  where s.code = '2026_1'
    and o.academic_semester_id = s.id
    and o.course_code = 'CSP600'
    and o.lecturer_id is null;
end;
$$;