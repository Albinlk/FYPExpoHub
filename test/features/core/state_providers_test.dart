import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/announcement.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/row_mappers.dart' show NotPersistableException;
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

Project _project({
  String id = 'p1',
  String title = 'Project One',
  bool featured = false,
  String status = 'published',
}) =>
    Project(
      id: id,
      eventId: 'fskm-fyp-2026',
      slug: 'project-one',
      title: title,
      programmeCode: 'CS266',
      programmeName: 'Computer Science',
      shortDescription: 'desc',
      category: 'AI',
      technologyTags: const [],
      coverImageUrl: '',
      teamDisplayNames: const ['Ali'],
      supervisorDisplayName: 'Dr. A',
      featured: featured,
      publicationStatus: status,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
      publishedAt: DateTime(2026, 7, 1),
    );

Announcement _announcement(String id,
        {bool pinned = false, String status = 'published'}) =>
    Announcement(
      id: id,
      eventId: 'fskm-fyp-2026',
      title: 'Announcement $id',
      body: 'Body $id',
      category: 'general',
      pinned: pinned,
      publicationStatus: status,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
      publishedAt: DateTime(2026, 7, 1),
    );

/// Mimics a real (already normalized) Supabase row: camelCase keys +
/// ISO-8601 date strings, as produced by normalizeKeys before fromJson.
Map<String, dynamic> _row(Project p) => <String, dynamic>{
      'id': p.id,
      'eventId': p.eventId,
      'slug': p.slug,
      'title': p.title,
      'programmeCode': p.programmeCode,
      'programmeName': p.programmeName,
      'shortDescription': p.shortDescription,
      'category': p.category,
      'technologyTags': p.technologyTags,
      'coverImageUrl': p.coverImageUrl,
      'teamDisplayNames': p.teamDisplayNames,
      'supervisorDisplayName': p.supervisorDisplayName,
      'featured': p.featured,
      'calonIndustri': p.calonIndustri,
      'publicationStatus': p.publicationStatus,
      'createdAt': p.createdAt.toIso8601String(),
      'updatedAt': p.updatedAt.toIso8601String(),
      'publishedAt': p.publishedAt?.toIso8601String(),
    }..removeWhere((_, v) => v == null);

/// Records calls and returns configured data. Optionally throws on reads to
/// simulate the Supabase-paused offline fallback path.
class _StubDatabaseService extends SupabaseDatabaseService {
  _StubDatabaseService()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final List<Map<String, dynamic>> projectsToReturn = [];
  final List<Map<String, dynamic>> announcementsToReturn = [];
  bool failReads = false;
  int lecturerQueryCount = 0;

  final List<(String, Map<String, dynamic>)> upserts = [];
  final List<(String, String)> deletes = [];
  bool failWrites = false;

  static const eventUuid = '00000000-0000-4000-8000-00000000e001';

  @override
  Future<String> resolveEventId(String slugOrId) async => eventUuid;

  @override
  Future<List<Map<String, dynamic>>> getLecturersOnce() async {
    lecturerQueryCount++;
    return [
      {
        'email': 'aminah@uitm.edu.my',
        'display_name': 'DR. AMINAH',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getProjectsOnce({
    bool publishedOnly = false,
    int? limit,
    int? offset,
    String eventId = 'fskm-fyp-2026',
  }) async {
    if (failReads) throw Exception('Supabase paused');
    if (!publishedOnly) return projectsToReturn;
    return projectsToReturn
        .where((r) => r['publicationStatus'] == 'published')
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAnnouncementsOnce({
    bool publishedOnly = false,
  }) async {
    if (failReads) throw Exception('Supabase paused');
    return announcementsToReturn;
  }

  @override
  Future<List<Map<String, dynamic>>> getVisitsOnce({int limit = 1000}) async {
    if (failReads) throw Exception('Supabase paused');
    return [];
  }

  void _maybeFail() {
    if (failWrites) throw Exception('permission denied');
  }

  @override
  Future<void> setProject(String id, Map<String, dynamic> data) async {
    _maybeFail();
    upserts.add(('projects', data));
  }

  @override
  Future<void> deleteProject(String id) async {
    _maybeFail();
    deletes.add(('projects', id));
  }

  @override
  Future<void> setAnnouncement(String id, Map<String, dynamic> data) async {
    _maybeFail();
    upserts.add(('announcements', data));
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    _maybeFail();
    deletes.add(('announcements', id));
  }
}

/// Database ids are uuids; the notifiers refuse to write anything else.
String _uuid(int n) => '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';

User _fakeLecturerUser() => User(
      id: 'user-1',
      email: 'aminah@uitm.edu.my',
      aud: 'authenticated',
      appMetadata: const {},
      userMetadata: const {},
      createdAt: DateTime(2026, 1, 1).toIso8601String(),
    );

void main() {
  // rootBundle (offline fallback asset) requires an initialized binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer container0(_StubDatabaseService db) => ProviderContainer(
        overrides: [
          supabaseDbServiceProvider.overrideWithValue(db),
          currentAuthUserProvider.overrideWith((ref) => null),
        ],
      );

  group('ProjectsNotifier offline fallback', () {
    test('seeds from the fallback JSON asset when Supabase read fails',
        () async {
      final db = _StubDatabaseService()..failReads = true;
      final container = container0(db);
      addTearDown(container.dispose);

      // Poll until the async fallback fills state (a 600KB JSON parse can
      // take longer than any fixed delay in debug mode).
      List<Project> projects = const [];
      for (var i = 0; i < 50 && projects.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        projects = container.read(publicProjectsProvider);
      }

      expect(projects, isNotEmpty);
      expect(projects.first.eventId, 'fskm-fyp-2026');
      // Placeholder rows keep an EMPTY cover url so ProjectCoverImage
      // renders its generated local cover (no third-party requests).
      expect(projects.first.coverImageUrl, isEmpty);
    });

    test('replaces fallback once Supabase returns rows', () async {
      final db = _StubDatabaseService()
        ..projectsToReturn.addAll([_row(_project(id: 'db-1', title: 'Live Project'))]);
      final container = container0(db);
      addTearDown(container.dispose);

      // Watch the provider and wait until the async swap completes.
      final sub = container.listen(
        publicProjectsProvider,
        (_, _) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final projects = container.read(publicProjectsProvider);
      expect(projects, hasLength(1));
      expect(projects.first.id, 'db-1');
      // Placeholder cover URLs are normalised to empty (generated covers).
      expect(projects.first.coverImageUrl, isEmpty);
      sub.close();
    });

    test('legacy placeholder paths and placehold.co links normalise to empty',
        () async {
      final db = _StubDatabaseService()
        ..projectsToReturn.addAll([
          _row(_project(id: 'legacy-1'))
              ..['coverImageUrl'] = 'assets/images/project_placeholder.jpg',
          _row(_project(id: 'legacy-2'))
              ..['coverImageUrl'] =
              'https://placehold.co/400x250/3b82f6/ffffff?text=Old',
          _row(_project(id: 'real-1'))
              ..['coverImageUrl'] = 'https://example.com/real-cover.png',
        ]);
      final container = container0(db);
      addTearDown(container.dispose);

      final sub = container.listen(publicProjectsProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final byId = {
        for (final p in container.read(publicProjectsProvider)) p.id: p,
      };
      expect(byId['legacy-1']!.coverImageUrl, isEmpty);
      expect(byId['legacy-2']!.coverImageUrl, isEmpty);
      // Real uploaded URLs pass through untouched.
      expect(byId['real-1']!.coverImageUrl,
          'https://example.com/real-cover.png');
      sub.close();
    });
  });

  group('ProjectsNotifier mutations', () {
    test('addProject updates state and upserts a snake_case row', () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final id = _uuid(1);
      await container
          .read(projectsProvider.notifier)
          .addProject(_project(id: id, title: 'New Project'));

      expect(container.read(projectsProvider).any((p) => p.id == id), isTrue);
      expect(db.upserts.last.$1, 'projects');
      final row = db.upserts.last.$2;
      expect(row['id'], id);
      // The real columns — not the model's camelCase toJson() keys, which
      // PostgREST rejects outright.
      expect(row['event_id'], _StubDatabaseService.eventUuid);
      expect(row['publication_status'], 'published');
      expect(row.keys, isNot(contains('eventId')));
      expect(row.keys, isNot(contains('publicationStatus')));
    });

    test('a non-uuid (bundled fallback) id is refused, not sent', () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final notifier = container.read(projectsProvider.notifier);
      await expectLater(
        notifier.addProject(_project(id: 'proj-cs230-001')),
        throwsA(isA<NotPersistableException>()),
      );
      expect(db.upserts, isEmpty);
      // Rolled back: the unsaveable row doesn't linger in the list.
      expect(container.read(projectsProvider), isEmpty);
    });

    test('a failed write rolls the list back and rethrows', () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final notifier = container.read(projectsProvider.notifier);
      await notifier.addProject(_project(id: _uuid(2), title: 'Saved'));
      db.failWrites = true;

      await expectLater(notifier.deleteProject(_uuid(2)), throwsException);
      expect(
        container.read(projectsProvider).map((p) => p.title),
        ['Saved'],
        reason: 'the delete never persisted, so the row must come back',
      );
    });

    test('deleteProject removes from state and calls Supabase delete',
        () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final id = _uuid(3);
      final notifier = container.read(projectsProvider.notifier);
      await notifier.addProject(_project(id: id));
      await notifier.deleteProject(id);

      expect(container.read(projectsProvider).any((p) => p.id == id), isFalse);
      expect(db.deletes, contains(('projects', id)));
    });

    test('togglePublishStatus flips draft <-> published and stamps publishedAt',
        () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final id = _uuid(4);
      final notifier = container.read(projectsProvider.notifier);
      await notifier.addProject(_project(id: id, status: 'draft'));

      await notifier.togglePublishStatus(id);
      var updated =
          container.read(projectsProvider).firstWhere((p) => p.id == id);
      expect(updated.publicationStatus, 'published');
      expect(updated.publishedAt, isNotNull);

      await notifier.togglePublishStatus(id);
      updated =
          container.read(projectsProvider).firstWhere((p) => p.id == id);
      expect(updated.publicationStatus, 'draft');
    });

    test('updateProject replaces matching id only and bumps updatedAt',
        () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final keep = _uuid(5);
      final change = _uuid(6);
      final notifier = container.read(projectsProvider.notifier);
      await notifier.addProject(_project(id: keep));
      await notifier.addProject(_project(id: change, title: 'Old Title'));

      await notifier.updateProject(_project(id: change, title: 'New Title'));

      final projects = container.read(projectsProvider);
      expect(projects.firstWhere((p) => p.id == change).title, 'New Title');
      expect(projects.firstWhere((p) => p.id == keep).title, 'Project One');
      expect(
        projects
            .firstWhere((p) => p.id == change)
            .updatedAt
            .isAfter(DateTime(2026, 7, 1)),
        isTrue,
      );
    });
  });

  group('featured + visits derived providers', () {
    test('featuredProjectsProvider filters published featured projects',
        () async {
      final db = _StubDatabaseService()
        ..projectsToReturn.addAll([
          _row(_project(id: 'f1', featured: true)),
          _row(_project(id: 'f2', featured: false)),
          _row(_project(id: 'f3', featured: true, status: 'draft')),
        ]);
      final container = container0(db);
      addTearDown(container.dispose);

      final sub = container.listen(featuredProjectsProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final featured = container.read(featuredProjectsProvider);
      expect(featured.map((p) => p.id), ['f1']);
      sub.close();
    });

    test('ProjectVisitCountsNotifier counts visits per project', () {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final counts = container.read(projectVisitCountsProvider.notifier);
      counts.recordVisit('a');
      counts.recordVisit('a');
      counts.recordVisit('b');

      expect(container.read(projectVisitCountsProvider), {'a': 2, 'b': 1});
    });
  });

  group('AnnouncementsNotifier', () {
    test('add + togglePinned + togglePublish update state and persist',
        () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final id = _uuid(10);
      final notifier = container.read(announcementsProvider.notifier);
      // Let the initial load settle first, as it would before an admin can
      // click anything (the stub never echoes writes back on a re-fetch).
      await pumpEventQueue();
      await notifier.addAnnouncement(_announcement(id));

      expect(container.read(announcementsProvider), hasLength(1));

      await notifier.togglePinned(id);
      expect(container.read(announcementsProvider).first.pinned, isTrue);

      await notifier.togglePublish(id);
      expect(
        container.read(announcementsProvider).first.publicationStatus,
        'draft',
      );
      // Every mutation upserts to Supabase, using the real column names.
      expect(db.upserts.length, 3);
      expect(db.upserts.last.$2['is_pinned'], isTrue);
      expect(db.upserts.last.$2.keys, isNot(contains('pinned')));
    });

    test('deleteAnnouncement removes the row', () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      final id = _uuid(11);
      final notifier = container.read(announcementsProvider.notifier);
      await pumpEventQueue();
      await notifier.addAnnouncement(_announcement(id));
      await notifier.deleteAnnouncement(id);

      expect(container.read(announcementsProvider), isEmpty);
      expect(db.deletes, contains(('announcements', id)));
    });
  });

  group('LecturerAuthNotifier', () {
    test('signs out clears lecturer state', () {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      expect(container.read(lecturerAuthProvider), isNull);
    });

    test('anonymous visitor does not fire the lecturers query', () {
      // The public shell watches lecturerAuthProvider on every page —
      // it must NOT trigger getLecturersOnce when nobody is signed in
      // (it previously queried the lecturers table for every visitor).
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      // Read the signed-in selector the shell uses, then let async
      // settles flush.
      expect(
        container.read(lecturerAuthProvider.select((l) => l != null)),
        isFalse,
      );
      // Give any (erroneously started) provider work a chance to run.
      container.listen(lecturerAuthProvider, (_, _) {});
      expect(db.lecturerQueryCount, 0,
          reason: 'lecturers table must not be queried for anonymous users');
    });

    test('a signed-in user who is NOT a lecturer is not treated as one',
        () async {
      final db = _StubDatabaseService();
      final container = ProviderContainer(
        overrides: [
          supabaseDbServiceProvider.overrideWithValue(db),
          currentAuthUserProvider.overrideWith(
            (ref) => User(
              id: 'user-2',
              email: 'student@student.uitm.edu.my',
              aud: 'authenticated',
              appMetadata: const {},
              userMetadata: const {},
              createdAt: DateTime(2026, 1, 1).toIso8601String(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(lecturerAuthProvider, (_, _) {},
          fireImmediately: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(container.read(lecturerAuthProvider), isNull,
          reason: 'only emails with a lecturer profile get the lecturer workspace');
      sub.close();
    });

    test('signed-in lecturer resolves display name from config', () async {
      final db = _StubDatabaseService();
      final container = container0(db);
      addTearDown(container.dispose);

      // Simulate sign-in: override the auth user with a lecturer email
      // and re-evaluate (drive through the same provider chain).
      final overrideContainer = ProviderContainer(
        overrides: [
          supabaseDbServiceProvider.overrideWithValue(db),
          currentAuthUserProvider.overrideWith((ref) => _fakeLecturerUser()),
        ],
      );
      addTearDown(overrideContainer.dispose);

      final sub = overrideContainer.listen(lecturerAuthProvider, (_, _) {},
          fireImmediately: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final lecturer = overrideContainer.read(lecturerAuthProvider);
      expect(lecturer, isNotNull);
      // Config takes precedence over metadata for the display name.
      expect(lecturer!.displayName, 'DR. AMINAH');
      expect(overrideContainer.read(lecturerUidProvider), 'user-1');
      sub.close();
    });
  });
}
