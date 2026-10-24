/// Explicit PostgREST column lists for every table read in
/// `supabase_database_service.dart`, `fypms_database_service.dart` and
/// `supabase_client_provider.dart`, in place of `select()` (= `*`).
///
/// Each list holds every column the row's consumer reads: the freezed model
/// (through `normalizeKeys`), the `*FromRow` mapper in `row_mappers.dart`, or
/// the page that reads the raw map. A column missing here silently becomes
/// null/default in the app, so when you add a field to a model, add its
/// column here too. A column that doesn't exist makes PostgREST reject the
/// whole query with a 400, so test/core/supabase/select_columns_test.dart
/// checks every name below against `supabase/migrations/*.sql`, and checks
/// that each model-backed list still covers its model.
abstract final class SelectColumns {
  // ───────────────────────────── Expo Hub tables ────────────────────────────

  /// `projects` → `projectFromRow` (also reads `abstract` as the fallback
  /// for an empty `short_description`, e.g. projects published from FYPMS).
  static const projects = 'id, event_id, slug, title, matric_id, programme_code, programme_name, '
      'short_description, abstract, category, tech_tags, booth_id, booth_number, booth_zone, '
      'presentation_day, cover_image_url, student_team, team_display_name, supervisor_display_name, '
      'examiner_display_name, demo_url, video_url, repository_url, featured, industry_candidate, '
      'publication_status, created_at, updated_at';

  /// `schedule_items` → `scheduleItemFromRow` (not `day_label`).
  static const scheduleItems = 'id, event_id, event_date, start_at, end_at, title, venue, audience, '
      'description, access_type, publication_status, created_at, updated_at';

  /// `booths` → `boothFromRow` (not `status` / `venue`, which no model reads).
  static const booths = 'id, event_id, booth_number, zone, location_note, presentation_day, '
      'floor_plan_url, linked_project_id, publication_status, created_at, updated_at';

  /// `announcements` → `announcementFromRow`.
  static const announcements = 'id, event_id, title, body, category, is_pinned, publication_status, '
      'published_at, created_at, updated_at';

  /// `award_winners` → `awardWinnerFromRow` (`title` is the project title).
  static const awardWinners = 'id, event_id, category_id, project_id, title, programme_code, '
      'team_display_name, supervisor_display_name, sponsor, description, publication_status, '
      'created_at, updated_at';

  /// `award_categories` → `AwardCategoryItem.fromRow`.
  static const awardCategories = 'id, title, description, sort_order, status';

  /// One `events` row in full → `eventFromRow` (the current event).
  static const events = 'id, title, session_label, start_at, end_at, daily_hours, venue, '
      'location_details, map_url, description, objectives, status, hero_image_url, poster_url, '
      'public_contact_email, faq_items, publication_status, updated_at, academic_semester_id';

  /// `events` in lists: `ExhibitionSummary.fromRow` (archive, admin
  /// Exhibitions) and the coordinator's expo-publication event picker
  /// (`id`, `title`, `academic_semester_id`). Leaves out the long text and
  /// jsonb columns (`description`, `objectives`, `faq_items`).
  static const eventSummaries = 'id, slug, title, start_at, venue, is_current, academic_semester_id';

  /// `settings`: callers only read `value`.
  static const settings = 'value';

  /// `imports` → `importFromRow`.
  static const imports = 'id, event_id, file_name, uploaded_by, status, summary, created_at, completed_at';

  /// `import_schedule_candidates` → `scheduleCandidateFromRow`.
  static const importScheduleCandidates = 'id, event_date, start_at, end_at, raw_start_str, '
      'raw_end_str, title, venue, audience, access_type, comparison_status, is_duplicate, '
      'is_overlapping, created_at';

  /// `import_award_candidates` → `awardCandidateFromRow`.
  static const importAwardCandidates = 'id, award_category, project_title, team_display_name, '
      'supervisor_display_name, programme_code, is_skip';

  /// `import_validation_issues` → `validationIssueFromRow`.
  static const importValidationIssues = 'id, issue_type, severity, message, worksheet_name, row_number';

  /// `import_privacy_skips` → `privacySkipFromRow`.
  static const importPrivacySkips = 'id, category, reason, sheet_name, created_at';

  /// `profiles` → `UserProfile.fromJson`, `LecturerRef.fromRow` and the
  /// admin lecturer / audit pages.
  static const profiles = 'id, email, display_name, role, is_active';

  /// `lecturer_assignments`: every column, because the admin "backfill
  /// lecturer IDs" action spreads the fetched row back into an upsert.
  static const lecturerAssignments = 'id, event_id, project_id, lecturer_id, lecturer_display_name, '
      'lecturer_email, role, status, assigned_by, assigned_at, updated_at';

  /// `student_project_visits` → `StudentVisit` (not `voided_by_role`).
  static const studentProjectVisits = 'id, event_id, project_id, assignment_id, lecturer_id, '
      'visit_role, visited_at, visit_note, status, source, voided_at, voided_by, void_reason, '
      'created_at, updated_at';

  /// `audit_logs` → `AuditEntry.fromRow` (admin audit page).
  static const auditLogs = 'id, action, target_type, target_id, actor_uid, actor_role, '
      'metadata_safe, created_at';

  /// `feedback_entries` → `feedbackFromRow`.
  static const feedbackEntries = 'id, event_id, subject, message, rating, status, admin_note, '
      'submitted_by, user_agent, created_at, updated_at';

  // ─────────────────────────────── FYPMS tables ─────────────────────────────

  /// `academic_semesters` → `AcademicSemester`.
  static const academicSemesters = 'id, code, label, status, start_date, end_date, created_at, updated_at';

  /// `academic_courses` → `AcademicCourse`.
  static const academicCourses = 'code, name, stage, credit_hours, is_active, created_at, updated_at';

  /// `fyp_course_offerings` → `FypCourseOffering`.
  static const fypCourseOfferings = 'id, academic_semester_id, course_code, lecturer_id, is_active, '
      'max_students, created_at, updated_at';

  /// `fyp_records` → `FypRecord`.
  static const fypRecords = 'id, academic_semester_id, student_id, current_course_code, '
      'programme_code, matric_id, project_title, project_description, project_type, '
      'external_industry_partner, main_supervisor_id, co_supervisor_id, examiner_id, '
      'previous_record_id, supervisor_approved_at, workflow_status, created_at, updated_at';

  /// `fyp_record_assignments` → `FypRecordAssignment`.
  static const fypRecordAssignments = 'id, fyp_record_id, academic_role, lecturer_id, is_active, '
      'assigned_by, assigned_at, created_at, updated_at';

  /// `fyp_record_assignments` when only the assigned record ids are needed.
  static const fypRecordAssignmentRefs = 'fyp_record_id, academic_role, lecturer_id, is_active';

  /// `fyp_supervision_requests` → `FypSupervisionRequest`.
  static const fypSupervisionRequests = 'id, fyp_record_id, preferred_supervisor_id, '
      'preferred_co_supervisor_id, project_area, project_title, rationale, status, decided_by, '
      'decided_at, decision_reason, created_at, updated_at';

  /// `fyp_progress_logs` → `FypProgressLog`.
  static const fypProgressLogs = 'id, fyp_record_id, week_number, progress_date, summary, challenges, '
      'next_plan, status, submitted_by, submitted_at, validated_by, validated_at, validation_comment, '
      'created_at, updated_at';

  /// `fyp_form_submissions` → `FypFormSubmission` (`payload` is shown as the
  /// form's answers, so it stays).
  static const fypFormSubmissions = 'id, fyp_record_id, form_code, form_version, payload, status, '
      'submitted_by, submitted_at, created_at, updated_at';

  /// `fyp_form_evaluations` → `ExistingFormEvaluation.fromRow`.
  static const fypFormEvaluations = 'id, evaluator_id, scores, comments, evaluated_at, updated_at';

  /// `fyp_rubric_templates` → `FypRubricTemplate`.
  static const fypRubricTemplates = 'id, rubric_code, rubric_name, form_code, criteria, '
      'evaluator_shares, version, is_active, created_at, updated_at';

  /// `fyp_report_submissions` → `FypReportSubmission`.
  static const fypReportSubmissions = 'id, fyp_record_id, report_type, version, file_url, '
      'similarity_index, plagiarism_report_url, page_count, reference_count, '
      'academic_reference_count, involves_human_subjects, ethics_form_url, endorsed_by, endorsed_at, '
      'status, submitted_by, submitted_at, reviewed_by, reviewed_at, review_comment, created_at, '
      'updated_at';

  /// `fyp_deliverables` → `FypDeliverable`.
  static const fypDeliverables = 'id, fyp_record_id, deliverable_type, title, description, file_url, '
      'version, is_required, submitted_by, submitted_at, created_at, updated_at';

  /// `fyp_lean_canvases` → `FypLeanCanvas`.
  static const fypLeanCanvases = 'id, fyp_record_id, canvas_version, blocks, is_latest, created_at, updated_at';

  /// `fyp_milestones` → `FypMilestone`.
  static const fypMilestones = 'id, fyp_record_id, milestone_code, milestone_title, description, '
      'target_date, status, completed_at, created_at, updated_at';

  /// `fyp_milestone_extensions` → `FypMilestoneExtension`, with the
  /// milestone's code and title (the `!inner` join also scopes it to a record).
  static const fypMilestoneExtensions = 'id, milestone_id, reason, requested_due_date, status, '
      'decision_comment, decided_at, created_at, '
      'fyp_milestones!inner(fyp_record_id, milestone_code, milestone_title)';

  /// `fyp_correction_items` → `FypCorrectionItem`.
  static const fypCorrectionItems = 'id, fyp_record_id, item_code, description, severity, status, '
      'created_by, evidence_note, evidence_url, evidence_submitted_at, created_at, updated_at';

  /// `fyp_presentation_sessions` → `FypPresentationSession`.
  static const fypPresentationSessions = 'id, offering_id, session_code, session_title, event_date, '
      'start_at, end_at, venue, session_type, created_at, updated_at';

  /// `fyp_presentation_slots` → `FypPresentationSlot`.
  static const fypPresentationSlots = 'id, session_id, fyp_record_id, slot_number, start_at, end_at, '
      'room, created_at, updated_at';

  /// A record's slots with their session → `FypScheduledPresentation`.
  static const fypPresentationSlotsWithSession =
      '$fypPresentationSlots, fyp_presentation_sessions($fypPresentationSessions)';

  /// `fyp_supervisor_change_requests` → `SupervisorChangeRequest`.
  static const fypSupervisorChangeRequests = 'id, fyp_record_id, reason, status, '
      'current_supervisor_id, proposed_supervisor_id, decision_comment, created_at';

  /// Change requests with the record they belong to (coordinator list).
  static const fypSupervisorChangeRequestsWithRecord =
      '$fypSupervisorChangeRequests, fyp_records(project_title, matric_id)';

  /// `fyp_special_evaluations` → `SpecialEvaluation`.
  static const fypSpecialEvaluations = 'fyp_record_id, progress_lmc_marks, chapters_complete, '
      'presented_at_exhibition, final_semester_courses_passed, eligible, note, assessed_at';

  /// `fyp_marks_summaries` → `FypMarksSummary`. Leaves out the
  /// `export_payload` jsonb snapshot: nothing in the app reads it.
  static const fypMarksSummaries = 'id, fyp_record_id, academic_semester_id, course_code, marks, '
      'weighted_total, grade, is_finalized, finalized_by, finalized_at, created_at, updated_at';

  /// `fyp_expo_publications` → `FypExpoPublication` (`payload` holds the
  /// title the coordinator page shows).
  static const fypExpoPublications = 'id, fyp_record_id, event_id, status, payload, '
      'published_project_id, prepared_by, prepared_at, published_by, published_at, created_at, '
      'updated_at';

  /// `fyp_audit_logs` → `FypAuditLog`.
  static const fypAuditLogs = 'id, actor_uid, actor_role, action, target_type, target_id, '
      'metadata_safe, source, created_at';

  /// Every list with the table it selects from, for the schema guard test.
  static const all = <(String table, String columns)>[
    ('projects', projects),
    ('schedule_items', scheduleItems),
    ('booths', booths),
    ('announcements', announcements),
    ('award_winners', awardWinners),
    ('award_categories', awardCategories),
    ('events', events),
    ('events', eventSummaries),
    ('settings', settings),
    ('imports', imports),
    ('import_schedule_candidates', importScheduleCandidates),
    ('import_award_candidates', importAwardCandidates),
    ('import_validation_issues', importValidationIssues),
    ('import_privacy_skips', importPrivacySkips),
    ('profiles', profiles),
    ('lecturer_assignments', lecturerAssignments),
    ('student_project_visits', studentProjectVisits),
    ('audit_logs', auditLogs),
    ('feedback_entries', feedbackEntries),
    ('academic_semesters', academicSemesters),
    ('academic_courses', academicCourses),
    ('fyp_course_offerings', fypCourseOfferings),
    ('fyp_records', fypRecords),
    ('fyp_record_assignments', fypRecordAssignments),
    ('fyp_record_assignments', fypRecordAssignmentRefs),
    ('fyp_supervision_requests', fypSupervisionRequests),
    ('fyp_progress_logs', fypProgressLogs),
    ('fyp_form_submissions', fypFormSubmissions),
    ('fyp_form_evaluations', fypFormEvaluations),
    ('fyp_rubric_templates', fypRubricTemplates),
    ('fyp_report_submissions', fypReportSubmissions),
    ('fyp_deliverables', fypDeliverables),
    ('fyp_lean_canvases', fypLeanCanvases),
    ('fyp_milestones', fypMilestones),
    ('fyp_milestone_extensions', fypMilestoneExtensions),
    ('fyp_correction_items', fypCorrectionItems),
    ('fyp_presentation_sessions', fypPresentationSessions),
    ('fyp_presentation_slots', fypPresentationSlots),
    ('fyp_presentation_slots', fypPresentationSlotsWithSession),
    ('fyp_supervisor_change_requests', fypSupervisorChangeRequests),
    ('fyp_supervisor_change_requests', fypSupervisorChangeRequestsWithRecord),
    ('fyp_special_evaluations', fypSpecialEvaluations),
    ('fyp_marks_summaries', fypMarksSummaries),
    ('fyp_expo_publications', fypExpoPublications),
    ('fyp_audit_logs', fypAuditLogs),
  ];
}
