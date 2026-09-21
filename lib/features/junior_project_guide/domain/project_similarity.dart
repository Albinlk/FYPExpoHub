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
    if (t.contains('deep learning') || t.contains('cnn') || t.contains('efficientnet') || t.contains('mobilenet') || t.contains('yolov') || t.contains('sasrec') || t.contains('deepfake')) add('Deep Learning / CV');
    if (t.contains('lstm') || t.contains('random forest') || t.contains('support vector') || t.contains('svm') || t.contains('whale optimization') || t.contains('decision tree') || t.contains(' aco ') || t.contains(' pso ') || t.contains('machine learning')) add('Machine Learning');
    if (t.contains('artificial intelligence') || t.contains('explainable ai') || t.contains(' xai ')) add('AI / XAI');
    if (t.contains('recommender') || t.contains('recommendation') || t.contains('collaborative') || t.contains('content-based') || t.contains('clustering') || t.contains('scent fingerprint')) add('Recommender System');
    if (t.contains('sentiment analysis') || (t.contains('sentiment') && !t.contains('transformer')) ) add('Sentiment Analysis');
    if (t.contains('knowledge graph') || t.contains('lexgraph') || t.contains('hierarchical knowledge')) add('Knowledge Graph');
    if (t.contains('blockchain') || t.contains('distributed ledger')) add('Blockchain');
    if (t.contains('intrusion detection') || t.contains('anomaly detection') || t.contains('network traffic analysis') || t.contains('ddos') || t.contains('network forensics') || t.contains(' nids ') || t.contains('snort') || t.contains('wireshark')) add('Network Security / IDS');
    if (t.contains('mqtt') || t.contains('esp32') || t.contains(' iot ') || t.contains('lora') || t.contains('b.a.t.m.a.n') || t.contains('cyber-physical') || t.contains('cyber physical')) add('IoT / Embedded');
    if (t.contains('zero trust') || t.contains('honeypot') || t.contains('vulnerability scanning') || t.contains('penetration testing') || t.contains('phishing') || t.contains('ransomware') || t.contains('malware') || t.contains('digital forensics') || t.contains('email security') || t.contains('qr code') || t.contains('smishing')) add('Cybersecurity');
    if (t.contains(' sdn ') || t.contains('ryu controller') || t.contains('gns3') || t.contains('vlan') || t.contains('load balancing') || t.contains(' ospf ') || t.contains(' vpn ') || t.contains(' 5g ') || t.contains(' dns ') || t.contains('http/3') || t.contains('mininet') || t.contains(' tcp ') || t.contains(' udp ') || t.contains('voip') || t.contains('wi-fi') || t.contains('wifi') || t.contains('radio-over-ip') || t.contains('radio over ip')) add('Networking');
    if (t.contains('virtual reality') || t.contains(' vr ') || t.contains('vr:') || t.contains('game-based') || t.contains('mobile legends') || t.contains('congkak') || t.contains('avialearn')) add('AR/VR / Game');
    if (t.contains('web-based') || t.contains('web application') || t.contains('dashboard') || t.contains('document management') || t.contains('nestjs') || t.contains('nest.js')) add('Web / Dashboard');
    if (t.contains('mobile application') || t.contains('mobile app') || t.contains(' android ') || t.contains('period tracker') || t.contains('fingerprint') || t.contains('face recognition')) add('Mobile App');
    if (t.contains('nas') || t.contains('cloud storage') || t.contains('cloud-native') || t.contains('cloud computing') || t.contains('docker')) add('Cloud / DevOps');
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

  /// The fixed set of category buckets [inferTagsFromTitle] can produce.
  /// Used by [categoryTags] to tell an already-standardized tag (Expo Hub
  /// projects are seeded with these directly) apart from genuinely raw,
  /// free-text tags (CSP600 CSV proposals, e.g. "MQTT", "OSPF", "Snort")
  /// that still need keyword categorization.
  static const Set<String> knownCategories = {
    'NLP / Transformer',
    'Generative AI / RAG',
    'LLM',
    'Reinforcement Learning',
    'Deep Learning / CV',
    'Machine Learning',
    'AI / XAI',
    'Recommender System',
    'Sentiment Analysis',
    'Knowledge Graph',
    'Blockchain',
    'Network Security / IDS',
    'IoT / Embedded',
    'Cybersecurity',
    'Networking',
    'AR/VR / Game',
    'Web / Dashboard',
    'Mobile App',
    'Cloud / DevOps',
    'Data Analytics',
    'GIS / Navigation',
    'AI / General',
    'General CS',
  };

  /// Tags collapsed onto the same standardized category vocabulary
  /// regardless of source: a tag that's already one of [knownCategories]
  /// (how Expo Hub projects are seeded) passes through unchanged, while a
  /// genuinely raw/free-text tag (how CSP600 CSV proposals are authored —
  /// e.g. "MQTT", "VLAN", "Snort") is keyword-categorized via
  /// [inferTagsFromTitle]. Intended for filter/browse UIs that need one
  /// consistent tech-stack vocabulary across both sources; [displayTags]
  /// remains the source of truth for showing a project's actual tags.
  static Set<String> categoryTags(Project p) {
    final raw = displayTags(p);
    final result = <String>{};
    for (final tag in raw) {
      if (knownCategories.contains(tag)) {
        result.add(tag);
      } else {
        result.addAll(inferTagsFromTitle(tag));
      }
    }
    if (result.isEmpty) result.addAll(inferTagsFromTitle(p.title));
    return result;
  }

  /// Precomputes each project's normalized tag set once, keyed by id.
  /// Pass the result as `tagIndex` to the methods below when comparing many
  /// projects (e.g. [buildClusters], [computeSimilarityCounts]) so [tagSet]
  /// — which re-normalizes and re-infers tags from scratch — isn't repeated
  /// for the same project on every one of its O(n) comparisons.
  static Map<String, Set<String>> buildTagIndex(List<Project> projects) {
    return {for (final p in projects) p.id: tagSet(p)};
  }

  static Set<String> _tagsFor(Project p, Map<String, Set<String>>? tagIndex) {
    return tagIndex?[p.id] ?? tagSet(p);
  }

  /// Returns the number of shared normalized tags between two projects.
  static int sharedTagCount(
    Project a,
    Project b, {
    Map<String, Set<String>>? tagIndex,
  }) {
    final aTags = _tagsFor(a, tagIndex);
    final bTags = _tagsFor(b, tagIndex);
    return aTags.intersection(bTags).length;
  }

  /// Jaccard similarity (0.0-1.0) between two projects' tag sets.
  static double jaccardSimilarity(
    Project a,
    Project b, {
    Map<String, Set<String>>? tagIndex,
  }) {
    final aTags = _tagsFor(a, tagIndex);
    final bTags = _tagsFor(b, tagIndex);
    if (aTags.isEmpty && bTags.isEmpty) return 0.0;
    final intersection = aTags.intersection(bTags).length;
    final union = aTags.union(bTags).length;
    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// Returns all projects that share [minSharedTagsForCluster] or more tags
  /// with [target] (excluding the target itself).
  static List<Project> findSimilar(
    Project target,
    List<Project> all, {
    Map<String, Set<String>>? tagIndex,
  }) {
    return all
        .where((p) =>
            p.id != target.id &&
            sharedTagCount(target, p, tagIndex: tagIndex) >=
                minSharedTagsForCluster)
        .toList();
  }

  /// Returns the count of projects similar to [target].
  ///
  /// Calling this once per row in a list (as opposed to
  /// [computeSimilarityCounts] once for the whole list) repeats an O(n) scan
  /// for every row — fine for a handful of projects, but avoid it once the
  /// list is in the hundreds.
  static int similarCount(
    Project target,
    List<Project> all, {
    Map<String, Set<String>>? tagIndex,
  }) {
    return findSimilar(target, all, tagIndex: tagIndex).length;
  }

  /// Computes every project's similar-project count in a single O(n^2) pass,
  /// keyed by id. Prefer this over calling [similarCount] per row when
  /// rendering a list, since that would repeat the O(n) scan per row.
  static Map<String, int> computeSimilarityCounts(
    List<Project> projects, {
    Map<String, Set<String>>? tagIndex,
  }) {
    final index = tagIndex ?? buildTagIndex(projects);
    final counts = <String, int>{for (final p in projects) p.id: 0};
    for (int i = 0; i < projects.length; i++) {
      for (int j = i + 1; j < projects.length; j++) {
        if (sharedTagCount(projects[i], projects[j], tagIndex: index) >=
            minSharedTagsForCluster) {
          final aId = projects[i].id;
          final bId = projects[j].id;
          counts[aId] = (counts[aId] ?? 0) + 1;
          counts[bId] = (counts[bId] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  /// Groups projects into clusters where each pair in a cluster shares
  /// [minSharedTagsForCluster] or more tags. Uses union-find so transitive
  /// relationships are included (A~B, B~C => A, B, C in same cluster).
  static List<RedundancyCluster> buildClusters(
    List<Project> projects, {
    Map<String, Set<String>>? tagIndex,
  }) {
    if (projects.length < 2) return [];

    final index = tagIndex ?? buildTagIndex(projects);
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
        if (sharedTagCount(projects[i], projects[j], tagIndex: index) >=
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
          final sharedTags =
              _sharedTagsAcrossCluster(clusterProjects, tagIndex: index);
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
  static List<String> _sharedTagsAcrossCluster(
    List<Project> cluster, {
    Map<String, Set<String>>? tagIndex,
  }) {
    if (cluster.isEmpty) return [];
    var intersection = _tagsFor(cluster.first, tagIndex);
    for (final p in cluster.skip(1)) {
      intersection = intersection.intersection(_tagsFor(p, tagIndex));
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
