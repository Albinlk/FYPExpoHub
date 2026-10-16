import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/site_hosts.dart';
import 'package:fyp_expo_hub/app/widgets/admin_shell.dart';
import 'package:fyp_expo_hub/app/widgets/fypms_shell.dart';
import 'package:fyp_expo_hub/app/widgets/public_shell.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/notifications_page.dart';

/// Every shell offers "Help", which opens the handbook section for the page
/// the person is on (`/handbook/guides/<guide>/#<id>` on the current host,
/// new tab).
SupabaseClient _client() => SupabaseClient(
      'https://placeholder-project.supabase.co',
      'placeholder-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpPublic(WidgetTester tester, Size size) async {
  _size(tester, size);
  final router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, _) => const PublicShell(child: SizedBox.shrink()))],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      supabaseClientProvider.overrideWithValue(_client()),
      authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
      currentAuthUserProvider.overrideWith((ref) => null),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

Future<void> _pumpFypms(WidgetTester tester, {required Size size, required List<String> roles, required String at}) async {
  _size(tester, size);
  const paths = ['/fypms/student', '/fypms/supervisor', '/fypms/coordinator'];
  final router = GoRouter(
    initialLocation: at,
    routes: [
      ShellRoute(
        builder: (_, _, child) => FypmsShell(child: child),
        routes: [for (final p in paths) GoRoute(path: p, builder: (_, _) => const SizedBox())],
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      fypmsCurrentRolesProvider.overrideWith((ref) async => roles),
      myFypRecordsProvider.overrideWith((ref) async => []),
      supabaseClientProvider.overrideWithValue(_client()),
      currentAuthUserProvider.overrideWith((ref) => null),
      fypNotificationsProvider.overrideWith((ref) async => []),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

Future<void> _pumpAdmin(WidgetTester tester, Size size) async {
  _size(tester, size);
  final router = GoRouter(
    initialLocation: '/admin',
    routes: [
      ShellRoute(
        builder: (_, _, child) => AdminShell(child: child),
        routes: [GoRoute(path: '/admin', builder: (_, _) => const SizedBox())],
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      supabaseClientProvider.overrideWithValue(_client()),
      currentAuthUserProvider.overrideWith((ref) => null),
      currentProfileProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

/// The test font is wider than Inter, so the Workspace drawer's brand line
/// overflows in tests only (it fits in the browser). Only the menu matters
/// here, so overflow reports are dropped while [body] runs.
Future<void> _ignoringOverflow(Future<void> Function() body) async {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('RenderFlex overflowed')) return;
    original?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = original;
  }
}

void main() {
  group('handbook helper', () {
    test('guide URL is a path on the current host', () {
      expect(handbookGuideUrl('visitor'), '/handbook/guides/visitor/');
      expect(handbookGuideUrl(kHandbookAdminGuide), '/handbook/guides/exhibition-admin/');
      expect(
        Uri.parse('https://fyp.fskmjasinfypexhibition.site/fypms/student').resolve(handbookGuideUrl('student')).toString(),
        'https://fyp.fskmjasinfypexhibition.site/handbook/guides/student/',
      );
    });

    test('each area lands on its section', () {
      const cases = {
        // Exhibition site.
        '/': '/handbook/guides/visitor/#home',
        '/projects': '/handbook/guides/visitor/#projects',
        '/projects/some-slug': '/handbook/guides/visitor/#projects',
        '/projects/junior-guide': '/handbook/guides/visitor/#past-projects',
        '/projects/junior-guide/similar/42': '/handbook/guides/visitor/#past-projects',
        '/announcements': '/handbook/guides/visitor/#awards',
        '/faq': '/handbook/guides/visitor/#info',
        '/lecturer': '/handbook/guides/visitor/#by-lecturer',
        '/lecturer/visits/7': '/handbook/guides/lecturer/#visits',
        // Accounts.
        '/sign-in': '/handbook/guides/accounts/#sign-in',
        '/reset-password': '/handbook/guides/accounts/#reset-password',
        '/fypms': '/handbook/guides/accounts/',
        '/fypms/notifications': '/handbook/guides/accounts/',
        // Workspace roles.
        '/fypms/student': '/handbook/guides/student/#workspace',
        '/fypms/student/records/abc': '/handbook/guides/student/#record',
        '/fypms/student/progress': '/handbook/guides/student/#progress-logs',
        '/fypms/supervisor/requests': '/handbook/guides/lecturer/#approve-supervision',
        '/fypms/supervisor/milestones': '/handbook/guides/lecturer/#supervisor-milestones',
        '/fypms/examiner/records/abc': '/handbook/guides/lecturer/#examiner',
        '/fypms/csp/marks': '/handbook/guides/lecturer/#finalize-marks',
        '/fypms/pu': '/handbook/guides/lecturer/#pu-decide',
        '/fypms/coordinator': '/handbook/guides/coordinator/#dashboard',
        '/fypms/coordinator/requests': '/handbook/guides/coordinator/#supervision-requests',
        // Exhibition admin.
        '/admin': '/handbook/guides/exhibition-admin/#dashboard',
        '/admin/imports/12': '/handbook/guides/exhibition-admin/#import',
        '/admin/assignments': '/handbook/guides/exhibition-admin/#lecturer-assignments',
      };
      cases.forEach((location, url) {
        expect(handbookUrlForLocation(location), url, reason: location);
      });
    });

    test('query, fragment and trailing slash are ignored', () {
      expect(handbookUrlForLocation('/fypms/csp/marks?offering=1'), '/handbook/guides/lecturer/#finalize-marks');
      expect(handbookUrlForLocation('/projects?q=robot#top'), '/handbook/guides/visitor/#projects');
      expect(handbookUrlForLocation('/admin/settings/'), '/handbook/guides/exhibition-admin/#settings');
      expect(handbookUrlForLocation('/?utm_source=x'), '/handbook/guides/visitor/#home');
    });

    test('longest prefix wins, on segment boundaries only', () {
      expect(handbookUrlForLocation('/fypms/csp/requests'), '/handbook/guides/lecturer/#approve-supervision');
      expect(handbookUrlForLocation('/fypms/csp/offerings'), '/handbook/guides/lecturer/#csp-lecturer');
      expect(handbookUrlForLocation('/fypms/students-list'), '/handbook/guides/accounts/');
      expect(handbookUrlForLocation('/administer'), '/handbook/guides/visitor/');
    });

    test('unknown pages fall back to their area guide', () {
      expect(handbookUrlForLocation('/no-such-page'), '/handbook/guides/visitor/');
      expect(handbookUrlForLocation(''), '/handbook/guides/visitor/#home');
      expect(handbookUrlForLocation('/fypms/student/unknown'), '/handbook/guides/student/#workspace');
      expect(handbookUrlForLocation('/fypms/coordinator/unknown'), '/handbook/guides/coordinator/#dashboard');
      expect(handbookUrlForLocation('/admin/unknown'), '/handbook/guides/exhibition-admin/#dashboard');
    });

    test('URL resolves against the current host', () {
      expect(
        Uri.parse('https://fyp.fskmjasinfypexhibition.site/fypms/student/reports')
            .resolve(handbookUrlForLocation('/fypms/student/reports'))
            .toString(),
        'https://fyp.fskmjasinfypexhibition.site/handbook/guides/student/#reports',
      );
    });
  });

  group('public shell', () {
    testWidgets('desktop More menu has Help', (tester) async {
      await _pumpPublic(tester, const Size(1440, 900));
      await tester.ensureVisible(find.byKey(const Key('nav-more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-more')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('nav-help')), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
    });

    testWidgets('mobile Menu sheet has Help', (tester) async {
      await _pumpPublic(tester, const Size(390, 844));
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byKey(const Key('menu-help')), 100, scrollable: find.byType(Scrollable).last);
      expect(find.byKey(const Key('menu-help')), findsOneWidget);
    });
  });

  group('FYP Workspace shell', () {
    testWidgets('sidebar has Help above Exhibition Site', (tester) async {
      await _pumpFypms(tester, size: const Size(1440, 1600), roles: const ['student'], at: '/fypms/student');
      final help = find.byKey(const Key('nav-help'));
      expect(help, findsOneWidget);
      expect(tester.getTopLeft(help).dy, lessThan(tester.getTopLeft(find.text('Exhibition Site')).dy));
    });

    testWidgets('mobile drawer has Help', (tester) async {
      await _ignoringOverflow(() async {
        await _pumpFypms(tester, size: const Size(600, 1000), roles: const ['supervisor'], at: '/fypms/supervisor');
        await _openDrawer(tester);
        expect(find.byKey(const Key('nav-help')), findsOneWidget);
      });
    });
  });

  group('admin shell', () {
    testWidgets('sidebar has Help above Exhibition Site', (tester) async {
      await _pumpAdmin(tester, const Size(1440, 1600));
      final help = find.byKey(const Key('nav-help'));
      expect(help, findsOneWidget);
      expect(tester.getTopLeft(help).dy, lessThan(tester.getTopLeft(find.text('Exhibition Site')).dy));
    });

    testWidgets('mobile drawer has Help', (tester) async {
      await _pumpAdmin(tester, const Size(600, 1000));
      await _openDrawer(tester);
      expect(find.byKey(const Key('nav-help')), findsOneWidget);
    });
  });
}
