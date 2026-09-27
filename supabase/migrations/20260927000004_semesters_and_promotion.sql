-- =============================================================================
-- Semesters, courses, offerings and CSP600 -> CSP650 promotion
-- (backlog S1, S3, S5)
--
-- academic_semesters / academic_courses / fyp_course_offerings existed but
-- had no managed write path, so a new semester or intake meant editing the
-- database. These audited RPCs are the coordinator's tools:
--
--   create_academic_semester      new semester (planned)
--   set_academic_semester_status  planned -> active -> completed -> archived;
--                                 activating one completes the previously
--                                 active semester, so exactly one is active
--   update_academic_course        name / credit hours / active flag
--   upsert_course_offering        who teaches CSP600 / CSP650 in a semester
--   promote_fyp_record            creates the student's CSP650 record in a
--                                 later semester from a CSP600 record whose
--                                 marks are finalized and not failed,
--                                 carrying programme, title and the
--                                 supervisor / co-supervisor / examiner
--
-- Past semesters are never deleted: records, marks and files keep their
-- semester, and archived semesters stay readable.
-- =============================================================================

create unique index if not exists academic_semesters_one_active
  on public.academic_semesters ((true)) where status = 'active';

create or replace function public.create_academic_semester(
  p_code text,
  p_label text,
  p_start_date date,
  p_end_date date
)
returns public.academic_semesters
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_code text := upper(btrim(coalesce(p_code, '')));
  v_result public.academic_semesters%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator manages semesters.' using errcode = '42501';
  end if;
  if v_code !~ '^[A-Z0-9_-]{3,20}$' then
    raise exception 'invalid-argument: Use a short code such as 2026_2 (letters, digits, _ or -).' using errcode = '22023';
  end if;
  if nullif(btrim(p_label), '') is null then
    raise exception 'invalid-argument: A label is required.' using errcode = '22023';
  end if;
  if p_start_date is null or p_end_date is null or p_end_date < p_start_date then
    raise exception 'invalid-argument: The semester must end after it starts.' using errcode = '22023';
  end if;
  if exists (select 1 from public.academic_semesters where code = v_code) then
    raise exception 'already-exists: Semester % already exists.', v_code using errcode = '23505';
  end if;
  if exists (
    select 1 from public.academic_semesters
    where status <> 'archived' and p_start_date <= end_date and p_end_date >= start_date
  ) then
    raise exception 'invalid-argument: The dates overlap another semester.' using errcode = '22023';
  end if;

  insert into public.academic_semesters (code, label, status, start_date, end_date, created_at, updated_at)
  values (v_code, btrim(p_label), 'planned', p_start_date, p_end_date, v_now, v_now)
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'semester_created', 'academic_semesters',
          v_result.id, jsonb_build_object('code', v_code), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.create_academic_semester(text, text, date, date) from public, anon;
grant execute on function public.create_academic_semester(text, text, date, date) to authenticated;

create or replace function public.set_academic_semester_status(
  p_semester_id uuid,
  p_status text
)
returns public.academic_semesters
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_sem public.academic_semesters%rowtype;
  v_result public.academic_semesters%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator manages semesters.' using errcode = '42501';
  end if;
  select * into v_sem from public.academic_semesters where id = p_semester_id for update;
  if not found then
    raise exception 'not-found: Semester not found.' using errcode = 'P0002';
  end if;
  if p_status not in ('planned', 'active', 'completed', 'archived') then
    raise exception 'invalid-argument: Unknown semester status.' using errcode = '22023';
  end if;
  -- Allowed moves; a completed semester may be re-opened (active) or archived.
  if not (
    (v_sem.status = 'planned' and p_status = 'active')
    or (v_sem.status = 'active' and p_status = 'completed')
    or (v_sem.status = 'completed' and p_status in ('active', 'archived'))
    or (v_sem.status = 'archived' and p_status = 'completed')
  ) then
    raise exception 'failed-precondition: The semester is % and cannot become %.', v_sem.status, p_status using errcode = '55000';
  end if;

  if p_status = 'active' then
    update public.academic_semesters set status = 'completed', updated_at = v_now
    where status = 'active' and id <> p_semester_id;
  end if;

  update public.academic_semesters set status = p_status, updated_at = v_now
  where id = p_semester_id
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'semester_status_changed', 'academic_semesters',
          p_semester_id, jsonb_build_object('from', v_sem.status, 'to', p_status), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.set_academic_semester_status(uuid, text) from public, anon;
grant execute on function public.set_academic_semester_status(uuid, text) to authenticated;

create or replace function public.update_academic_course(
  p_code text,
  p_name text,
  p_credit_hours integer,
  p_is_active boolean
)
returns public.academic_courses
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_result public.academic_courses%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator manages courses.' using errcode = '42501';
  end if;
  if nullif(btrim(p_name), '') is null or p_credit_hours is null or p_credit_hours < 0 or p_credit_hours > 20 then
    raise exception 'invalid-argument: Give the course a name and 0–20 credit hours.' using errcode = '22023';
  end if;

  update public.academic_courses
  set name = btrim(p_name), credit_hours = p_credit_hours, is_active = coalesce(p_is_active, true), updated_at = v_now
  where code = upper(btrim(p_code))
  returning * into v_result;
  if not found then
    raise exception 'not-found: Course not found.' using errcode = 'P0002';
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'course_updated', 'academic_courses',
          null, jsonb_build_object('code', v_result.code), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.update_academic_course(text, text, integer, boolean) from public, anon;
grant execute on function public.update_academic_course(text, text, integer, boolean) to authenticated;

create or replace function public.upsert_course_offering(
  p_semester_id uuid,
  p_course_code text,
  p_lecturer_id uuid,
  p_max_students integer default null,
  p_is_active boolean default true
)
returns public.fyp_course_offerings
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_course text := upper(btrim(coalesce(p_course_code, '')));
  v_result public.fyp_course_offerings%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator manages course offerings.' using errcode = '42501';
  end if;
  if not exists (select 1 from public.academic_semesters where id = p_semester_id and status <> 'archived') then
    raise exception 'not-found: Semester not found or archived.' using errcode = 'P0002';
  end if;
  if not exists (select 1 from public.academic_courses where code = v_course and is_active) then
    raise exception 'not-found: Course not found or inactive.' using errcode = 'P0002';
  end if;
  if p_lecturer_id is not null and not exists (select 1 from public.profiles where id = p_lecturer_id and is_active) then
    raise exception 'not-found: Lecturer profile not found or inactive.' using errcode = 'P0002';
  end if;
  if p_max_students is not null and p_max_students <= 0 then
    raise exception 'invalid-argument: The student limit must be positive.' using errcode = '22023';
  end if;

  insert into public.fyp_course_offerings (academic_semester_id, course_code, lecturer_id, is_active, max_students, created_at, updated_at)
  values (p_semester_id, v_course, p_lecturer_id, coalesce(p_is_active, true), p_max_students, v_now, v_now)
  on conflict (academic_semester_id, course_code) do update set
    lecturer_id = excluded.lecturer_id,
    is_active = excluded.is_active,
    max_students = excluded.max_students,
    updated_at = v_now
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'course_offering_saved', 'fyp_course_offerings',
          v_result.id, jsonb_build_object('course_code', v_course, 'lecturer_id', p_lecturer_id), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.upsert_course_offering(uuid, text, uuid, integer, boolean) from public, anon;
grant execute on function public.upsert_course_offering(uuid, text, uuid, integer, boolean) to authenticated;

create or replace function public.promote_fyp_record(
  p_fyp_record_id uuid,
  p_target_semester_id uuid
)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_src public.fyp_records%rowtype;
  v_target public.academic_semesters%rowtype;
  v_source_sem public.academic_semesters%rowtype;
  v_marks public.fyp_marks_summaries%rowtype;
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not (public.is_fyp_coordinator() or public.is_csp_lecturer('CSP600')) then
    raise exception 'permission-denied: Only the coordinator or CSP600 lecturer promotes students.' using errcode = '42501';
  end if;

  select * into v_src from public.fyp_records where id = p_fyp_record_id for update;
  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;
  if upper(v_src.current_course_code) <> 'CSP600' then
    raise exception 'failed-precondition: Only a CSP600 record can be promoted to CSP650.' using errcode = '55000';
  end if;
  if exists (select 1 from public.fyp_records where previous_record_id = v_src.id) then
    raise exception 'already-exists: This student already has a CSP650 record.' using errcode = '23505';
  end if;

  select * into v_marks from public.fyp_marks_summaries
  where fyp_record_id = v_src.id and course_code = 'CSP600' and is_finalized
  order by updated_at desc limit 1;
  if not found then
    raise exception 'failed-precondition: Finalize the CSP600 marks first.' using errcode = '55000';
  end if;
  if coalesce(v_marks.grade, 'F') = 'F' then
    raise exception 'failed-precondition: The student failed CSP600 and must repeat it.' using errcode = '55000';
  end if;

  select * into v_source_sem from public.academic_semesters where id = v_src.academic_semester_id;
  select * into v_target from public.academic_semesters where id = p_target_semester_id;
  if not found then
    raise exception 'not-found: Target semester not found.' using errcode = 'P0002';
  end if;
  if v_target.status not in ('planned', 'active') or v_target.start_date <= v_source_sem.start_date then
    raise exception 'invalid-argument: Choose a later semester that is planned or active.' using errcode = '22023';
  end if;

  insert into public.fyp_records (
    academic_semester_id, student_id, current_course_code, programme_code, matric_id,
    project_title, project_description, project_type, external_industry_partner,
    main_supervisor_id, co_supervisor_id, examiner_id, previous_record_id,
    workflow_status, created_at, updated_at
  ) values (
    p_target_semester_id, v_src.student_id, 'CSP650', v_src.programme_code, v_src.matric_id,
    v_src.project_title, v_src.project_description, v_src.project_type, v_src.external_industry_partner,
    v_src.main_supervisor_id, v_src.co_supervisor_id, v_src.examiner_id, v_src.id,
    'project_registered', v_now, v_now
  )
  returning * into v_result;

  -- Same supervisor / co-supervisor / examiner carry over.
  insert into public.fyp_record_assignments (fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at, created_at, updated_at)
  select v_result.id, a.academic_role, a.lecturer_id, true, v_uid, v_now, v_now, v_now
  from public.fyp_record_assignments a
  where a.fyp_record_id = v_src.id and a.is_active;

  update public.fyp_records
  set workflow_status = 'formulation_completed', updated_at = v_now
  where id = v_src.id and workflow_status not in ('project_archived', 'formulation_completed');

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'fyp_record_promoted', 'fyp_records',
          v_result.id, jsonb_build_object('from_record_id', v_src.id, 'semester_id', p_target_semester_id),
          'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.promote_fyp_record(uuid, uuid) from public, anon;
grant execute on function public.promote_fyp_record(uuid, uuid) to authenticated;
