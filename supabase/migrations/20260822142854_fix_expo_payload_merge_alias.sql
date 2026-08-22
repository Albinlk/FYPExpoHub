-- DEF-5: Fix jsonb_each alias bug 42703 column "k" does not exist
CREATE OR REPLACE FUNCTION public.prepare_expo_publication(p_fyp_record_id uuid, p_event_id uuid, p_payload jsonb DEFAULT NULL::jsonb)
RETURNS fyp_expo_publications
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
declare
  v_uid uuid := auth.uid();
  v_record public.fyp_records%rowtype;
  v_event_ok boolean;
  v_student_profile public.profiles%rowtype;
  v_supervisor_name text;
  v_payload jsonb;
  v_safe jsonb;
  v_result public.fyp_expo_publications%rowtype;
  v_now timestamptz := clock_timestamp();
  v_public_keys constant text[] := array[
    'title', 'matric_id', 'programme_code', 'short_description', 'abstract',
    'category', 'student_team', 'supervisor_display_name', 'publication_status',
    'demo_url', 'video_url', 'repository_url', 'cover_image_url', 'booth_number'
  ];
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.can_publish_fyp_record_to_expo(p_fyp_record_id) then
    raise exception 'permission-denied: Only the coordinator or administrator can prepare publications.'
      using errcode = '42501';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  select exists (
    select 1 from public.events where id = p_event_id and publication_status = 'published'
  ) into v_event_ok;
  if not v_event_ok then
    raise exception 'not-found: Published event not found.'
      using errcode = 'P0002';
  end if;

  select * into v_student_profile from public.profiles where id = v_record.student_id;
  select display_name into v_supervisor_name from public.profiles where id = v_record.main_supervisor_id;

  v_payload := jsonb_build_object(
    'title', coalesce(v_record.project_title, ''),
    'matric_id', v_record.matric_id,
    'programme_code', v_record.programme_code,
    'short_description', left(coalesce(v_record.project_description, ''), 500),
    'abstract', v_record.project_description,
    'category', coalesce(v_record.project_type, ''),
    'student_team', jsonb_build_array(
      jsonb_build_object(
        'name', v_student_profile.display_name,
        'matric_id', v_record.matric_id,
        'programme_code', v_record.programme_code
      )
    ),
    'supervisor_display_name', v_supervisor_name,
    'publication_status', 'draft'
  );

  if p_payload is not null then
    select coalesce(jsonb_object_agg(k, v), '{}'::jsonb) into v_safe
    from jsonb_each(p_payload) AS e(k, v)
    where k = any (v_public_keys);
    v_payload := v_payload || v_safe;
  end if;

  insert into public.fyp_expo_publications (
    fyp_record_id, event_id, status, payload, prepared_by, prepared_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_event_id, 'ready', v_payload, v_uid, v_now, v_now, v_now
  )
  on conflict (fyp_record_id, event_id)
  do update set
    payload = excluded.payload,
    status = 'ready',
    prepared_by = v_uid,
    prepared_at = v_now,
    updated_at = v_now
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'expo_publication_prepared', 'fyp_expo_publications', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'event_id', p_event_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

GRANT EXECUTE ON FUNCTION public.prepare_expo_publication(uuid, uuid, jsonb) TO anon, authenticated, service_role;
