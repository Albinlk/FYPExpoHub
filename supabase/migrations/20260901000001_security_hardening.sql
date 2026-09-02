-- ==============================================================================
-- FYP Expo Hub - Security Hardening (P0 fixes from security audit)
-- 20260901000001_security_hardening.sql
--
-- Fixes:
--   1. HIGH  storage.objects SELECT policy "FYPMS read private buckets" had no
--            TO clause -> applied to PUBLIC (anon). Anon could list/download
--            every student's private FYP reports. Now: authenticated + must be
--            able to read the record that owns the storage path.
--   2. HIGH  storage INSERT/UPDATE allowed any active authenticated user to
--            write into ALL FYPMS buckets with no path scoping. Now scoped to
--            the caller's own record path; fyp-public-assets writes limited
--            to coordinator/admin.
--   3. HIGH  list_fyp_students / list_fyp_staff / list_fyp_coordinators had no
--            caller gate -> anon could bulk-dump student/staff PII. Now gated
--            to FYP coordinator / CSP lecturer / admin (the roles that use
--            the coordinator & CSP request-approval pickers).
--   4. HIGH  Column-unrestricted "edited by student" UPDATE policies let
--            students self-advance workflow_status and self-approve
--            submissions. Direct UPDATE removed; all edits go through the
--            audited SECURITY DEFINER RPCs (the Dart data layer is read-only).
--   5. MED   fyp_marks_summaries "managed by csp lecturer" FOR ALL bypassed
--            finalize_marks (weighted_total computation + is_finalized lock).
--            CSP lecturers keep SELECT only.
--   6. MED   fyp_correction_confirmations INSERT still allowed the student
--            owner (DEF-4 hardened the RPC, not the policy). Now staff-only.
--   7. MED   is_csp_lecturer() fell back to the CSP600 role for ANY unknown
--            course code -> latent bypass. Unknown codes now deny.
--   8. MED   finalize_marks never cross-checked the caller-supplied course
--            code against the record's actual course. Now enforced.
--   9. MED   fyp_presentation_sessions/slots were readable by ALL
--            authenticated users (leaks every record id). Now scoped to
--            participants + managing staff.
--  10. LOW  REVOKE EXECUTE on mutating/listing RPCs from PUBLIC and anon
--            (grants were '=X' to PUBLIC; each function still raises 28000 on
--            null auth.uid() as defense in depth).
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- 1. Storage path helpers
--    Path convention: {semester_code}/{fyp_record_id}/{resource_type}/{version}/{file_name}
-- -----------------------------------------------------------------------------

create or replace function public.can_read_fyp_storage_path(p_path text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select case
    when auth.uid() is null then false
    when public.is_admin() or public.is_fyp_coordinator() then true
    else exists (
      select 1
      from public.fyp_records r
      where r.id::text = split_part(p_path, '/', 2)
        and public.can_read_fyp_record(r.id)
    )
  end;
$$;

create or replace function public.can_write_fyp_storage_path(p_path text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select case
    when auth.uid() is null then false
    when public.is_admin() or public.is_fyp_coordinator() then true
    else exists (
      select 1
      from public.fyp_records r
      where r.id::text = split_part(p_path, '/', 2)
        and r.student_id = auth.uid()
    )
  end;
$$;

-- -----------------------------------------------------------------------------
-- 2. Private FYPMS buckets: path-scoped policies (replacing public-scoped ones)
-- -----------------------------------------------------------------------------

drop policy if exists "FYPMS read private buckets" on storage.objects;
drop policy if exists "FYPMS insert objects" on storage.objects;
drop policy if exists "FYPMS update objects" on storage.objects;
drop policy if exists "FYPMS delete objects" on storage.objects;

create policy "FYPMS read private buckets"
  on storage.objects for select
  to authenticated
  using (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence')
    and public.can_read_fyp_storage_path(name)
  );

create policy "FYPMS insert objects"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence')
    and public.can_write_fyp_storage_path(name)
  );

create policy "FYPMS update objects"
  on storage.objects for update
  to authenticated
  using (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence')
    and public.can_write_fyp_storage_path(name)
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
    and (public.is_admin() or public.is_fyp_coordinator())
  );

-- Public assets bucket: writes coordinator/admin-only (content is served on
-- the public site; students must not be able to replace it).
create policy "FYPMS public assets insert"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'fyp-public-assets'
    and (public.is_admin() or public.is_fyp_coordinator())
  );

create policy "FYPMS public assets update"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'fyp-public-assets'
    and (public.is_admin() or public.is_fyp_coordinator())
  )
  with check (
    bucket_id = 'fyp-public-assets'
    and (public.is_admin() or public.is_fyp_coordinator())
  );

-- -----------------------------------------------------------------------------
-- 3. Coordinator/CSP list helpers: add caller gates
-- -----------------------------------------------------------------------------

create or replace function public.list_fyp_students()
returns table (
  id uuid,
  display_name text,
  email text,
  matric_id text,
  programme_code text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    p.display_name,
    p.email,
    nullif(p.email, '') as matric_id,
    r.programme_code
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code = 'student'
    and r.is_active = true
    and (
      public.is_fyp_coordinator()
      or public.has_academic_role('csp600_lecturer')
      or public.has_academic_role('csp650_lecturer')
    )
  order by p.id, p.display_name;
$$;

create or replace function public.list_fyp_staff(p_role_codes text[] default array['supervisor','co_supervisor','examiner'])
returns table (
  id uuid,
  display_name text,
  email text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    p.display_name,
    p.email
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code = any(p_role_codes)
    and r.is_active = true
    and (
      public.is_fyp_coordinator()
      or public.has_academic_role('csp600_lecturer')
      or public.has_academic_role('csp650_lecturer')
    )
  order by p.id, p.display_name;
$$;

create or replace function public.list_fyp_coordinators()
returns table (
  id uuid,
  display_name text,
  email text
)
language sql
stable
security definer
set search_path = public
as $$
  select distinct on (p.id)
    p.id,
    p.display_name,
    p.email
  from public.profiles p
  join public.profile_academic_roles r on r.profile_id = p.id
  where p.is_active = true
    and r.role_code in ('fyp_coordinator')
    and r.is_active = true
    and (
      public.is_fyp_coordinator()
      or public.has_academic_role('csp600_lecturer')
      or public.has_academic_role('csp650_lecturer')
    )
  order by p.id, p.display_name;
$$;

-- -----------------------------------------------------------------------------
-- 4. Remove dangerous direct UPDATE/ALL policies (edits via RPCs only)
-- -----------------------------------------------------------------------------

drop policy if exists "Records edited by owner" on public.fyp_records;
drop policy if exists "Records edited by csp lecturer" on public.fyp_records;

drop policy if exists "Progress logs edited by student" on public.fyp_progress_logs;

drop policy if exists "Form submissions edited by student" on public.fyp_form_submissions;

drop policy if exists "Reports edited by student" on public.fyp_report_submissions;

drop policy if exists "Deliverables edited by student" on public.fyp_deliverables;

drop policy if exists "Canvases edited by student" on public.fyp_lean_canvases;

drop policy if exists "Marks managed by csp lecturer" on public.fyp_marks_summaries;
-- (existing "Marks read by record participants" SELECT policy remains)

drop policy if exists "Confirmations created by record participants" on public.fyp_correction_confirmations;
create policy "Confirmations created by staff"
  on public.fyp_correction_confirmations for insert
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_correction_items c
      where c.id = correction_item_id
        and (
          public.is_assigned_to_fyp_record(c.fyp_record_id, 'supervisor')
          or public.is_assigned_to_fyp_record(c.fyp_record_id, 'co_supervisor')
          or public.is_assigned_to_fyp_record(c.fyp_record_id, 'examiner')
        )
    )
  );

drop policy if exists "Extensions requested by record participants" on public.fyp_milestone_extensions;
create policy "Extensions requested by owner or csp"
  on public.fyp_milestone_extensions for insert
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or (
      requested_by = auth.uid()
      and exists (
        select 1 from public.fyp_milestones m
        where m.id = milestone_id
          and (
            public.is_active_fyp_student(m.fyp_record_id)
            or public.is_csp_lecturer(
              (select current_course_code from public.fyp_records r where r.id = m.fyp_record_id)
            )
          )
      )
    )
  );

-- Presentation sessions/slots: restrict record-id leak
drop policy if exists "Sessions read by authenticated" on public.fyp_presentation_sessions;
create policy "Sessions read by participants"
  on public.fyp_presentation_sessions for select
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select o.course_code from public.fyp_course_offerings o where o.id = offering_id)
    )
  );

drop policy if exists "Slots read by authenticated" on public.fyp_presentation_slots;
create policy "Slots read by participants"
  on public.fyp_presentation_slots for select
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (
        select o.course_code
        from public.fyp_presentation_sessions s
        join public.fyp_course_offerings o on o.id = s.offering_id
        where s.id = session_id
      )
    )
    or public.can_read_fyp_record(fyp_record_id)
  );

-- -----------------------------------------------------------------------------
-- 5. Helper hardening
-- -----------------------------------------------------------------------------

-- Unknown course codes no longer fall back to the CSP600 role check.
create or replace function public.is_csp_lecturer(p_course_code text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_admin()
    or exists (
      select 1 from public.profile_academic_roles
      where profile_id = auth.uid()
        and role_code = case upper(p_course_code)
          when 'CSP600' then 'csp600_lecturer'
          when 'CSP650' then 'csp650_lecturer'
          else null
        end
        and is_active = true
    );
$$;

-- -----------------------------------------------------------------------------
-- 6. finalize_marks: cross-check course code against the record's course
-- -----------------------------------------------------------------------------

create or replace function public.finalize_marks(
  p_fyp_record_id uuid,
  p_course_code text,
  p_component_breakdown jsonb
)
returns public.fyp_marks_summaries
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_record public.fyp_records%rowtype;
  v_result public.fyp_marks_summaries%rowtype;
  v_weighted_total numeric := 0;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_csp_lecturer(p_course_code) then
    raise exception 'permission-denied: Only the CSP lecturer can finalize marks.'
      using errcode = '42501';
  end if;

  if p_course_code not in ('CSP600', 'CSP650') then
    raise exception 'invalid-argument: Unsupported course code.'
      using errcode = '22023';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  -- Cross-check: the record must actually belong to the supplied course.
  if v_record.current_course_code <> p_course_code then
    raise exception 'permission-denied: Course code % does not match the record''s course (%).',
      p_course_code, v_record.current_course_code
      using errcode = '42501';
  end if;

  select coalesce(sum((v.value)::numeric), 0) into v_weighted_total
  from jsonb_each(coalesce(p_component_breakdown, '{}'::jsonb)) as v;

  if exists (
    select 1 from public.fyp_marks_summaries
    where fyp_record_id = p_fyp_record_id
      and academic_semester_id = v_record.academic_semester_id
      and course_code = p_course_code
      and is_finalized = true
  ) then
    raise exception 'failed-precondition: Marks are already finalized for this course.'
      using errcode = '55000';
  end if;

  insert into public.fyp_marks_summaries (
    fyp_record_id, academic_semester_id, course_code, marks, weighted_total, grade,
    is_finalized, finalized_by, finalized_at, export_payload, created_at, updated_at
  ) values (
    p_fyp_record_id, v_record.academic_semester_id, p_course_code,
    coalesce(p_component_breakdown, '{}'::jsonb),
    v_weighted_total, null, true, v_uid, v_now,
    jsonb_build_object(
      'fyp_record_id', p_fyp_record_id,
      'course_code', p_course_code,
      'weighted_total', v_weighted_total,
      'exported_at', v_now
    ),
    v_now, v_now
  )
  on conflict (fyp_record_id, academic_semester_id, course_code)
  do update set
    marks = excluded.marks,
    weighted_total = excluded.weighted_total,
    grade = excluded.grade,
    is_finalized = true,
    finalized_by = v_uid,
    finalized_at = v_now,
    export_payload = excluded.export_payload,
    updated_at = v_now
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'course_marks_finalized', 'fyp_marks_summaries', v_result.id,
    jsonb_build_object('course_code', p_course_code, 'weighted_total', v_weighted_total),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- -----------------------------------------------------------------------------
-- 7. Revoke PUBLIC/anon EXECUTE on mutating + listing RPCs (defense in depth)
-- -----------------------------------------------------------------------------

revoke execute on function public.update_fyp_record_field(uuid, text, text) from public, anon;
revoke execute on function public.admin_override_fyp_record_field(uuid, text, text, text) from public, anon;
revoke execute on function public.submit_report_version(uuid, text, text, numeric) from public, anon;
revoke execute on function public.confirm_fyp_corrections(uuid, text) from public, anon;
revoke execute on function public.prepare_expo_publication(uuid, uuid, jsonb) from public, anon;
revoke execute on function public.publish_fyp_record_to_expo(uuid) from public, anon;
revoke execute on function public.assign_supervisor_to_fyp_record(uuid, uuid, text) from public, anon;
revoke execute on function public.assign_examiner(uuid, uuid) from public, anon;
revoke execute on function public.finalize_marks(uuid, text, jsonb) from public, anon;
revoke execute on function public.schedule_presentation_slot(uuid, uuid, integer, timestamptz, timestamptz, text) from public, anon;
revoke execute on function public.create_fyp_record(uuid, uuid, text, text, text, text, text, text, text, uuid) from public, anon;
revoke execute on function public.submit_fyp_form(uuid, text, jsonb, text, numeric) from public, anon;
revoke execute on function public.save_lean_canvas(uuid, jsonb) from public, anon;
revoke execute on function public.submit_deliverable(uuid, text, text, text, text) from public, anon;
revoke execute on function public.submit_progress_log(uuid, integer, text, text, text, date) from public, anon;
revoke execute on function public.validate_progress_log(uuid, text, text) from public, anon;
revoke execute on function public.submit_form_evaluation(uuid, jsonb, text, text) from public, anon;
revoke execute on function public.create_correction_item(uuid, uuid, text, text) from public, anon;
revoke execute on function public.confirm_correction(uuid, text, text) from public, anon;
revoke execute on function public.decide_supervision_request(uuid, text, text) from public, anon;
revoke execute on function public.submit_supervision_request(uuid, uuid, text) from public, anon;
revoke execute on function public.grant_milestone_extension(uuid, uuid, text, date, text) from public, anon;
revoke execute on function public.create_or_update_milestone(uuid, text, text, text, date, text) from public, anon;
revoke execute on function public.archive_fyp_record(uuid, text) from public, anon;
revoke execute on function public.create_student_account_profile(uuid, text, text, text, text) from public, anon;
revoke execute on function public.list_fyp_students() from public, anon;
revoke execute on function public.list_fyp_staff(text[]) from public, anon;
revoke execute on function public.list_fyp_coordinators() from public, anon;
revoke execute on function public.handle_new_user() from public, anon;
