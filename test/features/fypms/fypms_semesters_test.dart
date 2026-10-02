import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/academic_course.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/academic_semester.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_semesters_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/semester_selector.dart';

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

FypRecord _record(String id, String semester) => FypRecord(
      id: id,
      academicSemesterId: semester,
      studentId: 's-$id',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      workflowStatus: 'formulation_in_progress',
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );

final _semesters = [_sem('s25', 'completed', 2025), _sem('s26', 'active', 2026), _sem('s27', 'planned', 2027)];

class _Admin extends SemesterAdmin {
  _Admin(super.ref);
  final calls = <String>[];

  @override
  Future<void> setStatus(String semesterId, String status) async => calls.add('$semesterId:$status');

  @override
  Future<void> promote(String fypRecordId, String targetSemesterId) async => calls.add('promote:$fypRecordId:$targetSemesterId');
}

void main() {
  test('S2 lists follow the active semester by default; "all" removes the filter', () async {
    final container = ProviderContainer(overrides: [
      fypmsSemestersProvider.overrideWith((ref) async => _semesters),
    ]);
    addTearDown(container.dispose);
    await container.read(fypmsSemestersProvider.future);
    expect(container.read(fypmsEffectiveSemesterIdProvider), 's26');
    container.read(fypmsSelectedSemesterProvider.notifier).select('s25');
    expect(container.read(fypmsEffectiveSemesterIdProvider), 's25');
    container.read(fypmsSelectedSemesterProvider.notifier).select(kAllSemesters);
    expect(container.read(fypmsEffectiveSemesterIdProvider), isNull);

    final records = [_record('a', 's25'), _record('b', 's26')];
    expect(inSemester(records, 's26').map((r) => r.id), ['b']);
    expect(inSemester(records, null), hasLength(2), reason: 'past semesters are kept, just filtered');
  });

  testWidgets('S1 semesters page offers the allowed transitions only', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late _Admin admin;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        fypmsSemestersProvider.overrideWith((ref) async => _semesters),
        fypmsOfferingsProvider.overrideWith((ref) async => const []),
        fypmsCoursesProvider.overrideWith((ref) async => [
              AcademicCourse(
                code: 'CSP600',
                name: 'Project Formulation',
                stage: 'formulation',
                creditHours: 2,
                isActive: true,
                createdAt: DateTime(2026, 1, 1),
                updatedAt: DateTime(2026, 1, 1),
              ),
            ]),
        fypStaffProvider.overrideWith((ref, roles) async => const []),
        semesterAdminProvider.overrideWith((ref) => admin = _Admin(ref)),
      ],
      child: const MaterialApp(home: CoordinatorSemestersPage()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('semester-2027_1-active')), findsOneWidget);
    expect(find.byKey(const Key('semester-2026_1-completed')), findsOneWidget);
    expect(find.byKey(const Key('semester-2025_1-archived')), findsOneWidget);
    expect(find.byKey(const Key('semester-2026_1-archived')), findsNothing, reason: 'complete it first');
    expect(find.text('CSP600: not offered'), findsNWidgets(3));

    await tester.tap(find.byKey(const Key('semester-2027_1-active')));
    await tester.pumpAndSettle();
    expect(find.text('Make active 2027_1?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Make active'));
    await tester.pumpAndSettle();
    expect(admin.calls, ['s27:active']);
  });

  testWidgets('S3 promotion offers only later planned / active semesters', (tester) async {
    late _Admin admin;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        fypmsSemestersProvider.overrideWith((ref) async => _semesters),
        semesterAdminProvider.overrideWith((ref) => admin = _Admin(ref)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const PromoteRecordDialog(fypRecordId: 'r1', currentSemesterId: 's26', title: 'AI Health'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('promote-semester')));
    await tester.pumpAndSettle();
    expect(find.text('2025_1 — Mar–Aug 2025'), findsNothing);
    expect(find.text('2026_1 — Mar–Aug 2026'), findsNothing);
    await tester.tap(find.text('2027_1 — Mar–Aug 2027').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Promote'));
    await tester.pumpAndSettle();
    expect(admin.calls, ['promote:r1:s27']);
  });
}
