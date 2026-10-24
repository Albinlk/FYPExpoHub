import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/router.dart';
import 'package:fyp_expo_hub/app/widgets/admin_shell.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/admin_auth/mfa.dart';
import 'package:fyp_expo_hub/features/admin_projects/presentation/pages/admin_projects_page.dart';

/// Cold start of a deferred area (R4): nothing preloaded, so opening an admin
/// route shows the loading spinner first and then the real shell and page.
///
/// Kept in its own file (its own isolate) so no other test has loaded the
/// admin library before it — see `preloadDeferredAreas` in router.dart.
User _admin() => User.fromJson({
      'id': 'user-1',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'admin@uitm.edu.my',
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

void main() {
  final originalErrorHandler = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      // Admin pages touch a not-initialized Supabase instance; only which
      // widgets render matters here.
      final message = details.exception.toString();
      final filtered = message.contains('RenderFlex overflowed') ||
          message.contains('ProviderException') ||
          message.contains('must initialize the supabase instance');
      if (!filtered) FlutterError.dumpErrorToConsole(details);
    };
  });
  tearDown(() => FlutterError.onError = originalErrorHandler);

  testWidgets('an admin route loads its code, then renders the admin page',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAuthUserProvider.overrideWith((ref) => _admin()),
          isAdminProvider.overrideWith((ref) async => true),
          fypmsCurrentRolesProvider.overrideWith((ref) async => const ['admin']),
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
    router.go('/admin/projects');

    // The new route's first frame is laid out offstage (Navigator does that
    // for transitions), so look for the spinner there too.
    final spinner =
        find.byKey(const Key('deferred-page-loading'), skipOffstage: false);
    var sawSpinner = false;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (spinner.evaluate().isNotEmpty) sawSpinner = true;
      if (find.byType(AdminProjectsPage).evaluate().isNotEmpty) break;
    }

    expect(router.routerDelegate.currentConfiguration.uri.path, '/admin/projects');
    expect(sawSpinner, isTrue, reason: 'the admin code loads before the page');
    expect(spinner, findsNothing);
    expect(find.byType(AdminShell), findsOneWidget);
    expect(find.byType(AdminProjectsPage), findsOneWidget);
  });
}
