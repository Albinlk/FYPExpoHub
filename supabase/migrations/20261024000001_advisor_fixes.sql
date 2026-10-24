-- Supabase advisor fixes (R3), from a static check of the migrations
-- (the live advisors couldn't be run: the CLI and MCP sessions were signed
-- out). Run the advisors again after applying.
--
-- 1. unindexed_foreign_keys: index each foreign-key column that no existing
--    index starts with. Checked against pg_index at apply time, so a column
--    that is already covered (under any index name) gets no duplicate.
-- 2. auth_rls_initplan: policies that call auth.uid() / auth.jwt() directly
--    re-evaluate it for every row; wrapping it in (select ...) evaluates it
--    once per query. Same conditions, only faster.

do $$
declare
  fk record;
begin
  for fk in
    select * from (values
      ('audit_logs', 'actor_uid'),
      ('audit_logs', 'import_id'),
      ('award_categories', 'event_id'),
      ('award_winners', 'category_id'),
      ('award_winners', 'project_id'),
      ('booths', 'linked_project_id'),
      ('events', 'updated_by'),
      ('feedback_entries', 'submitted_by'),
      ('fyp_audit_logs', 'actor_uid'),
      ('fyp_correction_confirmations', 'confirmed_by'),
      ('fyp_correction_confirmations', 'correction_item_id'),
      ('fyp_correction_items', 'created_by'),
      ('fyp_course_offerings', 'course_code'),
      ('fyp_course_offerings', 'lecturer_id'),
      ('fyp_deliverables', 'fyp_record_id'),
      ('fyp_deliverables', 'submitted_by'),
      ('fyp_expo_publications', 'prepared_by'),
      ('fyp_expo_publications', 'published_by'),
      ('fyp_expo_publications', 'published_project_id'),
      ('fyp_form_evaluations', 'evaluator_id'),
      ('fyp_form_evaluations', 'rubric_template_id'),
      ('fyp_form_submissions', 'submitted_by'),
      ('fyp_marks_summaries', 'academic_semester_id'),
      ('fyp_marks_summaries', 'course_code'),
      ('fyp_marks_summaries', 'finalized_by'),
      ('fyp_milestone_extensions', 'decided_by'),
      ('fyp_milestone_extensions', 'milestone_id'),
      ('fyp_milestone_extensions', 'requested_by'),
      ('fyp_notifications', 'fyp_record_id'),
      ('fyp_presentation_slots', 'fyp_record_id'),
      ('fyp_progress_logs', 'submitted_by'),
      ('fyp_progress_logs', 'validated_by'),
      ('fyp_record_assignments', 'assigned_by'),
      ('fyp_records', 'co_supervisor_id'),
      ('fyp_records', 'current_course_code'),
      ('fyp_records', 'previous_record_id'),
      ('fyp_report_submissions', 'reviewed_by'),
      ('fyp_report_submissions', 'submitted_by'),
      ('fyp_special_evaluations', 'assessed_by'),
      ('fyp_supervision_requests', 'decided_by'),
      ('fyp_supervision_requests', 'fyp_record_id'),
      ('fyp_supervision_requests', 'preferred_co_supervisor_id'),
      ('fyp_supervision_requests', 'preferred_supervisor_id'),
      ('fyp_supervisor_change_requests', 'current_supervisor_id'),
      ('fyp_supervisor_change_requests', 'decided_by'),
      ('fyp_supervisor_change_requests', 'proposed_supervisor_id'),
      ('fyp_supervisor_change_requests', 'requested_by'),
      ('import_award_candidates', 'import_id'),
      ('import_privacy_skips', 'import_id'),
      ('import_review_decisions', 'import_id'),
      ('import_review_decisions', 'reviewed_by'),
      ('import_schedule_candidates', 'import_id'),
      ('import_validation_issues', 'import_id'),
      ('imports', 'event_id'),
      ('lecturer_assignments', 'assigned_by'),
      ('settings', 'updated_by'),
      ('student_project_visits', 'assignment_id'),
      ('student_project_visits', 'project_id'),
      ('student_project_visits', 'voided_by')
    ) as v(tbl, col)
  loop
    if to_regclass('public.' || fk.tbl) is null then
      continue;
    end if;
    if not exists (
      select 1
      from pg_index i
      join pg_attribute a
        on a.attrelid = i.indrelid and a.attnum = i.indkey[0]
      where i.indrelid = ('public.' || fk.tbl)::regclass
        and a.attname = fk.col
    ) and exists (
      select 1 from pg_attribute a
      where a.attrelid = ('public.' || fk.tbl)::regclass
        and a.attname = fk.col and not a.attisdropped
    ) then
      execute format('create index %I on public.%I (%I)',
        left('idx_' || fk.tbl || '_' || fk.col, 63), fk.tbl, fk.col);
    end if;
  end loop;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'academic_courses' and policyname = 'Authenticated users read academic courses') then
    execute $p$alter policy "Authenticated users read academic courses" on public.academic_courses
  using ((select auth.role()) = 'authenticated')$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'academic_semesters' and policyname = 'Authenticated users read academic semesters') then
    execute $p$alter policy "Authenticated users read academic semesters" on public.academic_semesters
  using ((select auth.role()) = 'authenticated')$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'feedback_entries' and policyname = 'Users read own feedback') then
    execute $p$alter policy "Users read own feedback" on public.feedback_entries
  using (public.is_admin()
    or ((select auth.uid()) is not null and submitted_by = (select auth.uid())))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'fyp_course_offerings' and policyname = 'Authenticated users read course offerings') then
    execute $p$alter policy "Authenticated users read course offerings" on public.fyp_course_offerings
  using ((select auth.role()) = 'authenticated')$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'fyp_course_offerings' and policyname = 'Lecturers update own offerings') then
    execute $p$alter policy "Lecturers update own offerings" on public.fyp_course_offerings
  using (lecturer_id = (select auth.uid()) and is_active = true)
  with check (lecturer_id = (select auth.uid()))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'fyp_form_evaluations' and policyname = 'Evaluations read by record participants') then
    execute $p$alter policy "Evaluations read by record participants" on public.fyp_form_evaluations
  using (public.is_admin()
    or public.is_fyp_coordinator()
    or evaluator_id = (select auth.uid())
    or exists (
      select 1 from public.fyp_form_submissions s
      where s.id = form_submission_id and public.can_read_fyp_record(s.fyp_record_id)
    ))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'fyp_record_assignments' and policyname = 'Assignments read by record staff') then
    execute $p$alter policy "Assignments read by record staff" on public.fyp_record_assignments
  using (public.is_admin()
    or public.is_fyp_coordinator()
    or lecturer_id = (select auth.uid())
    or exists (
      select 1 from public.fyp_records r
      where r.id = fyp_record_id
        and r.student_id = (select auth.uid())
    ))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'fyp_records' and policyname = 'Records read by student owner') then
    execute $p$alter policy "Records read by student owner" on public.fyp_records
  using (student_id = (select auth.uid()))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'fyp_rubric_templates' and policyname = 'Rubrics read by authenticated') then
    execute $p$alter policy "Rubrics read by authenticated" on public.fyp_rubric_templates
  using ((select auth.role()) = 'authenticated')$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'lecturer_assignments' and policyname = 'Lecturers read own assignments') then
    execute $p$alter policy "Lecturers read own assignments" on public.lecturer_assignments
  using (lecturer_id = (select auth.uid()) and status = 'active')$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'profile_academic_roles' and policyname = 'Users read own academic roles') then
    execute $p$alter policy "Users read own academic roles" on public.profile_academic_roles
  using (profile_id = (select auth.uid()) or public.is_admin() or public.is_fyp_coordinator())$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'profile_academic_roles' and policyname = 'Users read own academic roles active') then
    execute $p$alter policy "Users read own academic roles active" on public.profile_academic_roles
  using (profile_id = (select auth.uid()))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'profiles' and policyname = 'Users can read own profile') then
    execute $p$alter policy "Users can read own profile" on public.profiles
  using ((select auth.uid()) = id)$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'projects' and policyname = 'Public can read published projects') then
    execute $p$alter policy "Public can read published projects" on public.projects
  using (publication_status = 'published'
    or public.is_admin()
    or exists (
      select 1 from public.lecturer_assignments la
      where la.project_id = projects.id
      and la.lecturer_id = (select auth.uid())
      and la.status = 'active'
    ))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'schedule_items' and policyname = 'Public can read public schedule items') then
    execute $p$alter policy "Public can read public schedule items" on public.schedule_items
  using ((publication_status = 'published' and access_type = 'public')
    or public.is_admin()
    or ((select auth.role()) = 'authenticated' and publication_status = 'published'))$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'settings' and policyname = 'Authenticated users read settings') then
    execute $p$alter policy "Authenticated users read settings" on public.settings
  using ((select auth.role()) = 'authenticated')$p$;
  end if;
end
$$;

do $$
begin
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'student_project_visits' and policyname = 'Lecturers read own visits') then
    execute $p$alter policy "Lecturers read own visits" on public.student_project_visits
  using (lecturer_id = (select auth.uid()))$p$;
  end if;
end
$$;
