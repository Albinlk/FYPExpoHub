import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_reports.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_report_submission.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_reports_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_reports_page.dart';

FypRecord _record() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      workflowStatus: 'proposal_submitted',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

FypReportSubmission _report({String status = 'submitted'}) => FypReportSubmission(
      id: 'rep-1',
      fypRecordId: 'rec-1',
      reportType: 'proposal',
      version: 1,
      fileUrl: '2026_1/rec-1/proposal/1/report.pdf',
      plagiarismReportUrl: '2026_1/rec-1/proposal_plagiarism/1/turnitin.pdf',
      similarityIndex: 18,
      status: status,
      submittedAt: DateTime(2026, 9, 20),
      createdAt: DateTime(2026, 9, 20),
      updatedAt: DateTime(2026, 9, 20),
    );

Future<void> _pump(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  group('F6 rules', () {
    test('similarity index must be given and at most 30 %', () {
      expect(similarityProblem(''), contains('Enter the similarity index'));
      expect(similarityProblem('abc'), contains('between 0 and 100'));
      expect(similarityProblem('101'), contains('between 0 and 100'));
      expect(similarityProblem('30.5'), contains('30 % limit'));
      expect(similarityProblem('30'), isNull);
      expect(similarityProblem(' 12.5 % '), isNull);
      expect(parseSimilarity(' 12.5 % '), 12.5);
    });

    test('bucket and status labels', () {
      expect(reportBucket('final'), 'fyp-final-reports');
      expect(reportBucket('proposal'), 'fyp-proposal-reports');
      expect(reportStatusLabel('submitted'), 'Awaiting supervisor endorsement');
      expect(reportStatusLabel('under_review'), 'Endorsed — under review');
      expect(reportStatusLabel('rejected'), 'Returned');
    });
  });

  testWidgets('F6 dialog blocks a similarity index above 30 % and needs both files', (tester) async {
    await _pump(
      tester,
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => ReportSubmissionDialog(record: _record()),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Report (PDF / DOC / DOCX)'), findsOneWidget);
    expect(find.text('Original plagiarism report (PDF)'), findsOneWidget);
    final submit = find.widgetWithText(ElevatedButton, 'Submit');

    await tester.enterText(find.byKey(const Key('similarity-index')), '34');
    await tester.pump();
    expect(find.textContaining('30 % limit'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('similarity-index')), '18');
    await tester.pump();
    expect(find.textContaining('30 % limit'), findsNothing);
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull, reason: 'files not attached');
  });

  group('SupervisorReportsPage', () {
    Widget page({required List<FypReportSubmission> reports, List<Object?>? called}) => ProviderScope(
          overrides: [
            assignedFypRecordsProvider.overrideWith((ref, role) async => role == 'supervisor' ? [_record()] : const []),
            fypReportSubmissionsProvider.overrideWith((ref, recordId) async => reports),
            endorseReportProvider.overrideWithValue(
              (reportId, decision, comment, recordId) async => called?.addAll([reportId, decision, comment, recordId]),
            ),
          ],
          child: const MaterialApp(home: SupervisorReportsPage()),
        );

    testWidgets('shows similarity, files and endorses', (tester) async {
      final called = <Object?>[];
      await _pump(tester, page(reports: [_report()], called: called));

      expect(find.text('Proposal (F6a) · v1'), findsOneWidget);
      expect(find.text('Similarity index: 18 %'), findsOneWidget);
      expect(find.text('Awaiting supervisor endorsement'), findsOneWidget);
      expect(find.text('Plagiarism report'), findsOneWidget);

      await tester.tap(find.text('Endorse'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(called, ['rep-1', 'endorsed', null, 'rec-1']);
      expect(find.text('Report endorsed.'), findsOneWidget);
    });

    testWidgets('returning needs a comment', (tester) async {
      final called = <Object?>[];
      await _pump(tester, page(reports: [_report()], called: called));

      await tester.tap(find.text('Return'));
      await tester.pump();
      expect(find.text('Say why the report is returned.'), findsOneWidget);
      expect(called, isEmpty);

      await tester.enterText(find.byType(TextField), 'Similarity report is for a different draft.');
      await tester.tap(find.text('Return'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(called, ['rep-1', 'returned', 'Similarity report is for a different draft.', 'rec-1']);
    });

    testWidgets('endorsed reports have no actions', (tester) async {
      await _pump(tester, page(reports: [_report(status: 'under_review')]));
      expect(find.text('Endorsed — under review'), findsOneWidget);
      expect(find.text('Endorse'), findsNothing);
    });
  });
}
