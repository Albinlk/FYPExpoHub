import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/academic_semester.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/csp_cohort_page.dart';

/// P10: CSP600 lecturer assigns examiners (handbook Table 2.1 #19) and hands
/// the cohort over to CSP650 (#29).
AcademicSemester _sem(String id, String status, int year) => AcademicSemester(
      id: id,
      code: '${year}_1',
      label: 'Mar–Aug $year',
      status: status,
      startDate: DateTime(year, 3, 1),
      endDate: DateTime(year, 8, 31),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

FypRecord _rec(String id, String course, {String? examiner}) => FypRecord(
      id: id,
      academicSemesterId: 's26',
      studentId: 'stu-$id',
      currentCourseCode: course,
      programmeCode: 'CS266',
      projectTitle: 'Project $id',
      mainSupervisorId: 'sv-1',
      examinerId: examiner,
      workflowStatus: 'proposal_submitted',
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );

class _Admin extends SemesterAdmin {
  _Admin(super.ref);
  final promoted = <String>[];

  @override
  Future<void> promote(String fypRecordId, String targetSemesterId) async {
    if (fypRecordId == 'b') throw Exception('failed-precondition: CSP600 marks are not finalized.');
    promoted.add('$fypRecordId->$targetSemesterId');
  }
}

void main() {
  late _Admin admin;
  final assigned = <String>[];

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    assigned.clear();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        fypmsCurrentRolesProvider.overrideWith((ref) async => ['csp600_lecturer']),
        fypRecordsProvider.overrideWith((ref) async => [_rec('a', 'CSP600'), _rec('b', 'CSP600', examiner: 'ex-1'), _rec('c', 'CSP650')]),
        supervisorsDirectoryProvider.overrideWith((ref) async => [
              {'id': 'sv-1', 'display_name': 'Dr. Supervisor'},
              {'id': 'ex-1', 'display_name': 'Dr. Examiner'},
              {'id': 'ex-2', 'display_name': 'Dr. Second'},
            ]),
        fypmsSemestersProvider.overrideWith((ref) async => [_sem('s26', 'active', 2026), _sem('s27', 'planned', 2027)]),
        assignExaminerProvider.overrideWithValue((record, examiner) async => assigned.add('$record:$examiner')),
        semesterAdminProvider.overrideWith((ref) => admin = _Admin(ref)),
      ],
      child: const MaterialApp(home: CspCohortPage()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('lists only CSP600 students, with their examiner or a warning', (tester) async {
    await pump(tester);
    expect(find.text('Project a'), findsOneWidget);
    expect(find.text('Project b'), findsOneWidget);
    expect(find.text('Project c'), findsNothing, reason: 'CSP650 is not this lecturer\'s');
    expect(find.text('Examiner: not assigned'), findsOneWidget);
    expect(find.text('Examiner: Dr. Examiner'), findsOneWidget);
  });

  testWidgets('assigns an examiner, never offering the supervisor', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('assign-examiner-a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('examiner-picker')));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Supervisor'), findsNothing);
    await tester.tap(find.text('Dr. Second').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Assign Examiner'));
    await tester.pumpAndSettle();
    expect(assigned, ['a:ex-2']);
  });

  testWidgets('hand over promotes the ready students and lists the rest', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('handover-cohort')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('handover-semester')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2027_1 — Mar–Aug 2027').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hand Over'));
    await tester.pumpAndSettle();
    expect(admin.promoted, ['a->s27']);
    expect(find.text('1 promoted, 1 not promoted.'), findsOneWidget);
    expect(find.textContaining('marks are not finalized'), findsOneWidget);
  });
}
