import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/supabase/supabase_client_provider.dart';
import '../core/state/state_providers.dart';
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
import 'widgets/admin_shell.dart';
import 'widgets/public_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final user = ref.read(currentAuthUserProvider);
      final path = state.uri.toString();
      final isLoggingIn = path == '/admin/sign-in';
      final isAdminPath = path.startsWith('/admin');
      final isAdminDomain = Uri.base.host == 'admin.fskmjasinfypexhibition.site';

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
    ],
  );
});
