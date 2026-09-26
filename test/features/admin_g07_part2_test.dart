import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/award_category.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/domain/models/project_lecturer_assignment.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/admin_assignments/domain/assignment_matching.dart';
import 'package:fyp_expo_hub/features/admin_assignments/presentation/pages/admin_assignments_page.dart';
import 'package:fyp_expo_hub/features/admin_audit/presentation/pages/admin_audit_page.dart';
import 'package:fyp_expo_hub/features/admin_awards/presentation/widgets/award_categories_section.dart';

Project _project(String id, {String sv = 'Dr. Aminah binti Ali', String? ex = 'PM Ts. Rahman Hassan'}) => Project(
      id: id,
      eventId: 'fskm-fyp-2026',
      slug: 'p-$id',
      title: 'Project $id',
      matricId: '2026123456',
      programmeCode: 'CS266',
      programmeName: 'Computer Science',
      shortDescription: '',
      category: 'Software Engineering',
      technologyTags: const [],
      boothNumber: 'B$id',
      coverImageUrl: '',
      teamDisplayNames: const ['Ali'],
      supervisorDisplayName: sv,
      examinerDisplayName: ex,
      featured: false,
      calonIndustri: false,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

const _aminah = LecturerRef(id: 'lec-a', name: 'AMINAH BINTI ALI', email: 'aminah@uitm.edu.my');
const _rahman = LecturerRef(id: 'lec-r', name: 'Rahman Hassan');

ProjectLecturerAssignment _assignment(String project, String lecturer, String role, {String status = 'active'}) =>
    ProjectLecturerAssignment(
      id: 'asg-$project-$role',
      eventId: 'ev',
      projectId: project,
      lecturerDisplayName: lecturer == 'lec-a' ? 'AMINAH BINTI ALI' : 'Rahman Hassan',
      lecturerId: lecturer,
      role: role,
      status: status,
      assignedAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

class _Projects extends ProjectsNotifier {
  _Projects(this.list);
  final List<Project> list;
  @override
  List<Project> build() => list;
}

class _Db extends SupabaseDatabaseService {
  _Db()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final upserts = <Map<String, dynamic>>[];
  final removed = <String>[];
  final categories = <Map<String, dynamic>>[];

  @override
  Future<String> resolveEventId(String slugOrId) async => 'event-uuid';

  @override
  Future<void> upsertAssignmentsByKey(List<Map<String, dynamic>> rows) async => upserts.addAll(rows);

  @override
  Future<void> removeAssignment(String id) async => removed.add(id);

  @override
  Future<void> upsertAwardCategory(Map<String, dynamic> row) async => categories.add(row);

  @override
  Future<List<Map<String, dynamic>>> getAwardCategoriesOnce() async => const [];
}

Future<void> _pump(WidgetTester tester, Widget home, List<Override> overrides) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: home)));
  await tester.pumpAndSettle();
}

void main() {
  group('assignment matching', () {
    test('names meet despite titles, case, spacing and punctuation', () {
      expect(normalizePersonName('Dr. Aminah  binti Ali'), 'AMINAH BINTI ALI');
      expect(normalizePersonName('PM Ts. Rahman Hassan'), 'RAHMAN HASSAN');
      expect(normalizePersonName("Prof. Madya Dr. Siti (FSKM)"), 'SITI FSKM');
    });

    test('proposes unmatched pairs, skips existing, counts unknown and ambiguous names', () {
      final r = proposeAssignments(
        projects: [_project('1'), _project('2', ex: 'Unknown Person'), _project('3', sv: 'Siti')],
        lecturers: [_aminah, _rahman, const LecturerRef(id: 's1', name: 'Siti'), const LecturerRef(id: 's2', name: 'SITI')],
        existing: [_assignment('1', 'lec-a', 'supervisor')],
      );
      expect([for (final p in r.proposals) '${p.project.id}:${p.lecturer.id}:${p.role}'],
          ['1:lec-r:examiner', '2:lec-a:supervisor', '3:lec-r:examiner']);
      expect(r.unmatchedNames, {'UNKNOWN PERSON'});
      expect(r.ambiguousNames, {'SITI'});
    });

    test('a removed assignment is proposed again; inactive lecturers are not candidates', () {
      final r = proposeAssignments(
        projects: [_project('1', ex: null)],
        lecturers: [_aminah],
        existing: [_assignment('1', 'lec-a', 'supervisor', status: 'removed')],
      );
      expect(r.proposals.single.role, 'supervisor');
      expect(LecturerRef.fromRow({'id': 'x', 'display_name': 'X', 'is_active': false}), isNull);
    });
  });

  testWidgets('G-07 admin creates matched assignments and removes one', (tester) async {
    final db = _Db();
    await _pump(tester, const AdminAssignmentsPage(), [
      supabaseDbServiceProvider.overrideWithValue(db),
      currentAuthUserProvider.overrideWith((ref) => null),
      projectsProvider.overrideWith(() => _Projects([_project('1'), _project('2')])),
      allLecturersProvider.overrideWith((ref) async => [
            {'id': 'lec-a', 'display_name': 'AMINAH BINTI ALI', 'email': 'aminah@uitm.edu.my', 'is_active': true},
            {'id': 'lec-r', 'display_name': 'Rahman Hassan', 'is_active': true},
          ]),
      allAssignmentsProvider.overrideWith((ref) async => [_assignment('1', 'lec-a', 'supervisor')]),
    ]);

    expect(find.textContaining('3 new assignments match'), findsOneWidget);
    await tester.tap(find.byKey(const Key('apply-matches')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();
    expect(db.upserts, hasLength(3));
    expect(db.upserts.first, containsPair('event_id', 'event-uuid'));
    expect(db.upserts.map((r) => r['status']).toSet(), {'active'});
    expect(db.upserts.firstWhere((r) => r['lecturer_id'] == 'lec-a')['lecturer_email'], 'aminah@uitm.edu.my');
    expect(db.upserts.firstWhere((r) => r['lecturer_id'] == 'lec-r').containsKey('lecturer_email'), isFalse);

    await tester.tap(find.byTooltip('Remove assignment'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(db.removed, ['asg-1-supervisor']);
  });

  testWidgets('G-07 audit log lists, searches and filters entries', (tester) async {
    await _pump(tester, const AdminAuditPage(), [
      allLecturersProvider.overrideWith((ref) async => [
            {'id': 'lec-a', 'display_name': 'AMINAH BINTI ALI'},
          ]),
      adminAuditLogsProvider.overrideWith((ref) async => [
            AuditEntry.fromRow({
              'created_at': '2026-09-22T02:05:00Z',
              'action': 'visit_marked',
              'target_type': 'student_project_visits',
              'actor_uid': 'lec-a',
              'actor_role': 'lecturer',
              'metadata_safe': {'project_id': 'p-1'},
            }),
            AuditEntry.fromRow({
              'created_at': '2026-09-21T01:00:00Z',
              'action': 'import_published',
              'target_type': 'imports',
              'actor_role': 'admin',
            }),
          ]),
    ]);
    expect(find.text('Visit marked'), findsOneWidget);
    expect(find.textContaining('22 Sep 2026 10:05 · AMINAH BINTI ALI'), findsOneWidget, reason: 'Malaysia time + name');
    expect(find.text('Import published'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('audit-search')), 'p-1');
    await tester.pumpAndSettle();
    expect(find.text('Import published'), findsNothing);
    expect(find.text('Visit marked'), findsOneWidget);
  });

  testWidgets('G-07 admin adds an award category for the event', (tester) async {
    final db = _Db();
    await _pump(tester, const Scaffold(body: SingleChildScrollView(child: AwardCategoriesSection())), [
      supabaseDbServiceProvider.overrideWithValue(db),
    ]);
    expect(find.textContaining('No categories yet'), findsOneWidget);
    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('category-title')), 'Gold Innovation Award');
    await tester.enterText(find.byKey(const Key('category-order')), '1');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(db.categories.single, allOf(
      containsPair('title', 'Gold Innovation Award'),
      containsPair('event_id', 'event-uuid'),
      containsPair('sort_order', 1),
      containsPair('status', 'active'),
    ));
    expect(db.categories.single.containsKey('id'), isFalse, reason: 'new rows get a database id');
  });

  test('categories round-trip their row', () {
    final c = AwardCategoryItem.fromRow({'id': 'c1', 'title': 'Best UX', 'sort_order': 2, 'status': 'hidden'});
    expect(c.isActive, isFalse);
    expect(c.toRow(eventId: 'e')['id'], 'c1');
  });
}
