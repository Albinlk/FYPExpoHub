import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_supervisor_change.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/nomination_documents.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/supervisor_change_widgets.dart';

/// P13: the nominating lecturer attaches the nominee's CV and the "not a
/// relative or close friend" declaration (FSKM handbook App. N); the PU
/// approves only once both are there.
PendingNomination _nom({bool withDocs = false}) => PendingNomination.fromJson({
      'assignment_id': 'a-1',
      'fyp_record_id': 'rec-1',
      'academic_role': 'supervisor',
      'lecturer_name': 'Dr. Aminah',
      'student_name': 'Ali',
      'matric_id': '2023123456',
      'programme_code': 'CS266',
      'course_code': 'CSP600',
      'project_title': 'Smart Campus',
      if (withDocs) 'cv_path': 'a-1/cv-1.pdf',
      if (withDocs) 'not_related_declared_at': '2026-10-10T08:00:00Z',
    });

Future<void> _pumpPu(WidgetTester tester, PendingNomination n) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      pendingNominationsProvider.overrideWith((ref) async => [n]),
      approvedNominationsProvider.overrideWith((ref) async => []),
    ],
    child: const MaterialApp(home: PuNominationsPage()),
  ));
  await tester.pumpAndSettle();
}

FilledButton _approve(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Approve'));

void main() {
  test('parses the CV and declaration', () {
    expect(_nom().hasDocuments, isFalse);
    final n = _nom(withDocs: true);
    expect(n.hasDocuments, isTrue);
    expect(n.cvPath, 'a-1/cv-1.pdf');
  });

  testWidgets('PU cannot approve until the CV and declaration are attached', (tester) async {
    await _pumpPu(tester, _nom());
    expect(find.textContaining('Waiting for the CV and declaration'), findsOneWidget);
    expect(_approve(tester).onPressed, isNull);
  });

  testWidgets('PU sees the CV and can approve once attached', (tester) async {
    await _pumpPu(tester, _nom(withDocs: true));
    expect(find.text('View CV'), findsOneWidget);
    expect(find.textContaining('Declared not a relative or close friend'), findsOneWidget);
    expect(_approve(tester).onPressed, isNotNull);
  });

  testWidgets('nominator page lists nominations with Attach CV', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [myPendingNominationsProvider.overrideWith((ref) async => [_nom()])],
      child: const MaterialApp(home: NominatorNominationsPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Supervisor: Dr. Aminah'), findsOneWidget);
    await tester.tap(find.text('Attach CV'));
    await tester.pumpAndSettle();
    expect(find.text('Attach CV and Declaration'), findsOneWidget);
    // Ticking the declaration alone is not enough: a CV is required too.
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    final send = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Send to PU'));
    expect(send.onPressed, isNull);
  });

  test('the server needs the CV and declaration before approval', () {
    final sql = File('supabase/migrations/20261010000005_nomination_cv.sql').readAsStringSync();
    expect(sql, contains("'fyp-nomination-cvs', 'fyp-nomination-cvs', false"));
    expect(sql, contains("p_decision = 'approved' and (v_a.cv_path is null or v_a.not_related_declared_at is null)"));
    expect(sql, contains('fyp_can_nominate_for_assignment(public.fyp_nomination_cv_assignment(name))'));
    expect(sql, contains('fyp_can_view_nomination_cv(public.fyp_nomination_cv_assignment(name))'));
  });
}
