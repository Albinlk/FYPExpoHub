import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/announcement.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/domain/models/student_visit.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
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

  final List<(String, Map<String, dynamic>)> upserts = [];
  final List<(String, String)> deletes = [];

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

  @override
  Future<void> setProject(String id, Map<String, dynamic> data) async {
    upserts.add(('projects', data));
  }

  @override
  Future<void> deleteProject(String id) async {
    deletes.add(('projects', id));
  }

  @override
  Future<void> setAnnouncement(String id, Map<String, dynamic> data) async {
    upserts.add(('announcements', data));
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    deletes.add(('announcements', id));
  }
}

void main() {
  ProviderContainer _container(_StubDatabaseService db) => ProviderContainer(
        overrides: [
          supabaseDbServiceProvider.overrideWithValue(db),
          currentAuthUserProvider.overrideWith((ref) => null),
        ],
      );

  group('ProjectsNotifier offline fallback', () {
    test('seeds from bundled ExcelData when Supabase read fails', () {
      final db = _StubDatabaseService()..failReads = true;
      final container = _container(db);
      addTearDown(container.dispose);

      final projects = container.read(publicProjectsProvider);
      expect(projects, isNotEmpty);
      expect(projects.first.eventId, 'fskm-fyp-2026');
      // Placeholder rows keep an EMPTY cover url so ProjectCoverImage
      // renders its generated local cover (no third-party requests).
      expect(projects.first.coverImageUrl, isEmpty);
    });

    test('replaces fallback once Supabase returns rows', () async {
      final db = _StubDatabaseService()
        ..projectsToReturn.addAll([_row(_project(id: 'db-1', title: 'Live Project'))]);
      final container = _container(db);
      addTearDown(container.dispose);

      // Watch the provider and wait until the async swap completes.
      final sub = container.listen(
        publicProjectsProvider,
        (_, __) {},
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
      final container = _container(db);
      addTearDown(container.dispose);

      final sub = container.listen(publicProjectsProvider, (_, __) {});
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
    test('addProject updates state and upserts to Supabase', () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      final notifier = container.read(projectsProvider.notifier);
      notifier.addProject(_project(id: 'new-1', title: 'New Project'));

      expect(
        container.read(projectsProvider).any((p) => p.id == 'new-1'),
        isTrue,
      );
      expect(db.upserts, isNotEmpty);
      expect(db.upserts.last.$1, 'projects');
      expect(db.upserts.last.$2['id'], 'new-1');
    });

    test('deleteProject removes from state and calls Supabase delete', () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      final notifier = container.read(projectsProvider.notifier);
      notifier.addProject(_project(id: 'doomed'));
      notifier.deleteProject('doomed');

      expect(
        container.read(projectsProvider).any((p) => p.id == 'doomed'),
        isFalse,
      );
      expect(db.deletes, contains(('projects', 'doomed')));
    });

    test('togglePublishStatus flips draft <-> published and stamps publishedAt',
        () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      final notifier = container.read(projectsProvider.notifier);
      notifier.addProject(_project(id: 't1', status: 'draft'));

      notifier.togglePublishStatus('t1');
      var updated =
          container.read(projectsProvider).firstWhere((p) => p.id == 't1');
      expect(updated.publicationStatus, 'published');
      expect(updated.publishedAt, isNotNull);

      notifier.togglePublishStatus('t1');
      updated =
          container.read(projectsProvider).firstWhere((p) => p.id == 't1');
      expect(updated.publicationStatus, 'draft');
    });

    test('updateProject replaces matching id only and bumps updatedAt', () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      final notifier = container.read(projectsProvider.notifier);
      notifier.addProject(_project(id: 'keep'));
      notifier.addProject(_project(id: 'change', title: 'Old Title'));

      notifier.updateProject(_project(id: 'change', title: 'New Title'));

      final projects = container.read(projectsProvider);
      expect(
        projects.firstWhere((p) => p.id == 'change').title,
        'New Title',
      );
      expect(
        projects.firstWhere((p) => p.id == 'keep').title,
        'Project One',
      );
      expect(
        projects
            .firstWhere((p) => p.id == 'change')
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
      final container = _container(db);
      addTearDown(container.dispose);

      final sub = container.listen(featuredProjectsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final featured = container.read(featuredProjectsProvider);
      expect(featured.map((p) => p.id), ['f1']);
      sub.close();
    });

    test('ProjectVisitCountsNotifier counts visits per project', () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      final counts = container.read(projectVisitCountsProvider.notifier);
      counts.recordVisit('a');
      counts.recordVisit('a');
      counts.recordVisit('b');

      expect(container.read(projectVisitCountsProvider), {'a': 2, 'b': 1});
    });
  });

  group('AnnouncementsNotifier', () {
    test('add + togglePinned + togglePublish update state and persist', () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      final notifier = container.read(announcementsProvider.notifier);
      notifier.addAnnouncement(_announcement('a1'));

      expect(container.read(announcementsProvider), hasLength(1));

      notifier.togglePinned('a1');
      expect(container.read(announcementsProvider).first.pinned, isTrue);

      notifier.togglePublish('a1');
      expect(
        container.read(announcementsProvider).first.publicationStatus,
        'draft',
      );
      // Every mutation upserts to Supabase.
      expect(db.upserts.length, 3);
    });

    test('deleteAnnouncement removes the row', () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      final notifier = container.read(announcementsProvider.notifier);
      notifier.addAnnouncement(_announcement('gone'));
      notifier.deleteAnnouncement('gone');

      expect(container.read(announcementsProvider), isEmpty);
      expect(db.deletes, contains(('announcements', 'gone')));
    });
  });

  group('LecturerAuthNotifier', () {
    test('signs out clears lecturer state', () {
      final db = _StubDatabaseService();
      final container = _container(db);
      addTearDown(container.dispose);

      expect(container.read(lecturerAuthProvider), isNull);
    });
  });
}
