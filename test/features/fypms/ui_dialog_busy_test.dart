import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_progress_log.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_rpc_service.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/csp_milestones_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_progress_page.dart';

FypRecord _record() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      workflowStatus: 'project_registered',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

/// A real service pointed at a placeholder host: every call fails (the test
/// binding answers all HTTP with 400), which is exactly the failure path.
SupabaseRpcService _failingRpc() => SupabaseRpcService(SupabaseClient(
      'https://placeholder-project.supabase.co',
      'placeholder-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    ));

Future<void> _pump(WidgetTester tester, Widget home, List<Override> overrides) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: home)));
  await tester.pumpAndSettle();
}

void main() {
  group('CSP milestone dialog', () {
    testWidgets('Save enables as soon as code and title are typed, and failures stay inline', (tester) async {
      final rpc = _failingRpc();
      await _pump(tester, const CspMilestonesPage(), [
        fypRecordsProvider.overrideWith((ref) async => [_record()]),
        fypMilestonesProvider.overrideWith((ref, id) async => []),
        supabaseRpcServiceProvider.overrideWithValue(rpc),
      ]);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('New Milestone'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save')).onPressed, isNull);

      await tester.enterText(find.widgetWithText(TextField, 'Milestone Code'), 'M1');
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Proposal');
      await tester.pump();
      final save = find.widgetWithText(FilledButton, 'Save');
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull, reason: 'enabled after typing');

      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not save the milestone'), findsOneWidget);
      expect(find.text('New Milestone'), findsOneWidget, reason: 'dialog stays open');
      expect(find.text('Proposal'), findsOneWidget, reason: 'typed text kept');
    });

    testWidgets('outside tap does not close the dialog', (tester) async {
      await _pump(tester, const CspMilestonesPage(), [
        fypRecordsProvider.overrideWith((ref) async => [_record()]),
        fypMilestonesProvider.overrideWith((ref, id) async => []),
        supabaseRpcServiceProvider.overrideWithValue(_failingRpc()),
      ]);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.text('New Milestone'), findsOneWidget);
    });
  });

  group('Supervisor progress review', () {
    FypProgressLog log() => FypProgressLog(
          id: 'log-1',
          fypRecordId: 'rec-1',
          weekNumber: 3,
          progressDate: DateTime(2026, 8, 10),
          summary: 'Completed literature review.',
          status: 'submitted',
          submittedAt: DateTime(2026, 8, 11),
          createdAt: DateTime(2026, 8, 10),
          updatedAt: DateTime(2026, 8, 11),
        );

    testWidgets('rejecting needs a reason and nothing is sent without one', (tester) async {
      final calls = <String>[];
      await _pump(tester, const SupervisorProgressPage(), [
        assignedFypRecordsProvider.overrideWith((ref, role) async => [_record()]),
        fypProgressLogsProvider.overrideWith((ref, id) async => [log()]),
        validateProgressLogProvider.overrideWithValue((id, decision, comment, recordId) async {
          calls.add('$id|$decision|${comment ?? ''}');
        }),
      ]);

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(find.textContaining('why the log is not accepted'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Missing references');
      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pumpAndSettle();
      expect(calls, ['log-1|rejected|Missing references']);
      expect(find.text('Log rejected.'), findsOneWidget);
    });
  });
}
