import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router_title_io.dart'
    if (dart.library.js_interop) '../app/router_title_web.dart';
import '../app/theme/theme.dart';
import '../core/supabase/supabase_client_provider.dart' show currentAuthUserProvider;
import 'router_guards.dart';
import '../features/admin_auth/presentation/pages/sign_in_page.dart';
import '../features/admin_auth/presentation/pages/reset_password_page.dart';
import '../features/public_archive/presentation/pages/archive_page.dart';
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
import '../features/junior_project_guide/presentation/pages/similar_projects_page.dart';
import 'widgets/public_shell.dart';
import 'deferred/admin_pages.dart' deferred as admin;
import 'deferred/deferred_page.dart';
import 'deferred/fypms_pages.dart' deferred as fypms;
import 'site_hosts.dart';
import 'widgets/external_redirect_page.dart';

// -------------------------------------------------------------
// DEFERRED AREAS
// -------------------------------------------------------------
// The Admin area and the FYP Workspace are deferred libraries: on the web the
// JavaScript build ships them as separate part files that are downloaded the
// first time someone opens /admin/** or /fypms/**, so exhibition visitors
// never fetch that code. Route guards (resolveRouterRedirect) still run
// before any of it is needed; only the page bodies wait for the download.

final DeferredLibrary _adminLibrary = DeferredLibrary(admin.loadLibrary);
final DeferredLibrary _fypmsLibrary = DeferredLibrary(fypms.loadLibrary);

/// An Admin-area widget, built once the admin library has loaded.
Widget _admin(Widget Function() build) =>
    DeferredPage(library: _adminLibrary, builder: (_) => build());

/// An FYP Workspace widget, built once the workspace library has loaded.
Widget _fypms(Widget Function() build) =>
    DeferredPage(library: _fypmsLibrary, builder: (_) => build());

/// Fetches the Admin and FYP Workspace code ahead of time, e.g. once a
/// signed-in user is about to enter either area. Safe to call repeatedly.
///
/// Tests that render pages from both areas in one file call this from
/// `setUpAll`: on the Dart VM the first `loadLibrary` call is tied to the
/// zone it ran in, so a load first started inside one `testWidgets` body can
/// never complete in a later test's zone.
Future<void> preloadDeferredAreas() =>
    Future.wait([_adminLibrary.load(), _fypmsLibrary.load()]);

final goRouterProvider = Provider<GoRouter>((ref) {
  // Re-run the redirect guards whenever the signed-in user changes —
  // sign-in, sign-out, or an expired session — instead of only on the next
  // navigation (a user whose session ended could otherwise stay on an
  // admin page).
  final authChanges = ValueNotifier<int>(0);
  ref.listen(currentAuthUserProvider.select((u) => u?.id), (_, _) {
    authChanges.value++;
  });
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authChanges,
    observers: [RouteTitleObserver()],
    // Branded 404 for unknown URLs.
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: _NotFoundPage(uri: state.uri.toString()),
    ),
    redirect: (context, state) {
      return resolveRouterRedirect(ref, state.uri.toString());
    },
    routes: [
      // -------------------------------------------------------------
      // PUBLIC USER SHELL ROUTES
      // -------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) => PublicShell(child: child),
        routes: [
          // The exhibition is the homepage. CSP600 / CSP650 (the FYP
          // Workspace) is reached by signing in; /expo redirects here.
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
            routes: [
              GoRoute(
                path: 'similar/:projectId',
                builder: (context, state) => SimilarProjectsPage(
                  projectId: state.pathParameters['projectId'] ?? '',
                ),
              ),
            ],
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
            path: '/archive',
            builder: (context, state) => const ArchivePage(),
            routes: [
              GoRoute(
                path: ':slug',
                builder: (context, state) => ArchivedEventPage(slug: state.pathParameters['slug'] ?? ''),
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
        path: kSignInPath,
        builder: (context, state) =>
            SignInPage(notAdmin: state.uri.queryParameters['reason'] == kNotAdminReason, noAccess: state.uri.queryParameters['reason'] == kNoAccessReason),
      ),
      // Hop to the other site (exhibition ↔ FYP Workspace host).
      GoRoute(
        path: kExternalRedirectPath,
        builder: (context, state) => ExternalRedirectPage(to: state.uri.queryParameters['to']),
      ),
      // Old address; resolveRouterRedirect forwards it to /sign-in.
      GoRoute(
        path: kLegacySignInPath,
        builder: (context, state) => const SignInPage(),
      ),
      // Password-recovery email landing (G-32). Outside /admin so the admin
      // guard doesn't bounce the short-lived recovery session.
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // -------------------------------------------------------------
      // PROTECTED ADMIN SHELL ROUTES
      // -------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) => _admin(() => admin.MfaGate(child: admin.AdminShell(child: child))),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => _admin(() => admin.DashboardPage()),
          ),
          GoRoute(
            path: '/admin/event',
            builder: (context, state) => _admin(() => admin.AdminEventPage()),
          ),
          GoRoute(
            path: '/admin/schedule',
            builder: (context, state) => _admin(() => admin.AdminSchedulePage()),
          ),
          GoRoute(
            path: '/admin/projects',
            builder: (context, state) => _admin(() => admin.AdminProjectsPage()),
          ),
          GoRoute(
            path: '/admin/booths',
            builder: (context, state) => _admin(() => admin.AdminBoothsPage()),
          ),
          GoRoute(
            path: '/admin/announcements',
            builder: (context, state) => _admin(() => admin.AdminAnnouncementsPage()),
          ),
          GoRoute(
            path: '/admin/feedback',
            builder: (context, state) => _admin(() => admin.AdminFeedbackPage()),
          ),
          GoRoute(
            path: '/admin/awards',
            builder: (context, state) => _admin(() => admin.AdminAwardsPage()),
          ),
          GoRoute(
            path: '/admin/visits',
            builder: (context, state) => _admin(() => admin.AdminVisitsPage()),
          ),
          GoRoute(
            path: '/admin/imports',
            builder: (context, state) => _admin(() => admin.AdminImportsPage()),
            routes: [
              GoRoute(
                path: ':importId',
                builder: (context, state) {
                  final importId = state.pathParameters['importId'] ?? '';
                  return _admin(() => admin.ImportDetailPage(importId: importId));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/lecturers',
            builder: (context, state) => _admin(() => admin.AdminLecturersPage()),
          ),
          GoRoute(
            path: '/admin/assignments',
            builder: (context, state) => _admin(() => admin.AdminAssignmentsPage()),
          ),
          GoRoute(
            path: '/admin/audit',
            builder: (context, state) => _admin(() => admin.AdminAuditPage()),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => _admin(() => admin.AdminSettingsPage()),
          ),
        ],
      ),

      // -------------------------------------------------------------
      // PROTECTED FYPMS SHELL ROUTES (role-aware)
      // -------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) => _fypms(() => fypms.MfaGate(child: fypms.FypmsShell(child: child))),
        routes: [
          GoRoute(
            path: '/fypms',
            builder: (context, state) => _fypms(() => fypms.StudentDashboardPage()),
          ),
          // ---- Student workspace ----
          GoRoute(
            path: '/fypms/student',
            builder: (context, state) => _fypms(() => fypms.StudentDashboardPage()),
          ),
          GoRoute(
            path: '/fypms/student/records',
            builder: (context, state) => _fypms(() => fypms.StudentRecordsPage()),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return _fypms(() => fypms.StudentRecordDetailPage(recordId: recordId));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/student/supervision',
            builder: (context, state) => _fypms(() => fypms.StudentSupervisionPage()),
          ),
          GoRoute(
            path: '/fypms/student/progress',
            builder: (context, state) => _fypms(() => fypms.StudentProgressPage()),
          ),
          GoRoute(
            path: '/fypms/student/forms',
            builder: (context, state) => _fypms(() => fypms.StudentFormsPage()),
          ),
          GoRoute(
            path: '/fypms/student/lean-canvas',
            builder: (context, state) => _fypms(() => fypms.StudentLeanCanvasPage()),
          ),
          GoRoute(
            path: '/fypms/student/deliverables',
            builder: (context, state) => _fypms(() => fypms.StudentDeliverablesPage()),
          ),
          GoRoute(
            path: '/fypms/student/reports',
            builder: (context, state) => _fypms(() => fypms.StudentReportsPage()),
          ),
          GoRoute(
            path: '/fypms/student/milestones',
            builder: (context, state) => _fypms(() => fypms.StudentMilestonesPage()),
          ),
          GoRoute(
            path: '/fypms/student/corrections',
            builder: (context, state) => _fypms(() => fypms.StudentCorrectionsPage()),
          ),
          GoRoute(
            path: '/fypms/student/presentations',
            builder: (context, state) => _fypms(() => fypms.StudentPresentationsPage()),
          ),
          GoRoute(
            path: '/fypms/student/marks',
            builder: (context, state) => _fypms(() => fypms.StudentMarksPage()),
          ),
          // ---- Supervisor workspace ----
          GoRoute(
            path: '/fypms/supervisor',
            builder: (context, state) => _fypms(() => fypms.SupervisorDashboardPage()),
          ),
          GoRoute(
            path: '/fypms/supervisor/records',
            builder: (context, state) => _fypms(() => fypms.SupervisorDashboardPage()),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return _fypms(() => fypms.LecturerRecordDetailPage(recordId: recordId));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/supervisor/requests',
            builder: (context, state) => _fypms(() => fypms.SupervisorRequestsPage()),
          ),
          GoRoute(
            path: '/fypms/supervisor/reports',
            builder: (context, state) => _fypms(() => fypms.SupervisorReportsPage()),
          ),
          GoRoute(
            path: '/fypms/supervisor/progress',
            builder: (context, state) => _fypms(() => fypms.SupervisorProgressPage()),
          ),
          GoRoute(
            path: '/fypms/supervisor/evaluations',
            builder: (context, state) => _fypms(() => fypms.SupervisorEvaluationsPage()),
          ),
          GoRoute(
            path: '/fypms/supervisor/corrections',
            builder: (context, state) => _fypms(() => fypms.SupervisorCorrectionsPage()),
          ),
          GoRoute(
            path: '/fypms/supervisor/milestones',
            builder: (context, state) => _fypms(() => fypms.SupervisorMilestonesPage()),
          ),
          // ---- Examiner workspace ----
          GoRoute(
            path: '/fypms/examiner',
            builder: (context, state) => _fypms(() => fypms.ExaminerDashboardPage()),
          ),
          GoRoute(
            path: '/fypms/examiner/records',
            builder: (context, state) => _fypms(() => fypms.ExaminerDashboardPage()),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return _fypms(() => fypms.LecturerRecordDetailPage(recordId: recordId));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/examiner/evaluations',
            builder: (context, state) => _fypms(() => fypms.ExaminerEvaluationsPage()),
          ),
          GoRoute(
            path: '/fypms/examiner/corrections',
            builder: (context, state) => _fypms(() => fypms.ExaminerCorrectionsPage()),
          ),
          // ---- CSP workspace ----
          GoRoute(
            path: '/fypms/csp',
            builder: (context, state) => _fypms(() => fypms.CspDashboardPage()),
          ),
          GoRoute(
            path: '/fypms/csp/requests',
            builder: (context, state) => _fypms(() => fypms.CspRequestsPage()),
          ),
          GoRoute(
            path: '/fypms/csp/offerings',
            builder: (context, state) => _fypms(() => fypms.CspOfferingsPage()),
          ),
          GoRoute(
            path: '/fypms/csp/cohort',
            builder: (context, state) => _fypms(() => fypms.CspCohortPage()),
          ),
          GoRoute(
            path: '/fypms/csp/nominations',
            builder: (context, state) => _fypms(() => fypms.NominatorNominationsPage()),
          ),
          GoRoute(
            path: '/fypms/csp/milestones',
            builder: (context, state) => _fypms(() => fypms.CspMilestonesPage()),
          ),
          GoRoute(
            path: '/fypms/csp/evaluations',
            builder: (context, state) => _fypms(() => fypms.CspEvaluationsPage()),
          ),
          GoRoute(
            path: '/fypms/notifications',
            builder: (context, state) => _fypms(() => fypms.NotificationsPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/reports',
            builder: (context, state) => _fypms(() => fypms.CoordinatorReportsPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/rubrics',
            builder: (context, state) => _fypms(() => fypms.CoordinatorRubricsPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/users',
            builder: (context, state) => _fypms(() => fypms.CoordinatorUsersPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/enrol',
            builder: (context, state) => _fypms(() => fypms.CoordinatorEnrolPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/semesters',
            builder: (context, state) => _fypms(() => fypms.CoordinatorSemestersPage()),
          ),
          GoRoute(
            path: '/fypms/pu',
            builder: (context, state) => _fypms(() => fypms.PuNominationsPage()),
          ),
          GoRoute(
            path: '/fypms/csp/presentations',
            builder: (context, state) => _fypms(() => fypms.CoordinatorPresentationsPage()),
          ),
          GoRoute(
            path: '/fypms/csp/marks',
            builder: (context, state) => _fypms(() => fypms.CspMarksPage()),
          ),
          // ---- Coordinator workspace ----
          GoRoute(
            path: '/fypms/coordinator',
            builder: (context, state) => _fypms(() => fypms.CoordinatorDashboardPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/records',
            builder: (context, state) => _fypms(() => fypms.CoordinatorRecordsPage()),
            routes: [
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return _fypms(() => fypms.LecturerRecordDetailPage(recordId: recordId));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fypms/coordinator/assignments',
            builder: (context, state) => _fypms(() => fypms.CoordinatorAssignmentsPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/requests',
            builder: (context, state) => _fypms(() => fypms.CoordinatorRequestsPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/presentations',
            builder: (context, state) => _fypms(() => fypms.CoordinatorPresentationsPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/expo',
            builder: (context, state) => _fypms(() => fypms.CoordinatorExpoPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/mark-allocation',
            builder: (context, state) => _fypms(() => fypms.CoordinatorMarkAllocationPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/audit',
            builder: (context, state) => _fypms(() => fypms.CoordinatorAuditPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/letters',
            builder: (context, state) => _fypms(() => fypms.CoordinatorLettersPage()),
          ),
          GoRoute(
            path: '/fypms/coordinator/nominations',
            builder: (context, state) => _fypms(() => fypms.NominatorNominationsPage()),
          ),
        ],
      ),
    ],
  );
});

/// Branded 404 page for unknown routes.
class _NotFoundPage extends StatelessWidget {
  final String uri;


  const _NotFoundPage({required this.uri});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final padding =
        isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile;
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.travel_explore_outlined,
                size: 72,
                color: DesignSystem.outlineVariant,
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              Text(
                'Page Not Found',
                textAlign: TextAlign.center,
                style: (isDesktop ? DesignSystem.h2 : DesignSystem.h2Mobile)
                    .copyWith(color: DesignSystem.primary),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              Text(
                'The page "$uri" does not exist or has moved.',
                textAlign: TextAlign.center,
                style: DesignSystem.bodyMd.copyWith(
                  color: DesignSystem.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceXl),
              Wrap(
                spacing: DesignSystem.spaceMd,
                runSpacing: DesignSystem.spaceSm,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home_outlined, size: 18),
                    label: const Text('Go Home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.primary,
                      foregroundColor: DesignSystem.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/projects'),
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    label: const Text('Browse Projects'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignSystem.primary,
                      side: const BorderSide(color: DesignSystem.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sets the browser tab / window title per route (NavigatorObserver).
/// Uses `document.title` via JS interop on web; no-op elsewhere.
class RouteTitleObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _apply(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _apply(newRoute);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _apply(previousRoute);

  void _apply(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name;
    if (name == null) return;
    final title = _titleForPath(name);
    _setDocumentTitle(title.isEmpty ? 'FYP Expo Hub' : title);
  }

  static String _titleForPath(String path) {
    String t(String s) => '$s · FYP Expo Hub';
    if (path == '/') return 'FYP Expo Hub — FSKM Final Year Project Exhibition';
    if (path == '/info') return t('Exhibition Info');
    if (path == '/schedule') return t('Schedule');
    if (path == '/booths') return t('Booths');
    if (path == '/announcements') return t('Announcements');
    if (path == '/awards') return t('Awards');
    if (path == '/projects/junior-guide') return t('Past Projects Guide');
    if (path.startsWith('/projects/')) return t('Project Details');
    if (path == '/projects') return t('Projects');
    if (path == '/lecturer/sign-in' || path == '/lecturer/visits') {
      return t('My Visits');
    }
    if (path == '/lecturer' || path.startsWith('/lecturer/')) {
      return t('Find by Lecturer');
    }
    if (path == '/faq') return t('FAQ');
    if (path == '/privacy') return t('Privacy Policy');
    if (path == '/archive' || path.startsWith('/archive/')) return t('Past Exhibitions');
    if (path == '/reset-password') return t('Reset Password');
    if (path == '/admin') return t('Admin Dashboard');
    if (path == '/sign-in' || path == '/admin/sign-in') return t('Sign In');
    if (path.startsWith('/admin/')) return t('Admin · ${_segmentLabel(path)}');
    if (path == '/fypms') return t('FYPMS');
    if (path.startsWith('/fypms')) return t('FYPMS · ${_segmentLabel(path)}');
    return '';
  }

  /// "/admin/imports/abc-123" → "Imports"; "/fypms/pu/nominations" → "Nominations".
  /// Id-like trailing segments (digits, uuids) are skipped.
  static String _segmentLabel(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    var i = parts.length - 1;
    while (i > 1 && RegExp(r'^[0-9a-f-]{8,}$|^\d+$').hasMatch(parts[i])) {
      i--;
    }
    final raw = parts.length > 1 ? parts[i] : parts.first;
    return raw
        .split(RegExp(r'[-_]'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Exposed for tests.
  static String titleForPath(String path) => _titleForPath(path);

  static void _setDocumentTitle(String title) {
    // Web sets document.title via conditional import; no-op elsewhere.
    setDocumentTitleImpl(title);
  }
}
