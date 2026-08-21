import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/router.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';

/// FYPMS workspace/role route-guard tests.
///
/// Exercises the real `goRouterProvider` redirect logic: auth gate for all
/// `/fypms` routes, per-role home routing, and cross-workspace blocking.
/// Assertions are on the resolved route path only. The destination pages are
/// rendered (they may reference a not-initialized Supabase instance and have
/// pre-existing layout overflows), so those render-time reports are filtered
/// here; they are not part of this suite's contract.
User? _user(String email) => User.fromJson({
      'id': 'user-1',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': email,
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'identities': <dynamic>[],
      'created_at': '2026-01-01T00:00:00.000Z',
      'updated_at': '2026-01-01T00:00:00.000Z',
    });

class _RouterHost extends ConsumerWidget {
  const _RouterHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(routerConfig: router);
  }
}

/// Renders the router, navigates, and returns the resolved route path after the
/// async redirect has run (bounded pumps; no `pumpAndSettle` because pages
/// contain indeterminate progress indicators).
Future<String> _resolve(
  WidgetTester tester, {
  required String target,
  User? user,
  List<String> roles = const [],
}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentAuthUserProvider.overrideWith((ref) => user),
        fypmsCurrentRolesProvider.overrideWith((ref) async => roles),
      ],
      child: const _RouterHost(),
    ),
  );
  await tester.pump();
  final ctx = tester.element(find.byType(_RouterHost));
  final router = ProviderScope.containerOf(ctx).read(goRouterProvider);
  router.go(target);
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  return router.routerDelegate.currentConfiguration.uri.path;
}

void main() {
  final originalErrorHandler = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      // The target pages touch a not-initialized Supabase instance and have
      // pre-existing desktop-layout overflows. This suite only asserts routes,
      // so filter those render-time reports here.
      final message = details.exception.toString();
      final filtered = message.contains('RenderFlex overflowed') ||
          message.contains('ProviderException') ||
          message.contains('must initialize the supabase instance');
      if (!filtered) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
  });
  tearDown(() => FlutterError.onError = originalErrorHandler);

  group('FYPMS auth gate', () {
    testWidgets('unauthenticated user is sent to sign-in for any /fypms route',
        (tester) async {
      expect(
        await _resolve(tester, target: '/fypms/student', user: null),
        '/admin/sign-in',
      );
      expect(
        await _resolve(tester, target: '/fypms/coordinator/assignments', user: null),
        '/admin/sign-in',
      );
    });
  });

  group('FYPMS role homes', () {
    testWidgets('coordinator lands on /fypms/coordinator', (tester) async {
      expect(
        await _resolve(
            tester, target: '/fypms', user: _user('c@fypms.test'), roles: const ['fyp_coordinator']),
        '/fypms/coordinator',
      );
    });

    testWidgets('admin lands on /fypms/coordinator', (tester) async {
      expect(
        await _resolve(tester, target: '/fypms', user: _user('a@fypms.test'), roles: const ['admin']),
        '/fypms/coordinator',
      );
    });

    testWidgets('student lands on /fypms/student', (tester) async {
      expect(
        await _resolve(tester, target: '/fypms', user: _user('s@fypms.test'), roles: const ['student']),
        '/fypms/student',
      );
    });

    testWidgets('supervisor and co-supervisor land on /fypms/supervisor',
        (tester) async {
      expect(
        await _resolve(tester, target: '/fypms', user: _user('sup@fypms.test'), roles: const ['supervisor']),
        '/fypms/supervisor',
      );
      expect(
        await _resolve(tester, target: '/fypms', user: _user('cosup@fypms.test'), roles: const ['co_supervisor']),
        '/fypms/supervisor',
      );
    });

    testWidgets('examiner lands on /fypms/examiner', (tester) async {
      expect(
        await _resolve(tester, target: '/fypms', user: _user('ex@fypms.test'), roles: const ['examiner']),
        '/fypms/examiner',
      );
    });

    testWidgets('csp lecturer lands on /fypms/csp', (tester) async {
      expect(
        await _resolve(tester, target: '/fypms', user: _user('csp@fypms.test'), roles: const ['csp600_lecturer']),
        '/fypms/csp',
      );
    });

    testWidgets('user without roles keeps the /fypms shell (no access screen)',
        (tester) async {
      expect(
        await _resolve(tester, target: '/fypms', user: _user('none@fypms.test')),
        '/fypms',
      );
    });
  });

  group('Cross-workspace blocking', () {
    testWidgets('student cannot enter supervisor/examiner/coordinator workspaces',
        (tester) async {
      const roles = ['student'];
      expect(
        await _resolve(tester, target: '/fypms/supervisor', user: _user('s@x'), roles: roles),
        '/fypms/student',
      );
      expect(
        await _resolve(tester, target: '/fypms/examiner', user: _user('s@x'), roles: roles),
        '/fypms/student',
      );
      expect(
        await _resolve(tester, target: '/fypms/coordinator/assignments', user: _user('s@x'), roles: roles),
        '/fypms/student',
      );
      expect(
        await _resolve(tester, target: '/fypms/csp', user: _user('s@x'), roles: roles),
        '/fypms/student',
      );
    });

    testWidgets('examiner cannot enter coordinator workspace (self-assign prevention)',
        (tester) async {
      expect(
        await _resolve(tester, target: '/fypms/coordinator/assignments', user: _user('ex@x'), roles: const ['examiner']),
        '/fypms/examiner',
      );
      expect(
        await _resolve(tester, target: '/fypms/csp', user: _user('ex@x'), roles: const ['examiner']),
        '/fypms/examiner',
      );
    });

    testWidgets('csp lecturer cannot enter supervisor workspace', (tester) async {
      expect(
        await _resolve(tester, target: '/fypms/supervisor/evaluations', user: _user('csp@x'), roles: const ['csp650_lecturer']),
        '/fypms/csp',
      );
    });

    testWidgets('supervisor cannot enter coordinator workspace', (tester) async {
      expect(
        await _resolve(tester, target: '/fypms/coordinator/records', user: _user('sup@x'), roles: const ['supervisor']),
        '/fypms/supervisor',
      );
    });
  });
}