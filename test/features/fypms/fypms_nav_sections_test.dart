import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/widgets/fypms_shell.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
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
  });
}
