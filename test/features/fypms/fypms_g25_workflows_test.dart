import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_milestone_extension.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_course_offering.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_milestone.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_records_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_milestones_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_presentations_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/create_session_dialog.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/milestone_extension_widgets.dart';

FypRecord _record() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP650',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      workflowStatus: 'project_ongoing',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

FypMilestone _milestone(String id, String status) => FypMilestone(
      id: id,
      fypRecordId: 'rec-1',
      milestoneCode: id.toUpperCase(),
      milestoneTitle: 'Chapter $id',
      targetDate: DateTime(2026, 10, 1),
      status: status,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

FypMilestoneExtension _extension({String status = 'pending'}) => FypMilestoneExtension.fromJson({
      'id': 'ext-1',
      'milestone_id': 'm2',
      'reason': 'Hospitalised for a week',
      'requested_due_date': '2026-10-15',
      'status': status,
      'fyp_milestones': {'milestone_code': 'M2', 'milestone_title': 'Chapter m2'},
    });

Future<void> _pump(WidgetTester tester, Widget home, List<Override> overrides) async {
  tester.view.physicalSize = const Size(375, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: home)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('G-25 student requests an extension only where none is pending', (tester) async {
    await _pump(tester, const StudentMilestonesPage(), [
      myFypRecordsProvider.overrideWith((ref) async => [_record()]),
      fypMilestonesProvider.overrideWith((ref, id) async => [
            _milestone('m1', 'in_progress'),
            _milestone('m2', 'in_progress'),
            _milestone('m3', 'completed'),
          ]),
      fypMilestoneExtensionsProvider.overrideWith((ref, id) async => [_extension()]),
    ]);
    // m1 can ask; m2 has a pending request; m3 is completed.
    expect(find.text('Request extension'), findsOneWidget);
    expect(find.text('Extension to 15-10-2026 pending'), findsOneWidget);

    await tester.tap(find.text('Request extension'));
    await tester.pumpAndSettle();
    final request = find.widgetWithText(FilledButton, 'Request');
    expect(tester.widget<FilledButton>(request).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('extension-reason')), 'Lab closed');
    await tester.pump();
    expect(tester.widget<FilledButton>(request).onPressed, isNull, reason: 'a date is still needed');
  });

  testWidgets('G-25 lecturer approves, and rejects only with a reason', (tester) async {
    final calls = <String>[];
    await _pump(tester, const Scaffold(body: ExtensionRequestsPanel(fypRecordId: 'rec-1')), [
      fypMilestoneExtensionsProvider.overrideWith((ref, id) async => [_extension()]),
      decideMilestoneExtensionProvider.overrideWithValue((
          {required fypRecordId, required extensionId, required decision, comment}) async {
        calls.add('$extensionId:$decision:${comment ?? ''}');
      }),
    ]);
    expect(find.text('Extension requests (1)'), findsOneWidget);
    expect(find.text('Hospitalised for a week'), findsOneWidget);

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    final confirm = find.descendant(of: find.byType(AlertDialog), matching: find.widgetWithText(FilledButton, 'Reject'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('reject-reason')), 'No medical certificate');
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(calls, ['ext-1:rejected:No medical certificate', 'ext-1:approved:']);
  });

  testWidgets('G-25 decided requests do not show in the lecturer panel', (tester) async {
    await _pump(tester, const Scaffold(body: ExtensionRequestsPanel(fypRecordId: 'rec-1')), [
      fypMilestoneExtensionsProvider.overrideWith((ref, id) async => [_extension(status: 'approved')]),
    ]);
    expect(find.textContaining('Extension requests'), findsNothing);
  });

  testWidgets('G-25 student sees their scheduled presentation', (tester) async {
    await _pump(tester, const StudentPresentationsPage(), [
      myFypRecordsProvider.overrideWith((ref) async => [_record()]),
      fypRecordPresentationsProvider.overrideWith((ref, id) async => [
            FypScheduledPresentation.fromJson({
              'slot_number': 3,
              'start_at': '2026-10-05T01:40:00Z',
              'end_at': '2026-10-05T02:00:00Z',
              'room': 'Lab 3',
              'fyp_presentation_sessions': {
                'session_code': 'P2',
                'session_title': 'Progress presentation 2',
                'session_type': 'defence',
                'venue': 'Block B',
              },
            }),
          ]),
    ]);
    expect(find.text('P2 — Progress presentation 2'), findsOneWidget);
    expect(find.textContaining('Slot 3'), findsOneWidget);
    expect(find.textContaining('Lab 3 · Block B'), findsOneWidget);
  });

  testWidgets('G-25 no slot yet shows a clear empty state', (tester) async {
    await _pump(tester, const StudentPresentationsPage(), [
      myFypRecordsProvider.overrideWith((ref) async => [_record()]),
      fypRecordPresentationsProvider.overrideWith((ref, id) async => const []),
    ]);
    expect(find.textContaining('No presentation has been scheduled'), findsOneWidget);
  });

  testWidgets('G-25 coordinator edits a field (reason required) and archives', (tester) async {
    final overrides = <String>[];
    final archived = <String>[];
    await _pump(tester, const CoordinatorRecordsPage(), [
      fypRecordsProvider.overrideWith((ref) async => [_record()]),
      overrideFypRecordFieldProvider.overrideWithValue((id, field, value, reason) async {
        overrides.add('$id:$field:$value:$reason');
      }),
      archiveFypRecordProvider.overrideWithValue((id, reason) async => archived.add('$id:$reason')),
    ]);

    await tester.tap(find.byTooltip('Record actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit field…'));
    await tester.pumpAndSettle();
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.enterText(find.byKey(const Key('override-value')), 'AI Health Companion');
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNull, reason: 'reason is mandatory');
    await tester.enterText(find.byKey(const Key('override-reason')), 'Title approved by panel');
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(overrides, ['rec-1:project_title:AI Health Companion:Title approved by panel']);

    await tester.tap(find.byTooltip('Record actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('archive-reason')), 'Withdrew from programme');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();
    expect(archived, ['rec-1:Withdrew from programme']);
  });

  testWidgets('G-25 lecturer creates a presentation session', (tester) async {
    final created = <String>[];
    await _pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => CreateSessionDialog(offerings: [
                FypCourseOffering(
                  id: 'off-650',
                  academicSemesterId: 'sem-1',
                  courseCode: 'CSP650',
                  isActive: true,
                  createdAt: DateTime(2026, 8, 1),
                  updatedAt: DateTime(2026, 8, 1),
                ),
              ]),
            ),
            child: const Text('open'),
          ),
        ),
      ),
      [
        createPresentationSessionProvider.overrideWithValue(({
          required offeringId,
          required sessionCode,
          required sessionTitle,
          required startAt,
          required endAt,
          venue,
          sessionType = 'defence',
        }) async {
          created.add('$offeringId:$sessionCode:$sessionTitle:${endAt.difference(startAt).inHours}h:$sessionType');
        }),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('session-code')), 'P2');
    await tester.enterText(find.byKey(const Key('session-title')), 'Progress presentation 2');
    await tester.pump();
    final create = find.widgetWithText(FilledButton, 'Create');
    expect(tester.widget<FilledButton>(create).onPressed, isNull, reason: 'date not chosen');

    await tester.tap(find.byKey(const Key('session-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(create);
    await tester.pumpAndSettle();
    expect(created, ['off-650:P2:Progress presentation 2:4h:defence']);
  });
}
