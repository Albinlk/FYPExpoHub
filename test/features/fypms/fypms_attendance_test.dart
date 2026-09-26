import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_attendance.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/academic_semester.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_progress_log.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_progress_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/consultation_attendance_banner.dart';

final _start = DateTime(2026, 3, 2);
final _end = DateTime(2026, 6, 19);

FypProgressLog _log(DateTime date, {String status = 'validated'}) => FypProgressLog(
      id: 'log-${date.toIso8601String()}',
      fypRecordId: 'rec-1',
      weekNumber: semesterWeek(_start, date),
      progressDate: date,
      summary: 'Worked on chapter 2',
      status: status,
      createdAt: date,
      updatedAt: date,
    );

FypRecord _record() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      workflowStatus: 'formulation_in_progress',
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );

AcademicSemester _semester() => AcademicSemester(
      id: 'sem-1',
      code: '2026_1',
      label: 'Mar–Aug 2026',
      status: 'active',
      startDate: _start,
      endDate: _end,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  test('semester weeks count from the semester start', () {
    expect(semesterWeek(_start, _start), 1);
    expect(semesterWeek(_start, DateTime(2026, 3, 8)), 1);
    expect(semesterWeek(_start, DateTime(2026, 3, 9)), 2);
  });

  test('attendance: signed consultations per elapsed week, several in a week count once', () {
    final logs = [
      _log(DateTime(2026, 3, 3)),
      _log(DateTime(2026, 3, 5)), // same week 1
      _log(DateTime(2026, 3, 10)), // week 2
      _log(DateTime(2026, 3, 24)), // week 4
      _log(DateTime(2026, 3, 18), status: 'submitted'), // week 3, not signed
    ];
    final a = consultationAttendance(logs, semesterStart: _start, semesterEnd: _end, today: DateTime(2026, 3, 27));
    expect(a.expectedWeeks, 4);
    expect(a.attendedWeeks, 3);
    expect(a.percent, 75);
    expect(a.meetsRequirement, isFalse);
    expect(a.pending, 1);
    expect(a.summary, 'Signed consultations in 3 of 4 weeks (75 %)');
  });

  test('attendance stops counting at the semester end and meets 80 % when signed', () {
    final logs = [for (var w = 0; w < 16; w++) _log(_start.add(Duration(days: 7 * w + 1)))];
    final a = consultationAttendance(logs, semesterStart: _start, semesterEnd: _end, today: DateTime(2026, 9, 1));
    expect(a.expectedWeeks, 16);
    expect(a.attendedWeeks, 16);
    expect(a.meetsRequirement, isTrue);
  });

  Widget app(Widget child) => ProviderScope(
        overrides: [
          fypmsSemestersProvider.overrideWith((ref) async => [_semester()]),
          myFypRecordsProvider.overrideWith((ref) async => [_record()]),
          fypProgressLogsProvider.overrideWith((ref, recordId) async => const []),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('banner warns below 80 %', (tester) async {
    await tester.pumpWidget(app(ConsultationAttendanceBanner(
      record: _record(),
      logs: [_log(DateTime(2026, 3, 3))],
      today: DateTime(2026, 3, 27),
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 of 4 weeks (25 %)'), findsOneWidget);
    expect(find.textContaining('below the 80 % attendance requirement'), findsOneWidget);
  });

  testWidgets('F5 dialog needs the completed activity and shows the semester week', (tester) async {
    await tester.pumpWidget(app(Builder(
      builder: (context) => TextButton(
        onPressed: () => showDialog<void>(context: context, builder: (_) => ConsultationLogDialog(record: _record())),
        child: const Text('open'),
      ),
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Log Consultation (F5)'), findsOneWidget);
    expect(find.text('Date of meeting'), findsOneWidget);
    expect(find.textContaining('· Week '), findsOneWidget);
    final submit = find.widgetWithText(ElevatedButton, 'Submit');
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('completed-activity')), 'Finished the literature review');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
  });
}
