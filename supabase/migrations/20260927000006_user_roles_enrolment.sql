-- =============================================================================
-- User role management and student enrolment (backlog U2, U3, S4)
--
-- Roles lived only in the database. These audited RPCs back the Users &
-- Roles and Enrol Students screens:
--
--   admin_list_users          search people (email / name / matric) with
--                             their account role, active flag and FYPMS roles
--   set_user_academic_role    add / remove an FYPMS role (optionally per
--                             programme). Coordinators may not grant or
--                             remove fyp_coordinator; only admins can.
--   set_profile_active        activate / deactivate an account (not yourself)
--   set_profile_account_role  admin / lecturer / student (admins only, not
--                             yourself)
--   enroll_student            profile + student role + the FYP record for a
--                             semester and course (idempotent). The
--                             enroll-students Edge Function calls it as the
--                             signed-in coordinator after creating the login.
-- =============================================================================

create or replace function public.admin_list_users(p_search text default null, p_limit integer default 50)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_q text := '%' || lower(btrim(coalesce(p_search, ''))) || '%';
begin
  if auth.uid() is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only administrators and the FYP coordinator manage users.' using errcode = '42501';
  end if;
  return coalesce((
    select jsonb_agg(u order by u->>'display_name')
    from (
      select jsonb_build_object(
        'id', p.id,
        'email', p.email,
        'display_name', p.display_name,
        'role', p.role,
        'is_active', p.is_active,
        'matric_id', (select r.matric_id from public.fyp_records r where r.student_id = p.id and r.matric_id is not null limit 1),
        'roles', coalesce((
          select jsonb_agg(jsonb_build_object('role_code', ar.role_code, 'programme_code', ar.programme_code)
                           order by ar.role_code)
          from public.profile_academic_roles ar
          where ar.profile_id = p.id and ar.is_active
        ), '[]'::jsonb)
      ) as u
      from public.profiles p
      where lower(coalesce(p.email, '')) like v_q
         or lower(coalesce(p.display_name, '')) like v_q
         or exists (select 1 from public.fyp_records r where r.student_id = p.id and lower(coalesce(r.matric_id, '')) like v_q)
      order by p.display_name
      limit greatest(1, least(coalesce(p_limit, 50), 200))
    ) s
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.admin_list_users(text, integer) from public, anon;
grant execute on function public.admin_list_users(text, integer) to authenticated;

create or replace function public.set_user_academic_role(
  p_profile_id uuid,
  p_role_code text,
  p_programme_code text default '',
  p_active boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_programme text := upper(btrim(coalesce(p_programme_code, '')));
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only administrators and the FYP coordinator manage roles.' using errcode = '42501';
  end if;
  if p_role_code not in ('student', 'supervisor', 'co_supervisor', 'examiner', 'csp600_lecturer',
                         'csp650_lecturer', 'fyp_coordinator', 'programme_head') then
    raise exception 'invalid-argument: Unknown role.' using errcode = '22023';
  end if;
  if p_role_code = 'fyp_coordinator' and not public.is_admin() then
    raise exception 'permission-denied: Only an administrator can grant or remove the coordinator role.' using errcode = '42501';
  end if;
  if p_profile_id = v_uid and p_role_code = 'fyp_coordinator' and not coalesce(p_active, true) then
    raise exception 'failed-precondition: You cannot remove your own coordinator role.' using errcode = '55000';
  end if;
  if not exists (select 1 from public.profiles where id = p_profile_id) then
    raise exception 'not-found: User not found.' using errcode = 'P0002';
  end if;

  if coalesce(p_active, true) then
    insert into public.profile_academic_roles (profile_id, role_code, programme_code, is_active, created_at, updated_at)
    values (p_profile_id, p_role_code, v_programme, true, v_now, v_now)
    on conflict (profile_id, role_code, programme_code) do update set is_active = true, updated_at = v_now;
  else
    update public.profile_academic_roles set is_active = false, updated_at = v_now
    where profile_id = p_profile_id and role_code = p_role_code and programme_code = v_programme;
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
          case when coalesce(p_active, true) then 'academic_role_granted' else 'academic_role_removed' end,
          'profiles', p_profile_id,
          jsonb_build_object('role_code', p_role_code, 'programme_code', v_programme), 'database_rpc', v_now);
  return jsonb_build_object('profile_id', p_profile_id, 'role_code', p_role_code,
                            'programme_code', v_programme, 'is_active', coalesce(p_active, true));
end;
$$;

revoke execute on function public.set_user_academic_role(uuid, text, text, boolean) from public, anon;
grant execute on function public.set_user_academic_role(uuid, text, text, boolean) to authenticated;

create or replace function public.set_profile_active(p_profile_id uuid, p_active boolean)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_target public.profiles%rowtype;
  v_result public.profiles%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only administrators and the FYP coordinator manage accounts.' using errcode = '42501';
  end if;
  if p_profile_id = v_uid then
    raise exception 'failed-precondition: You cannot deactivate your own account.' using errcode = '55000';
  end if;
  select * into v_target from public.profiles where id = p_profile_id;
  if not found then
    raise exception 'not-found: User not found.' using errcode = 'P0002';
  end if;
  if v_target.role = 'admin' and not public.is_admin() then
    raise exception 'permission-denied: Only an administrator can change an administrator account.' using errcode = '42501';
  end if;

  update public.profiles set is_active = coalesce(p_active, true), updated_at = v_now
  where id = p_profile_id
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
          case when coalesce(p_active, true) then 'account_activated' else 'account_deactivated' end,
          'profiles', p_profile_id, '{}'::jsonb, 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.set_profile_active(uuid, boolean) from public, anon;
grant execute on function public.set_profile_active(uuid, boolean) to authenticated;

create or replace function public.set_profile_account_role(p_profile_id uuid, p_role text)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_old text;
  v_result public.profiles%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_admin() then
    raise exception 'permission-denied: Only administrators change account types.' using errcode = '42501';
  end if;
  if p_role not in ('admin', 'lecturer', 'student') then
    raise exception 'invalid-argument: Account type must be admin, lecturer or student.' using errcode = '22023';
  end if;
  if p_profile_id = v_uid then
    raise exception 'failed-precondition: You cannot change your own account type.' using errcode = '55000';
  end if;
  select role into v_old from public.profiles where id = p_profile_id for update;
  if not found then
    raise exception 'not-found: User not found.' using errcode = 'P0002';
  end if;

  update public.profiles set role = p_role, updated_at = v_now
  where id = p_profile_id
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, 'admin', 'account_role_changed', 'profiles', p_profile_id,
          jsonb_build_object('from', v_old, 'to', p_role), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.set_profile_account_role(uuid, text) from public, anon;
grant execute on function public.set_profile_account_role(uuid, text) to authenticated;

create or replace function public.enroll_student(
  p_user_id uuid,
  p_email text,
  p_display_name text,
  p_programme_code text,
  p_matric_id text,
  p_semester_id uuid,
  p_course_code text default 'CSP600'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_email text := lower(btrim(coalesce(p_email, '')));
  v_name text := upper(btrim(coalesce(p_display_name, '')));
  v_programme text := upper(btrim(coalesce(p_programme_code, '')));
  v_course text := upper(btrim(coalesce(p_course_code, 'CSP600')));
  v_record_id uuid;
  v_created boolean := false;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only administrators and the FYP coordinator enrol students.' using errcode = '42501';
  end if;
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' or v_name = '' or v_programme = '' then
    raise exception 'invalid-argument: Each student needs an email, a name and a programme code.' using errcode = '22023';
  end if;
  if v_course not in ('CSP600', 'CSP650') then
    raise exception 'invalid-argument: Course must be CSP600 or CSP650.' using errcode = '22023';
  end if;
  if not exists (select 1 from public.academic_semesters where id = p_semester_id and status in ('planned', 'active')) then
    raise exception 'invalid-argument: Choose a planned or active semester.' using errcode = '22023';
  end if;
  if exists (select 1 from public.profiles where id = p_user_id and role in ('admin', 'lecturer')) then
    raise exception 'failed-precondition: % is a staff account.', v_email using errcode = '55000';
  end if;

  insert into public.profiles (id, email, display_name, role, is_active, created_at, updated_at)
  values (p_user_id, v_email, v_name, 'student', true, v_now, v_now)
  on conflict (id) do update set
    email = excluded.email, display_name = excluded.display_name, role = 'student', is_active = true, updated_at = v_now;

  insert into public.profile_academic_roles (profile_id, role_code, programme_code, is_active, created_at, updated_at)
  values (p_user_id, 'student', v_programme, true, v_now, v_now)
  on conflict (profile_id, role_code, programme_code) do update set is_active = true, updated_at = v_now;

  select id into v_record_id from public.fyp_records
  where academic_semester_id = p_semester_id and student_id = p_user_id and current_course_code = v_course;
  if v_record_id is null then
    insert into public.fyp_records (academic_semester_id, student_id, current_course_code, programme_code, matric_id,
                                    workflow_status, created_at, updated_at)
    values (p_semester_id, p_user_id, v_course, v_programme, nullif(btrim(p_matric_id), ''),
            'awaiting_supervisor_assignment', v_now, v_now)
    returning id into v_record_id;
    v_created := true;
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'student_enrolled', 'fyp_records', v_record_id,
          jsonb_build_object('student_id', p_user_id, 'course_code', v_course, 'semester_id', p_semester_id,
                             'record_created', v_created),
          'database_rpc', v_now);
  return jsonb_build_object('fyp_record_id', v_record_id, 'record_created', v_created);
end;
$$;

revoke execute on function public.enroll_student(uuid, text, text, text, text, uuid, text) from public, anon;
grant execute on function public.enroll_student(uuid, text, text, text, text, uuid, text) to authenticated;
