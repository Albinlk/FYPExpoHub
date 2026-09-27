import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_reports_page.dart';

final _json = <String, dynamic>{
  'records': 3,
  'status_counts': {'project_ongoing': 2, 'withdrawn': 1},
  'course_counts': {'CSP600': 2, 'CSP650': 1},
  'finalized': {
    'CSP600': {'count': 2, 'average_total': 71.25},
  },
  'grades': [
    {'course_code': 'CSP600', 'grade': 'B+', 'count': 1},
    {'course_code': 'CSP600', 'grade': 'A-', 'count': 1},
  ],
  'workload': [
    {'lecturer_id': 'l1', 'name': 'Dr. "Aminah"', 'supervisor': 2, 'co_supervisor': 1, 'examiner': 0, 'total': 3},
  ],
  'without_supervisor': 1,
  'overdue_milestones': 0,
};

void main() {
  test('F6 report parses and exports the workload CSV', () {
    final r = CohortReport.fromJson(_json);
    expect(r.grades['CSP600'], {'B+': 1, 'A-': 1});
    expect(r.finalized['CSP600']!.average, 71.25);
    expect(r.workload.single.total, 3);
    expect(r.workloadCsv().split('\n').last, '"Dr. ""Aminah""",2,1,0,3');
  });

  testWidgets('F6 page shows totals, statuses in words and grades in UiTM order', (tester) async {
    tester.view.physicalSize = const Size(1100, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [fypCohortReportProvider.overrideWith((ref) async => CohortReport.fromJson(_json))],
      child: const MaterialApp(home: CoordinatorReportsPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Cohort Reports'), findsOneWidget);
    expect(find.text('project ongoing'), findsOneWidget);
    expect(find.text('CSP600 — 2 finalized, average 71.3%'), findsOneWidget);
    final a = tester.getTopLeft(find.text('A-')).dy;
    final b = tester.getTopLeft(find.text('B+')).dy;
    expect(a, lessThan(b));
    expect(find.text('Dr. "Aminah"'), findsOneWidget);
  });
}
