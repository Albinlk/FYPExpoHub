-- ==============================================================================
-- FYP Expo Hub - PostgreSQL Functions / RPC for Sensitive Operations
-- 20260814000003_rpc_functions.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. mark_student_project_visited
-- -----------------------------------------------------------------------------
create or replace function public.mark_student_project_visited(
  p_assignment_id uuid,
  p_visit_note text default null
)
returns public.student_project_visits
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles%rowtype;
  v_assignment public.lecturer_assignments%rowtype;
  v_settings jsonb;
  v_visit_tracker jsonb;
  v_visits_enabled boolean;
  v_existing public.student_project_visits%rowtype;
  v_result public.student_project_visits%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  -- 1. Verify user profile and active status
  select * into v_profile from public.profiles
  where id = v_uid and is_active = true;

  if not found then
    raise exception 'permission-denied: Active user profile not found.'
      using errcode = '42501';
  end if;

  -- 2. Verify assignment
  select * into v_assignment from public.lecturer_assignments
  where id = p_assignment_id and status = 'active';

  if not found then
    raise exception 'not-found: Active lecturer assignment not found.'
      using errcode = 'P0002';
  end if;

  if v_profile.role <> 'admin' and v_assignment.lecturer_id <> v_uid then
    raise exception 'permission-denied: You are not the assigned lecturer for this project.'
      using errcode = '42501';
  end if;

  -- 3. Check visit settings from public.settings
  select value into v_settings from public.settings where key = 'visit_tracker';
  if v_settings is not null then
    v_visits_enabled := coalesce((v_settings->>'visitsEnabled')::boolean, true);
    if not v_visits_enabled and v_profile.role <> 'admin' then
      raise exception 'failed-precondition: Student project visits are currently disabled.'
        using errcode = '55000';
    end if;
  end if;

  -- 4. Check existing visit record
  select * into v_existing from public.student_project_visits
  where event_id = v_assignment.event_id
    and project_id = v_assignment.project_id
    and lecturer_id = v_assignment.lecturer_id
    and visit_role = v_assignment.role;

  if found then
    if v_existing.status = 'completed' then
      raise exception 'already-exists: You have already marked this visit as completed.'
        using errcode = '23505';
    else
      -- Restore voided record
      update public.student_project_visits
      set
        status = 'completed',
        visited_at = v_now,
        visit_note = coalesce(p_visit_note, v_existing.visit_note),
        source = 'lecturer',
        voided_at = null,
        voided_by = null,
        voided_by_role = null,
        void_reason = null,
        updated_at = v_now
      where id = v_existing.id
      returning * into v_result;
    end if;
  else
    -- Insert new visit record
    insert into public.student_project_visits (
      event_id,
      project_id,
      assignment_id,
      lecturer_id,
      visit_role,
      status,
      visited_at,
      visit_note,
      source,
      created_at,
      updated_at
    ) values (
      v_assignment.event_id,
      v_assignment.project_id,
      v_assignment.id,
      v_assignment.lecturer_id,
      v_assignment.role,
      'completed',
      v_now,
      p_visit_note,
      'lecturer',
      v_now,
      v_now
    )
    returning * into v_result;
  end if;

  -- 5. Atomic audit logging
  insert into public.audit_logs (
    actor_uid,
    actor_role,
    action,
    target_type,
    target_id,
    event_id,
    metadata_safe,
    source,
    created_at
  ) values (
    v_uid,
    v_profile.role,
    'visit_marked',
    'student_project_visits',
    v_result.id,
    v_assignment.event_id,
    jsonb_build_object(
      'project_id', v_assignment.project_id,
      'assignment_id', v_assignment.id,
      'visit_role', v_assignment.role
    ),
    'database_rpc',
    v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 2. void_student_project_visit
-- -----------------------------------------------------------------------------
create or replace function public.void_student_project_visit(
  p_visit_id uuid,
  p_reason text
)
returns public.student_project_visits
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles%rowtype;
  v_visit public.student_project_visits%rowtype;
  v_result public.student_project_visits%rowtype;
  v_settings jsonb;
  v_undo_window integer := 30;
  v_diff_minutes numeric;
  v_now timestamptz := clock_timestamp();
  v_reason_clean text;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: Must be signed in.'
      using errcode = '28000';
  end if;

  v_reason_clean := trim(p_reason);
  if v_reason_clean is null or length(v_reason_clean) = 0 then
    raise exception 'invalid-argument: A non-empty reason is required to void a visit.'
      using errcode = '22023';
  end if;

  select * into v_profile from public.profiles
  where id = v_uid and is_active = true;

  if not found then
    raise exception 'permission-denied: Profile not active.'
      using errcode = '42501';
  end if;

  select * into v_visit from public.student_project_visits
  where id = p_visit_id;

  if not found then
    raise exception 'not-found: Visit record not found.'
      using errcode = 'P0002';
  end if;

  if v_visit.status <> 'completed' then
    raise exception 'failed-precondition: Visit has already been voided.'
      using errcode = '55000';
  end if;

  -- Undo window & permission enforcement
  if v_profile.role <> 'admin' then
    if v_visit.lecturer_id <> v_uid then
      raise exception 'permission-denied: You can only void your own visits.'
        using errcode = '42501';
    end if;

    select value into v_settings from public.settings where key = 'visit_tracker';
    if v_settings is not null and (v_settings->>'lecturerUndoWindowMinutes') is not null then
      v_undo_window := (v_settings->>'lecturerUndoWindowMinutes')::integer;
    end if;

    v_diff_minutes := extract(epoch from (v_now - v_visit.visited_at)) / 60.0;
    if v_diff_minutes > v_undo_window then
      raise exception 'failed-precondition: The %-minute window to undo this visit has expired.', v_undo_window
        using errcode = '55000';
    end if;
  end if;

  update public.student_project_visits
  set
    status = 'voided',
    voided_at = v_now,
    voided_by = v_uid,
    voided_by_role = v_profile.role,
    void_reason = v_reason_clean,
    updated_at = v_now
  where id = p_visit_id
  returning * into v_result;

  -- Atomic audit log
  insert into public.audit_logs (
    actor_uid,
    actor_role,
    action,
    target_type,
    target_id,
    event_id,
    metadata_safe,
    source,
    created_at
  ) values (
    v_uid,
    v_profile.role,
    'visit_voided',
    'student_project_visits',
    p_visit_id,
    v_visit.event_id,
    jsonb_build_object(
      'project_id', v_visit.project_id,
      'reason', v_reason_clean,
      'voided_by_role', v_profile.role
    ),
    'database_rpc',
    v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 3. publish_approved_import_changes
-- -----------------------------------------------------------------------------
create or replace function public.publish_approved_import_changes(
  p_import_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles%rowtype;
  v_import public.imports%rowtype;
  v_decision record;
  v_sch_candidate public.import_schedule_candidates%rowtype;
  v_aw_candidate public.import_award_candidates%rowtype;
  v_published_schedule_count integer := 0;
  v_published_awards_count integer := 0;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: Must be signed in.' using errcode = '28000';
  end if;

  select * into v_profile from public.profiles
  where id = v_uid and role = 'admin' and is_active = true;

  if not found then
    raise exception 'permission-denied: Only administrators can publish imports.' using errcode = '42501';
  end if;

  select * into v_import from public.imports where id = p_import_id;
  if not found then
    raise exception 'not-found: Import record not found.' using errcode = 'P0002';
  end if;

  -- Process explicit review decisions
  for v_decision in
    select * from public.import_review_decisions
    where import_id = p_import_id
  loop
    if v_decision.candidate_type = 'schedule' and v_decision.action in ('publish', 'replace_existing') then
      select * into v_sch_candidate from public.import_schedule_candidates
      where id = v_decision.candidate_id::uuid;

      if found then
        insert into public.schedule_items (
          event_id,
          day_label,
          event_date,
          start_at,
          end_at,
          title,
          description,
          venue,
          audience,
          access_type,
          publication_status,
          created_at,
          updated_at
        ) values (
          v_import.event_id,
          v_sch_candidate.day_label,
          coalesce(v_sch_candidate.event_date, current_date),
          coalesce(v_sch_candidate.start_at, v_now),
          coalesce(v_sch_candidate.end_at, v_now + interval '1 hour'),
          v_sch_candidate.title,
          coalesce(v_sch_candidate.description, 'Imported from Master File'),
          v_sch_candidate.venue,
          coalesce(v_sch_candidate.audience, 'General'),
          case when v_decision.action = 'mark_internal' then 'internal' else 'public' end,
          'published',
          v_now,
          v_now
        );
        v_published_schedule_count := v_published_schedule_count + 1;
      end if;

    elsif v_decision.candidate_type = 'award' and v_decision.action in ('publish', 'replace_existing') then
      select * into v_aw_candidate from public.import_award_candidates
      where id = v_decision.candidate_id::uuid;

      if found then
        insert into public.award_winners (
          event_id,
          title,
          project_id,
          team_display_name,
          supervisor_display_name,
          programme_code,
          publication_status,
          created_at,
          updated_at
        ) values (
          v_import.event_id,
          v_aw_candidate.award_category,
          null,
          v_aw_candidate.team_display_name,
          v_aw_candidate.supervisor_display_name,
          v_aw_candidate.programme_code,
          'published',
          v_now,
          v_now
        );
        v_published_awards_count := v_published_awards_count + 1;
      end if;
    end if;
  end loop;

  -- Update import log
  update public.imports
  set
    status = 'published',
    summary = jsonb_build_object(
      'published_schedules', v_published_schedule_count,
      'published_awards', v_published_awards_count
    ),
    completed_at = v_now,
    updated_at = v_now
  where id = p_import_id;

  -- Audit log
  insert into public.audit_logs (
    actor_uid,
    actor_role,
    action,
    target_type,
    target_id,
    event_id,
    import_id,
    metadata_safe,
    source,
    created_at
  ) values (
    v_uid,
    'admin',
    'import_published',
    'imports',
    p_import_id,
    v_import.event_id,
    p_import_id,
    jsonb_build_object(
      'published_schedules', v_published_schedule_count,
      'published_awards', v_published_awards_count
    ),
    'database_rpc',
    v_now
  );

  return jsonb_build_object(
    'import_id', p_import_id,
    'status', 'published',
    'published_schedules', v_published_schedule_count,
    'published_awards', v_published_awards_count
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- 4. create_lecturer_account_profile
-- -----------------------------------------------------------------------------
create or replace function public.create_lecturer_account_profile(
  p_user_id uuid,
  p_email text,
  p_display_name text
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.profiles%rowtype;
  v_now timestamptz := clock_timestamp();
  v_email_norm text := lower(trim(p_email));
  v_name_norm text := upper(trim(p_display_name));
begin
  v_uid := auth.uid();
  if v_uid is null or not public.is_admin() then
    raise exception 'permission-denied: Only administrators can create lecturer profiles.'
      using errcode = '42501';
  end if;

  insert into public.profiles (
    id,
    email,
    display_name,
    role,
    is_active,
    created_at,
    updated_at
  ) values (
    p_user_id,
    v_email_norm,
    v_name_norm,
    'lecturer',
    true,
    v_now,
    v_now
  )
  on conflict (id) do update set
    email = v_email_norm,
    display_name = v_name_norm,
    role = 'lecturer',
    is_active = true,
    updated_at = v_now
  returning * into v_result;

  -- Audit log
  insert into public.audit_logs (
    actor_uid,
    actor_role,
    action,
    target_type,
    target_id,
    metadata_safe,
    source,
    created_at
  ) values (
    v_uid,
    'admin',
    'lecturer_profile_created',
    'profiles',
    p_user_id,
    jsonb_build_object('email', v_email_norm, 'display_name', v_name_norm),
    'database_rpc',
    v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 5. update_event_configuration
-- -----------------------------------------------------------------------------
create or replace function public.update_event_configuration(
  p_event_id uuid,
  p_payload jsonb
)
returns public.events
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_result public.events%rowtype;
  v_start_at timestamptz;
  v_end_at timestamptz;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null or not public.is_admin() then
    raise exception 'permission-denied: Only administrators can update event configuration.'
      using errcode = '42501';
  end if;

  if p_payload ? 'start_at' and p_payload ? 'end_at' then
    v_start_at := (p_payload->>'start_at')::timestamptz;
    v_end_at := (p_payload->>'end_at')::timestamptz;
    if v_end_at <= v_start_at then
      raise exception 'invalid-argument: end_at must be strictly after start_at.'
        using errcode = '22023';
    end if;
  end if;

  update public.events
  set
    title = coalesce(p_payload->>'title', title),
    session_label = coalesce(p_payload->>'session_label', session_label),
    start_at = coalesce((p_payload->>'start_at')::timestamptz, start_at),
    end_at = coalesce((p_payload->>'end_at')::timestamptz, end_at),
    daily_hours = coalesce(p_payload->>'daily_hours', daily_hours),
    venue = coalesce(p_payload->>'venue', venue),
    location_details = coalesce(p_payload->>'location_details', location_details),
    map_url = coalesce(p_payload->>'map_url', map_url),
    description = coalesce(p_payload->>'description', description),
    objectives = case when p_payload ? 'objectives' then (p_payload->'objectives') else objectives end,
    status = coalesce(p_payload->>'status', status),
    publication_status = coalesce(p_payload->>'publication_status', publication_status),
    hero_image_url = coalesce(p_payload->>'hero_image_url', hero_image_url),
    poster_url = coalesce(p_payload->>'poster_url', poster_url),
    public_contact_email = coalesce(p_payload->>'public_contact_email', public_contact_email),
    faq_items = case when p_payload ? 'faq_items' then (p_payload->'faq_items') else faq_items end,
    updated_at = v_now,
    updated_by = v_uid
  where id = p_event_id
  returning * into v_result;

  -- Audit log
  insert into public.audit_logs (
    actor_uid,
    actor_role,
    action,
    target_type,
    target_id,
    event_id,
    metadata_safe,
    source,
    created_at
  ) values (
    v_uid,
    'admin',
    'event_updated',
    'events',
    p_event_id,
    p_event_id,
    jsonb_build_object('updated_fields', (select array_agg(key) from jsonb_each(p_payload))),
    'database_rpc',
    v_now
  );

  return v_result;
end;
$$;
