-- F9 progress presentation sessions (portal plan P9).
--
-- FSKM handbook, Table 2.1 #39: the CSP650 Project lecturer evaluates each
-- student's progress presentation with F9. Sessions could only be a defence
-- or the exhibition ('defence' / 'expo'), so F9 had nowhere to be scheduled.
-- Adds 'progress' to the allowed session types (table check and both RPCs).

alter table public.fyp_presentation_sessions
  drop constraint if exists fyp_presentation_sessions_session_type_check;
alter table public.fyp_presentation_sessions
  add constraint fyp_presentation_sessions_session_type_check
  check (session_type in ('defence', 'expo', 'progress'));

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

  if coalesce(p_session_type, 'defence') not in ('defence', 'expo', 'progress') then
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

create or replace function public.update_presentation_session(
  p_session_id uuid,
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
  v_uid uuid := auth.uid();
  v_result public.fyp_presentation_sessions%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.fyp_can_manage_session(p_session_id) then
    raise exception 'permission-denied: Only the course lecturer or coordinator can edit this session.' using errcode = '42501';
  end if;
  if nullif(btrim(p_session_title), '') is null then
    raise exception 'invalid-argument: A title is required.' using errcode = '22023';
  end if;
  if p_start_at is null or p_end_at is null or p_end_at <= p_start_at then
    raise exception 'invalid-argument: The session must end after it starts.' using errcode = '22023';
  end if;
  if coalesce(p_session_type, 'defence') not in ('defence', 'expo', 'progress') then
    raise exception 'invalid-argument: Session type must be defence or expo.' using errcode = '22023';
  end if;

  update public.fyp_presentation_sessions
  set session_title = btrim(p_session_title),
      start_at = p_start_at,
      end_at = p_end_at,
      event_date = (p_start_at at time zone 'Asia/Kuala_Lumpur')::date,
      venue = nullif(btrim(p_venue), ''),
      session_type = coalesce(p_session_type, 'defence'),
      updated_at = v_now
  where id = p_session_id
  returning * into v_result;
  if not found then
    raise exception 'not-found: Session not found.' using errcode = 'P0002';
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'presentation_session_updated',
          'fyp_presentation_sessions', p_session_id, '{}'::jsonb, 'database_rpc', v_now);
  return v_result;
end;
$$;
