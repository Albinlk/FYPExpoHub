import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/widgets/admin_shell.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

/// The exhibition admin menu's groups open and close from their headers,
/// "Collapse all" / "Expand all" does every group at once, and the page you
/// are on stays visible inside a closed group.
Future<void> _pump(WidgetTester tester, {required Size size, String at = '/admin'}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: at,
    routes: [
      ShellRoute(
        builder: (_, _, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/admin/event', builder: (_, _) => const SizedBox()),
        ],
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      supabaseClientProvider.overrideWithValue(SupabaseClient(
        'https://placeholder-project.supabase.co',
        'placeholder-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      )),
      currentAuthUserProvider.overrideWith((ref) => null),
      currentProfileProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => adminCollapsedGroups.value = <String>{});

  const desktop = Size(1440, 1600);

  testWidgets('a group header closes and reopens its group', (tester) async {
    await _pump(tester, size: desktop);
    expect(find.text('Booth Management'), findsOneWidget);

    await tester.tap(find.byKey(const Key('admin-group-Projects & booths')));
    await tester.pumpAndSettle();
    expect(find.text('Booth Management'), findsNothing);
    expect(find.text('Event Information'), findsOneWidget); // other groups stay open

    await tester.tap(find.byKey(const Key('admin-group-Projects & booths')));
    await tester.pumpAndSettle();
    expect(find.text('Booth Management'), findsOneWidget);
  });

  testWidgets('Collapse all closes every group, then the button expands all', (tester) async {
    await _pump(tester, size: desktop);
    expect(find.text('COLLAPSE ALL'), findsOneWidget);

    await tester.tap(find.byKey(const Key('admin-nav-toggle-all')));
    await tester.pumpAndSettle();
    for (final item in ['Event Information', 'Booth Management', 'Lecturer Management', 'Settings']) {
      expect(find.text(item), findsNothing, reason: item);
    }
    expect(find.text('Overview Dashboard'), findsOneWidget); // not in a group
    expect(find.text('EXPAND ALL'), findsOneWidget);

    await tester.tap(find.byKey(const Key('admin-nav-toggle-all')));
    await tester.pumpAndSettle();
    for (final item in ['Event Information', 'Booth Management', 'Lecturer Management', 'Settings']) {
      expect(find.text(item), findsOneWidget, reason: item);
    }
  });

  testWidgets('the current page stays visible in a closed group', (tester) async {
    await _pump(tester, size: desktop, at: '/admin/event');
    await tester.tap(find.byKey(const Key('admin-nav-toggle-all')));
    await tester.pumpAndSettle();

    expect(find.text('Event Information'), findsOneWidget);
    expect(find.text('Schedule Management'), findsNothing);
  });

  testWidgets('the phone drawer shares the same state', (tester) async {
    adminCollapsedGroups.value = {'System'};
    await _pump(tester, size: const Size(600, 1000));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('admin-nav-toggle-all')), findsOneWidget);
    expect(find.text('Audit Log'), findsNothing);
    expect(find.text('Booth Management'), findsOneWidget);
  });
}
