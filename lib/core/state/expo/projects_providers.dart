import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_fallback.dart';
import '../../domain/models/project.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import '../../widgets/project_cover_image.dart';
import 'service_providers.dart';

// ==========================================
// PROJECTS STATE
// ==========================================
class ProjectsNotifier extends Notifier<List<Project>> {
  ProjectsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  List<Project> _parseProjects(List<Map<String, dynamic>> dataList) {
    return dataList.map((m) {
      final norm = normalizeKeys(m);
      final project = Project.fromJson(norm);
      // Placeholder rows keep an EMPTY cover url — ProjectCoverImage then
      // renders its deterministic generated gradient cover locally
      // (no third-party placehold.co requests).
      if (project.coverImageUrl == 'assets/images/project_placeholder.jpg' ||
          ProjectCoverImage.isPlaceholderUrl(project.coverImageUrl)) {
        return project.copyWith(coverImageUrl: '');
      }
      return project;
    }).toList();
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
    try {
      final data = await OfflineFallback.load();
      final fallback = _parseProjects(data['projects'] ?? const []);
      if (state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
      }
    } catch (e) {
      logDebug('Projects fallback asset warning: $e');
    }
    try {
      final data = await remote;
      if (data.isNotEmpty) {
        state = _parseProjects(data);
      }
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

  void addProject(Project project) {
    state = [...state, project];
    ref.read(supabaseDbServiceProvider).setProject(project.id, project.toJson());
  }

  void updateProject(Project updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final p in state)
        if (p.id == updated.id) data else p,
    ];
    ref.read(supabaseDbServiceProvider).setProject(updated.id, data.toJson());
  }

  void deleteProject(String id) {
    state = state.where((p) => p.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteProject(id);
  }

  void togglePublishStatus(String id) {
    final idx = state.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = state[idx];
    final toggled = p.copyWith(
      publicationStatus: p.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: p.publicationStatus != 'published' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final item in state)
        if (item.id == id) toggled else item,
    ];
    ref.read(supabaseDbServiceProvider).setProject(id, toggled.toJson());
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

final mostVisitedProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(publicProjectsProvider);
  final counts = ref.watch(projectVisitCountsProvider);
  final sorted = List<Project>.from(projects)
    ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
  return sorted;
});
