import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/router.dart';
import 'package:fyp_expo_hub/app/site_hosts.dart';
import 'package:fyp_expo_hub/core/domain/models/lecturer.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

/// The exhibition is the homepage; CSP600 / CSP650 (the FYP Workspace) is
/// behind sign-in and ready to move to `fyp.fskmjasinfypexhibition.site`.
const _cspHost = 'fyp.fskmjasinfypexhibition.site';

User _user() => User.fromJson({
      'id': 'user-1',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 's@student.uitm.edu.my',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'identities': <dynamic>[],
      'created_at': '2026-01-01T00:00:00.000Z',
      'updated_at': '2026-01-01T00:00:00.000Z',
    })!;

/// Not a lecturer (the real notifier reads an uninitialised Supabase).
class _NoLecturer extends LecturerAuthNotifier {
  @override
  Lecturer? build() => null;
}

class _Host extends ConsumerWidget {
  const _Host();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      MaterialApp.router(routerConfig: ref.watch(goRouterProvider));
}

/// Navigates and returns the resolved location (path + query).
Future<Uri> _resolve(
  WidgetTester tester, {
  required String target,
  String cspHost = '',
  String host = kMainHost,
  User? user,
  List<String> roles = const [],
  bool isAdmin = false,
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      currentAuthUserProvider.overrideWith((ref) => user),
      fypmsCurrentRolesProvider.overrideWith((ref) async => roles),
      isAdminProvider.overrideWith((ref) async => isAdmin),
      isLecturerProvider.overrideWith((ref) async => false),
      lecturerAuthProvider.overrideWith(_NoLecturer.new),
      cspHostProvider.overrideWithValue(cspHost),
      currentHostProvider.overrideWithValue(host),
    ],
    child: const _Host(),
  ));
  await tester.pump();
  final router = ProviderScope.containerOf(tester.element(find.byType(_Host))).read(goRouterProvider);
  router.go(target);
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  return router.routerDelegate.currentConfiguration.uri;
}

void main() {
  final originalOnError = FlutterError.onError;
  setUp(() {
    // Destination pages touch an uninitialised Supabase; only routes matter.
    FlutterError.onError = (details) {
      final m = details.exception.toString();
      if (m.contains('RenderFlex overflowed') ||
          m.contains('ProviderException') ||
          m.contains('must initialize the supabase instance')) {
        return;
      }
      FlutterError.dumpErrorToConsole(details);
    };
  });
  tearDown(() => FlutterError.onError = originalOnError);

  group('one site (today)', () {
    testWidgets('the old /expo address opens the exhibition home', (tester) async {
      expect((await _resolve(tester, target: '/expo')).path, '/');
    });

    testWidgets('signed out, the Workspace asks to sign in and comes back', (tester) async {
      final uri = await _resolve(tester, target: '/fypms');
      expect(uri.path, '/sign-in');
      expect(uri.queryParameters['from'], '/fypms');
    });

    testWidgets('a signed-in student lands in their CSP workspace', (tester) async {
      final uri = await _resolve(tester, target: '/fypms', user: _user(), roles: const ['student']);
      expect(uri.path, '/fypms/student');
    });

    testWidgets('a signed-in non-admin opening /admin stays on sign-in, told why', (tester) async {
      final uri = await _resolve(tester, target: '/admin/settings', user: _user(), roles: const ['supervisor']);
      expect(uri.path, '/sign-in');
      expect(uri.queryParameters['reason'], 'not-admin');
      expect(find.byKey(const Key('not-admin-notice')), findsOneWidget);
      expect(find.textContaining('s@student.uitm.edu.my'), findsOneWidget);
    });

    testWidgets('a signed-in account with no role is told why on sign-in', (tester) async {
      final uri = await _resolve(tester, target: '/sign-in', user: _user());
      expect(uri.path, '/sign-in');
      expect(uri.queryParameters['reason'], 'no-access');
      expect(find.byKey(const Key('no-access-notice')), findsOneWidget);
      expect(find.textContaining('has no access yet'), findsOneWidget);
      expect(find.text('Switch Account'), findsOneWidget);
    });

    testWidgets('the no-access notice keeps the return path and does not loop', (tester) async {
      final uri = await _resolve(tester,
          target: '/sign-in?from=%2Fadmin&reason=no-access', user: _user());
      expect(uri.path, '/sign-in');
      expect(uri.queryParameters['reason'], 'no-access');
      expect(uri.queryParameters['from'], '/admin');
      expect(find.byKey(const Key('no-access-notice')), findsOneWidget);
    });

    testWidgets('once a role is granted, the no-access page moves on', (tester) async {
      final uri = await _resolve(tester,
          target: '/sign-in?reason=no-access', user: _user(), roles: const ['student']);
      expect(uri.path, '/fypms/student');
    });

    testWidgets('signed out, the sign-in page shows no access notice', (tester) async {
      final uri = await _resolve(tester, target: '/sign-in?reason=no-access');
      expect(uri.path, '/sign-in');
      expect(find.byKey(const Key('no-access-notice')), findsNothing);
    });
  });

  group('Workspace on its own host', () {
    testWidgets('main site sends /fypms… to the Workspace host', (tester) async {
      final uri = await _resolve(tester, target: '/fypms/student?tab=forms', cspHost: _cspHost);
      expect(uri.path, kExternalRedirectPath);
      expect(uri.queryParameters['to'], 'https://$_cspHost/fypms/student?tab=forms');
    });

    testWidgets('main site keeps serving the exhibition', (tester) async {
      expect((await _resolve(tester, target: '/projects', cspHost: _cspHost)).path, '/projects');
    });

    testWidgets('on the Workspace host, / opens the Workspace (sign-in first)', (tester) async {
      final uri = await _resolve(tester, target: '/', cspHost: _cspHost, host: _cspHost);
      expect(uri.path, '/sign-in');
      expect(uri.queryParameters['from'], '/fypms');
    });

    testWidgets('on the Workspace host, exhibition pages go back to the main site', (tester) async {
      final uri = await _resolve(tester, target: '/booths', cspHost: _cspHost, host: _cspHost);
      expect(uri.path, kExternalRedirectPath);
      expect(uri.queryParameters['to'], 'https://$kMainHost/booths');
    });

    testWidgets('on the Workspace host, signing in lands in the Workspace', (tester) async {
      final uri = await _resolve(tester,
          target: '/sign-in', cspHost: _cspHost, host: _cspHost, user: _user(), roles: const ['student']);
      expect(uri.path, '/fypms/student');
    });
  });

  test('the hop only follows our own hosts', () {
    expect(allowedRedirectHosts(_cspHost), {kMainHost, _cspHost});
    expect(allowedRedirectHosts(''), {kMainHost});
    expect(isWorkspacePath('/fypms/csp'), isTrue);
    expect(isWorkspacePath('/projects'), isFalse);
  });
}
