import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_expo_publication.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_marks_summary.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_progress_log.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_expo_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/csp_marks_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_records_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_progress_page.dart';

// Regression tests for the six release-hardening guarantees.
// (c) is covered by test/features/fypms/fypms_route_guards_test.dart.

FypRecord _ownRecord() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      projectTitle: 'My Own Project',
      workflowStatus: 'project_registered',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

FypRecord _foreignRecord() => FypRecord(
      id: 'rec-2',
      academicSemesterId: 'sem-1',
      studentId: 'stu-2',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      projectTitle: 'Another Student Project',
      workflowStatus: 'project_registered',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

FypProgressLog _submittedLog() => FypProgressLog(
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

FypMarksSummary _finalizedMarks() => FypMarksSummary(
      id: 'marks-1',
      fypRecordId: 'rec-1',
      academicSemesterId: 'sem-1',
      courseCode: 'CSP600',
      marks: const {'proposal': 20},
      weightedTotal: 85.0,
      grade: 'A',
      isFinalized: true,
      finalizedAt: DateTime(2026, 8, 13),
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
    );

FypExpoPublication _draftPublication() => FypExpoPublication(
      id: 'pub-draft',
      fypRecordId: 'rec-1',
      eventId: 'event-1',
      status: 'draft',
      payload: const {'title': 'My Own Project'},
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
    );

Future<void> _pump(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1440, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

Finder _dialogButton(String label) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(label));

void main() {
  group('Regression (a): student record isolation', () {
    testWidgets('records page renders only the signed-in student record',
        (tester) async {
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            // Even though the global list contains a foreign record, the page
            // must consume the per-student list only.
            fypRecordsProvider.overrideWith((ref) async => [_ownRecord(), _foreignRecord()]),
            myFypRecordsProvider.overrideWith((ref) async => [_ownRecord()]),
            currentAuthUserProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(home: const StudentRecordsPage()),
        ),
      );

      expect(find.text('My Own Project'), findsOneWidget);
      expect(find.text('Another Student Project'), findsNothing);
    });
  });

  group('Regression (b): supervisor cannot validate an unassigned log', () {
    testWidgets('the denial is surfaced instead of a fake success', (tester) async {
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            assignedFypRecordsProvider.overrideWith(
                (ref, role) async => [_ownRecord()]),
            fypProgressLogsProvider.overrideWith(
                (ref, recordId) async => [_submittedLog()]),
            validateProgressLogProvider.overrideWithValue(
                (logId, status, comment, recordId) async {
              throw Exception(
                  'permission-denied: Only assigned supervisors can validate progress logs.');
            }),
          ],
          child: MaterialApp(home: const SupervisorProgressPage()),
        ),
      );

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Submit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('permission-denied'), findsOneWidget);
    });
  });

  group('Regression (d): unprepared/unsafe publication cannot be published', () {
    testWidgets('a draft publication does not render a Publish action',
        (tester) async {
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            fypExpoPublicationsProvider.overrideWith(
                (ref) async => [_draftPublication()]),
            fypRecordsProvider.overrideWith((ref) async => [_ownRecord()]),
            fypPublishedEventsProvider.overrideWith((ref) async => [
              {'id': 'event-1', 'title': 'Expo 2026'}
            ]),
          ],
          child: MaterialApp(home: const CoordinatorExpoPage()),
        ),
      );

      expect(find.textContaining('Status: draft'), findsOneWidget);
      expect(find.text('Publish'), findsNothing);
    });

    testWidgets('an unsafe payload is never sent by Prepare (payload = null)',
        (tester) async {
      final called = <dynamic>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            fypExpoPublicationsProvider.overrideWith(
                (ref) async => [_draftPublication()]),
            fypRecordsProvider.overrideWith((ref) async => [_ownRecord()]),
            fypPublishedEventsProvider.overrideWith((ref) async => [
              {'id': 'event-1', 'title': 'Expo 2026'}
            ]),
            prepareExpoPublicationProvider.overrideWithValue((recordId, eventId, payload) async {
              called.addAll([recordId, eventId, payload]);
            }),
          ],
          child: MaterialApp(home: const CoordinatorExpoPage()),
        ),
      );

      await tester.tap(find.text('Prepare Publication'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Own Project').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expo 2026').last);
      await tester.pumpAndSettle();

      await tester.tap(_dialogButton('Prepare'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Coordinator page passes a null payload pointer; no raw private data
      // leaves the client (server-side whitelist builds the safe projection).
      expect(called.length, 3);
      expect(called[0], 'rec-1');
      expect(called[1], 'event-1');
      expect(called[2], isNull);
    });
  });

  group('Regression (e): finalized marks cannot be silently edited', () {
    testWidgets('re-finalize attempt surfaces the failed-precondition guard',
        (tester) async {
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            fypRecordsProvider.overrideWith((ref) async => [_ownRecord()]),
            fypMarksSummariesProvider.overrideWith(
                (ref, recordId) async => [_finalizedMarks()]),
            finalizeMarksProvider.overrideWithValue(
                (recordId, courseCode, breakdown) async {
              throw Exception(
                  'failed-precondition: Marks are already finalized for this course.');
            }),
          ],
          child: MaterialApp(home: const CspMarksPage()),
        ),
      );

      await tester.tap(find.text('Finalize'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        '{"proposal": 20, "report": 40, "viva": 40}',
      );
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Finalize'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('already finalized'), findsOneWidget);
    });
  });
}