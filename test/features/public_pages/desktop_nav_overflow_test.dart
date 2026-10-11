import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/widgets/public_shell.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

/// Redesign audit: at 800 px the desktop nav ran "Announcements" under the
/// Sign In button. Below 1312 px the lower-priority links move into More.
void main() {
  Future<void> pumpShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (_, _) => const PublicShell(child: SizedBox.shrink()))],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        )),
        authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
        currentAuthUserProvider.overrideWith((ref) => null),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('800 px: three links inline, the rest under More, nothing under Sign In', (tester) async {
    await pumpShell(tester, const Size(800, 700));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Exhibition'), findsNothing); // the exhibition is Home now
    expect(find.text('Announcements'), findsNothing);

    // Geometry is checked in the browser: the test font is wider than Inter.
    expect(find.text('Booths'), findsOneWidget);
    expect(find.text('Schedule'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('nav-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-more')));
    await tester.pumpAndSettle();
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Find by Lecturer'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);

    // Feedback shrinks to an icon so it does not cover card text.
    expect(find.byKey(const Key('feedback-fab-compact')), findsOneWidget);
  });

  testWidgets('1280 px: five links inline, the rest under More', (tester) async {
    await pumpShell(tester, const Size(1280, 900));
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Find by Lecturer'), findsNothing);
  });

  testWidgets('1440 px: every link inline and the labelled Feedback button', (tester) async {
    await pumpShell(tester, const Size(1440, 900));
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Find by Lecturer'), findsOneWidget);
    expect(find.byKey(const Key('feedback-fab-compact')), findsNothing);
    expect(find.text('Feedback'), findsOneWidget);
  });
}
