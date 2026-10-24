/// Everything only the Admin area (`/admin/**`) needs: its shell, the MFA
/// gate in front of it, and every admin page.
///
/// `router.dart` imports this library `deferred as admin`, so on the web the
/// JavaScript build puts this code in its own `main.dart.js_N.part.js` file
/// and exhibition visitors never download it. Anything listed here that is
/// also imported eagerly somewhere else stays in the main bundle — keep
/// public code from importing these files directly.
library;

export '../../features/admin_announcements/presentation/pages/admin_announcements_page.dart'
    show AdminAnnouncementsPage;
export '../../features/admin_assignments/presentation/pages/admin_assignments_page.dart'
    show AdminAssignmentsPage;
export '../../features/admin_audit/presentation/pages/admin_audit_page.dart'
    show AdminAuditPage;
export '../../features/admin_auth/mfa.dart' show MfaGate;
export '../../features/admin_awards/presentation/pages/admin_awards_page.dart'
    show AdminAwardsPage;
export '../../features/admin_booths/presentation/pages/admin_booths_page.dart'
    show AdminBoothsPage;
export '../../features/admin_dashboard/presentation/pages/dashboard_page.dart'
    show DashboardPage;
export '../../features/admin_event/presentation/pages/admin_event_page.dart'
    show AdminEventPage;
export '../../features/admin_feedback/presentation/pages/admin_feedback_page.dart'
    show AdminFeedbackPage;
export '../../features/admin_imports/presentation/pages/admin_imports_page.dart'
    show AdminImportsPage;
export '../../features/admin_imports/presentation/pages/import_detail_page.dart'
    show ImportDetailPage;
export '../../features/admin_lecturers/presentation/pages/admin_lecturers_page.dart'
    show AdminLecturersPage;
export '../../features/admin_projects/presentation/pages/admin_projects_page.dart'
    show AdminProjectsPage;
export '../../features/admin_schedule/presentation/pages/admin_schedule_page.dart'
    show AdminSchedulePage;
export '../../features/admin_settings/presentation/pages/admin_settings_page.dart'
    show AdminSettingsPage;
export '../../features/admin_visits/presentation/pages/admin_visits_page.dart'
    show AdminVisitsPage;
export '../widgets/admin_shell.dart' show AdminShell;
