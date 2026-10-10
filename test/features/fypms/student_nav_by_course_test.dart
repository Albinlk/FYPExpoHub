import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/widgets/fypms_shell.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/notifications_page.dart';

/// Portal plan P1: a student's menu follows their course. Lean Canvas,
/// Deliverables and Corrections are CSP650 (Project) pages.
FypRecord _record(String course) => FypRecord(
      id: 'rec-$course',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: course,
      programmeCode: 'CS266',
      workflowStatus: 'project_registered',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

Future<void> _pump(WidgetTester tester, List<FypRecord> records) async {
  tester.view.physicalSize = const Size(1440, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/fypms/student',
    routes: [
      ShellRoute(
        builder: (_, _, child) => FypmsShell(child: child),
        routes: [GoRoute(path: '/fypms/student', builder: (_, _) => const SizedBox())],
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      fypmsCurrentRolesProvider.overrideWith((ref) async => ['student']),
      myFypRecordsProvider.overrideWith((ref) async => records),
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
  testWidgets('a CSP600-only student does not see CSP650 pages', (tester) async {
    await _pump(tester, [_record('CSP600')]);
    expect(find.text('Forms'), findsWidgets);
    expect(find.text('Lean Canvas'), findsNothing);
    expect(find.text('Deliverables'), findsNothing);
    expect(find.text('Corrections'), findsNothing);
  });

  testWidgets('a CSP650 student sees the Project pages', (tester) async {
    await _pump(tester, [_record('CSP600'), _record('CSP650')]);
    expect(find.text('Lean Canvas'), findsWidgets);
    expect(find.text('Deliverables'), findsWidgets);
    expect(find.text('Corrections'), findsWidgets);
  });
}
