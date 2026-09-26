import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/award.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/admin_booths/presentation/pages/admin_booths_page.dart';
import 'package:fyp_expo_hub/features/lecturer_visits/presentation/widgets/undo_visit_dialog.dart';
import 'package:fyp_expo_hub/features/public_awards/presentation/pages/awards_page.dart';

const _event = '22222222-2222-4222-8222-222222222222';
const _booth = '33333333-3333-4333-8333-333333333333';
const _p1 = '44444444-4444-4444-8444-444444444441';
const _p2 = '44444444-4444-4444-8444-444444444442';

Map<String, dynamic> _projectRow(String id, String title, {String? boothId}) => {
      'id': id,
      'event_id': _event,
      'slug': 'p-$id',
      'title': title,
      'programme_code': 'CS251',
      'programme_name': 'Netcentric',
      'short_description': 'd',
      'category': 'Computer Science',
      'tech_tags': ['IoT'],
      'student_team': ['ALI'],
      'supervisor_display_name': 'DR. A',
      'booth_id': boothId,
      'booth_number': boothId == null ? null : 'DS7-03',
      'booth_zone': boothId == null ? null : 'DS7',
      'featured': false,
      'publication_status': 'published',
      'created_at': '2026-07-01T00:00:00Z',
      'updated_at': '2026-07-01T00:00:00Z',
    };

/// Booth DS7-03 on Day 2 with a floor plan, holding project 1.
class _Db extends SupabaseDatabaseService {
  _Db()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final boothWrites = <Map<String, dynamic>>[];
  final projectWrites = <Map<String, dynamic>>[];
  final log = <String>[];

  @override
  Future<List<Map<String, dynamic>>> getBoothsOnce({bool publishedOnly = false}) async => [
        {
          'id': _booth,
          'event_id': _event,
          'booth_number': 'DS7-03',
          'zone': 'DS7',
          'location_note': 'Near the door',
          'presentation_day': 'Day 2 - 07 Aug 2026',
          'floor_plan_url': 'https://example.com/plan.png',
          'linked_project_id': _p1,
          'publication_status': 'published',
          'created_at': '2026-07-01T00:00:00Z',
          'updated_at': '2026-07-01T00:00:00Z',
        },
      ];

  @override
  Future<List<Map<String, dynamic>>> getProjectsOnce({bool publishedOnly = false, int? limit, int? offset}) async =>
      [_projectRow(_p1, 'Smart Farm', boothId: _booth), _projectRow(_p2, 'Hate Speech Detector')];

  @override
  Future<void> setBooth(String id, Map<String, dynamic> data) async {
    boothWrites.add(data);
    log.add('booth');
  }

  @override
  Future<void> setProject(String id, Map<String, dynamic> data) async {
    projectWrites.add(data);
    log.add('project ${data['title']}');
  }

  @override
  Future<void> deleteBooth(String id) async => log.add('delete booth');
}

Future<void> _pumpBooths(WidgetTester tester, _Db db) async {
  tester.view.physicalSize = const Size(1400, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      supabaseDbServiceProvider.overrideWithValue(db),
      currentAuthUserProvider.overrideWith((ref) => null),
    ],
    child: const MaterialApp(home: AdminBoothsPage()),
  ));
  await tester.pumpAndSettle();
}

class _AwardsStub extends AwardsNotifier {
  _AwardsStub(this._items);
  final List<PublishedAwardWinner> _items;
  @override
  List<PublishedAwardWinner> build() => _items;
}

class _ProjectsStub extends ProjectsNotifier {
  _ProjectsStub(this._items);
  final List<Project> _items;
  @override
  List<Project> build() => _items;
}

void main() {
  group('G-05 booths', () {
    testWidgets('editing keeps presentation day and floor plan', (tester) async {
      final db = _Db();
      await _pumpBooths(tester, db);

      await tester.tap(find.byTooltip('Edit booth'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Near the door'), 'Beside the stage');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      final row = db.boothWrites.single;
      expect(row['location_note'], 'Beside the stage');
      expect(row['presentation_day'], 'Day 2 - 07 Aug 2026');
      expect(row['floor_plan_url'], 'https://example.com/plan.png');
    });

    testWidgets('moving the booth to another project releases the old one', (tester) async {
      final db = _Db();
      await _pumpBooths(tester, db);

      await tester.tap(find.byTooltip('Edit booth'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Hate Speech').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      final released = db.projectWrites.firstWhere((r) => r['title'] == 'Smart Farm');
      expect(released['booth_id'], isNull);
      expect(released['booth_number'], isNull);
      final linked = db.projectWrites.firstWhere((r) => r['title'] == 'Hate Speech Detector');
      expect(linked['booth_id'], _booth);
    });

    testWidgets('deleting a booth clears it from its project first', (tester) async {
      final db = _Db();
      await _pumpBooths(tester, db);

      await tester.tap(find.byTooltip('Delete booth'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(db.log, ['project Smart Farm', 'delete booth']);
      expect(db.projectWrites.single['booth_id'], isNull);
    });
  });

  testWidgets('G-18 awards: stored award name, linked project, sponsor', (tester) async {
    final project = Project(
      id: _p1,
      eventId: _event,
      slug: 'smart-farm',
      title: 'Smart Farm',
      programmeCode: 'CS251',
      programmeName: 'Netcentric Computing',
      shortDescription: 'd',
      category: 'Computer Science',
      technologyTags: const [],
      coverImageUrl: '',
      teamDisplayNames: const ['ALI'],
      supervisorDisplayName: 'DR. A',
      featured: false,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );
    final award = PublishedAwardWinner(
      id: 'aw-1',
      eventId: _event,
      awardCategoryId: '',
      projectId: _p1,
      projectTitle: 'Best Poster Award',
      publicationStatus: 'published',
      sponsor: 'TM Research',
      createdAt: DateTime(2026, 8, 7),
      updatedAt: DateTime(2026, 8, 7),
    );
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const AwardsPage())]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        publicAwardsProvider.overrideWith(() => _AwardsStub([award])),
        publicProjectsProvider.overrideWith(() => _ProjectsStub([project])),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Best Poster Award'), findsOneWidget);
    expect(find.text('Final Year Project Award'), findsNothing);
    expect(find.text('Smart Farm'), findsOneWidget);
    expect(find.text('Sponsor: TM Research'), findsOneWidget);
    expect(find.text('View project'), findsOneWidget);
  });

  testWidgets('G-28 cancelling a visit needs a reason', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showUndoVisitDialog(context),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final cancel = find.widgetWithText(ElevatedButton, 'Cancel Visit');
    expect(find.text('Cancellation reason *'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(cancel).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Student not at booth');
    await tester.pump();
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(result, 'Student not at booth');
  });

  test('G-29 inactive lecturers are not signed-in lecturers', () {
    final container = ProviderContainer(overrides: [
      allLecturersProvider.overrideWith((ref) async => [
            {'id': 'l1', 'email': 'active@uitm.edu.my', 'display_name': 'DR. ACTIVE', 'is_active': true},
            {'id': 'l2', 'email': 'gone@uitm.edu.my', 'display_name': 'DR. GONE', 'is_active': false},
          ]),
    ]);
    addTearDown(container.dispose);
    return container.read(allLecturersProvider.future).then((_) {
      final config = container.read(lecturerConfigProvider);
      expect(config.keys, ['active@uitm.edu.my']);
    });
  });
}
