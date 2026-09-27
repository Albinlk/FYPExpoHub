-- =============================================================================
-- Rubric editor and presentation session / slot edits (backlog U4, U5)
--
-- U4  save_rubric_version (coordinator): a new version of a form's rubric —
--     criteria (key, label, weight, 0-10 max, supervisor_only, clo) and the
--     evaluator shares. The previous version is deactivated, never changed:
--     every evaluation keeps pointing at the rubric version it was scored
--     with, so past marks are stable.
-- U5  update_presentation_session / delete_presentation_session /
--     delete_presentation_slot (course lecturer of the offering or
--     coordinator), audited. Deleting a session removes its slots.
-- =============================================================================

create or replace function public.save_rubric_version(
  p_form_code text,
  p_rubric_name text,
  p_criteria jsonb,
  p_evaluator_shares jsonb
)
returns public.fyp_rubric_templates
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_current public.fyp_rubric_templates%rowtype;
  v_result public.fyp_rubric_templates%rowtype;
  v_c jsonb;
  v_keys text[] := '{}';
  v_share record;
  v_roles text[];
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator edits rubrics.' using errcode = '42501';
  end if;
  v_roles := public.fyp_form_evaluator_roles(p_form_code);
  if cardinality(v_roles) = 0 then
    raise exception 'invalid-argument: % is not scored with a rubric.', p_form_code using errcode = '22023';
  end if;
  if nullif(btrim(p_rubric_name), '') is null then
    raise exception 'invalid-argument: The rubric needs a name.' using errcode = '22023';
  end if;
  if jsonb_typeof(p_criteria) <> 'array' or jsonb_array_length(p_criteria) = 0 or jsonb_array_length(p_criteria) > 30 then
    raise exception 'invalid-argument: A rubric needs 1–30 criteria.' using errcode = '22023';
  end if;

  for v_c in select * from jsonb_array_elements(p_criteria) loop
    if coalesce(v_c->>'key', '') !~ '^[a-z][a-z0-9_]{0,40}$' then
      raise exception 'invalid-argument: Criterion key "%" must be lower-case letters, digits or _.', v_c->>'key' using errcode = '22023';
    end if;
    if v_c->>'key' = any(v_keys) then
      raise exception 'invalid-argument: Criterion "%" appears twice.', v_c->>'key' using errcode = '22023';
    end if;
    v_keys := v_keys || (v_c->>'key');
    if nullif(btrim(v_c->>'label'), '') is null then
      raise exception 'invalid-argument: Every criterion needs a label.' using errcode = '22023';
    end if;
    if coalesce((v_c->>'weight')::numeric, 0) <= 0 or (v_c->>'weight')::numeric > 20 then
      raise exception 'invalid-argument: Weight for "%" must be between 0 and 20.', v_c->>'label' using errcode = '22023';
    end if;
    if coalesce((v_c->>'max')::numeric, 10) <> 10 then
      raise exception 'invalid-argument: Criteria are scored 0–10 (textbook scale).' using errcode = '22023';
    end if;
  end loop;

  -- Shares: flat {role: n} or per CLO {CLO1: {role: n}}; roles must be ones
  -- that evaluate this form; each share 0-100.
  if jsonb_typeof(p_evaluator_shares) <> 'object' then
    raise exception 'invalid-argument: Evaluator shares must be an object.' using errcode = '22023';
  end if;
  for v_share in
    select s.key as role, s.value as share from jsonb_each(p_evaluator_shares) s where jsonb_typeof(s.value) = 'number'
    union all
    select r.key, r.value from jsonb_each(p_evaluator_shares) g, jsonb_each(g.value) r where jsonb_typeof(g.value) = 'object'
  loop
    if not (v_share.role = any(v_roles)) then
      raise exception 'invalid-argument: % does not evaluate %.', v_share.role, p_form_code using errcode = '22023';
    end if;
    if jsonb_typeof(v_share.share) <> 'number' or (v_share.share)::text::numeric < 0 or (v_share.share)::text::numeric > 100 then
      raise exception 'invalid-argument: Shares must be 0–100.' using errcode = '22023';
    end if;
  end loop;

  select * into v_current from public.fyp_rubric_templates
  where form_code = p_form_code and is_active
  order by version desc limit 1;

  update public.fyp_rubric_templates set is_active = false, updated_at = v_now
  where form_code = p_form_code and is_active;

  insert into public.fyp_rubric_templates (rubric_code, rubric_name, form_code, criteria, evaluator_shares, version, is_active, created_at, updated_at)
  values (
    coalesce(v_current.rubric_code, p_form_code || '_RUBRIC'),
    btrim(p_rubric_name), p_form_code,
    (select jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
       'key', c->>'key', 'label', btrim(c->>'label'), 'weight', (c->>'weight')::numeric, 'max', 10,
       'supervisor_only', case when coalesce((c->>'supervisor_only')::boolean, false) then true end,
       'clo', nullif(btrim(coalesce(c->>'clo', '')), ''))))
     from jsonb_array_elements(p_criteria) c),
    p_evaluator_shares,
    coalesce((select max(version) from public.fyp_rubric_templates
              where rubric_code = coalesce(v_current.rubric_code, p_form_code || '_RUBRIC')), 0) + 1,
    true, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'rubric_version_saved', 'fyp_rubric_templates',
          v_result.id, jsonb_build_object('form_code', p_form_code, 'version', v_result.version), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.save_rubric_version(text, text, jsonb, jsonb) from public, anon;
grant execute on function public.save_rubric_version(text, text, jsonb, jsonb) to authenticated;

-- Who may manage a session: the offering's course lecturer or the coordinator.
create or replace function public.fyp_can_manage_session(p_session_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_fyp_coordinator() or exists (
    select 1 from public.fyp_presentation_sessions s
    join public.fyp_course_offerings o on o.id = s.offering_id
    where s.id = p_session_id and public.is_csp_lecturer(o.course_code)
  );
$$;

revoke execute on function public.fyp_can_manage_session(uuid) from public, anon;
grant execute on function public.fyp_can_manage_session(uuid) to authenticated;

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
  if coalesce(p_session_type, 'defence') not in ('defence', 'expo') then
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

revoke execute on function public.update_presentation_session(uuid, text, timestamptz, timestamptz, text, text) from public, anon;
grant execute on function public.update_presentation_session(uuid, text, timestamptz, timestamptz, text, text) to authenticated;

create or replace function public.delete_presentation_session(p_session_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_slots integer;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.fyp_can_manage_session(p_session_id) then
    raise exception 'permission-denied: Only the course lecturer or coordinator can delete this session.' using errcode = '42501';
  end if;
  select count(*) into v_slots from public.fyp_presentation_slots where session_id = p_session_id;
  delete from public.fyp_presentation_sessions where id = p_session_id;
  if not found then
    raise exception 'not-found: Session not found.' using errcode = 'P0002';
  end if;
  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'presentation_session_deleted',
          'fyp_presentation_sessions', p_session_id, jsonb_build_object('slots_removed', v_slots), 'database_rpc', v_now);
  return jsonb_build_object('session_id', p_session_id, 'slots_removed', v_slots);
end;
$$;

revoke execute on function public.delete_presentation_session(uuid) from public, anon;
grant execute on function public.delete_presentation_session(uuid) to authenticated;

create or replace function public.delete_presentation_slot(p_slot_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_slot public.fyp_presentation_slots%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  select * into v_slot from public.fyp_presentation_slots where id = p_slot_id;
  if not found then
    raise exception 'not-found: Slot not found.' using errcode = 'P0002';
  end if;
  if v_uid is null or not public.fyp_can_manage_session(v_slot.session_id) then
    raise exception 'permission-denied: Only the course lecturer or coordinator can remove slots.' using errcode = '42501';
  end if;
  delete from public.fyp_presentation_slots where id = p_slot_id;
  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid), 'presentation_slot_deleted',
          'fyp_presentation_slots', p_slot_id,
          jsonb_build_object('session_id', v_slot.session_id, 'fyp_record_id', v_slot.fyp_record_id), 'database_rpc', v_now);
  return jsonb_build_object('slot_id', p_slot_id);
end;
$$;

revoke execute on function public.delete_presentation_slot(uuid) from public, anon;
grant execute on function public.delete_presentation_slot(uuid) to authenticated;
