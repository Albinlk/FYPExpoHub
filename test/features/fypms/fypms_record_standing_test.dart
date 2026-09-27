import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/record_admin_dialogs.dart';

FypRecord _record(String status) => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP650',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      workflowStatus: status,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

class _FakeStanding extends RecordStanding {
  _FakeStanding(super.ref, this.calls);
  final List<String> calls;

  @override
  Future<void> hold(String fypRecordId, String status, String reason) async => calls.add('hold $status $reason');

  @override
  Future<void> reinstate(String fypRecordId, String reason) async => calls.add('reinstate $reason');

  @override
  Future<void> reopenMarks(String fypRecordId, String courseCode, String reason) async =>
      calls.add('reopen $courseCode $reason');
}

Future<void> _open(WidgetTester tester, Widget dialog, List<String> calls) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [recordStandingProvider.overrideWith((ref) => _FakeStanding(ref, calls))],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(context: context, builder: (_) => dialog),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('F4 incomplete needs a reason, then holds the record', (tester) async {
    final calls = <String>[];
    await _open(tester, RecordStandingDialog(record: _record('project_ongoing'), action: 'incomplete'), calls);
    expect(find.text('Mark Incomplete (TL)'), findsOneWidget);
    final confirm = find.widgetWithText(FilledButton, 'Confirm');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('standing-reason')), 'Medical leave');
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(calls, ['hold incomplete Medical leave']);
    expect(find.text('Record marked incomplete.'), findsOneWidget);
  });

  testWidgets('F4 reinstate calls reinstate', (tester) async {
    final calls = <String>[];
    await _open(tester, RecordStandingDialog(record: _record('withdrawn'), action: 'reinstate'), calls);
    await tester.enterText(find.byKey(const Key('standing-reason')), 'Came back');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Reinstate'));
    await tester.pumpAndSettle();
    expect(calls, ['reinstate Came back']);
  });

  testWidgets('F3 reopening marks defaults to the current course and needs a 10-character reason', (tester) async {
    final calls = <String>[];
    await _open(tester, ReopenMarksDialog(record: _record('project_completed')), calls);
    await tester.enterText(find.byKey(const Key('reopen-reason')), 'too short');
    await tester.pump();
    final reopen = find.widgetWithText(FilledButton, 'Reopen');
    expect(tester.widget<FilledButton>(reopen).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('reopen-reason')), 'Examiner score on the wrong record');
    await tester.pump();
    await tester.tap(reopen);
    await tester.pumpAndSettle();
    expect(calls, ['reopen CSP650 Examiner score on the wrong record']);
  });

  test('F4 held statuses', () {
    expect(kHeldStatuses, {'withdrawn', 'incomplete'});
  });
}
