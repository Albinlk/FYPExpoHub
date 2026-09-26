import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_course_marks.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_rubric_template.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_mark_allocation_page.dart';

FypRubricTemplate _rubric(String code, Map<String, dynamic> shares) => FypRubricTemplate(
      id: 'rub-$code',
      rubricCode: code,
      rubricName: '$code rubric',
      formCode: code,
      criteria: const [],
      evaluatorShares: shares,
      version: 1,
      isActive: true,
      createdAt: DateTime(2026, 9, 26),
      updatedAt: DateTime(2026, 9, 26),
    );

final _rubrics = [
  _rubric('F2', {'lecturer': 10}),
  _rubric('F3', {'lecturer': 10}),
  _rubric('F4', {'lecturer': 10}),
  _rubric('F7', {'lecturer': 10, 'supervisor': 10, 'examiner': 5}),
  _rubric('F8', {'supervisor': 30, 'examiner': 15}),
  _rubric('F9', {'lecturer': 10}),
  _rubric('F10', {'supervisor': 15, 'examiner': 15}),
  _rubric('F11', {
    'CLO1': {'supervisor': 25, 'examiner': 20},
    'CLO4': {'supervisor': 5, 'examiner': 5},
  }),
  _rubric('F13', {'lecturer': 5}),
];

void main() {
  test('CourseMarks parses the compute_fyp_course_marks payload', () {
    final m = CourseMarks.fromJson({
      'course_code': 'CSP650',
      'total': 27.5,
      'allocated': 100,
      'grade': 'E',
      'complete': false,
      'components': [
        {'form_code': 'F11', 'clo': 'CLO1', 'role': 'supervisor', 'share': 25, 'percent': 100, 'evaluations': 1, 'contribution': 25},
      ],
      'missing': [
        {'form_code': 'F9', 'role': 'lecturer', 'share': 10, 'reason': 'no_submission'},
      ],
    });
    expect(m.complete, isFalse);
    expect(m.components.single.label, 'F11 CLO1 · Supervisor');
    expect(m.missing.single.label, 'F9 · Course lecturer');
    expect(m.missing.single.reason, 'no_submission');
  });

  test('shareTotal handles flat and per-CLO shares; both courses total 100', () {
    expect(shareTotal({'lecturer': 10, 'supervisor': 10, 'examiner': 5}), 25);
    expect(shareTotal(_rubrics.firstWhere((r) => r.formCode == 'F11').evaluatorShares), 55);
    num course(List<String> codes) =>
        codes.fold(0, (sum, c) => sum + shareTotal(_rubrics.firstWhere((r) => r.formCode == c).evaluatorShares));
    expect(course(['F2', 'F3', 'F4', 'F7', 'F8']), 100);
    expect(course(['F9', 'F10', 'F11', 'F13']), 100);
  });

  Future<List<num>> pumpAllocation(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final saved = <num>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        fypRubricTemplatesProvider.overrideWith((ref) async => _rubrics),
        setCsp600FormulationSharesProvider.overrideWithValue((f2, f3, f4) async => saved.addAll([f2, f3, f4])),
      ],
      child: const MaterialApp(home: CoordinatorMarkAllocationPage()),
    ));
    await tester.pumpAndSettle();
    return saved;
  }

  testWidgets('allocation page shows both courses at 100 %', (tester) async {
    await pumpAllocation(tester);
    expect(tester.widget<Text>(find.byKey(const Key('total-CSP600'))).data, '100 %');
    expect(tester.widget<Text>(find.byKey(const Key('total-CSP650'))).data, '100 %');
  });

  testWidgets('F2-F4 must add up to 30 before saving', (tester) async {
    final saved = await pumpAllocation(tester);
    final save = find.widgetWithText(FilledButton, 'Save');

    await tester.enterText(find.byKey(const Key('share-F4')), '11');
    await tester.pump();
    expect(find.text('F2 + F3 + F4 = 31 / 30'), findsOneWidget);
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('share-F2')), '5');
    await tester.enterText(find.byKey(const Key('share-F3')), '14');
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(saved, [5, 14, 11]);
    expect(find.text('Mark allocation saved.'), findsOneWidget);
  });
}
