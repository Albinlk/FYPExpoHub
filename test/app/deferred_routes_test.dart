import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/deferred/deferred_page.dart';
import 'package:fyp_expo_hub/app/router.dart';
import 'package:fyp_expo_hub/app/widgets/admin_shell.dart';
import 'package:fyp_expo_hub/app/widgets/fypms_shell.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/admin_auth/mfa.dart';
import 'package:fyp_expo_hub/features/admin_projects/presentation/pages/admin_projects_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_dashboard_page.dart';

/// The Admin area and the FYP Workspace are deferred libraries (R4): their
/// routes build a [DeferredPage] that loads the library, then the real shell
/// and page. These tests cover the loader itself and that the real router
/// still lands on the real pages.
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

class _RouterHost extends ConsumerWidget {
  const _RouterHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      MaterialApp.router(routerConfig: ref.watch(goRouterProvider));
}

Future<Uri> _open(
  WidgetTester tester, {
  required String target,
  required User user,
  bool isAdmin = false,
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
        isAdminProvider.overrideWith((ref) async => isAdmin),
        fypmsCurrentRolesProvider.overrideWith((ref) async => roles),
        mfaStateProvider.overrideWith(
          (ref) async =>
              const MfaState(enabledFactorId: null, needsChallenge: false),
        ),
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
  return router.routerDelegate.currentConfiguration.uri;
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DeferredPage', () {
    testWidgets('shows a spinner until the library loads, then the page',
        (tester) async {
      final load = Completer<void>();
      final library = DeferredLibrary(() => load.future);

      await tester.pumpWidget(_app(DeferredPage(
        library: library,
        builder: (_) => const Text('loaded page'),
      )));
      expect(find.byKey(const Key('deferred-page-loading')), findsOneWidget);
      expect(find.text('loaded page'), findsNothing);

      load.complete();
      await tester.pump();
      expect(find.text('loaded page'), findsOneWidget);
      expect(find.byKey(const Key('deferred-page-loading')), findsNothing);
      expect(library.isLoaded, isTrue);
    });

    testWidgets('builds straight away once the library is loaded',
        (tester) async {
      final library = DeferredLibrary(() async {});
      await library.load();

      await tester.pumpWidget(_app(DeferredPage(
        library: library,
        builder: (_) => const Text('loaded page'),
      )));
      // No extra pump: the first frame is already the page.
      expect(find.text('loaded page'), findsOneWidget);
    });

    testWidgets('pages sharing a library all build once it loads',
        (tester) async {
      final load = Completer<void>();
      final library = DeferredLibrary(() => load.future);

      await tester.pumpWidget(_app(Column(children: [
        DeferredPage(library: library, builder: (_) => const Text('a')),
        DeferredPage(library: library, builder: (_) => const Text('b')),
      ])));
      expect(find.byKey(const Key('deferred-page-loading')), findsNWidgets(2));

      load.complete();
      await tester.pump();
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('a failed load offers Retry, which loads again',
        (tester) async {
      var calls = 0;
      final library = DeferredLibrary(() async {
        calls++;
        if (calls == 1) throw Exception('network down');
      });

      await tester.pumpWidget(_app(DeferredPage(
        library: library,
        builder: (_) => const Text('loaded page'),
      )));
      await tester.pump();
      expect(find.byKey(const Key('deferred-page-error')), findsOneWidget);
      expect(find.text('loaded page'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      expect(calls, 2);
      expect(find.text('loaded page'), findsOneWidget);
      expect(find.byKey(const Key('deferred-page-error')), findsNothing);
    });
  });

  group('Deferred routes in the real router', () {
    // Load both areas once, outside any test's fake-async zone (see
    // preloadDeferredAreas). The router still goes through DeferredPage.
    setUpAll(preloadDeferredAreas);

    final originalErrorHandler = FlutterError.onError;
    setUp(() {
      FlutterError.onError = (details) {
        // The pages touch a not-initialized Supabase instance and have
        // desktop-layout overflows; only which widgets render matters here.
        final message = details.exception.toString();
        final filtered = message.contains('RenderFlex overflowed') ||
            message.contains('ProviderException') ||
            message.contains('must initialize the supabase instance');
        if (!filtered) FlutterError.dumpErrorToConsole(details);
      };
    });
    tearDown(() => FlutterError.onError = originalErrorHandler);

    testWidgets('an admin route renders the admin shell and page after loading',
        (tester) async {
      final uri = await _open(
        tester,
        target: '/admin/projects',
        user: _user('admin@uitm.edu.my'),
        isAdmin: true,
      );
      expect(uri.path, '/admin/projects');
      expect(find.byKey(const Key('deferred-page-loading')), findsNothing);
      expect(find.byType(AdminShell), findsOneWidget);
      expect(find.byType(AdminProjectsPage), findsOneWidget);
    });

    testWidgets('an FYP Workspace route renders its shell and page after loading',
        (tester) async {
      final uri = await _open(
        tester,
        target: '/fypms/student',
        user: _user('s@fypms.test'),
        roles: const ['student'],
      );
      expect(uri.path, '/fypms/student');
      expect(find.byKey(const Key('deferred-page-loading')), findsNothing);
      expect(find.byType(FypmsShell), findsOneWidget);
      expect(find.byType(StudentDashboardPage), findsOneWidget);
    });
  });
}
