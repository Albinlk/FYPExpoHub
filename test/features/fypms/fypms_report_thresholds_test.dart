import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_reports.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_report_submission.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_reports_page.dart';

FypRecord _record() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      workflowStatus: 'proposal_in_progress',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

void main() {
  test('textbook minimums: proposal 30 pages / 15 refs, final 50 / 30, half academic', () {
    expect(reportMinimums('proposal'), (30, 15));
    expect(reportMinimums('final'), (50, 30));
    expect(reportCountsProblem('proposal', '29', '15', '8'), contains('30 pages'));
    expect(reportCountsProblem('proposal', '30', '14', '8'), contains('15 references'));
    expect(reportCountsProblem('proposal', '30', '16', '7'), contains('half'));
    expect(reportCountsProblem('proposal', '30', '16', '17'), contains('cannot exceed'));
    expect(reportCountsProblem('proposal', '30', '16', '8'), isNull);
    expect(reportCountsProblem('final', '49', '30', '15'), contains('50 pages'));
    expect(reportCountsProblem('final', '', '30', '15'), contains('Enter'));
  });

  testWidgets('R11 F6 dialog: counts are checked and human subjects need the REC form', (tester) async {
    tester.view.physicalSize = const Size(375, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(context: context, builder: (_) => ReportSubmissionDialog(record: _record())),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.textContaining('At least 30 pages and 15 references'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('report-pages')), '25');
    await tester.enterText(find.byKey(const Key('report-refs')), '20');
    await tester.enterText(find.byKey(const Key('report-academic')), '12');
    await tester.pump();
    expect(find.text('A proposal needs at least 30 pages.'), findsOneWidget);

    expect(find.text('REC ethics form (PDF)'), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('human-subjects')));
    await tester.tap(find.byKey(const Key('human-subjects')));
    await tester.pump();
    expect(find.text('REC ethics form (PDF)'), findsOneWidget);
  });

  testWidgets('R11 the report card shows counts and the REC form link', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: ReportSubmissionCard(
            report: FypReportSubmission(
              id: 'r1',
              fypRecordId: 'rec-1',
              reportType: 'proposal',
              version: 1,
              fileUrl: '2026_2/rec-1/proposal/1/p.pdf',
              similarityIndex: 12,
              plagiarismReportUrl: '2026_2/rec-1/proposal_plagiarism/1/x.pdf',
              pageCount: 42,
              referenceCount: 18,
              academicReferenceCount: 10,
              involvesHumanSubjects: true,
              ethicsFormUrl: '2026_2/rec-1/proposal_ethics/1/rec.pdf',
              status: 'submitted',
              submittedAt: DateTime(2026, 9, 20),
              createdAt: DateTime(2026, 9, 20),
              updatedAt: DateTime(2026, 9, 20),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('42 pages · 18 references (10 academic) · human subjects'), findsOneWidget);
    expect(find.text('REC ethics form'), findsOneWidget);
  });
}
