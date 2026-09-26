import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_special_evaluation.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_form_submission.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/form_evaluations_view.dart';

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

FypFormSubmission _submission(String code) => FypFormSubmission(
      id: 'sub-$code',
      fypRecordId: 'rec-1',
      formCode: code,
      formVersion: 1,
      payload: const {},
      status: 'submitted',
      submittedAt: DateTime(2026, 9, 20),
      createdAt: DateTime(2026, 9, 20),
      updatedAt: DateTime(2026, 9, 20),
    );

SpecialEvaluation _assessed({required bool eligible}) => SpecialEvaluation(
      fypRecordId: 'rec-1',
      progressLmcMarks: 13,
      chaptersComplete: true,
      presentedAtExhibition: true,
      finalSemesterCoursesPassed: eligible,
      eligible: eligible,
    );

void main() {
  test('checks payload parses; 7.5 is the Progress + LMC threshold', () {
    final c = SpecialEvaluationChecks.fromJson({
      'progress_lmc_marks': 7.5,
      'progress_lmc_complete': true,
      'final_report_submitted': true,
      'exhibition_visit_recorded': false,
      'assessment': {
        'fyp_record_id': 'rec-1',
        'progress_lmc_marks': 7.5,
        'chapters_complete': true,
        'presented_at_exhibition': false,
        'final_semester_courses_passed': true,
        'eligible': false,
        'assessed_at': '2026-09-26T10:00:00+08:00',
      },
    });
    expect(c.progressMet, isTrue);
    expect(c.assessment!.eligible, isFalse);
    expect(c.assessment!.presentedAtExhibition, isFalse);
    expect(const SpecialEvaluationChecks(
      progressLmcMarks: 7.49,
      progressLmcComplete: true,
      finalReportSubmitted: true,
      exhibitionVisitRecorded: true,
    ).progressMet, isFalse);
  });

  test('F14 follows the flag; F15/F16 follow the record qualification', () {
    final closed = fypmsFormCodesFor(applicationsOpen: false, qualified: false);
    expect(closed, isNot(contains('F14')));
    expect(closed, isNot(contains('F15')));
    final open = fypmsFormCodesFor(applicationsOpen: true, qualified: false);
    expect(open, contains('F14'));
    expect(open, isNot(contains('F16')));
    final qualified = fypmsFormCodesFor(applicationsOpen: false, qualified: true);
    expect(qualified, containsAll(['F15', 'F16']));
    expect(fypmsCanEvaluate('F14', 'lecturer'), isFalse, reason: 'F14 is not rubric-scored');
  });

  Future<void> pump(WidgetTester tester, Widget view, List<Override> overrides) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: view),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('R8 CSP650 lecturer checks F14 at phone width and saves the decision', (tester) async {
    final saved = <Map<String, Object?>>[];
    await pump(
      tester,
      FormEvaluationsView(
        title: 'Course Evaluations',
        role: 'lecturer',
        records: AsyncData([_record()]),
        emptyText: 'none',
      ),
      [
        fypFormSubmissionsProvider.overrideWith((ref, id) async => [_submission('F9')]),
        fypSpecialEvaluationProvider.overrideWith((ref, id) async => null),
        fypSpecialEvaluationChecksProvider.overrideWith((ref, id) async => const SpecialEvaluationChecks(
              progressLmcMarks: 13,
              progressLmcComplete: true,
              finalReportSubmitted: true,
              exhibitionVisitRecorded: true,
            )),
        assessSpecialEvaluationProvider.overrideWithValue(({
          required fypRecordId,
          required chaptersComplete,
          required presentedAtExhibition,
          required finalSemesterCoursesPassed,
          note,
        }) async {
          saved.add({
            'id': fypRecordId,
            'chapters': chaptersComplete,
            'presented': presentedAtExhibition,
            'courses': finalSemesterCoursesPassed,
          });
        }),
      ],
    );

    expect(find.text('F14 — Special evaluation'), findsOneWidget);
    expect(find.text('Not assessed'), findsOneWidget);

    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('13.00 of 15'), findsOneWidget);
    // Chapters and exhibition are suggested; the courses check is the lecturer's.
    expect(find.textContaining('Does not qualify'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('f14-courses')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('f14-courses')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Qualifies'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved.single, {'id': 'rec-1', 'chapters': true, 'presented': true, 'courses': true});
  });

  for (final eligible in [false, true]) {
    testWidgets('R8 supervisor F15 is ${eligible ? 'open' : 'closed'} when the student is '
        '${eligible ? '' : 'not '}qualified', (tester) async {
      await pump(
        tester,
        FormEvaluationsView(
          title: 'Evaluations',
          role: 'supervisor',
          records: AsyncData([_record()]),
          emptyText: 'none',
        ),
        [
          fypFormSubmissionsProvider.overrideWith((ref, id) async => [_submission('F15')]),
          fypSpecialEvaluationProvider.overrideWith((ref, id) async => _assessed(eligible: eligible)),
        ],
      );
      expect(find.text('F14 — Special evaluation'), findsNothing, reason: 'lecturer only');
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed == null, !eligible);
      expect(find.text(eligible ? 'Evaluate' : 'Not qualified'), findsOneWidget);
    });
  }
}
