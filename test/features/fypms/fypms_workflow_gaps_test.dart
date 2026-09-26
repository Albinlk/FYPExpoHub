import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_correction_item.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_milestone.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_corrections_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_milestones_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/correction_evidence_dialog.dart';

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

FypCorrectionItem _item({String status = 'evidence_submitted'}) => FypCorrectionItem(
      id: 'corr-1',
      fypRecordId: 'rec-1',
      itemCode: 'CORR-ABCD1234',
      description: 'Expand the methodology chapter.',
      severity: 'minor',
      status: status,
      evidenceNote: 'Added section 3.4 on sampling.',
      evidenceUrl: '2026_2/rec-1/correction_CORR-ABCD1234/1/chapter3.pdf',
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 2),
    );

Widget _app(Widget home) => ProviderScope(
      overrides: [
        assignedFypRecordsProvider.overrideWith((ref, role) async => [_record()]),
        fypCorrectionItemsProvider.overrideWith((ref, recordId) async => [_item()]),
        fypMilestonesProvider.overrideWith((ref, recordId) async => [
              FypMilestone(
                id: 'm-1',
                fypRecordId: 'rec-1',
                milestoneCode: 'M1',
                milestoneTitle: 'Chapter 1-3 draft',
                status: 'in_progress',
                createdAt: DateTime(2026, 8, 1),
                updatedAt: DateTime(2026, 8, 1),
              ),
            ]),
      ],
      child: MaterialApp(home: home),
    );

void main() {
  Future<void> pump(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('G-23 staff see the correction evidence before confirming', (tester) async {
    await pump(tester, _app(const SupervisorCorrectionsPage()));
    expect(find.text('Student: Added section 3.4 on sampling.'), findsOneWidget);
    expect(find.text('Evidence file'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('G-23 evidence needs a note or a file', (tester) async {
    await pump(
      tester,
      _app(Builder(
        builder: (context) => TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => CorrectionEvidenceDialog(record: _record(), item: _item(status: 'open')),
          ),
          child: const Text('open'),
        ),
      )),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(FilledButton, 'Submit');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('evidence-note')), 'Rewrote the abstract.');
    await tester.pump();
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
  });

  testWidgets('G-22 supervisors see milestones read-only', (tester) async {
    await pump(tester, _app(const SupervisorMilestonesPage()));
    expect(find.text('M1 — Chapter 1-3 draft'), findsOneWidget);
    expect(find.text('Add Milestone'), findsNothing);
    expect(find.byTooltip('Edit milestone'), findsNothing);
  });
}
