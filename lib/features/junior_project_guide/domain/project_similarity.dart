import '../../../core/domain/models/project.dart';

/// Computes tag-overlap similarity between projects and identifies
/// potentially redundant clusters (projects sharing 3+ technology tags).
class ProjectSimilarity {
  static const minSharedTagsForCluster = 3;

  /// Normalizes a tag to lowercase for case-insensitive comparison.
  static String _normalizeTag(String tag) => tag.toLowerCase().trim();

  /// Returns the set of normalized tech tags for a project.
  static Set<String> tagSet(Project p) {
    return p.technologyTags.map(_normalizeTag).toSet();
  }

  /// Returns the number of shared normalized tags between two projects.
  static int sharedTagCount(Project a, Project b) {
    final aTags = tagSet(a);
    final bTags = tagSet(b);
    return aTags.intersection(bTags).length;
  }

  /// Jaccard similarity (0.0-1.0) between two projects' tag sets.
  static double jaccardSimilarity(Project a, Project b) {
    final aTags = tagSet(a);
    final bTags = tagSet(b);
    if (aTags.isEmpty && bTags.isEmpty) return 0.0;
    final intersection = aTags.intersection(bTags).length;
    final union = aTags.union(bTags).length;
    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// Returns all projects that share [minSharedTagsForCluster] or more tags
  /// with [target] (excluding the target itself).
  static List<Project> findSimilar(Project target, List<Project> all) {
    return all.where((p) =>
        p.id != target.id &&
        sharedTagCount(target, p) >= minSharedTagsForCluster).toList();
  }

  /// Returns the count of projects similar to [target].
  static int similarCount(Project target, List<Project> all) {
    return findSimilar(target, all).length;
  }

  /// Groups projects into clusters where each pair in a cluster shares
  /// [minSharedTagsForCluster] or more tags. Uses union-find so transitive
  /// relationships are included (A~B, B~C => A, B, C in same cluster).
  static List<RedundancyCluster> buildClusters(List<Project> projects) {
    if (projects.length < 2) return [];

    final n = projects.length;
    final parent = List<int>.generate(n, (i) => i);

    int find(int x) {
      if (parent[x] != x) {
        parent[x] = find(parent[x]);
      }
      return parent[x];
    }

    void union(int x, int y) {
      final rx = find(x);
      final ry = find(y);
      if (rx != ry) {
        parent[rx] = ry;
      }
    }

    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (sharedTagCount(projects[i], projects[j]) >=
            minSharedTagsForCluster) {
          union(i, j);
        }
      }
    }

    final clusterMap = <int, List<int>>{};
    for (int i = 0; i < n; i++) {
      final root = find(i);
      clusterMap.putIfAbsent(root, () => []).add(i);
    }

    final clusters = clusterMap.values
        .where((indices) => indices.length >= 2)
        .map((indices) {
          final clusterProjects =
              indices.map((i) => projects[i]).toList(growable: false);
          final sharedTags = _sharedTagsAcrossCluster(clusterProjects);
          return RedundancyCluster(
            projects: clusterProjects,
            sharedTags: sharedTags,
          );
        })
        .toList()
      ..sort((a, b) => b.projects.length.compareTo(a.projects.length));

    return clusters;
  }

  /// Intersects tag sets across all projects in a cluster to find
  /// tags shared by every member.
  static List<String> _sharedTagsAcrossCluster(List<Project> cluster) {
    if (cluster.isEmpty) return [];
    var intersection = tagSet(cluster.first);
    for (final p in cluster.skip(1)) {
      intersection = intersection.intersection(tagSet(p));
    }
    return intersection.toList()..sort();
  }
}

/// A group of projects that share [ProjectSimilarity.minSharedTagsForCluster]
/// or more technology tags.
class RedundancyCluster {
  final List<Project> projects;
  final List<String> sharedTags;

  const RedundancyCluster({
    required this.projects,
    required this.sharedTags,
  });

  int get count => projects.length;
}
