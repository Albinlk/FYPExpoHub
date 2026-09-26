-- =============================================================================
-- F1 Mutual Acceptance Form (FSKM FYP Text Book, 4th ed.)
--
-- F1 is an agreement the chosen supervisor (and co-supervisor, if any) signs
-- with the student; it names the project area and title. FYPMS only let an
-- already-assigned supervisor or the coordinator decide, so the supervisor the
-- student chose could never accept their own request, and the form had no
-- co-supervisor, area or title.
--
--   * fyp_supervision_requests gains preferred_co_supervisor_id, project_area,
--     project_title.
--   * submit_supervision_request: supervisor required (active `supervisor`
--     role); optional co-supervisor (supervisor / co_supervisor role, not the
--     same person); title required; one pending request per record; once a
--     supervisor is assigned, changes go through the coordinator (F1 terms).
--   * decide_supervision_request: the named supervisor may decide. Approval
--     assigns the supervisor, the co-supervisor (sets co_supervisor_id too)
--     and the project title.
--   * list_my_supervision_requests(): requests naming the caller, with the
--     student's name, so a supervisor sees them before being assigned.
-- =============================================================================

alter table public.fyp_supervision_requests
  add column if not exists preferred_co_supervisor_id uuid references public.profiles(id) on delete set null,
  add column if not exists project_area text,
  add column if not exists project_title text;

drop function if exists public.submit_supervision_request(uuid, uuid, text);

create function public.submit_supervision_request(
  p_fyp_record_id uuid,
  p_preferred_supervisor_id uuid default null,
  p_rationale text default null,
  p_preferred_co_supervisor_id uuid default null,
  p_project_area text default null,
  p_project_title text default null
)
returns public.fyp_supervision_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_record public.fyp_records%rowtype;
  v_title text := nullif(trim(p_project_title), '');
  v_area text := nullif(trim(p_project_area), '');
  v_result public.fyp_supervision_requests%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit a supervision request.'
      using errcode = '42501';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;

  if v_record.main_supervisor_id is not null then
    raise exception 'failed-precondition: A supervisor is already assigned; changes go through the FYP coordinator.'
      using errcode = '55000';
  end if;

  if exists (
    select 1 from public.fyp_supervision_requests
    where fyp_record_id = p_fyp_record_id and status = 'pending'
  ) then
    raise exception 'failed-precondition: This record already has a pending supervision request.'
      using errcode = '55000';
  end if;

  if p_preferred_supervisor_id is null then
    raise exception 'invalid-argument: Choose the supervisor who agreed to supervise you.'
      using errcode = '22023';
  end if;

  if not exists (
    select 1
    from public.profile_academic_roles r
    join public.profiles p on p.id = r.profile_id
    where r.profile_id = p_preferred_supervisor_id
      and r.role_code = 'supervisor' and r.is_active and p.is_active
  ) then
    raise exception 'invalid-argument: The chosen supervisor is not an active supervisor.'
      using errcode = '22023';
  end if;

  if p_preferred_co_supervisor_id is not null then
    if p_preferred_co_supervisor_id = p_preferred_supervisor_id then
      raise exception 'invalid-argument: The co-supervisor must be a different person.'
        using errcode = '22023';
    end if;
    if not exists (
      select 1
      from public.profile_academic_roles r
      join public.profiles p on p.id = r.profile_id
      where r.profile_id = p_preferred_co_supervisor_id
        and r.role_code in ('supervisor', 'co_supervisor') and r.is_active and p.is_active
    ) then
      raise exception 'invalid-argument: The chosen co-supervisor is not an active supervisor.'
        using errcode = '22023';
    end if;
  end if;

  if v_title is null then
    raise exception 'invalid-argument: Enter the project title agreed with the supervisor.'
      using errcode = '22023';
  end if;
  if length(v_title) > 300 or length(coalesce(v_area, '')) > 200 then
    raise exception 'invalid-argument: Project title is limited to 300 characters and area to 200.'
      using errcode = '22023';
  end if;

  insert into public.fyp_supervision_requests (
    fyp_record_id, preferred_supervisor_id, preferred_co_supervisor_id,
    project_area, project_title, rationale, status, created_at, updated_at
  ) values (
    p_fyp_record_id, p_preferred_supervisor_id, p_preferred_co_supervisor_id,
    v_area, v_title, nullif(trim(p_rationale), ''), 'pending', v_now, v_now
  )
  returning * into v_result;

  update public.fyp_records
  set workflow_status = 'supervision_requested', updated_at = v_now
  where id = p_fyp_record_id;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'supervision_request_submitted', 'fyp_supervision_requests', v_result.id,
    jsonb_build_object(
      'fyp_record_id', p_fyp_record_id,
      'preferred_supervisor_id', p_preferred_supervisor_id,
      'preferred_co_supervisor_id', p_preferred_co_supervisor_id
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

create or replace function public.decide_supervision_request(
  p_request_id uuid,
  p_decision text,
  p_decision_reason text default null
)
returns public.fyp_supervision_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_request public.fyp_supervision_requests%rowtype;
  v_record public.fyp_records%rowtype;
  v_result public.fyp_supervision_requests%rowtype;
  v_supervisor_id uuid;
  v_is_named boolean;
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

  select * into v_request from public.fyp_supervision_requests where id = p_request_id;
  if not found then
    raise exception 'not-found: Supervision request not found.'
      using errcode = 'P0002';
  end if;

  select * into v_record from public.fyp_records where id = v_request.fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  -- The supervisor the student named signs F1 (textbook); an assigned
  -- supervisor and the coordinator may also decide.
  v_is_named := v_request.preferred_supervisor_id = v_uid;

  if not (
    v_is_named
    or public.is_assigned_to_fyp_record(v_record.id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_record.id, 'co_supervisor')
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the chosen supervisor or the coordinator can decide this request.'
      using errcode = '42501';
  end if;

  if v_request.status <> 'pending' then
    raise exception 'failed-precondition: Request has already been decided.'
      using errcode = '55000';
  end if;

  update public.fyp_supervision_requests
  set status = p_decision,
      decided_by = v_uid,
      decided_at = v_now,
      decision_reason = nullif(trim(p_decision_reason), ''),
      updated_at = v_now
  where id = p_request_id
  returning * into v_result;

  if p_decision = 'approved' then
    if v_is_named
       or public.is_assigned_to_fyp_record(v_record.id, 'supervisor')
       or public.is_assigned_to_fyp_record(v_record.id, 'co_supervisor') then
      v_supervisor_id := v_uid;
    else
      v_supervisor_id := v_request.preferred_supervisor_id;
    end if;

    if v_supervisor_id is null then
      raise exception 'invalid-argument: No supervisor selected for this request.'
        using errcode = '22023';
    end if;

    update public.fyp_records
    set main_supervisor_id = v_supervisor_id,
        co_supervisor_id = coalesce(v_request.preferred_co_supervisor_id, co_supervisor_id),
        project_title = coalesce(v_request.project_title, project_title),
        workflow_status = 'supervision_approved',
        updated_at = v_now
    where id = v_request.fyp_record_id;

    insert into public.fyp_record_assignments (
      fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at,
      created_at, updated_at
    ) values (
      v_request.fyp_record_id, 'supervisor', v_supervisor_id, true, v_uid, v_now, v_now, v_now
    )
    on conflict (fyp_record_id, academic_role, lecturer_id)
    do update set is_active = true, updated_at = v_now;

    if v_request.preferred_co_supervisor_id is not null then
      insert into public.fyp_record_assignments (
        fyp_record_id, academic_role, lecturer_id, is_active, assigned_by, assigned_at,
        created_at, updated_at
      ) values (
        v_request.fyp_record_id, 'co_supervisor', v_request.preferred_co_supervisor_id, true,
        v_uid, v_now, v_now, v_now
      )
      on conflict (fyp_record_id, academic_role, lecturer_id)
      do update set is_active = true, updated_at = v_now;
    end if;
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'supervision_request_' || p_decision, 'fyp_supervision_requests', v_result.id,
    jsonb_build_object(
      'fyp_record_id', v_request.fyp_record_id,
      'supervisor_id', v_supervisor_id,
      'co_supervisor_id', case when p_decision = 'approved' then v_request.preferred_co_supervisor_id end,
      'decided_as', case when v_is_named then 'named_supervisor' else 'assigned_or_coordinator' end
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- Requests that name the caller as supervisor or co-supervisor, newest first,
-- with the student's display name and course (not otherwise readable before
-- the lecturer is assigned to the record).
create or replace function public.list_my_supervision_requests()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(jsonb_agg(row_to_json(x)::jsonb order by x.status <> 'pending', x.created_at desc), '[]'::jsonb)
  from (
    select q.*,
           case when q.preferred_supervisor_id = auth.uid() then 'supervisor' else 'co_supervisor' end as my_role,
           p.display_name as student_name,
           r.current_course_code as course_code,
           r.programme_code
    from public.fyp_supervision_requests q
    join public.fyp_records r on r.id = q.fyp_record_id
    left join public.profiles p on p.id = r.student_id
    where auth.uid() is not null
      and (q.preferred_supervisor_id = auth.uid() or q.preferred_co_supervisor_id = auth.uid())
  ) as x;
$$;

revoke execute on function public.submit_supervision_request(uuid, uuid, text, uuid, text, text) from public, anon;
revoke execute on function public.decide_supervision_request(uuid, text, text) from public, anon;
revoke execute on function public.list_my_supervision_requests() from public, anon;
grant execute on function public.submit_supervision_request(uuid, uuid, text, uuid, text, text) to authenticated;
grant execute on function public.decide_supervision_request(uuid, text, text) to authenticated;
grant execute on function public.list_my_supervision_requests() to authenticated;
