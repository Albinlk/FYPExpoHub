// ignore_for_file: curly_braces_in_flow_control_structures
import '../../../core/domain/models/project.dart';

/// Computes tag-overlap similarity between projects and identifies
/// potentially redundant clusters (projects sharing 3+ technology tags).
class ProjectSimilarity {
  static const minSharedTagsForCluster = 3;

  /// Normalizes a tag to lowercase for case-insensitive comparison.
  static String _normalizeTag(String tag) => tag.toLowerCase().trim();

  /// Returns effective normalized tags — falls back to title inference
  /// when data still carries placeholder ["FYP"] (legacy Supabase/offline data).
  static Set<String> tagSet(Project p) {
    final raw = p.technologyTags;
    final isPlaceholder = raw.length == 1 && raw.first.toUpperCase() == 'FYP';
    final effective = isPlaceholder
        ? inferTagsFromTitle(p.title)
        : raw;
    return effective.map(_normalizeTag).toSet();
  }

  /// Lightweight title → tech tag inference (mirrors tech_tags_inferred.csv).
  /// Keeps Project Guide readable even before Supabase migration.
  static List<String> inferTagsFromTitle(String title) {
    final t = ' ${title.toLowerCase()} ';
    final out = <String>[];
    void add(String tag) { if (!out.contains(tag)) out.add(tag); }

    if (t.contains('multilingual transformer') || t.contains('malay transformer') || t.contains(' bert ') || t.contains('transformer') || t.contains('stance detection') || t.contains('emotion recognition')) add('NLP / Transformer');
    if (t.contains('retrieval-augmented') || t.contains(' rag ') || t.contains('generative ai')) add('Generative AI / RAG');
    if (t.contains('llm') || t.contains('deepseek') || t.contains('large language model')) add('LLM');
    if (t.contains('reinforcement learning')) add('Reinforcement Learning');
    if (t.contains('deep learning') || t.contains('cnn') || t.contains('efficientnet') || t.contains('mobilenet') || t.contains('yolov') || t.contains('sasrec')) add('Deep Learning / CV');
    if (t.contains('lstm') || t.contains('random forest') || t.contains('support vector') || t.contains('svm') || t.contains('whale optimization') || t.contains('decision tree') || t.contains(' aco ') || t.contains(' pso ') || t.contains('machine learning')) add('Machine Learning');
    if (t.contains('artificial intelligence') || t.contains('explainable ai') || t.contains(' xai ')) add('AI / XAI');
    if (t.contains('recommender') || t.contains('recommendation') || t.contains('collaborative') || t.contains('content-based') || t.contains('clustering') || t.contains('scent fingerprint')) add('Recommender System');
    if (t.contains('sentiment analysis') || (t.contains('sentiment') && !t.contains('transformer')) ) add('Sentiment Analysis');
    if (t.contains('knowledge graph') || t.contains('lexgraph') || t.contains('hierarchical knowledge')) add('Knowledge Graph');
    if (t.contains('blockchain') || t.contains('distributed ledger')) add('Blockchain');
    if (t.contains('intrusion detection') || t.contains('anomaly detection') || t.contains('network traffic analysis')) add('Network Security / IDS');
    if (t.contains('mqtt') || t.contains('esp32') || t.contains(' iot ') || t.contains('lora') || t.contains('b.a.t.m.a.n')) add('IoT / Embedded');
    if (t.contains('zero trust') || t.contains('honeypot') || t.contains('vulnerability scanning') || t.contains('penetration testing') || t.contains('phishing') || t.contains('ransomware') || t.contains('malware')) add('Cybersecurity');
    if (t.contains(' sdn ') || t.contains('ryu controller') || t.contains('gns3') || t.contains('vlan') || t.contains('load balancing') || t.contains(' ospf ') || t.contains(' vpn ') || t.contains(' 5g ')) add('Networking');
    if (t.contains('virtual reality') || t.contains(' vr ') || t.contains('vr:') || t.contains('game-based') || t.contains('mobile legends') || t.contains('congkak') || t.contains('avialearn')) add('AR/VR / Game');
    if (t.contains('web-based') || t.contains('web application') || t.contains('dashboard')) add('Web / Dashboard');
    if (t.contains('mobile application') || t.contains(' android ') || t.contains('period tracker') || t.contains('fingerprint') || t.contains('face recognition')) add('Mobile App');
    if (t.contains('nas') || t.contains('cloud storage') || t.contains('cloud-native') || t.contains('docker swarm')) add('Cloud / DevOps');
    if (t.contains('portfolio optimization') || t.contains('price and trend') || t.contains('crime hotspot') || t.contains('expense tracking') || t.contains(' halal ') || t.contains('dropout risk')) add('Data Analytics');
    if (t.contains('apnrs') || t.contains('navigation routing') || t.contains('path optimization')) add('GIS / Navigation');
    if (out.isEmpty) {
      if (t.contains(' ai ') || t.trim().startsWith('ai ') || t.contains(' ai-')) add('AI / General');
      else add('General CS');
    }
    return out.take(4).toList();
  }

  /// Public getter for display — returns inferred when placeholder.
  static List<String> displayTags(Project p) {
    final raw = p.technologyTags;
    final isPlaceholder = raw.length == 1 && raw.first.toUpperCase() == 'FYP';
    if (isPlaceholder) return inferTagsFromTitle(p.title);
    return raw;
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
