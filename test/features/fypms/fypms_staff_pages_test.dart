import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_correction_item.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_expo_publication.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_form_submission.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_marks_summary.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_presentation_session.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_presentation_slot.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_progress_log.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record_assignment.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_supervision_request.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_assignments_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_expo_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_presentations_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_requests_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/csp_marks_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/csp_requests_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/examiner_corrections_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/examiner_evaluations_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_corrections_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_evaluations_page.dart';
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

FypSupervisionRequest _request() => FypSupervisionRequest(
      id: 'req-1',
      fypRecordId: 'rec-1',
      preferredSupervisorId: 'staff-1',
      rationale: 'Interested in healthcare AI.',
      status: 'pending',
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

FypFormSubmission _submission() => FypFormSubmission(
      id: 'sub-1',
      fypRecordId: 'rec-1',
      formCode: 'F8',
      formVersion: 1,
      payload: const {'title': 'Progress Report'},
      status: 'submitted',
      submittedAt: DateTime(2026, 8, 11),
      createdAt: DateTime(2026, 8, 11),
      updatedAt: DateTime(2026, 8, 11),
    );

FypCorrectionItem _correction() => FypCorrectionItem(
      id: 'corr-1',
      fypRecordId: 'rec-1',
      itemCode: 'CORR-ABCD1234',
      description: 'Expand methodology section.',
      severity: 'minor',
      status: 'open',
      createdAt: DateTime(2026, 8, 12),
      updatedAt: DateTime(2026, 8, 12),
    );

FypPresentationSession _session() => FypPresentationSession(
      id: 'sess-1',
      sessionCode: 'SESS-1',
      sessionTitle: 'Defence',
      eventDate: DateTime(2026, 9, 1, 9, 0),
      startAt: DateTime(2026, 9, 1, 9, 0),
      endAt: DateTime(2026, 9, 1, 17, 0),
      venue: 'Lab 3',
      sessionType: 'defence',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

FypPresentationSlot _slot() => FypPresentationSlot(
      id: 'slot-1',
      sessionId: 'sess-1',
      fypRecordId: 'rec-1',
      slotNumber: 1,
      startAt: DateTime(2026, 9, 1, 9, 0),
      endAt: DateTime(2026, 9, 1, 9, 30),
      room: 'Lab 3',
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
    );

FypExpoPublication _readyPublication() => FypExpoPublication(
      id: 'pub-1',
      fypRecordId: 'rec-1',
      eventId: 'event-1',
      status: 'ready',
      payload: const {'title': 'AI Health Assistant'},
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
    );

FypMarksSummary _marksSummary() => FypMarksSummary(
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

FypRecordAssignment _assignment() => FypRecordAssignment(
      id: 'asg-1',
      fypRecordId: 'rec-1',
      academicRole: 'supervisor',
      lecturerId: 'staff-1',
      isActive: true,
      assignedAt: DateTime(2026, 8, 1),
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

const _staff = [
  {'id': 'staff-1', 'display_name': 'Dr. Aminah', 'email': 'aminah@example.com'},
];

const _events = [
  {'id': 'event-1', 'title': 'Expo 2026'},
];

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
  baseOverrides() => [
        fypRecordsProvider.overrideWith((ref) async => [_record()]),
        fypPendingSupervisionRequestsProvider.overrideWith((ref) async => [_request()]),
        assignedFypRecordsProvider.overrideWith((ref, role) async => [_record()]),
        fypStaffProvider.overrideWith((ref, roles) async => _staff),
        fypPresentationSessionsProvider.overrideWith((ref) async => [_session()]),
        fypPresentationSlotsProvider.overrideWith((ref, sessionId) async => [_slot()]),
        fypExpoPublicationsProvider.overrideWith((ref) async => [_readyPublication()]),
        fypPublishedEventsProvider.overrideWith((ref) async => _events),
        fypRecordAssignmentsProvider.overrideWith((ref, recordId) async => [_assignment()]),
        fypProgressLogsProvider.overrideWith((ref, recordId) async => [_submittedLog()]),
        fypFormSubmissionsProvider.overrideWith((ref, recordId) async => [_submission()]),
        fypCorrectionItemsProvider.overrideWith((ref, recordId) async => [_correction()]),
        fypMarksSummariesProvider.overrideWith((ref, recordId) async => [_marksSummary()]),
      ];

  Widget home(Widget page) => MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: page,
      );

  Widget app(Widget page) => ProviderScope(
        overrides: baseOverrides(),
        child: home(page),
      );
  group('Supervision requests (coordinator & CSP)', () {
    testWidgets('shows preferred supervisor and Approve/Reject', (tester) async {
      await _pump(tester, app(const CoordinatorRequestsPage()));

      expect(find.text('Supervision Requests'), findsOneWidget);
      expect(find.text('AI Health Assistant'), findsOneWidget);
      expect(find.text('Preferred supervisor: Dr. Aminah (aminah@example.com)'),
          findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Assign Supervisor'), findsNothing);
    });

    testWidgets('CSP page renders the same pending request card', (tester) async {
      await _pump(tester, app(const CspRequestsPage()));

      expect(find.text('AI Health Assistant'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
    });

    testWidgets('approve invokes decideSupervisionRequestProvider', (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            decideSupervisionRequestProvider.overrideWithValue(
              (requestId, decision, reason) async {
                called.addAll([requestId, decision, reason ?? '']);
              },
            ),
          ],
          child: home(const CoordinatorRequestsPage()),
        ),
      );

      await tester.tap(find.text('Approve'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['req-1', 'approved', '']);
      expect(find.text('Request approved.'), findsOneWidget);
    });
  });

  group('CoordinatorAssignmentsPage', () {
    testWidgets('renders role assign buttons and active assignment', (tester) async {
      await _pump(tester, app(const CoordinatorAssignmentsPage()));

      expect(find.text('Assignments'), findsOneWidget);
      expect(find.text('Supervisor'), findsOneWidget);
      expect(find.text('Co-Supervisor'), findsOneWidget);
      expect(find.text('Examiner'), findsOneWidget);
      expect(find.text('• supervisor'), findsOneWidget);
    });

    testWidgets('assigning an examiner calls assignExaminerProvider', (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            assignExaminerProvider.overrideWithValue((recordId, examinerId) async {
              called.addAll([recordId, examinerId]);
            }),
          ],
          child: home(const CoordinatorAssignmentsPage()),
        ),
      );

      await tester.tap(find.text('Examiner'));
      await tester.pumpAndSettle();
      expect(find.text('Assign examiner'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr. Aminah (aminah@example.com)').last);
      await tester.pumpAndSettle();

      await tester.tap(_dialogButton('Assign'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['rec-1', 'staff-1']);
      expect(find.text('examiner assigned.'), findsOneWidget);
    });
  });

  group('CspMarksPage', () {
    testWidgets('renders finalized marks summary', (tester) async {
      await _pump(tester, app(const CspMarksPage()));

      expect(find.text('Finalize Marks'), findsOneWidget);
      expect(find.text('AI Health Assistant'), findsOneWidget);
      expect(find.text('CSP600 — Grade: A'), findsOneWidget);
    });

    testWidgets('finalizing marks calls finalizeMarksProvider', (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            finalizeMarksProvider.overrideWithValue(
                (recordId, courseCode, breakdown) async {
              called.addAll([recordId, courseCode]);
            }),
          ],
          child: home(const CspMarksPage()),
        ),
      );

      await tester.tap(find.text('Finalize').first);
      await tester.pumpAndSettle();
      expect(find.text('Finalize Course Marks'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        '{"proposal": 20, "report": 40, "viva": 40}',
      );
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Finalize'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['rec-1', 'CSP600']);
      expect(find.text('Marks finalized.'), findsOneWidget);
    });
  });

  group('SupervisorProgressPage', () {
    testWidgets('shows Review button only for submitted logs', (tester) async {
      await _pump(tester, app(const SupervisorProgressPage()));

      expect(find.text('Progress Reviews'), findsOneWidget);
      expect(find.text('Completed literature review.'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('W3'), findsOneWidget);
    });

    testWidgets('validating a log calls validateProgressLogProvider', (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            validateProgressLogProvider.overrideWithValue(
                (logId, status, comment, recordId) async {
              called.addAll([logId, status, comment ?? '', recordId]);
            }),
          ],
          child: home(const SupervisorProgressPage()),
        ),
      );

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      expect(find.text('Review Progress Log'), findsOneWidget);
      expect(find.text('Validate'), findsOneWidget);
      final decisionItems = tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .items;
      expect(
        decisionItems!.map((e) => e.value),
        containsAll(['validated', 'rejected']),
      );

      await tester.tap(_dialogButton('Submit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['log-1', 'validated', '', 'rec-1']);
      expect(find.text('Log validated.'), findsOneWidget);
    });
  });

  group('SupervisorEvaluationsPage', () {
    testWidgets('opens evaluate dialog with decision options', (tester) async {
      await _pump(tester, app(const SupervisorEvaluationsPage()));

      expect(find.text('Evaluations'), findsOneWidget);
      expect(find.text('Form F8'), findsOneWidget);
      expect(find.text('Evaluate'), findsOneWidget);

      await tester.tap(find.text('Evaluate'));
      await tester.pumpAndSettle();

      expect(find.text('Evaluate Submission'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      final decisionItems = tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .items;
      expect(
        decisionItems!.map((e) => e.value),
        containsAll(['approved', 'rejected', 'resubmission_required']),
      );
    });

    testWidgets('submitting evaluation calls submitFormEvaluationProvider',
        (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            submitFormEvaluationProvider.overrideWithValue(
                (submissionId, scores, comments, decision, recordId) async {
              called.addAll([submissionId, decision, recordId]);
            }),
          ],
          child: home(const SupervisorEvaluationsPage()),
        ),
      );

      await tester.tap(find.text('Evaluate'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '{"rubric_item_1": 5}');
      await tester.tap(_dialogButton('Submit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['sub-1', 'approved', 'rec-1']);
      expect(find.text('Evaluation submitted.'), findsOneWidget);
    });
  });

  group('ExaminerEvaluationsPage', () {
    testWidgets('opens evaluate dialog with decision options', (tester) async {
      await _pump(tester, app(const ExaminerEvaluationsPage()));

      expect(find.text('Examiner Evaluations'), findsOneWidget);
      expect(find.text('Form F8'), findsOneWidget);

      await tester.tap(find.text('Evaluate'));
      await tester.pumpAndSettle();

      expect(find.text('Evaluate Submission'), findsOneWidget);
      final decisionItems = tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .items;
      expect(
        decisionItems!.map((e) => e.value),
        containsAll(['approved', 'rejected', 'resubmission_required']),
      );
    });
  });

  group('Corrections pages', () {
    testWidgets('supervisor page lists correction items', (tester) async {
      await _pump(tester, app(const SupervisorCorrectionsPage()));

      expect(find.text('Corrections'), findsOneWidget);
      expect(find.text('CORR-ABCD1234 — minor'), findsOneWidget);
      expect(find.text('Expand methodology section.'), findsOneWidget);
    });

    testWidgets('examiner page lists correction items', (tester) async {
      await _pump(tester, app(const ExaminerCorrectionsPage()));

      expect(find.text('CORR-ABCD1234 — minor'), findsOneWidget);
    });

    testWidgets('creating a correction calls createCorrectionItemProvider',
        (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            createCorrectionItemProvider.overrideWithValue(
                (recordId, submissionId, text, severity) async {
              called.addAll([recordId, text, severity]);
            }),
          ],
          child: home(const SupervisorCorrectionsPage()),
        ),
      );

      await tester.tap(find.text('Add Correction'));
      await tester.pumpAndSettle();
      expect(find.text('New Correction Item'), findsOneWidget);
      expect(find.text('Item Code'), findsNothing);

      await tester.enterText(
        find.byType(TextField).first,
        'Update the references section.',
      );
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Create'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['rec-1', 'Update the references section.', 'minor']);
      expect(find.text('Correction item created.'), findsOneWidget);
    });
  });

  group('CoordinatorPresentationsPage', () {
    testWidgets('lists sessions and opens slot scheduling dialog', (tester) async {
      await _pump(tester, app(const CoordinatorPresentationsPage()));

      expect(find.text('Presentations'), findsOneWidget);
      expect(find.text('SESS-1 — Defence'), findsOneWidget);

      await tester.tap(find.text('SESS-1 — Defence'));
      await tester.pumpAndSettle();
      expect(find.text('Presentation Slots'), findsOneWidget);
      expect(find.text('Slot 1'), findsOneWidget);

      await tester.tap(find.text('Schedule Slot'));
      await tester.pumpAndSettle();
      expect(find.text('Schedule Slot'), findsWidgets);
      expect(find.text('Slot Number'), findsOneWidget);
      expect(find.text('Start: 09:00'), findsOneWidget);
      expect(find.text('End: 09:30'), findsOneWidget);
    });

    testWidgets('scheduling a slot calls schedulePresentationSlotProvider',
        (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            schedulePresentationSlotProvider.overrideWithValue(
                (sessionId, recordId, slotNumber, startAt, endAt, room) async {
              called.addAll([sessionId, recordId, '$slotNumber', '09:00', 'Lab 3']);
            }),
          ],
          child: home(const CoordinatorPresentationsPage()),
        ),
      );

      await tester.tap(find.text('SESS-1 — Defence'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Schedule Slot'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AI Health Assistant').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '2');
      await tester.pumpAndSettle();
      await tester.tap(_dialogButton('Schedule'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['sess-1', 'rec-1', '2', '09:00', 'Lab 3']);
      expect(find.text('Slot scheduled.'), findsOneWidget);
    });
  });

  group('CoordinatorExpoPage', () {
    testWidgets('lists ready publications with publish action', (tester) async {
      await _pump(tester, app(const CoordinatorExpoPage()));

      expect(find.text('Expo Publications'), findsOneWidget);
      expect(find.text('AI Health Assistant'), findsOneWidget);
      expect(find.textContaining('Status: ready | event-1'), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);
    });

    testWidgets('publishing calls publishFypRecordToExpoProvider', (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            publishFypRecordToExpoProvider.overrideWithValue((publicationId) async {
              called.add(publicationId);
            }),
          ],
          child: home(const CoordinatorExpoPage()),
        ),
      );

      await tester.tap(find.text('Publish'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['pub-1']);
      expect(find.text('Published to Expo.'), findsOneWidget);
    });

    testWidgets('preparing a publication calls prepareExpoPublicationProvider',
        (tester) async {
      final called = <String>[];
      await _pump(
        tester,
        ProviderScope(
          overrides: [
            ...baseOverrides(),
            prepareExpoPublicationProvider.overrideWithValue(
                (recordId, eventId, payload) async {
              called.addAll([recordId, eventId]);
            }),
          ],
          child: home(const CoordinatorExpoPage()),
        ),
      );

      await tester.tap(find.text('Prepare Publication'));
      await tester.pumpAndSettle();

      expect(find.text('Prepare Publication'), findsWidgets);
      expect(find.text('FYP Record'), findsOneWidget);
      expect(find.text('Event'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('AI Health Assistant').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expo 2026').last);
      await tester.pumpAndSettle();

      await tester.tap(_dialogButton('Prepare'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(called, ['rec-1', 'event-1']);
      expect(find.text('Publication prepared.'), findsOneWidget);
    });
  });
}