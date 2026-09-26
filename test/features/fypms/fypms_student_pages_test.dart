import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_deliverable.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_lean_canvas.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_deliverables_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_lean_canvas_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/student_supervision_page.dart';

FypRecord _record() => FypRecord(
      id: 'rec-1',
      academicSemesterId: 'sem-1',
      studentId: 'stu-1',
      currentCourseCode: 'CSP600',
      programmeCode: 'CS266',
      projectTitle: 'AI Health Assistant',
      workflowStatus: 'project_registered',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

Widget _leanCanvasApp({FypLeanCanvas? canvas}) {
  return ProviderScope(
    overrides: [
      myFypRecordsProvider.overrideWith((ref) async => [_record()]),
      fypLeanCanvasProvider.overrideWith(
        (ref, recordId) async => recordId == 'rec-1' ? canvas : null,
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      home: const StudentLeanCanvasPage(),
    ),
  );
}

Widget _deliverablesApp({List<FypDeliverable> deliverables = const []}) {
  return ProviderScope(
    overrides: [
      myFypRecordsProvider.overrideWith((ref) async => [_record()]),
      fypDeliverablesProvider.overrideWith(
        (ref, recordId) async => recordId == 'rec-1' ? deliverables : const [],
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      home: const StudentDeliverablesPage(),
    ),
  );
}

Widget _supervisionApp({FypRecord? record}) {
  return ProviderScope(
    overrides: [
      myFypRecordsProvider.overrideWith((ref) async => [record ?? _record()]),
      fypSupervisionRequestsProvider.overrideWith((ref, recordId) async => const []),
      supervisorsDirectoryProvider.overrideWith((ref) async => const [
            {'id': 'sv-1', 'display_name': 'DR. AMINAH', 'role_code': 'supervisor'},
            {'id': 'sv-2', 'display_name': 'DR. FARID', 'role_code': 'supervisor'},
            {'id': 'co-1', 'display_name': 'EN. BADRUL', 'role_code': 'co_supervisor'},
            {'id': 'ex-1', 'display_name': 'DR. EXAMINER', 'role_code': 'examiner'},
          ]),
    ],
    child: MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      home: const StudentSupervisionPage(),
    ),
  );
}

void main() {
  Future<void> pumpWithSize(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
  }

  group('StudentLeanCanvasPage', () {
    testWidgets('renders all nine lean canvas blocks when no canvas exists',
        (tester) async {
      await pumpWithSize(tester, _leanCanvasApp());
      await tester.pumpAndSettle();

      expect(find.text('Draft your Lean Canvas (F13)'), findsOneWidget);
      expect(find.text('Problem'), findsOneWidget);
      expect(find.text('Customer Segments'), findsOneWidget);
      expect(find.text('Unique Value Proposition'), findsOneWidget);
      expect(find.text('Solution'), findsOneWidget);
      expect(find.text('Channels'), findsOneWidget);
      expect(find.text('Revenue Streams'), findsOneWidget);
      expect(find.text('Cost Structure'), findsOneWidget);
      expect(find.text('Key Metrics'), findsOneWidget);
      expect(find.text('Unfair Advantage'), findsOneWidget);
      expect(find.text('Save Canvas'), findsOneWidget);
    });

    testWidgets('shows revision header when a previous version exists',
        (tester) async {
      await pumpWithSize(tester, _leanCanvasApp(
        canvas: FypLeanCanvas(
          id: 'lc-1',
          fypRecordId: 'rec-1',
          canvasVersion: 2,
          blocks: const {'problem': 'Existing text'},
          isLatest: true,
          createdAt: DateTime(2026, 8, 2),
          updatedAt: DateTime(2026, 8, 3),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Revision 3 (saving creates a new version)'), findsOneWidget);
      expect(find.text('Existing text'), findsOneWidget);
    });
  });

  group('StudentDeliverablesPage (textbook CSP650 list)', () {
    FypDeliverable del(String type, {String? url, int version = 1}) => FypDeliverable(
          id: 'del-$type',
          fypRecordId: 'rec-1',
          deliverableType: type,
          title: type,
          fileUrl: url,
          version: version,
          isRequired: false,
          createdAt: DateTime(2026, 8, 1),
          updatedAt: DateTime(2026, 8, 1),
        );

    testWidgets('empty: 0/4 required, eight checklist items', (tester) async {
      await pumpWithSize(tester, _deliverablesApp());
      await tester.pumpAndSettle();

      expect(find.text('Exhibition Readiness'), findsOneWidget);
      expect(find.text('0/4 required deliverables submitted'), findsOneWidget);
      for (final title in [
        'FYP report (PDF)',
        'FYP report (Word)',
        'Presentation slides',
        'Poster',
        'Raw data',
        'System with test data',
        'Instructions on system setup',
        '.apk / .exe file',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.textContaining('If relevant'), findsNWidgets(4));
      expect(find.text('Submit'), findsNWidgets(8));
    });

    testWidgets('counts required files; keeps older items visible', (tester) async {
      await pumpWithSize(tester, _deliverablesApp(deliverables: [
        del('final_report_pdf', url: '2026_1/rec-1/deliverable_final_report_pdf/2/report.pdf', version: 2),
        del('poster'), // no file yet
        del('demo', url: 'https://youtu.be/x'), // legacy type
      ]));
      await tester.pumpAndSettle();

      expect(find.text('1/4 required deliverables submitted'), findsOneWidget);
      expect(find.textContaining('Submitted (v2)'), findsOneWidget);
      expect(find.text('Replace'), findsOneWidget);
      expect(find.text('Other submitted items'), findsOneWidget);
      expect(find.text('demo · v1'), findsOneWidget);
    });

    testWidgets('required items need a file; "if relevant" items may be an https link', (tester) async {
      await pumpWithSize(tester, _deliverablesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit').first); // FYP report (PDF)
      await tester.pumpAndSettle();
      expect(find.text('Choose file (.pdf)'), findsOneWidget);
      expect(find.text('Link'), findsNothing);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit').at(5)); // System with test data
      await tester.pumpAndSettle();
      await tester.tap(find.text('Link'));
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(ElevatedButton, 'Submit');
      await tester.enterText(find.byKey(const Key('deliverable-link')), 'http://example.com/repo');
      await tester.pump();
      expect(find.text('Use an https:// address'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);
      await tester.enterText(find.byKey(const Key('deliverable-link')), 'https://github.com/team/system');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
    });
  });

  group('StudentSupervisionPage (F1)', () {
    testWidgets('F1 needs a supervisor and a title; co-supervisor excludes the supervisor', (tester) async {
      await pumpWithSize(tester, _supervisionApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Request'));
      await tester.pumpAndSettle();
      expect(find.text('F1 — Mutual Acceptance'), findsOneWidget);
      final submit = find.widgetWithText(ElevatedButton, 'Submit');
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNull, reason: 'no supervisor yet');

      await tester.tap(find.byKey(const Key('f1-supervisor')));
      await tester.pumpAndSettle();
      expect(find.text('DR. EXAMINER'), findsNothing, reason: 'only supervisors can be chosen');
      await tester.tap(find.text('DR. AMINAH').last);
      await tester.pumpAndSettle();
      // Title is pre-filled from the record, so the form is complete.
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);

      await tester.tap(find.byKey(const ValueKey('f1-co-supervisor-sv-1')));
      await tester.pumpAndSettle();
      expect(find.text('EN. BADRUL'), findsWidgets);
      expect(find.text('DR. FARID'), findsWidgets);
      expect(find.text('DR. AMINAH'), findsOneWidget, reason: 'the chosen supervisor is not offered as co-supervisor');
      await tester.tap(find.text('None').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('f1-title')), '  ');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNull, reason: 'title required');
    });

    testWidgets('no new request once a supervisor is assigned', (tester) async {
      await pumpWithSize(tester, _supervisionApp(record: _record().copyWith(mainSupervisorId: 'sv-1')));
      await tester.pumpAndSettle();

      expect(find.text('New Request'), findsNothing);
      expect(find.textContaining('contact the FYP coordinator'), findsOneWidget);
    });
  });
}
