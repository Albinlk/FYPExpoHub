import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/widgets/fypms_shell.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/web/local_prefs.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/notifications_page.dart';

/// The Workspace menu is grouped by role. Someone with several roles sees
/// one collapsible section per role, and only the section holding the
/// current page is open, instead of one long list with repeated entries.
Future<void> _pump(WidgetTester tester, {required List<String> roles, required String at}) async {
  tester.view.physicalSize = const Size(1440, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  const paths = ['/fypms/supervisor', '/fypms/csp/marks', '/fypms/coordinator', '/fypms/student'];
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
      supabaseClientProvider.overrideWithValue(SupabaseClient(
        'https://placeholder-project.supabase.co',
        'placeholder-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      )),
      currentAuthUserProvider.overrideWith((ref) => null),
      fypNotificationsProvider.overrideWith((ref) async => []),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

void main() {
  const lecturerAdmin = ['supervisor', 'csp600_lecturer', 'admin'];

  // Each test starts from a browser that has never saved the menu.
  setUp(() => localPrefs = MemoryLocalPrefs());

  testWidgets('several roles: one section per role, only the current one open', (tester) async {
    await _pump(tester, roles: lecturerAdmin, at: '/fypms/csp/marks');

    expect(find.text('SUPERVISOR'), findsOneWidget);
    expect(find.text('CSP600 LECTURER'), findsOneWidget);
    expect(find.text('COORDINATOR'), findsOneWidget); // admins work in the coordinator area
    // CSP section is open (we are on its Marks page) with its group labels.
    expect(find.text('Marks'), findsOneWidget);
    expect(find.text('ASSESSMENT'), findsOneWidget);
    // Supervisor and Admin sections are closed: no duplicate entries.
    expect(find.text('Report Endorsement'), findsNothing);
    expect(find.text('Users & Roles'), findsNothing);
    expect(find.text('Evaluations'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
  });

  testWidgets('tapping a section header opens and closes it', (tester) async {
    await _pump(tester, roles: lecturerAdmin, at: '/fypms/csp/marks');

    await tester.tap(find.byKey(const Key('nav-section-Supervisor')));
    await tester.pumpAndSettle();
    expect(find.text('Report Endorsement'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-section-Supervisor')));
    await tester.pumpAndSettle();
    expect(find.text('Report Endorsement'), findsNothing);
  });

  testWidgets('one role: no section headers, just labelled groups', (tester) async {
    await _pump(tester, roles: const ['fyp_coordinator'], at: '/fypms/coordinator');

    expect(find.byKey(const Key('nav-section-Coordinator')), findsNothing);
    expect(find.text('PEOPLE'), findsOneWidget);
    expect(find.text('SETUP'), findsOneWidget);
    expect(find.text('Users & Roles'), findsOneWidget);
    expect(find.byKey(const Key('fypms-nav-toggle-all')), findsNothing);
  });

  testWidgets('Collapse all closes every section, then the button expands all', (tester) async {
    await _pump(tester, roles: lecturerAdmin, at: '/fypms/csp/marks');
    expect(find.text('COLLAPSE ALL'), findsOneWidget);

    await tester.tap(find.byKey(const Key('fypms-nav-toggle-all')));
    await tester.pumpAndSettle();
    for (final item in ['Marks', 'Report Endorsement', 'Users & Roles']) {
      expect(find.text(item), findsNothing, reason: item);
    }
    expect(find.text('SUPERVISOR'), findsOneWidget); // the headings stay
    expect(find.text('EXPAND ALL'), findsOneWidget);

    await tester.tap(find.byKey(const Key('fypms-nav-toggle-all')));
    await tester.pumpAndSettle();
    // (The Coordinator section is below the fold of the lazy list here.)
    for (final item in ['Marks', 'Report Endorsement']) {
      expect(find.text(item), findsOneWidget, reason: item);
    }
    expect(find.text('COLLAPSE ALL'), findsOneWidget);
  });

  testWidgets('the open sections are saved and come back after a reload', (tester) async {
    await _pump(tester, roles: lecturerAdmin, at: '/fypms/csp/marks');
    await tester.tap(find.byKey(const Key('nav-section-Supervisor')));
    await tester.pumpAndSettle();
    expect(readStringSet(kWorkspaceNavOpenKey), {'Supervisor', 'CSP600 Lecturer'});

    // "Reload": a fresh app on the same browser storage.
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, roles: lecturerAdmin, at: '/fypms/csp/marks');
    expect(find.text('Report Endorsement'), findsOneWidget);
    expect(find.text('Marks'), findsOneWidget);
    expect(find.text('Users & Roles'), findsNothing);
  });

  testWidgets('the current page opens its section even if it was saved closed', (tester) async {
    localPrefs = MemoryLocalPrefs({kWorkspaceNavOpenKey: '["Coordinator"]'});
    await _pump(tester, roles: lecturerAdmin, at: '/fypms/csp/marks');

    expect(find.text('Marks'), findsOneWidget); // CSP section: current page
    expect(find.text('Users & Roles'), findsOneWidget); // saved open
    expect(find.text('Report Endorsement'), findsNothing); // saved closed
  });

  testWidgets('Collapse all is saved too', (tester) async {
    await _pump(tester, roles: lecturerAdmin, at: '/fypms/csp/marks');
    await tester.tap(find.byKey(const Key('fypms-nav-toggle-all')));
    await tester.pumpAndSettle();
    expect(readStringSet(kWorkspaceNavOpenKey), isEmpty);
  });
}
