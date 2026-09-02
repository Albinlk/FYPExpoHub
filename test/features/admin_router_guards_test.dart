import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/router.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/domain/models/lecturer.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';

/// Admin + lecturer route-guard tests for the non-FYPMS halves of the router:
///   - unauthenticated `/admin/**` -> `/admin/sign-in`
///   - authenticated non-admin `/admin/**` -> `/admin/sign-in`
///   - signed-in admin on `/admin/sign-in` -> `/admin`
///   - signed-in lecturer on `/admin/sign-in` -> `/lecturer/visits`
/// Assertions are on the resolved route path only; page render-time errors
/// (uninitialized Supabase, overflows) are filtered like the FYPMS suite.
User _user(String email) => User.fromJson({
      'id': 'user-1',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': email,
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'identities': <dynamic>[],
      'created_at': '2026-01-01T00:00:00.000Z',
      'updated_at': '2026-01-01T00:00:00.000Z',
    })!;

Lecturer _lecturer() => Lecturer(
      id: 'user-1',
      uid: 'user-1',
      displayName: 'DR. AMINAH',
      email: 'aminah@uitm.edu.my',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _RouterHost extends ConsumerWidget {
  const _RouterHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(routerConfig: router);
  }
}

/// Notifier stub that skips the config/user re-evaluation logic and just
/// returns a fixed lecturer state.
class _FixedLecturerNotifier extends LecturerAuthNotifier {
  _FixedLecturerNotifier(this._lecturer);

  final Lecturer? _lecturer;

  @override
  Lecturer? build() => _lecturer;
}

Future<String> _resolve(
  WidgetTester tester, {
  required String target,
  User? user,
  bool isAdmin = false,
  Lecturer? lecturer,
}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentAuthUserProvider.overrideWith((ref) => user),
        isAdminProvider.overrideWith((ref) async => isAdmin),
        lecturerAuthProvider
            .overrideWith(() => _FixedLecturerNotifier(lecturer)),
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

  group('Admin auth gate', () {
    testWidgets('unauthenticated user hitting /admin routes is sent to sign-in',
        (tester) async {
      expect(
        await _resolve(tester, target: '/admin', user: null),
        '/admin/sign-in',
      );
      expect(
        await _resolve(tester, target: '/admin/projects', user: null),
        '/admin/sign-in',
      );
      expect(
        await _resolve(tester, target: '/admin/visits', user: null),
        '/admin/sign-in',
      );
    });

    testWidgets('authenticated non-admin is bounced from /admin to sign-in',
        (tester) async {
      expect(
        await _resolve(
          tester,
          target: '/admin/projects',
          user: _user('lecturer@uitm.edu.my'),
          isAdmin: false,
        ),
        '/admin/sign-in',
      );
    });

    testWidgets('authenticated admin reaches /admin pages', (tester) async {
      expect(
        await _resolve(
          tester,
          target: '/admin/projects',
          user: _user('admin@uitm.edu.my'),
          isAdmin: true,
        ),
        '/admin/projects',
      );
    });

    testWidgets('admin landing on sign-in page is redirected to /admin',
        (tester) async {
      expect(
        await _resolve(
          tester,
          target: '/admin/sign-in',
          user: _user('admin@uitm.edu.my'),
          isAdmin: true,
        ),
        '/admin',
      );
    });
  });

  group('Lecturer post-sign-in routing', () {
    testWidgets('lecturer landing on sign-in page is redirected to My Visits',
        (tester) async {
      expect(
        await _resolve(
          tester,
          target: '/admin/sign-in',
          user: _user('aminah@uitm.edu.my'),
          isAdmin: false,
          lecturer: _lecturer(),
        ),
        '/lecturer/visits',
      );
    });

    testWidgets('lecturer can reach My Visits directly', (tester) async {
      expect(
        await _resolve(
          tester,
          target: '/lecturer/visits',
          user: _user('aminah@uitm.edu.my'),
          lecturer: _lecturer(),
        ),
        '/lecturer/visits',
      );
    });

    testWidgets('anonymous visitors keep access to public routes',
        (tester) async {
      expect(
        await _resolve(tester, target: '/projects', user: null),
        '/projects',
      );
      expect(
        await _resolve(tester, target: '/schedule', user: null),
        '/schedule',
      );
    });
  });
}
