import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/portal/presentation/pages/portal_home_page.dart';

/// Portal plan P1: `/` presents the three parts of the final year project —
/// FYP Exhibition, CSP600 Project Formulation, CSP650 Project — with a way in.
void main() {
  User user() => User(
        id: 'u1',
        email: 'student@student.uitm.edu.my',
        aud: 'authenticated',
        appMetadata: const {},
        userMetadata: const {},
        createdAt: DateTime(2026, 7, 1).toIso8601String(),
      );

  Future<GoRouter> pump(WidgetTester tester, Size size, {User? signedIn}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget page(String name) => Scaffold(body: Text('page:$name'));
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: PortalHomePage())),
        GoRoute(path: '/expo', builder: (_, _) => page('expo')),
        GoRoute(path: '/projects', builder: (_, _) => page('projects')),
        GoRoute(path: '/projects/junior-guide', builder: (_, _) => page('guide')),
        GoRoute(path: '/sign-in', builder: (_, _) => page('sign-in')),
        GoRoute(path: '/fypms', builder: (_, _) => page('fypms')),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentAuthUserProvider.overrideWith((ref) => signedIn),
        supabaseClientProvider.overrideWithValue(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        )),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    return router;
  }

  for (final size in const [Size(375, 812), Size(1280, 900)]) {
    testWidgets('shows the three parts without overflow at ${size.width.toInt()}px', (tester) async {
      await pump(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('FYP Exhibition'), findsOneWidget);
      expect(find.text('CSP600 · Project Formulation'), findsOneWidget);
      expect(find.text('CSP650 · Final Year Project'), findsOneWidget);
      expect(find.byKey(const Key('portal-sign-in')), findsOneWidget);
    });
  }

  testWidgets('the exhibition card opens /expo', (tester) async {
    final router = await pump(tester, const Size(1280, 900));
    await tester.ensureVisible(find.text('Explore the Exhibition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore the Exhibition'));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/expo');
  });

  testWidgets('signed out, a course card asks to sign in and comes back to the courses', (tester) async {
    final router = await pump(tester, const Size(1280, 900));
    await tester.ensureVisible(find.text('Sign In for CSP600'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In for CSP600'));
    await tester.pumpAndSettle();
    final uri = router.routerDelegate.currentConfiguration.uri;
    expect(uri.path, '/sign-in');
    expect(uri.queryParameters['from'], '/fypms');
  });

  testWidgets('signed in, a course card goes straight to the workspace', (tester) async {
    final router = await pump(tester, const Size(1280, 900), signedIn: user());
    expect(find.byKey(const Key('portal-sign-in')), findsNothing);
    await tester.ensureVisible(find.text('Go to CSP650'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to CSP650'));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/fypms');
  });
}
