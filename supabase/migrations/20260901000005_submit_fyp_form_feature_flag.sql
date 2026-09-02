-- ==============================================================================
-- FYP Expo Hub - Server-side F14-F16 feature flag enforcement
-- 20260901000005_submit_fyp_form_feature_flag.sql
--
-- The F14-F16 ("special evaluation") forms were gated ONLY client-side via
-- the settings.fypms_features.special_evaluation_enabled flag read by the
-- Flutter app. A student could still submit F14/F15/F16 directly via the
-- REST RPC endpoint. This re-creates submit_fyp_form with the same body plus
-- a server-side check: F14/F15/F16 require the flag to be enabled.
-- ==============================================================================

create or replace function public.submit_fyp_form(
  p_fyp_record_id uuid,
  p_form_code text,
  p_payload jsonb,
  p_file_url text default null,
  p_similarity_index numeric default null
)
returns public.fyp_form_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_form public.fyp_form_submissions%rowtype;
  v_version integer;
  v_special_eval_enabled boolean;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_form_code not in ('F2', 'F3', 'F4', 'F6a', 'F7', 'F8', 'F9', 'F10', 'F11', 'F13', 'F14', 'F15', 'F16') then
    raise exception 'invalid-argument: Unsupported form code.'
      using errcode = '22023';
  end if;

  -- F14-F16 (special evaluation forms) require the feature flag enabled.
  if p_form_code in ('F14', 'F15', 'F16') then
    select coalesce((s.value ->> 'special_evaluation_enabled')::boolean, false)
      into v_special_eval_enabled
      from public.settings s
      where s.key = 'fypms_features';
    if not coalesce(v_special_eval_enabled, false) then
      raise exception 'permission-denied: Special evaluation forms (F14-F16) are not enabled.'
        using errcode = '42501';
    end if;
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit forms.'
      using errcode = '42501';
  end if;

  select coalesce(max(form_version), 0) + 1 into v_version
  from public.fyp_form_submissions
  where fyp_record_id = p_fyp_record_id and form_code = p_form_code;

  insert into public.fyp_form_submissions (
    fyp_record_id, form_code, form_version, payload, status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_form_code, v_version, coalesce(p_payload, '{}'::jsonb), 'submitted',
    v_uid, v_now, v_now, v_now
  )
  returning * into v_form;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_form_submitted', 'fyp_form_submissions', v_form.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'form_code', p_form_code, 'form_version', v_version, 'file_url', p_file_url),
    'database_rpc', v_now
  );

  return v_form;
end;
$$;
