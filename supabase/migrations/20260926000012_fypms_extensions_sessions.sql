-- =============================================================================
-- FYPMS workflows without a UI (known-gaps register G-25)
--
-- 1. Milestone extensions. grant_milestone_extension inserted a NEW row for
--    every call, so a lecturer "approving" a request left the student's
--    pending row pending and created a second, decided one. Requests and
--    decisions are now separate:
--      request_milestone_extension  record owner; one pending per milestone;
--                                   new date must be later than the current
--                                   target and not in the past (MYT)
--      decide_milestone_extension   CSP lecturer of the record's course or
--                                   coordinator; decides the pending row; an
--                                   approval moves the milestone target date
-- 2. Presentation sessions had no audited create path (only a broad RLS
--    policy). create_presentation_session validates and audits it.
-- 3. Students could read their own slot but not its session (date, venue):
--    sessions are now also readable by whoever can read a record slotted in
--    them.
-- =============================================================================

create or replace function public.request_milestone_extension(
  p_milestone_id uuid,
  p_reason text,
  p_requested_due_date date
)
returns public.fyp_milestone_extensions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_milestone public.fyp_milestones%rowtype;
  v_result public.fyp_milestone_extensions%rowtype;
  v_today date := (now() at time zone 'Asia/Kuala_Lumpur')::date;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_milestone from public.fyp_milestones where id = p_milestone_id;
  if not found then
    raise exception 'not-found: Milestone not found.'
      using errcode = 'P0002';
  end if;

  if not public.is_active_fyp_student(v_milestone.fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can request an extension.'
      using errcode = '42501';
  end if;

  if v_milestone.status = 'completed' then
    raise exception 'failed-precondition: This milestone is already completed.'
      using errcode = '55000';
  end if;

  if nullif(btrim(p_reason), '') is null then
    raise exception 'invalid-argument: A reason is required.'
      using errcode = '22023';
  end if;

  if p_requested_due_date is null or p_requested_due_date < v_today then
    raise exception 'invalid-argument: The new date cannot be in the past.'
      using errcode = '22023';
  end if;

  if v_milestone.target_date is not null and p_requested_due_date <= v_milestone.target_date then
    raise exception 'invalid-argument: The new date must be after the current target (%).',
      to_char(v_milestone.target_date, 'DD Mon YYYY')
      using errcode = '22023';
  end if;

  if exists (
    select 1 from public.fyp_milestone_extensions
    where milestone_id = p_milestone_id and status = 'pending'
  ) then
    raise exception 'already-exists: An extension request for this milestone is already pending.'
      using errcode = '23505';
  end if;

  insert into public.fyp_milestone_extensions (
    milestone_id, requested_by, reason, requested_due_date, status, created_at, updated_at
  ) values (
    p_milestone_id, v_uid, btrim(p_reason), p_requested_due_date, 'pending', v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'milestone_extension_requested', 'fyp_milestone_extensions', v_result.id,
    jsonb_build_object('milestone_id', p_milestone_id, 'requested_due_date', p_requested_due_date),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.request_milestone_extension(uuid, text, date) from public, anon;
grant execute on function public.request_milestone_extension(uuid, text, date) to authenticated;

create or replace function public.decide_milestone_extension(
  p_extension_id uuid,
  p_decision text,
  p_comment text default null
)
returns public.fyp_milestone_extensions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_ext public.fyp_milestone_extensions%rowtype;
  v_milestone public.fyp_milestones%rowtype;
  v_result public.fyp_milestone_extensions%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_decision not in ('approved', 'rejected') then
    raise exception 'invalid-argument: Decision must be approved or rejected.'
      using errcode = '22023';
  end if;

  select * into v_ext from public.fyp_milestone_extensions where id = p_extension_id for update;
  if not found then
    raise exception 'not-found: Extension request not found.'
      using errcode = 'P0002';
  end if;

  select * into v_milestone from public.fyp_milestones where id = v_ext.milestone_id;

  if not (
    public.is_csp_lecturer((select current_course_code from public.fyp_records r where r.id = v_milestone.fyp_record_id))
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the CSP lecturer or coordinator can decide extensions.'
      using errcode = '42501';
  end if;

  if v_ext.status <> 'pending' then
    raise exception 'failed-precondition: This request has already been %.', v_ext.status
      using errcode = '55000';
  end if;

  if p_decision = 'rejected' and nullif(btrim(p_comment), '') is null then
    raise exception 'invalid-argument: Give the student a reason when rejecting.'
      using errcode = '22023';
  end if;

  update public.fyp_milestone_extensions
  set status = p_decision,
      decided_by = v_uid,
      decided_at = v_now,
      decision_comment = nullif(btrim(p_comment), ''),
      updated_at = v_now
  where id = p_extension_id
  returning * into v_result;

  if p_decision = 'approved' then
    update public.fyp_milestones
    set target_date = v_ext.requested_due_date,
        status = case when status = 'overdue' then 'in_progress' else status end,
        updated_at = v_now
    where id = v_ext.milestone_id;
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'milestone_extension_' || p_decision, 'fyp_milestone_extensions', p_extension_id,
    jsonb_build_object('milestone_id', v_ext.milestone_id, 'requested_due_date', v_ext.requested_due_date),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.decide_milestone_extension(uuid, text, text) from public, anon;
grant execute on function public.decide_milestone_extension(uuid, text, text) to authenticated;

create or replace function public.create_presentation_session(
  p_offering_id uuid,
  p_session_code text,
  p_session_title text,
  p_start_at timestamptz,
  p_end_at timestamptz,
  p_venue text default null,
  p_session_type text default 'defence'
)
returns public.fyp_presentation_sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_course text;
  v_result public.fyp_presentation_sessions%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select course_code into v_course from public.fyp_course_offerings where id = p_offering_id;
  if not found then
    raise exception 'not-found: Course offering not found.'
      using errcode = 'P0002';
  end if;

  if not (public.is_csp_lecturer(v_course) or public.is_fyp_coordinator()) then
    raise exception 'permission-denied: Only the course lecturer or coordinator can create sessions.'
      using errcode = '42501';
  end if;

  if nullif(btrim(p_session_code), '') is null or nullif(btrim(p_session_title), '') is null then
    raise exception 'invalid-argument: A session code and title are required.'
      using errcode = '22023';
  end if;

  if p_start_at is null or p_end_at is null or p_end_at <= p_start_at then
    raise exception 'invalid-argument: The session must end after it starts.'
      using errcode = '22023';
  end if;

  if coalesce(p_session_type, 'defence') not in ('defence', 'expo') then
    raise exception 'invalid-argument: Session type must be defence or expo.'
      using errcode = '22023';
  end if;

  if exists (
    select 1 from public.fyp_presentation_sessions
    where offering_id = p_offering_id and session_code = upper(btrim(p_session_code))
  ) then
    raise exception 'already-exists: Session % already exists for this course.', upper(btrim(p_session_code))
      using errcode = '23505';
  end if;

  insert into public.fyp_presentation_sessions (
    offering_id, session_code, session_title, event_date, start_at, end_at, venue, session_type,
    created_at, updated_at
  ) values (
    p_offering_id, upper(btrim(p_session_code)), btrim(p_session_title),
    (p_start_at at time zone 'Asia/Kuala_Lumpur')::date, p_start_at, p_end_at,
    nullif(btrim(p_venue), ''), coalesce(p_session_type, 'defence'), v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'presentation_session_created', 'fyp_presentation_sessions', v_result.id,
    jsonb_build_object('offering_id', p_offering_id, 'session_code', v_result.session_code),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.create_presentation_session(uuid, text, text, timestamptz, timestamptz, text, text) from public, anon;
grant execute on function public.create_presentation_session(uuid, text, text, timestamptz, timestamptz, text, text) to authenticated;

-- A student (or anyone who can read a record) may read the sessions that
-- record has a slot in. SECURITY DEFINER so the slot lookup does not
-- re-enter the slots policy, which itself reads sessions.
create or replace function public.fyp_can_read_presentation_session(p_session_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.fyp_presentation_slots sl
    where sl.session_id = p_session_id and public.can_read_fyp_record(sl.fyp_record_id)
  );
$$;

revoke execute on function public.fyp_can_read_presentation_session(uuid) from public, anon;
grant execute on function public.fyp_can_read_presentation_session(uuid) to authenticated;

drop policy if exists "Sessions read by slot holders" on public.fyp_presentation_sessions;
create policy "Sessions read by slot holders"
  on public.fyp_presentation_sessions for select
  to authenticated
  using (public.fyp_can_read_presentation_session(id));

-- 4. Explicit EXECUTE grants. The production project got these from its
--    older default privileges; a freshly created project (newer Supabase
--    defaults) does not, so these app RPCs and RLS helpers failed there
--    with "permission denied for function". Production is unchanged.
do $$
declare
  v_fn regprocedure;
begin
  for v_fn in
    select p.oid::regprocedure
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'archive_fyp_record', 'can_edit_fyp_record', 'can_manage_fyp_offering',
        'can_publish_fyp_record_to_expo', 'confirm_correction', 'create_correction_item',
        'create_fyp_record', 'create_lecturer_account_profile', 'create_or_update_milestone',
        'create_student_account_profile', 'finalize_marks', 'grant_milestone_extension',
        'has_academic_role_for_programme', 'is_active_profile', 'list_fyp_coordinators',
        'list_fyp_staff', 'list_fyp_students', 'list_supervisors_public',
        'publish_fyp_record_to_expo', 'review_progress_log', 'save_lean_canvas',
        'schedule_presentation_slot', 'update_event_configuration', 'validate_progress_log',
        'void_student_project_visit'
      )
  loop
    execute format('grant execute on function %s to authenticated', v_fn);
  end loop;
end;
$$;
