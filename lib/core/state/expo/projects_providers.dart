import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_fallback.dart';
import '../../domain/models/project.dart';
import '../../supabase/row_mappers.dart';
import '../../utils/logger.dart';
import '../../widgets/project_cover_image.dart';
import 'optimistic_list.dart';
import 'service_providers.dart';

// ==========================================
// PROJECTS STATE
// ==========================================
class ProjectsNotifier extends Notifier<List<Project>>
    with OptimisticList<Project> {
  ProjectsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  /// One malformed row is skipped (and logged) rather than failing the whole
  /// list, which used to leave the page stuck on bundled data.
  List<Project> _parseProjects(List<Map<String, dynamic>> dataList) {
    final out = <Project>[];
    for (final m in dataList) {
      try {
        final project = projectFromRow(m);
        // Placeholder rows keep an EMPTY cover url — ProjectCoverImage then
        // renders its deterministic generated gradient cover locally
        // (no third-party placehold.co requests).
        out.add(project.coverImageUrl == 'assets/images/project_placeholder.jpg' ||
                ProjectCoverImage.isPlaceholderUrl(project.coverImageUrl)
            ? project.copyWith(coverImageUrl: '')
            : project);
      } catch (e) {
        logDebug('Skipping unparseable project row ${m['id']}: $e');
      }
    }
    return out;
  }

  @override
  List<Project> build() {
    _loadProjects();
    return const [];
  }

  /// Loads remote data and the offline-fallback asset in parallel. The
  /// fallback fills state first (near-instant content), and live Supabase
  /// rows overwrite it as soon as they arrive — the fallback is skipped
  /// entirely if remote wins the race.
  ///
  /// The remote future gets an immediate no-op catchError so its error is
  /// never unhandled in the window before the later await re-throws into
  /// the local try/catch.
  void _loadProjects() async {
    final remote = _fetchRemote().catchError(
      (Object e) => <Map<String, dynamic>>[],
    );
    // Admin lists skip the bundled fallback: its rows have no database
    // counterpart (non-uuid ids), so every edit to one would fail.
    if (publishedOnly) {
      try {
        final data = await OfflineFallback.load();
        final fallback = _parseProjects(data['projects'] ?? const []);
        if (state.isEmpty && fallback.isNotEmpty) {
          state = fallback;
        }
      } catch (e) {
        logDebug('Projects fallback asset warning: $e');
      }
    }
    try {
      var first = true;
      await loadRemote(() async {
        final data = first ? await remote : await _fetchRemote();
        first = false;
        // Empty remote: keep the bundled fallback that's already showing.
        return data.isEmpty ? null : _parseProjects(data);
      });
    } catch (e) {
      logDebug('Projects load from Supabase warning: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemote() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getProjectsOnce(publishedOnly: publishedOnly);
  }

  Future<void> refresh() async {
    try {
      final data = await _fetchRemote();
      if (data.isNotEmpty) {
        state = _parseProjects(data);
      }
    } catch (e) {
      logDebug('Projects refresh failed: $e');
    }
  }

  Future<void> _save(Project p) async {
    final db = ref.read(supabaseDbServiceProvider);
    final eventId = await db.resolveEventId(p.eventId);
    await db.setProject(p.id, projectToRow(p, eventId: eventId));
    _refreshPublic();
  }

  /// The public list is a separate notifier instance; reload it so an
  /// admin's change shows on public pages in the same session.
  void _refreshPublic() {
    if (!publishedOnly) ref.invalidate(publicProjectsProvider);
  }

  Future<void> addProject(Project project) =>
      commit([...state, project], () => _save(project));

  Future<void> updateProject(Project updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    return commit(
      [for (final p in state) if (p.id == updated.id) data else p],
      () => _save(data),
    );
  }

  Future<void> deleteProject(String id) => commit(
        state.where((p) => p.id != id).toList(),
        () async {
          await ref.read(supabaseDbServiceProvider).deleteProject(id);
          _refreshPublic();
        },
      );

  Future<void> togglePublishStatus(String id) async {
    final idx = state.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = state[idx];
    final toggled = p.copyWith(
      publicationStatus: p.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: p.publicationStatus != 'published' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    await commit(
      [for (final item in state) if (item.id == id) toggled else item],
      () => _save(toggled),
    );
  }
}

final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  () => ProjectsNotifier(),
);

final publicProjectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  () => ProjectsNotifier(publishedOnly: true),
);

final featuredProjectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(publicProjectsProvider).where((p) => p.featured).toList();
});

final projectsMapProvider = Provider<Map<String, Project>>((ref) {
  return Map.fromEntries(
    ref.watch(publicProjectsProvider).map((p) => MapEntry(p.id, p)),
  );
});

// ==========================================
// PROJECT VISIT TRACKING (page-view counters, not lecturer visits)
// ==========================================
class ProjectVisitCountsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void recordVisit(String projectId) {
    state = {...state, projectId: (state[projectId] ?? 0) + 1};
  }
}

final projectVisitCountsProvider =
    NotifierProvider<ProjectVisitCountsNotifier, Map<String, int>>(
      () => ProjectVisitCountsNotifier(),
    );

/// The Home page's "Featured Projects": projects an admin marked Featured
/// first, then the rest in most-visited order, up to [count].
List<Project> featuredForHome(List<Project> mostVisited, {int count = 6}) => [
      ...mostVisited.where((p) => p.featured),
      ...mostVisited.where((p) => !p.featured),
    ].take(count).toList();

final mostVisitedProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(publicProjectsProvider);
  final counts = ref.watch(projectVisitCountsProvider);
  final sorted = List<Project>.from(projects)
    ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
  return sorted;
});
