import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_supervisor_change.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/supervisor_change_widgets.dart';

FypRecord _record() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP650',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      mainSupervisorId: 'sv-1',
      examinerId: 'ex-1',
      workflowStatus: 'project_ongoing',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

final _directory = [
  {'id': 'sv-1', 'display_name': 'DR AMINAH'},
  {'id': 'sv-2', 'display_name': 'DR SITI'},
  {'id': 'ex-1', 'display_name': 'DR RAHMAN'},
];

Future<void> _pump(WidgetTester tester, Widget body, List<Override> overrides) async {
  tester.view.physicalSize = const Size(375, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [supervisorsDirectoryProvider.overrideWith((ref) async => _directory), ...overrides],
    child: MaterialApp(home: Scaffold(body: body)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('R11 student asks for a change; the current supervisor and examiner are not offered', (tester) async {
    final sent = <String>[];
    await _pump(tester, SupervisorChangeSection(record: _record()), [
      fypSupervisorChangesProvider.overrideWith((ref, id) async => const []),
      requestSupervisorChangeProvider.overrideWithValue((id, reason, proposed) async => sent.add('$id|$reason|$proposed')),
    ]);
    await tester.tap(find.text('Request supervisor change'));
    await tester.pumpAndSettle();
    final send = find.widgetWithText(FilledButton, 'Send request');
    await tester.enterText(find.byKey(const Key('change-reason')), 'Too short');
    await tester.pump();
    expect(tester.widget<FilledButton>(send).onPressed, isNull);

    await tester.tap(find.byKey(const Key('change-proposed')));
    await tester.pumpAndSettle();
    expect(find.text('DR AMINAH'), findsNothing);
    expect(find.text('DR RAHMAN'), findsNothing);
    await tester.tap(find.text('DR SITI').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('change-reason')), 'My supervisor has moved to another campus.');
    await tester.pump();
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(sent, ['rec-1|My supervisor has moved to another campus.|sv-2']);
  });

  testWidgets('R11 a pending request hides the button and shows its status', (tester) async {
    await _pump(tester, SupervisorChangeSection(record: _record()), [
      fypSupervisorChangesProvider.overrideWith((ref, id) async => [
            SupervisorChangeRequest.fromJson({'id': 'c1', 'fyp_record_id': 'rec-1', 'reason': 'x' * 25, 'status': 'pending'}),
          ]),
    ]);
    expect(find.textContaining('waiting for the FYP coordinator'), findsOneWidget);
    expect(find.text('Request supervisor change'), findsNothing);
  });

  testWidgets('R11 coordinator approves with the proposed supervisor preselected', (tester) async {
    final decided = <String>[];
    await _pump(tester, const SingleChildScrollView(child: SupervisorChangeRequestsPanel()), [
      pendingSupervisorChangesProvider.overrideWith((ref) async => [
            SupervisorChangeRequest.fromJson({
              'id': 'c1',
              'fyp_record_id': 'rec-1',
              'reason': 'My supervisor has moved to another campus.',
              'status': 'pending',
              'current_supervisor_id': 'sv-1',
              'proposed_supervisor_id': 'sv-2',
              'fyp_records': {'project_title': 'AI Health Assistant', 'matric_id': '2026123456'},
            }),
          ]),
      decideSupervisorChangeProvider.overrideWithValue((
          {required requestId, required fypRecordId, required decision, comment, newSupervisorId}) async {
        decided.add('$requestId|$decision|$newSupervisorId|${comment ?? ''}');
      }),
    ]);
    expect(find.text('From DR AMINAH to DR SITI'), findsOneWidget);
    await tester.tap(find.text('Approve…'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
    await tester.pumpAndSettle();
    expect(decided, ['c1|approved|sv-2|']);
  });

  testWidgets('R11 PU approves one nomination and rejects another with a reason', (tester) async {
    final calls = <String>[];
    await _pump(tester, const PuNominationsPage(), [
      pendingNominationsProvider.overrideWith((ref) async => [
            PendingNomination.fromJson({
              'assignment_id': 'a1',
              'fyp_record_id': 'rec-1',
              'academic_role': 'supervisor',
              'lecturer_name': 'DR SITI',
              'project_title': 'AI Health Assistant',
            }),
            PendingNomination.fromJson({
              'assignment_id': 'a2',
              'fyp_record_id': 'rec-2',
              'academic_role': 'examiner',
              'lecturer_name': 'DR RAHMAN',
            }),
          ]),
      decideNominationProvider.overrideWithValue((id, decision, comment) async => calls.add('$id|$decision|${comment ?? ''}')),
    ]);
    expect(find.text('Supervisor: DR SITI'), findsOneWidget);
    expect(find.text('Examiner: DR RAHMAN'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Approve').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('decision-reason')), 'Examiner is the co-author');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
    await tester.pumpAndSettle();
    expect(calls, ['a1|approved|', 'a2|rejected|Examiner is the co-author']);
  });
}
