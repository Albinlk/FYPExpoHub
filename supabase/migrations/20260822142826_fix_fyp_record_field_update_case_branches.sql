-- DEF-2: Fix P0002 by replacing dynamic EXECUTE with explicit CASE branches
-- Using typed branches avoids search_path / trigger visibility issues and uuid cast hazards

CREATE OR REPLACE FUNCTION public.update_fyp_record_field(p_fyp_record_id uuid, p_field text, p_value text)
RETURNS fyp_records
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
declare
  v_uid uuid := auth.uid();
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.can_edit_fyp_record(p_fyp_record_id) then
    raise exception 'permission-denied: You do not have permission to edit this record.' using errcode = '42501';
  end if;

  CASE p_field
    WHEN 'project_title' THEN
      UPDATE public.fyp_records SET project_title = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'project_description' THEN
      UPDATE public.fyp_records SET project_description = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'project_type' THEN
      UPDATE public.fyp_records SET project_type = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'external_industry_partner' THEN
      UPDATE public.fyp_records SET external_industry_partner = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    ELSE
      raise exception 'invalid-argument: Field % is not editable.', p_field using errcode = '22023';
  END CASE;

  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'fyp_record_field_updated', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('field', p_field), 'database_rpc', v_now);
  return v_result;
end;
$$;

CREATE OR REPLACE FUNCTION public.admin_override_fyp_record_field(p_fyp_record_id uuid, p_field text, p_value text, p_reason text)
RETURNS fyp_records
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
declare
  v_uid uuid := auth.uid();
  v_result public.fyp_records%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not (public.is_admin() or public.is_fyp_coordinator()) then
    raise exception 'permission-denied: Only the coordinator or administrator can override record fields.' using errcode = '42501';
  end if;
  if trim(coalesce(p_reason, '')) = '' then
    raise exception 'invalid-argument: A mandatory reason is required for an override.' using errcode = '22023';
  end if;

  CASE p_field
    WHEN 'project_title' THEN
      UPDATE public.fyp_records SET project_title = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'project_description' THEN
      UPDATE public.fyp_records SET project_description = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'project_type' THEN
      UPDATE public.fyp_records SET project_type = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'external_industry_partner' THEN
      UPDATE public.fyp_records SET external_industry_partner = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'matric_id' THEN
      UPDATE public.fyp_records SET matric_id = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'programme_code' THEN
      UPDATE public.fyp_records SET programme_code = p_value, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'main_supervisor_id' THEN
      UPDATE public.fyp_records SET main_supervisor_id = p_value::uuid, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'co_supervisor_id' THEN
      UPDATE public.fyp_records SET co_supervisor_id = p_value::uuid, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    WHEN 'examiner_id' THEN
      UPDATE public.fyp_records SET examiner_id = p_value::uuid, updated_at = v_now WHERE id = p_fyp_record_id RETURNING * INTO v_result;
    ELSE
      raise exception 'invalid-argument: Field % is not supported for override.', p_field using errcode = '22023';
  END CASE;

  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'fyp_record_field_overridden', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('field', p_field, 'reason', p_reason), 'database_rpc', v_now);
  return v_result;
end;
$$;

GRANT EXECUTE ON FUNCTION public.update_fyp_record_field(uuid, text, text) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.admin_override_fyp_record_field(uuid, text, text, text) TO anon, authenticated, service_role;
