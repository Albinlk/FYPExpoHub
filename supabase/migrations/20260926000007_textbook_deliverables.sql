-- =============================================================================
-- CSP650 deliverables (FSKM FYP Text Book, 4th ed., Table 2.1 item 51 /
-- Table 2.3 item 32): the student submits to the Project lecturer
--   * FYP report incl. abstract and appendices, in .pdf AND .doc
--   * presentation slides
--   * poster
--   * all files related to the project development: raw data, system with
--     test data, instructions on system setup, .apk / .exe  (if relevant)
--
-- FYPMS accepted any type name, only a pasted URL, and always stored
-- is_required = false. submit_deliverable now:
--   * accepts the textbook types only (legacy rows are left untouched);
--   * marks the four always-required ones is_required = true;
--   * requires a file uploaded to the record's own folder for the report,
--     slides and poster; the "if relevant" items may instead be an https
--     link (large systems, repositories, datasets).
-- =============================================================================

create or replace function public.submit_deliverable(
  p_fyp_record_id uuid,
  p_deliverable_type text,
  p_title text,
  p_description text default null,
  p_file_url text default null
)
returns public.fyp_deliverables
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_type text := btrim(coalesce(p_deliverable_type, ''));
  v_title text := nullif(btrim(coalesce(p_title, '')), '');
  v_url text := nullif(btrim(coalesce(p_file_url, '')), '');
  v_required boolean;
  v_link_allowed boolean;
  v_result public.fyp_deliverables%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit deliverables.'
      using errcode = '42501';
  end if;

  if v_type not in (
    'final_report_pdf', 'final_report_doc', 'presentation_slides', 'poster',
    'raw_data', 'system_test_data', 'setup_instructions', 'executable'
  ) then
    raise exception 'invalid-argument: Unknown deliverable type %.', v_type
      using errcode = '22023';
  end if;

  v_required := v_type in ('final_report_pdf', 'final_report_doc', 'presentation_slides', 'poster');
  v_link_allowed := not v_required;

  if v_title is null then
    raise exception 'invalid-argument: Deliverable title is required.'
      using errcode = '22023';
  end if;

  if v_url is null then
    raise exception 'invalid-argument: Upload the file%.',
      case when v_link_allowed then ' or give a link' else '' end
      using errcode = '22023';
  end if;

  if v_url like 'http%' then
    if not v_link_allowed then
      raise exception 'invalid-argument: Upload the file itself for this deliverable (links are only for large "if relevant" items).'
        using errcode = '22023';
    end if;
    if v_url !~* '^https://[^/\s]+' then
      raise exception 'invalid-argument: Links must be https:// addresses.'
        using errcode = '22023';
    end if;
  elsif v_url not like '%/' || p_fyp_record_id::text || '/%' then
    raise exception 'invalid-argument: Files must be uploaded to this record''s folder.'
      using errcode = '22023';
  end if;

  update public.fyp_deliverables
  set version = version + 1,
      title = v_title,
      description = nullif(btrim(coalesce(p_description, '')), ''),
      file_url = v_url,
      is_required = v_required,
      submitted_by = v_uid,
      submitted_at = v_now,
      updated_at = v_now
  where fyp_record_id = p_fyp_record_id
    and deliverable_type = v_type
  returning * into v_result;

  if not found then
    insert into public.fyp_deliverables (
      fyp_record_id, deliverable_type, title, description, file_url, version,
      is_required, submitted_by, submitted_at, created_at, updated_at
    ) values (
      p_fyp_record_id, v_type, v_title, nullif(btrim(coalesce(p_description, '')), ''), v_url, 1,
      v_required, v_uid, v_now, v_now, v_now
    )
    returning * into v_result;
  end if;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_deliverable_submitted', 'fyp_deliverables', v_result.id,
    jsonb_build_object(
      'fyp_record_id', p_fyp_record_id,
      'deliverable_type', v_type,
      'version', v_result.version,
      'is_link', v_url like 'http%'
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.submit_deliverable(uuid, text, text, text, text) from public, anon;
grant execute on function public.submit_deliverable(uuid, text, text, text, text) to authenticated;
