import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/supabase/supabase_client_provider.dart';
import '../core/state/state_providers.dart';
import '../core/state/fypms_state_providers.dart';
import '../features/fypms/presentation/pages/csp_dashboard_page.dart';
import '../features/fypms/presentation/pages/csp_marks_page.dart';
import '../features/fypms/presentation/pages/csp_milestones_page.dart';
import '../features/fypms/presentation/pages/csp_offerings_page.dart';
import '../features/fypms/presentation/pages/csp_requests_page.dart';
import '../features/fypms/presentation/pages/coordinator_assignments_page.dart';
import '../features/fypms/presentation/pages/coordinator_audit_page.dart';
import '../features/fypms/presentation/pages/coordinator_dashboard_page.dart';
import '../features/fypms/presentation/pages/coordinator_expo_page.dart';
import '../features/fypms/presentation/pages/coordinator_presentations_page.dart';
import '../features/fypms/presentation/pages/coordinator_records_page.dart';
import '../features/fypms/presentation/pages/coordinator_requests_page.dart';
import '../features/fypms/presentation/pages/supervisor_corrections_page.dart';
import '../features/fypms/presentation/pages/supervisor_evaluations_page.dart';
import '../features/fypms/presentation/pages/supervisor_milestones_page.dart';
import '../features/fypms/presentation/pages/supervisor_progress_page.dart';
import '../features/fypms/presentation/pages/examiner_dashboard_page.dart';
import '../features/fypms/presentation/pages/fypms_placeholder_page.dart';
import '../features/fypms/presentation/pages/lecturer_record_detail_page.dart';
import '../features/fypms/presentation/pages/student_corrections_page.dart';
import '../features/fypms/presentation/pages/student_dashboard_page.dart';
import '../features/fypms/presentation/pages/student_deliverables_page.dart';
import '../features/fypms/presentation/pages/student_forms_page.dart';
import '../features/fypms/presentation/pages/student_lean_canvas_page.dart';
import '../features/fypms/presentation/pages/student_marks_page.dart';
import '../features/fypms/presentation/pages/student_milestones_page.dart';
import '../features/fypms/presentation/pages/student_progress_page.dart';
import '../features/fypms/presentation/pages/student_record_detail_page.dart';
import '../features/fypms/presentation/pages/student_records_page.dart';
import '../features/fypms/presentation/pages/student_reports_page.dart';
import '../features/fypms/presentation/pages/student_supervision_page.dart';
import '../features/fypms/presentation/pages/supervisor_dashboard_page.dart';
import '../features/admin_announcements/presentation/pages/admin_announcements_page.dart';
import '../features/admin_auth/presentation/pages/sign_in_page.dart';
import '../features/admin_awards/presentation/pages/admin_awards_page.dart';
import '../features/admin_booths/presentation/pages/admin_booths_page.dart';
import '../features/admin_dashboard/presentation/pages/dashboard_page.dart';
import '../features/admin_event/presentation/pages/admin_event_page.dart';
import '../features/admin_feedback/presentation/pages/admin_feedback_page.dart';
import '../features/admin_imports/presentation/pages/admin_imports_page.dart';
import '../features/admin_imports/presentation/pages/import_detail_page.dart';
import '../features/admin_lecturers/presentation/pages/admin_lecturers_page.dart';
import '../features/admin_projects/presentation/pages/admin_projects_page.dart';
import '../features/admin_schedule/presentation/pages/admin_schedule_page.dart';
import '../features/admin_settings/presentation/pages/admin_settings_page.dart';
import '../features/admin_visits/presentation/pages/admin_visits_page.dart';
import '../features/exhibition_info/presentation/pages/info_page.dart';
import '../features/faq_privacy/presentation/pages/faq_privacy_page.dart';
import '../features/public_announcements/presentation/pages/announcements_page.dart';
import '../features/public_lecturer/presentation/pages/lecturer_page.dart';
import '../features/lecturer_auth/presentation/pages/lecturer_sign_in_page.dart';
import '../features/lecturer_visits/presentation/pages/lecturer_visits_page.dart';
import '../features/lecturer_visits/presentation/pages/lecturer_visit_detail_page.dart';
import '../features/public_awards/presentation/pages/awards_page.dart';
import '../features/public_booths/presentation/pages/booths_page.dart';
import '../features/public_home/presentation/pages/home_page.dart';
import '../features/public_projects/presentation/pages/project_detail_page.dart';
import '../features/public_projects/presentation/pages/projects_page.dart';
import '../features/public_schedule/presentation/pages/schedule_page.dart';
import '../features/junior_project_guide/presentation/pages/junior_project_browser_page.dart';
import 'widgets/admin_shell.dart';
import 'widgets/fypms_shell.dart';
import 'widgets/public_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final user = ref.read(currentAuthUserProvider);
      final path = state.uri.toString();
      final isLoggingIn = path == '/admin/sign-in';
      final isAdminPath = path.startsWith('/admin');
      final isFypmsPath = path.startsWith('/fypms');
      final isAdminDomain = Uri.base.host == 'admin.fskmjasinfypexhibition.site';

      // FYPMS routes: require authentication.
      if (isFypmsPath) {
        if (user == null) {
          return '/admin/sign-in';
        }
        final roles = await ref.read(fypmsCurrentRolesProvider.future);
        if (roles.isEmpty) {
          // Keep the shell, which renders the "No FYPMS Access" screen.
          return null;
        }
        final home = _fypmsHomeForRoles(roles);
        if (path == '/fypms' || path == '/fypms/') {
          return home;
        }
        // Per-workspace guards: users may only enter workspaces they hold a
        // role in. Redirect to their home workspace otherwise.
        final workspace = _fypmsWorkspaceForPath(path);
        if (workspace != null && !_roleAllowsWorkspace(roles, workspace)) {
          return home;
        }
        return null;
      }

      // On admin domain root, go to sign-in if not authenticated
      if (isAdminDomain && path == '/') {
        return user == null ? '/admin/sign-in' : '/admin';
      }

      if (isAdminPath && !isLoggingIn) {
        if (user == null) {
          return '/admin/sign-in';
        }
        final isAdmin = await ref.read(isAdminProvider.future);
        if (!isAdmin) {
          return '/admin/sign-in';
        }
      }

      if (user != null && isLoggingIn) {
        final isAdmin = await ref.read(isAdminProvider.future);
        if (isAdmin) {
          return '/admin';
        }
        final lecturer = ref.read(lecturerAuthProvider);
        if (lecturer != null) {
          return '/lecturer/visits';
        }
      }

      return null;
    },
    routes: [
      // -------------------------------------------------------------
      // PUBLIC USER SHELL ROUTES
      // -------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) => PublicShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/info',
            builder: (context, state) => const InfoPage(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const SchedulePage(),
          ),
          GoRoute(
            path: '/projects/junior-guide',
            builder: (context, state) => const JuniorProjectBrowserPage(),
          ),
          GoRoute(
            path: '/booths',
            builder: (context, state) => const BoothsPage(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (context, state) => const AnnouncementsPage(),
          ),
          GoRoute(
            path: '/awards',
            builder: (context, state) => const AwardsPage(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsPage(),
            routes: [
              GoRoute(
                path: ':slug',
                builder: (context, state) {
                  final slug = state.pathParameters['slug'] ?? '';
                  return ProjectDetailPage(slug: slug);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/lecturer',
            builder: (context, state) => const LecturerPage(),
          ),
          GoRoute(
            path: '/lecturer/sign-in',
            builder: (context, state) {
              final name = state.uri.queryParameters['name'] ?? '';
              return LecturerSignInPage(displayName: name);
            },
          ),
          GoRoute(
            path: '/lecturer/visits',
            builder: (context, state) => const LecturerVisitsPage(),
            routes: [
              GoRoute(
                path: ':projectId',
                builder: (context, state) {
                  final projectId = state.pathParameters['projectId'] ?? '';
                  return LecturerVisitDetailPage(projectId: projectId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/faq',
            builder: (context, state) => const FaqPrivacyPage(showPrivacyOnly: false),
          ),
          GoRoute(
            path: '/privacy',
            builder: (context, state) => const FaqPrivacyPage(showPrivacyOnly: true),
          ),
        ],
      ),

      // -------------------------------------------------------------
      // STANDALONE ADMIN ROUTE (No Shell NavBar)
      // -------------------------------------------------------------
      GoRoute(
        path: '/admin/sign-in',
        builder: (context, state) => const SignInPage(),
      ),

      // -------------------------------------------------------------
      // PROTECTED ADMIN SHELL ROUTES
      // -------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/admin/event',
            builder: (context, state) => const AdminEventPage(),
          ),
          GoRoute(
            path: '/admin/schedule',
            builder: (context, state) => const AdminSchedulePage(),
          ),
          GoRoute(
            path: '/admin/projects',
            builder: (context, state) => const AdminProjectsPage(),
          ),
          GoRoute(
            path: '/admin/booths',
            builder: (context, state) => const AdminBoothsPage(),
          ),
          GoRoute(
            path: '/admin/announcements',
            builder: (context, state) => const AdminAnnouncementsPage(),
          ),
          GoRoute(
            path: '/admin/feedback',
            builder: (context, state) => const AdminFeedbackPage(),
          ),
          GoRoute(
            path: '/admin/awards',
            builder: (context, state) => const AdminAwardsPage(),
          ),
          GoRoute(
            path: '/admin/visits',
            builder: (context, state) => const AdminVisitsPage(),
          ),
          GoRoute(
            path: '/admin/imports',
            builder: (context, state) => const AdminImportsPage(),
            routes: [
              GoRoute(
                path: ':importId',
                builder: (context, state) {
                  final importId = state.pathParameters['importId'] ?? '';
                  return ImportDetailPage(importId: importId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/lecturers',
            builder: (context, state) => const AdminLecturersPage(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const AdminSettingsPage(),
          ),
        ],
      ),

      // -------------------------------------------------------------
      // PROTECTED FYPMS SHELL ROUTES (role-aware)
      // -------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) => FypmsShell(child: child),
        routes: [
          GoRoute(
            path: '/fypms',
            builder: (context, state) => const StudentDashboardPage(),
          ),
          // ---- Student workspace ----
          GoRoute(
            path: '/fypms/student',
            builder: (context, state) => const StudentDashboardPage(),
          ),
          GoRoute(
            path: '/fypms/student/records',
            builder: (context, state) => const StudentRecordsPage(),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return StudentRecordDetailPage(recordId: recordId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/student/supervision',
            builder: (context, state) => const StudentSupervisionPage(),
          ),
          GoRoute(
            path: '/fypms/student/progress',
            builder: (context, state) => const StudentProgressPage(),
          ),
          GoRoute(
            path: '/fypms/student/forms',
            builder: (context, state) => const StudentFormsPage(),
          ),
          GoRoute(
            path: '/fypms/student/lean-canvas',
            builder: (context, state) => const StudentLeanCanvasPage(),
          ),
          GoRoute(
            path: '/fypms/student/deliverables',
            builder: (context, state) => const StudentDeliverablesPage(),
          ),
          GoRoute(
            path: '/fypms/student/reports',
            builder: (context, state) => const StudentReportsPage(),
          ),
          GoRoute(
            path: '/fypms/student/milestones',
            builder: (context, state) => const StudentMilestonesPage(),
          ),
          GoRoute(
            path: '/fypms/student/corrections',
            builder: (context, state) => const StudentCorrectionsPage(),
          ),
          GoRoute(
            path: '/fypms/student/presentations',
            builder: (context, state) => const FypmsPlaceholderPage(
              title: 'Presentations',
              icon: Icons.event,
            ),
          ),
          GoRoute(
            path: '/fypms/student/marks',
            builder: (context, state) => const StudentMarksPage(),
          ),
          // ---- Supervisor workspace ----
          GoRoute(
            path: '/fypms/supervisor',
            builder: (context, state) => const SupervisorDashboardPage(),
          ),
          GoRoute(
            path: '/fypms/supervisor/records',
            builder: (context, state) => const SupervisorDashboardPage(),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return LecturerRecordDetailPage(recordId: recordId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/supervisor/progress',
            builder: (context, state) => const SupervisorProgressPage(),
          ),
          GoRoute(
            path: '/fypms/supervisor/evaluations',
            builder: (context, state) => const SupervisorEvaluationsPage(),
          ),
          GoRoute(
            path: '/fypms/supervisor/corrections',
            builder: (context, state) => const SupervisorCorrectionsPage(),
          ),
          GoRoute(
            path: '/fypms/supervisor/milestones',
            builder: (context, state) => const SupervisorMilestonesPage(),
          ),
          // ---- Examiner workspace ----
          GoRoute(
            path: '/fypms/examiner',
            builder: (context, state) => const ExaminerDashboardPage(),
          ),
          GoRoute(
            path: '/fypms/examiner/records',
            builder: (context, state) => const ExaminerDashboardPage(),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return LecturerRecordDetailPage(recordId: recordId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/examiner/evaluations',
            builder: (context, state) => const FypmsPlaceholderPage(
              title: 'Evaluations',
              icon: Icons.description,
            ),
          ),
          GoRoute(
            path: '/fypms/examiner/corrections',
            builder: (context, state) => const FypmsPlaceholderPage(
              title: 'Corrections',
              icon: Icons.fact_check,
            ),
          ),
          // ---- CSP workspace ----
          GoRoute(
            path: '/fypms/csp',
            builder: (context, state) => const CspDashboardPage(),
          ),
          GoRoute(
            path: '/fypms/csp/requests',
            builder: (context, state) => const CspRequestsPage(),
          ),
          GoRoute(
            path: '/fypms/csp/offerings',
            builder: (context, state) => const CspOfferingsPage(),
          ),
          GoRoute(
            path: '/fypms/csp/milestones',
            builder: (context, state) => const CspMilestonesPage(),
          ),
          GoRoute(
            path: '/fypms/csp/presentations',
            builder: (context, state) => const FypmsPlaceholderPage(
              title: 'Presentations',
              icon: Icons.event,
            ),
          ),
          GoRoute(
            path: '/fypms/csp/marks',
            builder: (context, state) => const CspMarksPage(),
          ),
          // ---- Coordinator workspace ----
          GoRoute(
            path: '/fypms/coordinator',
            builder: (context, state) => const CoordinatorDashboardPage(),
          ),
          GoRoute(
            path: '/fypms/coordinator/records',
            builder: (context, state) => const CoordinatorRecordsPage(),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return LecturerRecordDetailPage(recordId: recordId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/coordinator/assignments',
            builder: (context, state) => const CoordinatorAssignmentsPage(),
          ),
          GoRoute(
            path: '/fypms/coordinator/requests',
            builder: (context, state) => const CoordinatorRequestsPage(),
          ),
          GoRoute(
            path: '/fypms/coordinator/presentations',
            builder: (context, state) => const CoordinatorPresentationsPage(),
          ),
          GoRoute(
            path: '/fypms/coordinator/expo',
            builder: (context, state) => const CoordinatorExpoPage(),
          ),
          GoRoute(
            path: '/fypms/coordinator/audit',
            builder: (context, state) => const CoordinatorAuditPage(),
          ),
        ],
      ),
    ],
  );
});

/// Resolves the landing workspace for a set of FYPMS role codes.
String _fypmsHomeForRoles(List<String> roles) {
  if (roles.contains('student')) return '/fypms/student';
  if (roles.contains('supervisor') || roles.contains('co_supervisor')) {
    return '/fypms/supervisor';
  }
  if (roles.contains('examiner')) return '/fypms/examiner';
  if (roles.contains('csp600_lecturer') || roles.contains('csp650_lecturer')) {
    return '/fypms/csp';
  }
  if (roles.contains('fyp_coordinator') || roles.contains('admin')) {
    return '/fypms/coordinator';
  }
  return '/fypms';
}

/// Identifies which FYPMS workspace a path belongs to, or null for the
/// workspace-agnostic `/fypms` root.
String? _fypmsWorkspaceForPath(String path) {
  const workspaces = [
    'student',
    'supervisor',
    'examiner',
    'csp',
    'coordinator',
  ];
  final segments = path.split('/');
  if (segments.length < 3 || segments[1] != 'fypms') return null;
  final workspace = segments[2];
  return workspaces.contains(workspace) ? workspace : null;
}

/// Whether the given role codes permit access to the given workspace.
bool _roleAllowsWorkspace(List<String> roles, String workspace) {
  final has = (String code) => roles.contains(code);
  switch (workspace) {
    case 'student':
      return has('student');
    case 'supervisor':
      return has('supervisor') || has('co_supervisor');
    case 'examiner':
      return has('examiner');
    case 'csp':
      return has('csp600_lecturer') || has('csp650_lecturer');
    case 'coordinator':
      return has('fyp_coordinator') || has('admin');
    default:
      return false;
  }
}
