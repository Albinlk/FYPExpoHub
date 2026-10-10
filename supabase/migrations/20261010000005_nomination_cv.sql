-- Nomination CV and declaration (portal plan P13).
--
-- FSKM handbook, Appendix N: a supervisor, co-supervisor or examiner
-- nomination needs the nominee's CV (about two years of supervision history,
-- or the expertise of staff with none), and the nominee must not be a
-- relative or close friend of the student or of the other supervisors.
--
-- The nominating lecturer (the CSP lecturer of the record's course or the
-- FYP coordinator, the same people who may nominate) attaches the CV and
-- makes the declaration. The Programme Unit (PU) head sees both and can only
-- approve a pending nomination once both are there. Nominations already
-- approved are not touched.
--
-- 1. Private bucket fyp-nomination-cvs (PDF, 5 MB), object path
--    <assignment_id>/<file name>.
-- 2. fyp_record_assignments: cv_path, not_related_declared_at / _by.
-- 3. submit_nomination_documents (nominator), list_my_pending_nominations
--    (nominator), list_pending_nominations and decide_nomination (PU) updated.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fyp-nomination-cvs', 'fyp-nomination-cvs', false, 5242880, array['application/pdf'])
on conflict (id) do nothing;

alter table public.fyp_record_assignments
  add column if not exists cv_path text,
  add column if not exists not_related_declared_at timestamptz,
  add column if not exists not_related_declared_by uuid references public.profiles(id) on delete set null;

-- The assignment an object path belongs to (its first folder), or null.
create or replace function public.fyp_nomination_cv_assignment(p_name text)
returns uuid
language sql
immutable
set search_path = public
as $$
  select case
    when split_part(p_name, '/', 1) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
      then split_part(p_name, '/', 1)::uuid
    else null
  end
$$;

-- Caller may nominate on the assignment's record: its CSP lecturer or the coordinator.
create or replace function public.fyp_can_nominate_for_assignment(p_assignment_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.fyp_record_assignments a
    join public.fyp_records r on r.id = a.fyp_record_id
    where a.id = p_assignment_id
      and (public.is_csp_lecturer(r.current_course_code) or public.is_fyp_coordinator())
  );
$$;

-- Caller may read the CV: the nominator, the programme's PU, or the nominee.
create or replace function public.fyp_can_view_nomination_cv(p_assignment_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.fyp_can_nominate_for_assignment(p_assignment_id) or exists (
    select 1
    from public.fyp_record_assignments a
    join public.fyp_records r on r.id = a.fyp_record_id
    where a.id = p_assignment_id
      and (a.lecturer_id = auth.uid() or public.is_programme_head(r.programme_code))
  );
$$;

revoke execute on function public.fyp_nomination_cv_assignment(text) from public, anon;
grant execute on function public.fyp_nomination_cv_assignment(text) to authenticated;
revoke execute on function public.fyp_can_nominate_for_assignment(uuid) from public, anon;
grant execute on function public.fyp_can_nominate_for_assignment(uuid) to authenticated;
revoke execute on function public.fyp_can_view_nomination_cv(uuid) from public, anon;
grant execute on function public.fyp_can_view_nomination_cv(uuid) to authenticated;

drop policy if exists "Nomination CVs read" on storage.objects;
drop policy if exists "Nomination CVs insert" on storage.objects;
drop policy if exists "Nomination CVs update" on storage.objects;
drop policy if exists "Nomination CVs delete" on storage.objects;

create policy "Nomination CVs read"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'fyp-nomination-cvs'
    and public.fyp_can_view_nomination_cv(public.fyp_nomination_cv_assignment(name))
  );

create policy "Nomination CVs insert"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'fyp-nomination-cvs'
    and public.fyp_can_nominate_for_assignment(public.fyp_nomination_cv_assignment(name))
  );

create policy "Nomination CVs update"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'fyp-nomination-cvs'
    and public.fyp_can_nominate_for_assignment(public.fyp_nomination_cv_assignment(name))
  )
  with check (
    bucket_id = 'fyp-nomination-cvs'
    and public.fyp_can_nominate_for_assignment(public.fyp_nomination_cv_assignment(name))
  );

create policy "Nomination CVs delete"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'fyp-nomination-cvs'
    and public.fyp_can_nominate_for_assignment(public.fyp_nomination_cv_assignment(name))
  );

-- The nominator attaches the CV (already uploaded) and declares the nominee
-- is not a relative or close friend.
create or replace function public.submit_nomination_documents(
  p_assignment_id uuid,
  p_cv_path text,
  p_not_related boolean
)
returns public.fyp_record_assignments
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_a public.fyp_record_assignments%rowtype;
  v_path text := nullif(btrim(p_cv_path), '');
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;

  select * into v_a from public.fyp_record_assignments where id = p_assignment_id for update;
  if not found then
    raise exception 'not-found: Nomination not found.' using errcode = 'P0002';
  end if;
  if not public.fyp_can_nominate_for_assignment(p_assignment_id) then
    raise exception 'permission-denied: Only the nominating lecturer or coordinator can attach the CV.'
      using errcode = '42501';
  end if;
  if not v_a.is_active then
    raise exception 'failed-precondition: This nomination is no longer active.' using errcode = '55000';
  end if;
  if v_path is null or public.fyp_nomination_cv_assignment(v_path) is distinct from p_assignment_id then
    raise exception 'invalid-argument: Upload the CV for this nomination first.' using errcode = '22023';
  end if;
  if not coalesce(p_not_related, false) then
    raise exception 'invalid-argument: Confirm the nominee is not a relative or close friend.' using errcode = '22023';
  end if;

  update public.fyp_record_assignments
  set cv_path = v_path,
      not_related_declared_at = v_now,
      not_related_declared_by = v_uid,
      updated_at = v_now
  where id = p_assignment_id
  returning * into v_a;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'nomination_documents_submitted', 'fyp_record_assignments', p_assignment_id,
    jsonb_build_object('fyp_record_id', v_a.fyp_record_id, 'academic_role', v_a.academic_role),
    'database_rpc', v_now);
  return v_a;
end;
$$;

revoke execute on function public.submit_nomination_documents(uuid, text, boolean) from public, anon;
grant execute on function public.submit_nomination_documents(uuid, text, boolean) to authenticated;

-- Nominations awaiting the PU on records the caller may nominate for.
create or replace function public.list_my_pending_nominations()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'assignment_id', a.id,
    'fyp_record_id', r.id,
    'academic_role', a.academic_role,
    'lecturer_id', a.lecturer_id,
    'lecturer_name', lp.display_name,
    'student_name', sp.display_name,
    'matric_id', r.matric_id,
    'programme_code', r.programme_code,
    'course_code', r.current_course_code,
    'project_title', r.project_title,
    'assigned_at', a.assigned_at,
    'cv_path', a.cv_path,
    'not_related_declared_at', a.not_related_declared_at
  ) order by a.assigned_at), '[]'::jsonb)
  from public.fyp_record_assignments a
  join public.fyp_records r on r.id = a.fyp_record_id
  left join public.profiles lp on lp.id = a.lecturer_id
  left join public.profiles sp on sp.id = r.student_id
  where a.is_active and a.pu_status = 'pending'
    and (public.is_csp_lecturer(r.current_course_code) or public.is_fyp_coordinator());
$$;

revoke execute on function public.list_my_pending_nominations() from public, anon;
grant execute on function public.list_my_pending_nominations() to authenticated;

-- PU list now carries the CV and declaration.
create or replace function public.list_pending_nominations()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'assignment_id', a.id,
    'fyp_record_id', r.id,
    'academic_role', a.academic_role,
    'lecturer_id', a.lecturer_id,
    'lecturer_name', lp.display_name,
    'student_name', sp.display_name,
    'matric_id', r.matric_id,
    'programme_code', r.programme_code,
    'course_code', r.current_course_code,
    'project_title', r.project_title,
    'assigned_at', a.assigned_at,
    'cv_path', a.cv_path,
    'not_related_declared_at', a.not_related_declared_at
  ) order by a.assigned_at), '[]'::jsonb)
  from public.fyp_record_assignments a
  join public.fyp_records r on r.id = a.fyp_record_id
  left join public.profiles lp on lp.id = a.lecturer_id
  left join public.profiles sp on sp.id = r.student_id
  where a.is_active and a.pu_status = 'pending'
    and public.is_programme_head(r.programme_code);
$$;

-- Approval now needs the CV and declaration (Appendix N); rejection does not.
create or replace function public.decide_nomination(
  p_assignment_id uuid,
  p_decision text,
  p_comment text default null
)
returns public.fyp_record_assignments
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_a public.fyp_record_assignments%rowtype;
  v_record public.fyp_records%rowtype;
  v_comment text := nullif(btrim(p_comment), '');
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if p_decision not in ('approved', 'rejected') then
    raise exception 'invalid-argument: Decision must be approved or rejected.' using errcode = '22023';
  end if;

  select * into v_a from public.fyp_record_assignments where id = p_assignment_id for update;
  if not found then
    raise exception 'not-found: Nomination not found.' using errcode = 'P0002';
  end if;
  select * into v_record from public.fyp_records where id = v_a.fyp_record_id;

  if not public.is_programme_head(v_record.programme_code) then
    raise exception 'permission-denied: Only the programme''s PU can approve nominations.' using errcode = '42501';
  end if;
  if not v_a.is_active or v_a.pu_status <> 'pending' then
    raise exception 'failed-precondition: This nomination is not awaiting approval.' using errcode = '55000';
  end if;
  if p_decision = 'rejected' and v_comment is null then
    raise exception 'invalid-argument: Give the coordinator a reason when rejecting.' using errcode = '22023';
  end if;
  if p_decision = 'approved' and (v_a.cv_path is null or v_a.not_related_declared_at is null) then
    raise exception 'failed-precondition: The nominating lecturer has not attached the CV and declaration yet.'
      using errcode = '55000';
  end if;

  update public.fyp_record_assignments
  set pu_status = p_decision,
      pu_decided_by = v_uid,
      pu_decided_at = v_now,
      pu_comment = v_comment,
      is_active = case when p_decision = 'rejected' then false else is_active end,
      updated_at = v_now
  where id = p_assignment_id
  returning * into v_a;

  -- A rejected nominee no longer holds the role on the record.
  if p_decision = 'rejected' then
    update public.fyp_records
    set main_supervisor_id = case when v_a.academic_role = 'supervisor' and main_supervisor_id = v_a.lecturer_id then null else main_supervisor_id end,
        co_supervisor_id = case when v_a.academic_role = 'co_supervisor' and co_supervisor_id = v_a.lecturer_id then null else co_supervisor_id end,
        examiner_id = case when v_a.academic_role = 'examiner' and examiner_id = v_a.lecturer_id then null else examiner_id end,
        updated_at = v_now
    where id = v_a.fyp_record_id;
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'nomination_' || p_decision, 'fyp_record_assignments', p_assignment_id,
    jsonb_build_object('fyp_record_id', v_a.fyp_record_id, 'academic_role', v_a.academic_role,
                       'lecturer_id', v_a.lecturer_id, 'comment', v_comment),
    'database_rpc', v_now);
  return v_a;
end;
$$;
