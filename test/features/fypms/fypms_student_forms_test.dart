import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_form_definitions.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/student_form_dialog.dart';

void main() {
  test('U1 every submittable form code has a definition or its own page', () {
    for (final code in fypmsFormCodesFor(applicationsOpen: true, qualified: true)) {
      expect(kStudentFormDefinitions.containsKey(code) || kFormsWithOwnPage.containsKey(code), isTrue, reason: code);
    }
  });

  test('U1 field checks and payload', () {
    const url = FormFieldDef('u', 'Slides link', kind: FormFieldKind.url);
    const n = FormFieldDef('n', 'Count', kind: FormFieldKind.number);
    const opt = FormFieldDef('o', 'Notes', required: false);
    expect(formFieldProblem(url, ''), contains('required'));
    expect(formFieldProblem(url, 'javascript:alert(1)'), contains('http(s)'));
    expect(formFieldProblem(url, 'https://drive.google.com/x'), isNull);
    expect(formFieldProblem(n, '-3'), contains('whole number'));
    expect(formFieldProblem(opt, ''), isNull);

    final def = kStudentFormDefinitions['F3']!;
    final payload = formPayload(def, {'title': ' Smart Campus ', 'reference_count': '18', 'scope': ''});
    expect(payload, {'title': 'Smart Campus', 'reference_count': 18});
    expect(formAnswers('F3', payload), [('Project title', 'Smart Campus'), ('Number of references', '18')]);
    expect(formAnswers('F3', {'legacy_note': 'old'}), [('legacy note', 'old')], reason: 'older free-form payloads still read');
  });

  testWidgets('U1 the dialog shows the form questions and blocks invalid answers', (tester) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const StudentFormDialog(fypRecordId: 'rec-1', formCodes: ['F2', 'F6a', 'F7', 'F13']),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Problem statement'), findsOneWidget);
    expect(find.textContaining('F6a is submitted on the Reports page.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('form-code')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('F7 — Proposal Presentation').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field-title')), 'Smart Campus');
    await tester.enterText(find.byKey(const Key('field-slides_url')), 'ftp://files/slides');
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Slides link must be an http(s) link.'), findsOneWidget);
    expect(find.byType(StudentFormDialog), findsOneWidget, reason: 'nothing submitted');
  });
}
