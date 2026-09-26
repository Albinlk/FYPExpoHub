-- ==============================================================================
-- FYP Expo Hub - Audit 2 hardening
-- 20260925000001_audit_2_hardening.sql
--
-- 1. stage_import(): stage an Excel import + all candidate rows atomically
-- 2. publish_approved_import_changes(): honour mark_internal / save_draft,
--    refuse double-publish, skip rows with no parsed time, keep the summary
-- 3. FYPMS: students can no longer INSERT workflow rows directly (bypassing
--    the audited submit_* RPCs with e.g. status = 'approved')
-- 4. fyp_course_offerings: only admins/coordinators create offerings
-- 5. profile_academic_roles: coordinators can't grant the coordinator role
-- 6. fyp_records: previous_record_id must belong to the same student
-- 7. Storage: students can't overwrite/delete a file once it's submitted
-- 8. feedback_entries: visitors can't set moderation fields; global throttle
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. stage_import
-- -----------------------------------------------------------------------------
-- SECURITY INVOKER: the admin-only RLS on imports/import_* still applies.
-- Being one plpgsql call, it's one transaction — a failure on any candidate
-- row rolls back the import record too (the client used to do 5 separate
-- inserts with no rollback). Columns are listed explicitly so NOT NULL
-- defaults apply to keys the client omits.
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
    auth.uid(),                       -- never trust the payload for this
    coalesce(i.status, 'pending_review'),
    coalesce(i.summary, '{}'::jsonb),
    coalesce(i.warnings_count, 0),
    coalesce(i.candidates_count, 0)
  from jsonb_populate_record(null::public.imports, p_import) i
  returning id into v_id;

  insert into public.import_schedule_candidates (
    id, import_id, row_number, day_label, event_date, start_at, end_at,
    raw_start_str, raw_end_str, title, description, venue, audience,
    access_type, comparison_status
  )
  select
    coalesce(c.id, gen_random_uuid()), v_id, c.row_number, c.day_label,
    c.event_date, c.start_at, c.end_at, c.raw_start_str, c.raw_end_str,
    c.title, c.description, c.venue, c.audience,
    coalesce(c.access_type, 'public'), coalesce(c.comparison_status, 'new')
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

-- -----------------------------------------------------------------------------
-- 2. publish_approved_import_changes
-- -----------------------------------------------------------------------------
-- Fixes over 20260814000003:
--   * 'mark_internal' was tested inside a branch that only ran for
--     publish/replace_existing, so it could never take effect
--   * 'save_draft' was ignored; it now publishes as a draft
--   * publishing the same import twice inserted every row again
--   * a candidate with no parsed time was published at clock_timestamp()
--     (i.e. "whenever the admin clicked Publish"); it's now skipped
--   * the import's summary (file hash, parser version...) was overwritten
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
      'skipped_incomplete', v_skipped
    ),
    'database_rpc', v_now
  );

  return jsonb_build_object(
    'import_id', p_import_id,
    'status', 'published',
    'published_schedules', v_schedules,
    'published_awards', v_awards,
    'skipped_incomplete', v_skipped
  );
end;
$$;

revoke execute on function public.publish_approved_import_changes(uuid) from public, anon;
-- Explicit: older projects got this from permissive default privileges,
-- but a fresh project (newer Supabase defaults) doesn't — the admin
-- publish button would fail with "permission denied for function".
grant execute on function public.publish_approved_import_changes(uuid) to authenticated;

-- -----------------------------------------------------------------------------
-- 3. FYPMS workflow rows: RPC-only inserts
-- -----------------------------------------------------------------------------
-- These policies only checked is_active_fyp_student(), not column values, so
-- a student could INSERT a report with status = 'approved', a progress log
-- with status = 'validated' and a forged validated_by, or an F14-F16 form
-- while the submit_fyp_form feature flag is off. The app never inserts into
-- these tables directly — every write goes through a SECURITY DEFINER
-- submit_* RPC (submit_supervision_request, submit_progress_log,
-- submit_fyp_form, submit_report_version, submit_deliverable), which
-- bypasses RLS — so the direct-insert path can simply go. (The matching
-- UPDATE policies were already dropped in 20260901000001.)
drop policy if exists "Requests created by student" on public.fyp_supervision_requests;
drop policy if exists "Progress logs created by student" on public.fyp_progress_logs;
drop policy if exists "Form submissions created by student" on public.fyp_form_submissions;
drop policy if exists "Reports created by student" on public.fyp_report_submissions;
drop policy if exists "Deliverables created by student" on public.fyp_deliverables;

-- -----------------------------------------------------------------------------
-- 4. fyp_course_offerings
-- -----------------------------------------------------------------------------
-- The old FOR ALL policy let ANY signed-in user insert an offering naming
-- themselves as lecturer (where none existed yet for that semester+course),
-- after which can_read_fyp_record() granted them every record and private
-- file in it. Creating/deleting offerings is now admin/coordinator only;
-- a lecturer may still update their own active offering.
drop policy if exists "Lecturers manage own offerings" on public.fyp_course_offerings;

create policy "Admins and coordinators manage offerings"
  on public.fyp_course_offerings for all
  using (public.is_admin() or public.is_fyp_coordinator())
  with check (public.is_admin() or public.is_fyp_coordinator());

create policy "Lecturers update own offerings"
  on public.fyp_course_offerings for update
  using (lecturer_id = auth.uid() and is_active = true)
  with check (lecturer_id = auth.uid());

-- -----------------------------------------------------------------------------
-- 5. profile_academic_roles
-- -----------------------------------------------------------------------------
-- Coordinators could grant any role — including fyp_coordinator — to anyone,
-- so one coordinator could mint more. Granting/revoking coordinator is now
-- admin-only (via "Admins manage academic roles").
drop policy if exists "Coordinators manage academic roles" on public.profile_academic_roles;

create policy "Coordinators manage non-coordinator roles"
  on public.profile_academic_roles for all
  using (public.is_fyp_coordinator() and role_code <> 'fyp_coordinator')
  with check (public.is_fyp_coordinator() and role_code <> 'fyp_coordinator');

-- -----------------------------------------------------------------------------
-- 6. fyp_records lineage
-- -----------------------------------------------------------------------------
-- create_fyp_record only checked that p_previous_record_id EXISTS, so a
-- record could be chained onto another student's history.
create or replace function public.enforce_fyp_record_lineage()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.previous_record_id is not null and not exists (
    select 1 from public.fyp_records p
    where p.id = new.previous_record_id
      and p.student_id = new.student_id
  ) then
    raise exception 'invalid-argument: The previous FYP record must belong to the same student.'
      using errcode = '22023';
  end if;

  -- A student registering THEMSELVES for CSP650 must continue their own
  -- CSP600 record (create_fyp_record let them skip straight to CSP650).
  -- Coordinators/admins can still create a CSP650 record without one — for
  -- students whose CSP600 predates this system.
  if tg_op = 'INSERT'
     and upper(new.current_course_code) = 'CSP650'
     and auth.uid() = new.student_id
     and not (public.is_admin() or public.is_fyp_coordinator())
     and not exists (
       select 1 from public.fyp_records p
       where p.id = new.previous_record_id
         and p.student_id = new.student_id
         and upper(p.current_course_code) = 'CSP600'
     ) then
    raise exception 'failed-precondition: To register for CSP650 yourself, continue your CSP600 record. If you did CSP600 before this system, ask your FYP coordinator to create your CSP650 record.'
      using errcode = '55000';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_fyp_records_lineage on public.fyp_records;
create trigger trg_fyp_records_lineage
  before insert or update of previous_record_id, student_id on public.fyp_records
  for each row execute function public.enforce_fyp_record_lineage();

-- -----------------------------------------------------------------------------
-- 7. Storage: submitted files are immutable for students
-- -----------------------------------------------------------------------------
-- can_write_fyp_storage_path() let the owning student UPDATE or DELETE any
-- object in their record's folder — including a report or deliverable
-- that was already submitted or approved. Uploads go to a fresh
-- {semester}/{record}/{type}/{version}/ path, so blocking changes to an
-- object once a submission row points at it doesn't affect new versions.
create or replace function public.fyp_storage_object_is_submitted(p_path text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.fyp_report_submissions s
    where s.file_url = p_path or s.file_url like '%/' || p_path
  ) or exists (
    select 1 from public.fyp_deliverables d
    where d.file_url = p_path or d.file_url like '%/' || p_path
  );
$$;

-- The storage policies below run these as the signed-in user. Older
-- projects got EXECUTE from permissive default privileges; granting it
-- explicitly keeps FYPMS file access working on a fresh project too.
revoke execute on function public.fyp_storage_object_is_submitted(text) from public, anon;
grant execute on function public.fyp_storage_object_is_submitted(text) to authenticated;
grant execute on function public.can_read_fyp_storage_path(text) to authenticated;
grant execute on function public.can_write_fyp_storage_path(text) to authenticated;

drop policy if exists "FYPMS update objects" on storage.objects;
drop policy if exists "FYPMS delete objects" on storage.objects;

create policy "FYPMS update objects"
  on storage.objects for update
  to authenticated
  using (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence')
    and public.can_write_fyp_storage_path(name)
    and (public.is_admin() or public.is_fyp_coordinator() or not public.fyp_storage_object_is_submitted(name))
  )
  with check (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence')
    and public.can_write_fyp_storage_path(name)
  );

create policy "FYPMS delete objects"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence')
    and public.can_write_fyp_storage_path(name)
    and (public.is_admin() or public.is_fyp_coordinator() or not public.fyp_storage_object_is_submitted(name))
  );

-- -----------------------------------------------------------------------------
-- 8. feedback_entries
-- -----------------------------------------------------------------------------
-- The public insert policy checked lengths only, so an anonymous insert
-- could set status = 'resolved', write an admin_note, or claim to be
-- submitted_by any profile.
drop policy if exists "Public can insert feedback" on public.feedback_entries;

create policy "Public can insert feedback"
  on public.feedback_entries for insert
  with check (
    length(subject) > 0 and length(subject) <= 200
    and length(message) > 0 and length(message) <= 2000
    and (rating is null or (rating >= 1 and rating <= 5))
    and status = 'new'
    and admin_note is null
    and (submitted_by is null or submitted_by = auth.uid())
  );

-- Coarse, site-wide throttle against scripted spam. Postgres can't see the
-- caller's IP, so this caps volume rather than singling out a sender; the
-- limit is far above what a real event's visitors produce.
create or replace function public.throttle_feedback_inserts()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if public.is_admin() then
    return new;
  end if;
  if (
    select count(*) from public.feedback_entries
    where created_at > now() - interval '1 minute'
  ) >= 30 then
    raise exception 'rate-limited: Too much feedback is being submitted right now. Please try again in a minute.'
      using errcode = '53400';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_feedback_throttle on public.feedback_entries;
create trigger trg_feedback_throttle
  before insert on public.feedback_entries
  for each row execute function public.throttle_feedback_inserts();
