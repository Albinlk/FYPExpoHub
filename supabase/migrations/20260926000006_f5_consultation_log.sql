-- =============================================================================
-- F5 Proposal/Project In-Progress Form, one entry per consultation
-- (FSKM FYP Text Book, 4th ed.)
--
-- F5 is updated after each supervision meeting: date of meeting, completed
-- activity, next activity/comment, signed by the supervisor/co-supervisor;
-- the Academic Affairs Division requires 80 % attendance. FYPMS allowed one
-- log per week (unique record + week) and took the week from the browser,
-- which assumed a semester starting on 1 March.
--
--   * unique (record, week) becomes unique (record, meeting date), so several
--     consultations can fall in one week.
--   * submit_progress_log derives the week from the record's semester start
--     date and the meeting date; the meeting may not be in the future or
--     outside the semester. The week argument is only a fallback when the
--     semester has no dates.
-- =============================================================================

do $$
declare v_name text;
begin
  select conname into v_name
  from pg_constraint
  where conrelid = 'public.fyp_progress_logs'::regclass
    and contype = 'u'
    and pg_get_constraintdef(oid) = 'UNIQUE (fyp_record_id, week_number)';
  if v_name is not null then
    execute format('alter table public.fyp_progress_logs drop constraint %I', v_name);
  end if;
end $$;

alter table public.fyp_progress_logs
  drop constraint if exists fyp_progress_logs_record_meeting_date_key;
alter table public.fyp_progress_logs
  add constraint fyp_progress_logs_record_meeting_date_key unique (fyp_record_id, progress_date);

create or replace function public.submit_progress_log(
  p_fyp_record_id uuid,
  p_week_number integer,
  p_summary text,
  p_challenges text default null,
  p_next_plan text default null,
  p_progress_date date default null
)
returns public.fyp_progress_logs
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_date date := coalesce(p_progress_date, current_date);
  v_start date;
  v_end date;
  v_week integer;
  v_summary text := nullif(trim(p_summary), '');
  v_result public.fyp_progress_logs%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit progress logs.'
      using errcode = '42501';
  end if;

  if v_summary is null then
    raise exception 'invalid-argument: Describe the activity completed since the last meeting.'
      using errcode = '22023';
  end if;

  if v_date > current_date then
    raise exception 'invalid-argument: The meeting date cannot be in the future.'
      using errcode = '22023';
  end if;

  select s.start_date, s.end_date into v_start, v_end
  from public.fyp_records r
  join public.academic_semesters s on s.id = r.academic_semester_id
  where r.id = p_fyp_record_id;

  if v_start is not null then
    if v_date < v_start or (v_end is not null and v_date > v_end) then
      raise exception 'invalid-argument: The meeting date must fall within the semester (% to %).', v_start, v_end
        using errcode = '22023';
    end if;
    v_week := (v_date - v_start) / 7 + 1;
  else
    v_week := p_week_number;
  end if;

  if v_week is null or v_week <= 0 then
    raise exception 'invalid-argument: A positive week number is required.'
      using errcode = '22023';
  end if;

  if exists (
    select 1 from public.fyp_progress_logs
    where fyp_record_id = p_fyp_record_id and progress_date = v_date
  ) then
    raise exception 'failed-precondition: A consultation on % is already logged.', v_date
      using errcode = '55000';
  end if;

  insert into public.fyp_progress_logs (
    fyp_record_id, week_number, progress_date, summary, challenges, next_plan,
    status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, v_week, v_date, v_summary,
    nullif(trim(p_challenges), ''), nullif(trim(p_next_plan), ''),
    'submitted', v_uid, v_now, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'progress_log_submitted', 'fyp_progress_logs', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'week_number', v_week, 'meeting_date', v_date),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.submit_progress_log(uuid, integer, text, text, text, date) from public, anon;
grant execute on function public.submit_progress_log(uuid, integer, text, text, text, date) to authenticated;
