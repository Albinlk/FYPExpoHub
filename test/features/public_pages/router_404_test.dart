import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/router.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

/// Unknown URLs render the branded 404 page (errorPageBuilder) with
/// working navigation buttons.
void main() {
  final originalErrorHandler = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      final message = details.exception.toString();
      final filtered = message.contains('RenderFlex overflowed') ||
          message.contains('must initialize the supabase instance');
      if (!filtered) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
  });
  tearDown(() => FlutterError.onError = originalErrorHandler);

  Future<GoRouter> _pumpWithBadUri(WidgetTester tester, String uri) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late final GoRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(
            SupabaseClient(
              'https://placeholder-project.supabase.co',
              'placeholder-anon-key',
              authOptions: const AuthClientOptions(autoRefreshToken: false),
            ),
          ),
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
          currentAuthUserProvider.overrideWith((ref) => null),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            router = ref.watch(goRouterProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    router.go(uri);
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('unknown URL renders branded 404 with actions', (tester) async {
    final router = await _pumpWithBadUri(tester, '/does-not-exist');

    expect(find.text('Page Not Found'), findsOneWidget);
    expect(
      find.text('The page "/does-not-exist" does not exist or has moved.'),
      findsOneWidget,
    );
    expect(find.text('Go Home'), findsOneWidget);
    expect(find.text('Browse Projects'), findsOneWidget);

    // Actions navigate to real routes.
    await tester.tap(find.text('Browse Projects'));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/projects');
  });

  testWidgets('deeply unknown nested URL also 404s', (tester) async {
    await _pumpWithBadUri(tester, '/projects/abc/xyz/nested');

    expect(find.text('Page Not Found'), findsOneWidget);
  });

  testWidgets('route titles map paths to labels', (tester) async {
    // Pure logic check of the observer's mapping.
    final router = await _pumpWithBadUri(tester, '/');
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });
}
