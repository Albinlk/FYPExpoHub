/// Everything only the FYP Workspace (`/fypms/**`) needs: its shell, the MFA
/// gate in front of it, and every workspace page.
///
/// `router.dart` imports this library `deferred as fypms`, so on the web the
/// JavaScript build puts this code in its own `main.dart.js_N.part.js` file
/// and exhibition visitors never download it. Anything listed here that is
/// also imported eagerly somewhere else stays in the main bundle — keep
/// public code from importing these files directly.
library;

export '../../features/admin_auth/mfa.dart' show MfaGate;
export '../../features/fypms/presentation/pages/coordinator_assignments_page.dart'
    show CoordinatorAssignmentsPage;
export '../../features/fypms/presentation/pages/coordinator_audit_page.dart'
    show CoordinatorAuditPage;
export '../../features/fypms/presentation/pages/coordinator_dashboard_page.dart'
    show CoordinatorDashboardPage;
export '../../features/fypms/presentation/pages/coordinator_enrol_page.dart'
    show CoordinatorEnrolPage;
export '../../features/fypms/presentation/pages/coordinator_expo_page.dart'
    show CoordinatorExpoPage;
export '../../features/fypms/presentation/pages/coordinator_mark_allocation_page.dart'
    show CoordinatorMarkAllocationPage;
export '../../features/fypms/presentation/pages/coordinator_presentations_page.dart'
    show CoordinatorPresentationsPage;
export '../../features/fypms/presentation/pages/coordinator_records_page.dart'
    show CoordinatorRecordsPage;
export '../../features/fypms/presentation/pages/coordinator_reports_page.dart'
    show CoordinatorReportsPage;
export '../../features/fypms/presentation/pages/coordinator_requests_page.dart'
    show CoordinatorRequestsPage;
export '../../features/fypms/presentation/pages/coordinator_rubrics_page.dart'
    show CoordinatorRubricsPage;
export '../../features/fypms/presentation/pages/coordinator_semesters_page.dart'
    show CoordinatorSemestersPage;
export '../../features/fypms/presentation/pages/coordinator_users_page.dart'
    show CoordinatorUsersPage;
export '../../features/fypms/presentation/pages/csp_cohort_page.dart'
    show CspCohortPage;
export '../../features/fypms/presentation/pages/csp_dashboard_page.dart'
    show CspDashboardPage;
export '../../features/fypms/presentation/pages/csp_evaluations_page.dart'
    show CspEvaluationsPage;
export '../../features/fypms/presentation/pages/csp_marks_page.dart'
    show CspMarksPage;
export '../../features/fypms/presentation/pages/csp_milestones_page.dart'
    show CspMilestonesPage;
export '../../features/fypms/presentation/pages/csp_offerings_page.dart'
    show CspOfferingsPage;
export '../../features/fypms/presentation/pages/csp_requests_page.dart'
    show CspRequestsPage;
export '../../features/fypms/presentation/pages/examiner_corrections_page.dart'
    show ExaminerCorrectionsPage;
export '../../features/fypms/presentation/pages/examiner_dashboard_page.dart'
    show ExaminerDashboardPage;
export '../../features/fypms/presentation/pages/examiner_evaluations_page.dart'
    show ExaminerEvaluationsPage;
export '../../features/fypms/presentation/pages/lecturer_record_detail_page.dart'
    show LecturerRecordDetailPage;
export '../../features/fypms/presentation/pages/notifications_page.dart'
    show NotificationsPage;
export '../../features/fypms/presentation/pages/student_corrections_page.dart'
    show StudentCorrectionsPage;
export '../../features/fypms/presentation/pages/student_dashboard_page.dart'
    show StudentDashboardPage;
export '../../features/fypms/presentation/pages/student_deliverables_page.dart'
    show StudentDeliverablesPage;
export '../../features/fypms/presentation/pages/student_forms_page.dart'
    show StudentFormsPage;
export '../../features/fypms/presentation/pages/student_lean_canvas_page.dart'
    show StudentLeanCanvasPage;
export '../../features/fypms/presentation/pages/student_marks_page.dart'
    show StudentMarksPage;
export '../../features/fypms/presentation/pages/student_milestones_page.dart'
    show StudentMilestonesPage;
export '../../features/fypms/presentation/pages/student_presentations_page.dart'
    show StudentPresentationsPage;
export '../../features/fypms/presentation/pages/student_progress_page.dart'
    show StudentProgressPage;
export '../../features/fypms/presentation/pages/student_record_detail_page.dart'
    show StudentRecordDetailPage;
export '../../features/fypms/presentation/pages/student_records_page.dart'
    show StudentRecordsPage;
export '../../features/fypms/presentation/pages/student_reports_page.dart'
    show StudentReportsPage;
export '../../features/fypms/presentation/pages/student_supervision_page.dart'
    show StudentSupervisionPage;
export '../../features/fypms/presentation/pages/supervisor_corrections_page.dart'
    show SupervisorCorrectionsPage;
export '../../features/fypms/presentation/pages/supervisor_dashboard_page.dart'
    show SupervisorDashboardPage;
export '../../features/fypms/presentation/pages/supervisor_evaluations_page.dart'
    show SupervisorEvaluationsPage;
export '../../features/fypms/presentation/pages/supervisor_milestones_page.dart'
    show SupervisorMilestonesPage;
export '../../features/fypms/presentation/pages/supervisor_progress_page.dart'
    show SupervisorProgressPage;
export '../../features/fypms/presentation/pages/supervisor_reports_page.dart'
    show SupervisorReportsPage;
export '../../features/fypms/presentation/pages/supervisor_requests_page.dart'
    show SupervisorRequestsPage;
export '../../features/fypms/presentation/widgets/nomination_documents.dart'
    show NominatorNominationsPage;
export '../../features/fypms/presentation/widgets/supervisor_change_widgets.dart'
    show CoordinatorLettersPage, PuNominationsPage;
export '../widgets/fypms_shell.dart' show FypmsShell;
