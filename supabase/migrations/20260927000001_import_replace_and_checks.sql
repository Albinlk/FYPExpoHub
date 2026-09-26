-- =============================================================================
-- Master File import: real "Replace existing", and keep the check results
-- (known-gaps register G-06)
--
-- 1. publish_approved_import_changes treated 'replace_existing' exactly like
--    'publish' — a plain insert, so "replacing" a schedule slot left the old
--    one live beside the new one. Replace now first removes the live rows
--    the candidate matches, then inserts it:
--      schedule  same event and day, and the same title (case/spacing
--                ignored) OR the same venue at an overlapping time
--      awards    same event, the same award name and team
--    Rows inserted earlier in this same publish are never removed (they
--    have created_at = the publish time), so two "replace" rows for one
--    award don't delete each other. Counts go to the summary and audit log.
-- 2. stage_import dropped the client's is_duplicate / is_overlapping /
--    overlap_details (columns existed, values were never copied).
-- =============================================================================

create or replace function public.stage_import(
  p_import jsonb,
  p_schedule_candidates jsonb default '[]'::jsonb,
  p_award_candidates jsonb default '[]'::jsonb,
  p_validation_issues jsonb default '[]'::jsonb,
  p_privacy_skips jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_id uuid;
begin
  if auth.uid() is null or not public.is_admin() then
    raise exception 'permission-denied: Only administrators can stage imports.'
      using errcode = '42501';
  end if;

  insert into public.imports (
    id, event_id, file_name, file_size_bytes, uploaded_by, status,
    summary, warnings_count, candidates_count
  )
  select
    coalesce(i.id, gen_random_uuid()),
    i.event_id,
    i.file_name,
    coalesce(i.file_size_bytes, 0),
    auth.uid(),
    coalesce(i.status, 'pending_review'),
    coalesce(i.summary, '{}'::jsonb),
    coalesce(i.warnings_count, 0),
    coalesce(i.candidates_count, 0)
  from jsonb_populate_record(null::public.imports, p_import) i
  returning id into v_id;

  insert into public.import_schedule_candidates (
    id, import_id, row_number, day_label, event_date, start_at, end_at,
    raw_start_str, raw_end_str, title, description, venue, audience,
    access_type, comparison_status, is_duplicate, is_overlapping, overlap_details
  )
  select
    coalesce(c.id, gen_random_uuid()), v_id, c.row_number, c.day_label,
    c.event_date, c.start_at, c.end_at, c.raw_start_str, c.raw_end_str,
    c.title, c.description, c.venue, c.audience,
    coalesce(c.access_type, 'public'), coalesce(c.comparison_status, 'new'),
    coalesce(c.is_duplicate, false), coalesce(c.is_overlapping, false), c.overlap_details
  from jsonb_populate_recordset(null::public.import_schedule_candidates, p_schedule_candidates) c;

  insert into public.import_award_candidates (
    id, import_id, row_number, award_category, project_title,
    team_display_name, supervisor_display_name, programme_code,
    comparison_status, is_skip
  )
  select
    coalesce(c.id, gen_random_uuid()), v_id, c.row_number, c.award_category,
    c.project_title, c.team_display_name, c.supervisor_display_name,
    c.programme_code, coalesce(c.comparison_status, 'new'),
    coalesce(c.is_skip, false)
  from jsonb_populate_recordset(null::public.import_award_candidates, p_award_candidates) c;

  insert into public.import_validation_issues (
    id, import_id, worksheet_name, row_number, issue_type, severity, message
  )
  select
    coalesce(v.id, gen_random_uuid()), v_id, v.worksheet_name,
    coalesce(v.row_number, 0), v.issue_type, coalesce(v.severity, 'warning'),
    v.message
  from jsonb_populate_recordset(null::public.import_validation_issues, p_validation_issues) v;

  insert into public.import_privacy_skips (
    id, import_id, sheet_name, row_number, field_name, reason, category,
    masked_preview
  )
  select
    coalesce(s.id, gen_random_uuid()), v_id, s.sheet_name,
    coalesce(s.row_number, 0), s.field_name, s.reason, s.category,
    s.masked_preview
  from jsonb_populate_recordset(null::public.import_privacy_skips, p_privacy_skips) s;

  return v_id;
end;
$$;

revoke execute on function public.stage_import(jsonb, jsonb, jsonb, jsonb, jsonb) from public, anon;
grant execute on function public.stage_import(jsonb, jsonb, jsonb, jsonb, jsonb) to authenticated;

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
  v_import public.imports%rowtype;
  v_decision record;
  v_sch public.import_schedule_candidates%rowtype;
  v_aw public.import_award_candidates%rowtype;
  v_schedules integer := 0;
  v_awards integer := 0;
  v_skipped integer := 0;
  v_replaced_schedules integer := 0;
  v_replaced_awards integer := 0;
  v_n integer;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: Must be signed in.' using errcode = '28000';
  end if;
  if not exists (
    select 1 from public.profiles where id = v_uid and role = 'admin' and is_active = true
  ) then
    raise exception 'permission-denied: Only administrators can publish imports.' using errcode = '42501';
  end if;

  select * into v_import from public.imports where id = p_import_id for update;
  if not found then
    raise exception 'not-found: Import record not found.' using errcode = 'P0002';
  end if;
  if v_import.status = 'published' then
    raise exception 'failed-precondition: This import has already been published.' using errcode = '55000';
  end if;

  for v_decision in
    select * from public.import_review_decisions where import_id = p_import_id
  loop
    if v_decision.candidate_type = 'schedule'
       and v_decision.action in ('publish', 'replace_existing', 'mark_internal', 'save_draft') then
      select * into v_sch from public.import_schedule_candidates
      where id = v_decision.candidate_id::uuid and import_id = p_import_id;
      if not found then continue; end if;

      if v_sch.event_date is null or v_sch.start_at is null or v_sch.end_at is null then
        v_skipped := v_skipped + 1;
        continue;
      end if;

      if v_decision.action = 'replace_existing' then
        delete from public.schedule_items si
        where si.event_id = v_import.event_id
          and si.event_date = v_sch.event_date
          and si.created_at < v_now
          and (
            lower(regexp_replace(btrim(si.title), '\s+', ' ', 'g'))
              = lower(regexp_replace(btrim(v_sch.title), '\s+', ' ', 'g'))
            or (
              nullif(lower(btrim(coalesce(si.venue, ''))), '') = lower(btrim(coalesce(v_sch.venue, '')))
              and si.start_at < v_sch.end_at and si.end_at > v_sch.start_at
            )
          );
        get diagnostics v_n = row_count;
        v_replaced_schedules := v_replaced_schedules + v_n;
      end if;

      insert into public.schedule_items (
        event_id, day_label, event_date, start_at, end_at, title, description,
        venue, audience, access_type, publication_status, created_at, updated_at
      ) values (
        v_import.event_id, v_sch.day_label, v_sch.event_date, v_sch.start_at,
        v_sch.end_at, v_sch.title,
        coalesce(v_sch.description, 'Imported from Master File'),
        v_sch.venue, coalesce(v_sch.audience, 'General'),
        case when v_decision.action = 'mark_internal' then 'internal' else coalesce(v_sch.access_type, 'public') end,
        case when v_decision.action = 'save_draft' then 'draft' else 'published' end,
        v_now, v_now
      );
      v_schedules := v_schedules + 1;

    elsif v_decision.candidate_type = 'award'
          and v_decision.action in ('publish', 'replace_existing', 'save_draft') then
      select * into v_aw from public.import_award_candidates
      where id = v_decision.candidate_id::uuid and import_id = p_import_id;
      if not found then continue; end if;

      if v_decision.action = 'replace_existing' then
        delete from public.award_winners aw
        where aw.event_id = v_import.event_id
          and aw.created_at < v_now
          and lower(btrim(aw.title)) = lower(btrim(v_aw.award_category))
          and lower(btrim(coalesce(aw.team_display_name, ''))) = lower(btrim(coalesce(v_aw.team_display_name, '')));
        get diagnostics v_n = row_count;
        v_replaced_awards := v_replaced_awards + v_n;
      end if;

      insert into public.award_winners (
        event_id, title, project_id, team_display_name, supervisor_display_name,
        programme_code, publication_status, created_at, updated_at
      ) values (
        v_import.event_id, v_aw.award_category, null, v_aw.team_display_name,
        v_aw.supervisor_display_name, v_aw.programme_code,
        case when v_decision.action = 'save_draft' then 'draft' else 'published' end,
        v_now, v_now
      );
      v_awards := v_awards + 1;
    end if;
  end loop;

  update public.imports
  set status = 'published',
      summary = coalesce(summary, '{}'::jsonb) || jsonb_build_object(
        'published_schedules', v_schedules,
        'published_awards', v_awards,
        'replaced_schedules', v_replaced_schedules,
        'replaced_awards', v_replaced_awards,
        'skipped_incomplete', v_skipped
      ),
      completed_at = v_now,
      updated_at = v_now
  where id = p_import_id;

  insert into public.audit_logs (
    actor_uid, actor_role, action, target_type, target_id, event_id,
    import_id, metadata_safe, source, created_at
  ) values (
    v_uid, 'admin', 'import_published', 'imports', p_import_id,
    v_import.event_id, p_import_id,
    jsonb_build_object(
      'published_schedules', v_schedules,
      'published_awards', v_awards,
      'replaced_schedules', v_replaced_schedules,
      'replaced_awards', v_replaced_awards,
      'skipped_incomplete', v_skipped
    ),
    'database_rpc', v_now
  );

  return jsonb_build_object(
    'import_id', p_import_id,
    'status', 'published',
    'published_schedules', v_schedules,
    'published_awards', v_awards,
    'replaced_schedules', v_replaced_schedules,
    'replaced_awards', v_replaced_awards,
    'skipped_incomplete', v_skipped
  );
end;
$$;

revoke execute on function public.publish_approved_import_changes(uuid) from public, anon;
grant execute on function public.publish_approved_import_changes(uuid) to authenticated;
