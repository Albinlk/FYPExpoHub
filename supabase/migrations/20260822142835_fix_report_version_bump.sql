-- DEF-3: Fix version never increments (always 1 / 23505 on second)
CREATE OR REPLACE FUNCTION public.submit_report_version(p_fyp_record_id uuid, p_report_type text, p_file_url text, p_similarity_index numeric DEFAULT NULL::numeric)
RETURNS fyp_report_submissions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
declare
  v_uid uuid := auth.uid();
  v_result public.fyp_report_submissions%rowtype;
  v_now timestamptz := clock_timestamp();
  v_next integer;
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if p_report_type not in ('proposal', 'final') then
    raise exception 'invalid-argument: Report type must be proposal or final.' using errcode = '22023';
  end if;
  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit report versions.' using errcode = '42501';
  end if;

  PERFORM 1 FROM public.fyp_records WHERE id = p_fyp_record_id FOR UPDATE;
  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;

  SELECT COALESCE(MAX(version), 0) + 1 INTO v_next
  FROM public.fyp_report_submissions
  WHERE fyp_record_id = p_fyp_record_id AND report_type = p_report_type;

  insert into public.fyp_report_submissions (
    fyp_record_id, report_type, version, file_url, similarity_index, status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_report_type, v_next, p_file_url, p_similarity_index, 'submitted', v_uid, v_now, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'report_version_submitted', 'fyp_report_submissions', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'report_type', p_report_type, 'version', v_next), 'database_rpc', v_now);
  return v_result;
end;
$$;

GRANT EXECUTE ON FUNCTION public.submit_report_version(uuid, text, text, numeric) TO anon, authenticated, service_role;
