import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_presentation_session.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_rubric_template.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_rubrics_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/create_session_dialog.dart';

FypRubricTemplate _rubric(String form, int version, {bool active = true}) => FypRubricTemplate(
      id: '$form-$version',
      rubricCode: '${form}_R',
      rubricName: '$form rubric v$version',
      formCode: form,
      criteria: const [
        {'key': 'depth', 'label': 'Depth of knowledge', 'weight': 3, 'max': 10},
        {'key': 'progress', 'label': 'Progress', 'weight': 1, 'max': 10, 'supervisor_only': true},
      ],
      evaluatorShares: const {'supervisor': 15, 'examiner': 15},
      version: version,
      isActive: active,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

Future<void> _open(WidgetTester tester, Widget dialog) async {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(context: context, builder: (_) => dialog),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  test('U4 the list shows the latest active version per form, in form order', () {
    final list = CoordinatorRubricsPage.activeRubrics([
      _rubric('F10', 1, active: false),
      _rubric('F10', 2),
      _rubric('F9', 1),
    ]);
    expect(list.map((r) => '${r.formCode}v${r.version}'), ['F9v1', 'F10v2']);
    expect(criterionKey('Literature review & sources'), 'literature_review_sources');
    expect(criterionKey('3D model'), 'c_3d_model');
  });

  testWidgets('U4 editor loads criteria and shares, and refuses a zero weight', (tester) async {
    await _open(tester, RubricEditorDialog(rubric: _rubric('F10', 2)));
    expect(find.text('Depth of knowledge'), findsOneWidget);
    expect(find.byKey(const Key('share--supervisor')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('criterion-weight-0')), '0');
    await tester.tap(find.text('Save new version'));
    await tester.pumpAndSettle();
    expect(find.text('Weights must be between 0 and 20.'), findsOneWidget);

    await tester.tap(find.text('Add criterion'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('criterion-label-2')), findsOneWidget);
  });

  testWidgets('U5 editing a session prefills it and saves instead of creating', (tester) async {
    await _open(
      tester,
      CreateSessionDialog(
        offerings: const [],
        session: FypPresentationSession(
          id: 's1',
          offeringId: 'o1',
          sessionCode: 'P2',
          sessionTitle: 'Progress presentation 2',
          eventDate: DateTime(2026, 10, 5),
          startAt: DateTime(2026, 10, 5, 9),
          endAt: DateTime(2026, 10, 5, 13),
          venue: 'Lab 3',
          sessionType: 'defence',
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      ),
    );
    expect(find.text('Edit Session'), findsOneWidget);
    expect(find.text('Progress presentation 2'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
  });
}
