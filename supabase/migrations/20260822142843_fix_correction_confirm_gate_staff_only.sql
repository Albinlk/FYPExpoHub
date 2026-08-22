-- DEF-4 SECURITY: restrict confirm_fyp_corrections to assigned supervisor/examiner (staff only)
CREATE OR REPLACE FUNCTION public.confirm_fyp_corrections(p_correction_item_id uuid, p_comment text DEFAULT NULL::text)
RETURNS fyp_correction_confirmations
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
declare
  v_uid uuid := auth.uid();
  v_item public.fyp_correction_items%rowtype;
  v_fyp_record_id uuid;
  v_result public.fyp_correction_confirmations%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  select * into v_item from public.fyp_correction_items where id = p_correction_item_id;
  if not found then
    raise exception 'not-found: Correction item not found.' using errcode = 'P0002';
  end if;

  v_fyp_record_id := v_item.fyp_record_id;

  if not (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_assigned_to_fyp_record(v_fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(v_fyp_record_id, 'examiner')
  ) then
    raise exception 'permission-denied: Only the assigned supervisor or examiner can confirm corrections.' using errcode = '42501';
  end if;

  insert into public.fyp_correction_confirmations (correction_item_id, confirmed_by, confirmed_at, comment, created_at, updated_at)
  values (p_correction_item_id, v_uid, v_now, p_comment, v_now, v_now)
  returning * into v_result;

  update public.fyp_correction_items
  set status = case when v_item.status = 'open' then 'in_progress' else v_item.status end,
      updated_at = v_now
  where id = p_correction_item_id;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'correction_confirmed', 'fyp_correction_confirmations', v_result.id,
    jsonb_build_object('correction_item_id', p_correction_item_id), 'database_rpc', v_now);
  return v_result;
end;
$$;

GRANT EXECUTE ON FUNCTION public.confirm_fyp_corrections(uuid, text) TO anon, authenticated, service_role;
