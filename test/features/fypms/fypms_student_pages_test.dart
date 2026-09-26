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

  group('StudentDeliverablesPage', () {
    testWidgets('shows readiness card and checklist when empty',
        (tester) async {
      await pumpWithSize(tester, _deliverablesApp());
      await tester.pumpAndSettle();

      expect(find.text('Exhibition Readiness'), findsOneWidget);
      expect(find.text('0/5 required deliverables submitted'), findsOneWidget);
      expect(find.text('Deliverables Checklist'), findsOneWidget);
      expect(find.text('Submit Deliverable'), findsOneWidget);
      expect(find.text('Lean Canvas (F13)'), findsOneWidget);
      expect(find.text('Project Demo / Artifact'), findsOneWidget);
      expect(find.textContaining('No deliverables submitted yet'), findsOneWidget);
    });

    testWidgets('counts submitted deliverables with file URLs toward readiness',
        (tester) async {
      await pumpWithSize(tester, _deliverablesApp(
        deliverables: [
          FypDeliverable(
            id: 'del-1',
            fypRecordId: 'rec-1',
            deliverableType: 'proposal',
            title: 'F1 Supervision Request',
            fileUrl: 'https://storage.example.com/del-1.pdf',
            version: 1,
            isRequired: true,
            createdAt: DateTime(2026, 8, 1),
            updatedAt: DateTime(2026, 8, 1),
          ),
          FypDeliverable(
            id: 'del-2',
            fypRecordId: 'rec-1',
            deliverableType: 'project_demo',
            title: 'Project Demo / Artifact',
            fileUrl: 'https://storage.example.com/demo.zip',
            version: 1,
            isRequired: true,
            createdAt: DateTime(2026, 8, 1),
            updatedAt: DateTime(2026, 8, 1),
          ),
          FypDeliverable(
            id: 'del-3',
            fypRecordId: 'rec-1',
            deliverableType: 'poster',
            title: 'Exhibition Poster',
            version: 1,
            isRequired: false,
            createdAt: DateTime(2026, 8, 1),
            updatedAt: DateTime(2026, 8, 1),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('2/5 required deliverables submitted'), findsOneWidget);
      expect(find.textContaining('Submitted (v1)'), findsNWidgets(3));
    });

    testWidgets('opens readiness preview dialog', (tester) async {
      await pumpWithSize(tester, _deliverablesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Preview Readiness'));
      await tester.pumpAndSettle();

      expect(find.text('Exhibition Readiness Preview'), findsOneWidget);
      expect(find.text('0/5 required deliverables ready'), findsOneWidget);
      expect(find.textContaining('NOT yet ready'), findsOneWidget);
    });

    testWidgets('opens submit dialog with checklist types', (tester) async {
      await pumpWithSize(tester, _deliverablesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Deliverable'));
      await tester.pumpAndSettle();

      expect(find.text('Submit Deliverable'), findsWidgets);
      expect(find.text('Deliverable Type'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
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
