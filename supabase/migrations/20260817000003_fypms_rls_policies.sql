-- ==============================================================================
-- FYP Expo Hub - FYPMS Row Level Security Policies
-- 20260817000003_fypms_rls_policies.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Enable RLS on all new FYPMS tables
-- -----------------------------------------------------------------------------
alter table public.profile_academic_roles enable row level security;
alter table public.academic_semesters enable row level security;
alter table public.academic_courses enable row level security;
alter table public.fyp_course_offerings enable row level security;
alter table public.fyp_records enable row level security;
alter table public.fyp_record_assignments enable row level security;
alter table public.fyp_milestones enable row level security;
alter table public.fyp_milestone_extensions enable row level security;
alter table public.fyp_supervision_requests enable row level security;
alter table public.fyp_progress_logs enable row level security;
alter table public.fyp_form_submissions enable row level security;
alter table public.fyp_form_evaluations enable row level security;
alter table public.fyp_rubric_templates enable row level security;
alter table public.fyp_report_submissions enable row level security;
alter table public.fyp_deliverables enable row level security;
alter table public.fyp_lean_canvases enable row level security;
alter table public.fyp_correction_items enable row level security;
alter table public.fyp_correction_confirmations enable row level security;
alter table public.fyp_presentation_sessions enable row level security;
alter table public.fyp_presentation_slots enable row level security;
alter table public.fyp_marks_summaries enable row level security;
alter table public.fyp_expo_publications enable row level security;
alter table public.fyp_audit_logs enable row level security;

-- -----------------------------------------------------------------------------
-- 1. profile_academic_roles
-- -----------------------------------------------------------------------------
create policy "Users read own academic roles"
  on public.profile_academic_roles for select
  using (profile_id = auth.uid() or public.is_admin() or public.is_fyp_coordinator());

create policy "Users read own academic roles active"
  on public.profile_academic_roles for select
  using (profile_id = auth.uid());

create policy "Admins manage academic roles"
  on public.profile_academic_roles for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Coordinators manage academic roles"
  on public.profile_academic_roles for all
  using (public.is_fyp_coordinator())
  with check (public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 2. academic_semesters
-- -----------------------------------------------------------------------------
create policy "Authenticated users read academic semesters"
  on public.academic_semesters for select
  using (auth.role() = 'authenticated');

create policy "Admins manage academic semesters"
  on public.academic_semesters for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Coordinators manage academic semesters"
  on public.academic_semesters for all
  using (public.is_fyp_coordinator())
  with check (public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 3. academic_courses
-- -----------------------------------------------------------------------------
create policy "Authenticated users read academic courses"
  on public.academic_courses for select
  using (auth.role() = 'authenticated');

create policy "Admins manage academic courses"
  on public.academic_courses for all
  using (public.is_admin())
  with check (public.is_admin());

create policy "Coordinators manage academic courses"
  on public.academic_courses for all
  using (public.is_fyp_coordinator())
  with check (public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 4. fyp_course_offerings
-- -----------------------------------------------------------------------------
create policy "Authenticated users read course offerings"
  on public.fyp_course_offerings for select
  using (auth.role() = 'authenticated');

create policy "Lecturers manage own offerings"
  on public.fyp_course_offerings for all
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or (lecturer_id = auth.uid() and is_active = true)
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or (lecturer_id = auth.uid() and is_active = true)
  );

-- -----------------------------------------------------------------------------
-- 5. fyp_records
-- -----------------------------------------------------------------------------
create policy "Records read by student owner"
  on public.fyp_records for select
  using (student_id = auth.uid());

create policy "Records read by assigned staff"
  on public.fyp_records for select
  using (public.can_read_fyp_record(id));

create policy "Records read by csp lecturer"
  on public.fyp_records for select
  using (public.is_csp_lecturer(current_course_code));

create policy "Records read by coordinator"
  on public.fyp_records for select
  using (public.is_fyp_coordinator());

create policy "Records read by admin"
  on public.fyp_records for select
  using (public.is_admin());

create policy "Records created by coordinator"
  on public.fyp_records for insert
  with check (public.is_admin() or public.is_fyp_coordinator());

create policy "Records edited by owner"
  on public.fyp_records for update
  using (student_id = auth.uid())
  with check (student_id = auth.uid());

create policy "Records edited by coordinator"
  on public.fyp_records for update
  using (public.is_admin() or public.is_fyp_coordinator())
  with check (public.is_admin() or public.is_fyp_coordinator());

create policy "Records edited by csp lecturer"
  on public.fyp_records for update
  using (public.is_csp_lecturer(current_course_code))
  with check (public.is_csp_lecturer(current_course_code));

create policy "Records deleted by coordinator"
  on public.fyp_records for delete
  using (public.is_admin() or public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 6. fyp_record_assignments
-- -----------------------------------------------------------------------------
create policy "Assignments read by record staff"
  on public.fyp_record_assignments for select
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or lecturer_id = auth.uid()
    or exists (
      select 1 from public.fyp_records r
      where r.id = fyp_record_id
        and r.student_id = auth.uid()
    )
  );

create policy "Assignments managed by coordinator"
  on public.fyp_record_assignments for all
  using (public.is_admin() or public.is_fyp_coordinator())
  with check (public.is_admin() or public.is_fyp_coordinator());

create policy "Assignments managed by csp lecturer"
  on public.fyp_record_assignments for all
  using (
    public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = fyp_record_id)
    )
  )
  with check (
    public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = fyp_record_id)
    )
  );

-- -----------------------------------------------------------------------------
-- 7. fyp_milestones
-- -----------------------------------------------------------------------------
create policy "Milestones read by record participants"
  on public.fyp_milestones for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Milestones created by csp lecturer"
  on public.fyp_milestones for insert
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = fyp_record_id)
    )
  );

create policy "Milestones updated by coordinator or csp lecturer"
  on public.fyp_milestones for update
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = fyp_record_id)
    )
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = fyp_record_id)
    )
  );

create policy "Milestones deleted by coordinator"
  on public.fyp_milestones for delete
  using (public.is_admin() or public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 8. fyp_milestone_extensions
-- -----------------------------------------------------------------------------
create policy "Extensions read by record participants"
  on public.fyp_milestone_extensions for select
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_milestones m
      where m.id = milestone_id and public.can_read_fyp_record(m.fyp_record_id)
    )
  );

create policy "Extensions requested by record participants"
  on public.fyp_milestone_extensions for insert
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_milestones m
      where m.id = milestone_id
        and public.can_read_fyp_record(m.fyp_record_id)
        and (
          requested_by = auth.uid()
          or public.is_csp_lecturer(
            (select current_course_code from public.fyp_records r where r.id = m.fyp_record_id)
          )
        )
    )
  );

create policy "Extensions decided by csp lecturer"
  on public.fyp_milestone_extensions for update
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_milestones m
      where m.id = milestone_id
        and public.is_csp_lecturer(
          (select current_course_code from public.fyp_records r where r.id = m.fyp_record_id)
        )
    )
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_milestones m
      where m.id = milestone_id
        and public.is_csp_lecturer(
          (select current_course_code from public.fyp_records r where r.id = m.fyp_record_id)
        )
    )
  );

-- -----------------------------------------------------------------------------
-- 9. fyp_supervision_requests (F1)
-- -----------------------------------------------------------------------------
create policy "Requests read by record participants"
  on public.fyp_supervision_requests for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Requests created by student"
  on public.fyp_supervision_requests for insert
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Requests decided by csp lecturer"
  on public.fyp_supervision_requests for update
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = fyp_record_id)
    )
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select current_course_code from public.fyp_records r where r.id = fyp_record_id)
    )
  );

create policy "Requests deleted by coordinator"
  on public.fyp_supervision_requests for delete
  using (public.is_admin() or public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 10. fyp_progress_logs (F5)
-- -----------------------------------------------------------------------------
create policy "Progress logs read by record participants"
  on public.fyp_progress_logs for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Progress logs created by student"
  on public.fyp_progress_logs for insert
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Progress logs edited by student"
  on public.fyp_progress_logs for update
  using (public.is_active_fyp_student(fyp_record_id))
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Progress logs validated by supervisor"
  on public.fyp_progress_logs for update
  using (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  )
  with check (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  );

-- -----------------------------------------------------------------------------
-- 11. fyp_form_submissions (F1 - F16)
-- -----------------------------------------------------------------------------
create policy "Form submissions read by record participants"
  on public.fyp_form_submissions for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Form submissions created by student"
  on public.fyp_form_submissions for insert
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Form submissions edited by student"
  on public.fyp_form_submissions for update
  using (public.is_active_fyp_student(fyp_record_id))
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Form submissions reviewed by assigned staff"
  on public.fyp_form_submissions for update
  using (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'examiner')
    or public.is_fyp_coordinator()
  )
  with check (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'examiner')
    or public.is_fyp_coordinator()
  );

-- -----------------------------------------------------------------------------
-- 12. fyp_form_evaluations
-- -----------------------------------------------------------------------------
create policy "Evaluations read by record participants"
  on public.fyp_form_evaluations for select
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or evaluator_id = auth.uid()
    or exists (
      select 1 from public.fyp_form_submissions s
      where s.id = form_submission_id and public.can_read_fyp_record(s.fyp_record_id)
    )
  );

create policy "Evaluations created by evaluator"
  on public.fyp_form_evaluations for insert
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or (
      evaluator_id = auth.uid()
      and exists (
        select 1 from public.fyp_form_submissions s
        where s.id = form_submission_id
          and (
            public.is_assigned_to_fyp_record(s.fyp_record_id, 'supervisor')
            or public.is_assigned_to_fyp_record(s.fyp_record_id, 'co_supervisor')
            or public.is_assigned_to_fyp_record(s.fyp_record_id, 'examiner')
          )
      )
    )
  );

create policy "Evaluations edited by evaluator"
  on public.fyp_form_evaluations for update
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or evaluator_id = auth.uid()
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or evaluator_id = auth.uid()
  );

-- -----------------------------------------------------------------------------
-- 13. fyp_rubric_templates
-- -----------------------------------------------------------------------------
create policy "Rubrics read by authenticated"
  on public.fyp_rubric_templates for select
  using (auth.role() = 'authenticated');

create policy "Rubrics managed by coordinator"
  on public.fyp_rubric_templates for all
  using (public.is_admin() or public.is_fyp_coordinator())
  with check (public.is_admin() or public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 14. fyp_report_submissions (F6a / F6b)
-- -----------------------------------------------------------------------------
create policy "Reports read by record participants"
  on public.fyp_report_submissions for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Reports created by student"
  on public.fyp_report_submissions for insert
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Reports edited by student"
  on public.fyp_report_submissions for update
  using (public.is_active_fyp_student(fyp_record_id))
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Reports reviewed by assigned staff"
  on public.fyp_report_submissions for update
  using (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'examiner')
    or public.is_fyp_coordinator()
  )
  with check (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'examiner')
    or public.is_fyp_coordinator()
  );

-- -----------------------------------------------------------------------------
-- 15. fyp_deliverables
-- -----------------------------------------------------------------------------
create policy "Deliverables read by record participants"
  on public.fyp_deliverables for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Deliverables created by student"
  on public.fyp_deliverables for insert
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Deliverables edited by student"
  on public.fyp_deliverables for update
  using (public.is_active_fyp_student(fyp_record_id))
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Deliverables managed by coordinator"
  on public.fyp_deliverables for all
  using (public.is_admin() or public.is_fyp_coordinator())
  with check (public.is_admin() or public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 16. fyp_lean_canvases (F13)
-- -----------------------------------------------------------------------------
create policy "Canvases read by record participants"
  on public.fyp_lean_canvases for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Canvases edited by student"
  on public.fyp_lean_canvases for all
  using (public.is_active_fyp_student(fyp_record_id))
  with check (public.is_active_fyp_student(fyp_record_id));

create policy "Canvases edited by supervisor"
  on public.fyp_lean_canvases for update
  using (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  )
  with check (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  );

-- -----------------------------------------------------------------------------
-- 17. fyp_correction_items (F12)
-- -----------------------------------------------------------------------------
create policy "Corrections read by record participants"
  on public.fyp_correction_items for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Corrections created by examiners"
  on public.fyp_correction_items for insert
  with check (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'examiner')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  );

create policy "Corrections updated by staff"
  on public.fyp_correction_items for update
  using (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'examiner')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  )
  with check (
    public.is_admin()
    or public.is_assigned_to_fyp_record(fyp_record_id, 'examiner')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  );

-- -----------------------------------------------------------------------------
-- 18. fyp_correction_confirmations (F12)
-- -----------------------------------------------------------------------------
create policy "Confirmations read by record participants"
  on public.fyp_correction_confirmations for select
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_correction_items c
      where c.id = correction_item_id and public.can_read_fyp_record(c.fyp_record_id)
    )
  );

create policy "Confirmations created by record participants"
  on public.fyp_correction_confirmations for insert
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or exists (
      select 1 from public.fyp_correction_items c
      where c.id = correction_item_id
        and (
          public.is_active_fyp_student(c.fyp_record_id)
          or public.is_assigned_to_fyp_record(c.fyp_record_id, 'supervisor')
          or public.is_assigned_to_fyp_record(c.fyp_record_id, 'co_supervisor')
          or public.is_assigned_to_fyp_record(c.fyp_record_id, 'examiner')
        )
    )
  );

-- -----------------------------------------------------------------------------
-- 19. fyp_presentation_sessions
-- -----------------------------------------------------------------------------
create policy "Sessions read by authenticated"
  on public.fyp_presentation_sessions for select
  using (auth.role() = 'authenticated');

create policy "Sessions managed by csp lecturer"
  on public.fyp_presentation_sessions for all
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select course_code from public.fyp_course_offerings o where o.id = offering_id)
    )
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select course_code from public.fyp_course_offerings o where o.id = offering_id)
    )
  );

-- -----------------------------------------------------------------------------
-- 20. fyp_presentation_slots
-- -----------------------------------------------------------------------------
create policy "Slots read by authenticated"
  on public.fyp_presentation_slots for select
  using (auth.role() = 'authenticated');

create policy "Slots managed by csp lecturer"
  on public.fyp_presentation_slots for all
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select o.course_code from public.fyp_presentation_sessions s
        join public.fyp_course_offerings o on o.id = s.offering_id
        where s.id = session_id)
    )
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(
      (select o.course_code from public.fyp_presentation_sessions s
        join public.fyp_course_offerings o on o.id = s.offering_id
        where s.id = session_id)
    )
  );

-- -----------------------------------------------------------------------------
-- 21. fyp_marks_summaries
-- -----------------------------------------------------------------------------
create policy "Marks read by record participants"
  on public.fyp_marks_summaries for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Marks managed by csp lecturer"
  on public.fyp_marks_summaries for all
  using (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(course_code)
  )
  with check (
    public.is_admin()
    or public.is_fyp_coordinator()
    or public.is_csp_lecturer(course_code)
  );

-- -----------------------------------------------------------------------------
-- 22. fyp_expo_publications
-- -----------------------------------------------------------------------------
create policy "Publications read by record participants"
  on public.fyp_expo_publications for select
  using (public.can_read_fyp_record(fyp_record_id));

create policy "Publications managed by coordinator"
  on public.fyp_expo_publications for all
  using (public.is_admin() or public.is_fyp_coordinator())
  with check (public.is_admin() or public.is_fyp_coordinator());

-- -----------------------------------------------------------------------------
-- 23. fyp_audit_logs (read-only for admin/coordinator, writes from RPC)
-- -----------------------------------------------------------------------------
create policy "FYP audit logs read by admin"
  on public.fyp_audit_logs for select
  using (public.is_admin());

create policy "FYP audit logs read by coordinator"
  on public.fyp_audit_logs for select
  using (public.is_fyp_coordinator());