// ignore_for_file: curly_braces_in_flow_control_structures
import '../../../core/domain/models/project.dart';

/// Computes tag-overlap similarity between projects and identifies
/// potentially redundant clusters (projects sharing 3+ technology tags).
class ProjectSimilarity {
  static const minSharedTagsForCluster = 3;

  /// Threshold for category-based clustering (see [categoryTags]) —
  /// deliberately lower than [minSharedTagsForCluster] because categoryTags
  /// operates on a coarse, 19-entry vocabulary where most projects carry
  /// only 1-2 tags (capped via inferTagsFromTitle's .take(4)); requiring 3
  /// identical broad categories out of that budget is nearly unreachable.
  /// 2 shared categories is still a specific, meaningful topical match at
  /// this vocabulary's granularity, and is safe against a mega-cluster from
  /// the catch-all 'General CS'/'AI / General' buckets: 82% of CSP650
  /// projects carry exactly one tag, so they can never reach an
  /// intersection of 2 with anyone (intersection <= min(|A|, |B|)).
  static const minSharedCategoriesForCluster = 2;

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

    // NLP / Transformer also absorbs Knowledge Graph — this dataset's
    // knowledge-graph projects are consistently built from text, and 3
    // projects didn't warrant a separate bucket from the other 8.
    if (t.contains('multilingual transformer') || t.contains('malay transformer') || t.contains(' bert ') || t.contains('transformer') || t.contains('stance detection') || t.contains('emotion recognition') || t.contains('knowledge graph') || t.contains('lexgraph') || t.contains('hierarchical knowledge')) add('NLP / Transformer');
    // LLM also absorbs Generative AI / RAG — both are modern generative-
    // language-AI work; distinguishing "RAG pipeline" from "LLM project"
    // isn't a distinction worth a dedicated bucket for 4 projects.
    if (t.contains('retrieval-augmented') || t.contains(' rag ') || t.contains('generative ai') || t.contains('llm') || t.contains('deepseek') || t.contains('large language model')) add('LLM');
    // Machine Learning also absorbs Reinforcement Learning (a standard ML
    // subfield; 1 project doesn't warrant its own bucket).
    if (t.contains('lstm') || t.contains('random forest') || t.contains('support vector') || t.contains('svm') || t.contains('whale optimization') || t.contains('decision tree') || t.contains(' aco ') || t.contains(' pso ') || t.contains('machine learning') || t.contains('reinforcement learning')) add('Machine Learning');
    if (t.contains('deep learning') || t.contains('cnn') || t.contains('efficientnet') || t.contains('mobilenet') || t.contains('yolov') || t.contains('sasrec') || t.contains('deepfake')) add('Deep Learning / CV');
    if (t.contains('artificial intelligence') || t.contains('explainable ai') || t.contains(' xai ')) add('AI / XAI');
    if (t.contains('recommender') || t.contains('recommendation') || t.contains('collaborative') || t.contains('content-based') || t.contains('clustering') || t.contains('scent fingerprint')) add('Recommender System');
    if (t.contains('sentiment analysis') || (t.contains('sentiment') && !t.contains('transformer')) ) add('Sentiment Analysis');
    if (t.contains('blockchain') || t.contains('distributed ledger')) add('Blockchain');
    if (t.contains('intrusion detection') || t.contains('anomaly detection') || t.contains('network traffic analysis') || t.contains('ddos') || t.contains('network forensics') || t.contains(' nids ') || t.contains('snort') || t.contains('wireshark')) add('Network Security / IDS');
    if (t.contains('mqtt') || t.contains('esp32') || t.contains(' iot ') || t.contains('lora') || t.contains('b.a.t.m.a.n') || t.contains('cyber-physical') || t.contains('cyber physical')) add('IoT / Embedded');
    if (t.contains('zero trust') || t.contains('honeypot') || t.contains('vulnerability scanning') || t.contains('penetration testing') || t.contains('phishing') || t.contains('ransomware') || t.contains('malware') || t.contains('digital forensics') || t.contains('email security') || t.contains('qr code') || t.contains('smishing')) add('Cybersecurity');
    if (t.contains(' sdn ') || t.contains('ryu controller') || t.contains('gns3') || t.contains('vlan') || t.contains('load balancing') || t.contains(' ospf ') || t.contains(' vpn ') || t.contains(' 5g ') || t.contains(' dns ') || t.contains('http/3') || t.contains('mininet') || t.contains(' tcp ') || t.contains(' udp ') || t.contains('voip') || t.contains('wi-fi') || t.contains('wifi') || t.contains('radio-over-ip') || t.contains('radio over ip')) add('Networking');
    if (t.contains('virtual reality') || t.contains(' vr ') || t.contains('vr:') || t.contains('game-based') || t.contains('mobile legends') || t.contains('congkak') || t.contains('avialearn')) add('AR/VR / Game');
    if (t.contains('web-based') || t.contains('web application') || t.contains('dashboard') || t.contains('document management') || t.contains('nestjs') || t.contains('nest.js')) add('Web / Dashboard');
    if (t.contains('mobile application') || t.contains('mobile app') || t.contains(' android ') || t.contains('period tracker') || t.contains('fingerprint') || t.contains('face recognition')) add('Mobile App');
    if (t.contains('nas') || t.contains('cloud storage') || t.contains('cloud-native') || t.contains('cloud computing') || t.contains('docker')) add('Cloud / DevOps');
    // Data Analytics also absorbs GIS / Navigation — the weakest semantic
    // fit of the four merges, but 2 projects is too sparse to stand alone.
    // ' gis ' / 'navigation' alone (not just 'navigation routing') so the
    // legacy literal tag "GIS / Navigation" itself still round-trips here.
    if (t.contains('portfolio optimization') || t.contains('price and trend') || t.contains('crime hotspot') || t.contains('expense tracking') || t.contains(' halal ') || t.contains('dropout risk') || t.contains('apnrs') || t.contains('navigation') || t.contains('path optimization') || t.contains(' gis ')) add('Data Analytics');
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

  /// Category tags inferred PURELY from [p.title], ignoring any existing
  /// `technologyTags` — regardless of cohort. CSP650 projects normally get
  /// their category tags straight from the (already-standardized) DB field
  /// via [categoryTags]/[displayTags] and never run through title
  /// inference unless the tag is missing; this is an independent,
  /// title-only signal for CSP650 too (e.g. as a cross-check, or as input
  /// to title-based redundancy tooling that wants a topic label rather
  /// than a raw shared-word list — see TitleSimilarity.buildTitleClusters).
  static Set<String> titleInferredCategoryTags(Project p) {
    return inferTagsFromTitle(p.title).toSet();
  }

  /// The fixed set of category buckets [inferTagsFromTitle] can produce.
  /// Used by [categoryTags] to tell an already-standardized tag (Expo Hub
  /// projects are seeded with these directly) apart from genuinely raw,
  /// free-text tags (CSP600 CSV proposals, e.g. "MQTT", "OSPF", "Snort")
  /// that still need keyword categorization.
  ///
  /// Deliberately excludes 'Reinforcement Learning', 'Generative AI / RAG',
  /// 'Knowledge Graph', and 'GIS / Navigation': those four were each used
  /// by only 1-4 projects (see project history), so inferTagsFromTitle now
  /// folds them into 'Machine Learning', 'LLM', 'NLP / Transformer', and
  /// 'Data Analytics' respectively. Leaving them in this set would make a
  /// legacy project literally tagged e.g. "Reinforcement Learning" pass
  /// through unmerged instead of being re-bucketed — this list must stay in
  /// sync with which add(...) calls exist in inferTagsFromTitle.
  static const Set<String> knownCategories = {
    'NLP / Transformer',
    'LLM',
    'Deep Learning / CV',
    'Machine Learning',
    'AI / XAI',
    'Recommender System',
    'Sentiment Analysis',
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
    'AI / General',
    'General CS',
  };

  /// Lowercased-tag -> canonical-cased [knownCategories] value. Admin-
  /// entered tags (the unrestricted free-text field on Admin Projects) can
  /// carry any casing, e.g. "data analytics" or "NETWORKING" — those must
  /// still resolve to the same canonical category as "Data Analytics" /
  /// "Networking" so two differently-cased duplicates of the same category
  /// actually intersect in [categoryTags]. Without this, a lowercase
  /// variant falls through to [inferTagsFromTitle] instead, which has no
  /// keyword matching a bare category name like "data analytics" or
  /// "networking" (its keywords are specific tech terms, e.g. 'sdn',
  /// 'vlan') and silently miscategorizes it into the 'General CS' catch-all.
  static final Map<String, String> _knownCategoriesByLowercase = {
    for (final c in knownCategories) c.toLowerCase(): c,
  };

  /// Tags collapsed onto the same standardized category vocabulary
  /// regardless of source: a tag that's already one of [knownCategories]
  /// (how Expo Hub projects are seeded), in any casing, passes through as
  /// its canonical form, while a genuinely raw/free-text tag (how CSP600
  /// CSV proposals are authored — e.g. "MQTT", "VLAN", "Snort") is
  /// keyword-categorized via [inferTagsFromTitle]. Intended for filter/
  /// browse UIs that need one consistent tech-stack vocabulary across both
  /// sources; [displayTags] remains the source of truth for showing a
  /// project's actual tags.
  static Set<String> categoryTags(Project p) {
    final raw = displayTags(p);
    final result = <String>{};
    for (final tag in raw) {
      final canonical = _knownCategoriesByLowercase[tag.toLowerCase().trim()];
      if (canonical != null) {
        result.add(canonical);
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

  /// Precomputes each project's normalized CATEGORY tag set once, keyed by
  /// id — mirrors [buildTagIndex] but backed by [categoryTags] instead of
  /// [tagSet], so cross-cohort comparisons (CSP650's pre-seeded category
  /// tags vs CSP600's raw free-text tags) are done on the same vocabulary.
  static Map<String, Set<String>> buildCategoryTagIndex(List<Project> projects) {
    return {for (final p in projects) p.id: categoryTags(p)};
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
    int? minShared,
  }) {
    final index = tagIndex ?? buildTagIndex(projects);
    final threshold = minShared ?? minSharedTagsForCluster;
    final counts = <String, int>{for (final p in projects) p.id: 0};
    for (int i = 0; i < projects.length; i++) {
      for (int j = i + 1; j < projects.length; j++) {
        if (sharedTagCount(projects[i], projects[j], tagIndex: index) >=
            threshold) {
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
    int? minShared,
  }) {
    if (projects.length < 2) return [];

    final index = tagIndex ?? buildTagIndex(projects);
    final threshold = minShared ?? minSharedTagsForCluster;
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
            threshold) {
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

  /// Average pairwise Jaccard similarity across all members of [cluster] —
  /// a "how strongly overlapping is this group" signal, as opposed to
  /// [RedundancyCluster.sharedTags] which only says *which* tags are common
  /// to every member. Cheap: clusters are small (single-digit membership),
  /// so this is nowhere near the O(n^2) cost of the corpus-wide passes
  /// above (e.g. a 6-member cluster is only 15 pairs).
  static double clusterCohesion(
    List<Project> cluster, {
    Map<String, Set<String>>? tagIndex,
  }) {
    if (cluster.length < 2) return 0.0;
    var total = 0.0;
    var pairs = 0;
    for (int i = 0; i < cluster.length; i++) {
      for (int j = i + 1; j < cluster.length; j++) {
        total += jaccardSimilarity(cluster[i], cluster[j], tagIndex: tagIndex);
        pairs++;
      }
    }
    return pairs == 0 ? 0.0 : total / pairs;
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
