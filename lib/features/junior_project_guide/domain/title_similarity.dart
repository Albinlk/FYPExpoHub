import '../../../core/domain/models/project.dart';
import 'project_similarity.dart';

/// Detects redundant FYP proposals by comparing project TITLES directly,
/// as a signal separate from (and complementary to) [ProjectSimilarity]'s
/// tag/category-based clustering. Two projects can share zero technology
/// tags yet have near-identical titles (or vice versa) — this catches the
/// former case.
///
/// Threshold rationale (validated against the real 490-project dataset,
/// not picked abstractly): a plain "N+ shared significant words" rule
/// (mirroring [ProjectSimilarity.minSharedTagsForCluster]) hub-chains
/// almost half the corpus into one meaningless 219-member cluster, because
/// generic multi-word academic phrasing ("real time", "machine learning
/// detection", "game based learning") bridges genuinely unrelated titles
/// transitively. Titles have a much richer, noisier vocabulary than the
/// 19-bucket category system, so a proportional (Jaccard) threshold is
/// required, not just a raw count. [minSharedTitleWords] + [minTitleJaccard]
/// together produced 14 clean, actionable clusters against the real data
/// (e.g. two nearly-identical "Tajweed error detection" app proposals).
class TitleSimilarity {
  static const minSharedTitleWords = 3;
  static const minTitleJaccard = 0.35;

  /// Function words and FYP-boilerplate that appear in the vast majority
  /// of titles regardless of actual topic (e.g. "system" appears in 38%
  /// of all 490 real titles) and add no differentiating signal.
  static const Set<String> _stopwords = {
    'a', 'an', 'the', 'for', 'and', 'of', 'in', 'on', 'to', 'with',
    'using', 'based', 'from', 'at', 'by', 'is', 'are', 'via', 'through',
    'into', 'as', 'or',
    'system', 'application', 'proposal', 'project', 'development',
    'implementation',
  };

  static final RegExp _programmeCode = RegExp(r'^cs\d+$');
  static final RegExp _placeholderPrefix =
      RegExp(r'^[a-z0-9]+\s+proposal\s*-', caseSensitive: false);

  /// Whether [title] is placeholder text rather than a real project title.
  /// Confirmed against the real dataset: 35/103 CSP600 CSV rows (34%) have
  /// title literally set to "CS251 PROPOSAL - <student name>", and 2
  /// CSP650 projects are "TBD (Project Title Pending)" — neither carries
  /// any real topical information, so comparing them would either produce
  /// meaningless matches (two students' names sharing common words) or
  /// silently cluster every placeholder together.
  static bool isPlaceholderTitle(String title) {
    final t = title.trim();
    if (t.isEmpty) return true;
    if (_placeholderPrefix.hasMatch(t)) return true;
    final upper = t.toUpperCase();
    if (upper.contains('TBD') || upper.contains('PENDING')) return true;
    return false;
  }

  /// Normalized, stopword-filtered significant words from [p]'s title.
  /// Returns an empty set for a placeholder title (see [isPlaceholderTitle])
  /// so such projects can never match anything.
  static Set<String> titleTokens(Project p) {
    if (isPlaceholderTitle(p.title)) return const {};
    final words = p.title
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length >= 2);
    final out = <String>{};
    for (var w in words) {
      if (_stopwords.contains(w)) continue;
      if (_programmeCode.hasMatch(w)) continue;
      // Crude pluralization normalization (no stemming library available):
      // strip a trailing 's' on longer words so e.g. "network"/"networks"
      // count as the same token. Short words are left alone to avoid
      // mangling e.g. "vs".
      if (w.length > 4 && w.endsWith('s')) w = w.substring(0, w.length - 1);
      out.add(w);
    }
    return out;
  }

  /// Precomputes each project's title tokens once, keyed by id — mirrors
  /// [ProjectSimilarity.buildTagIndex]'s purpose of avoiding re-tokenizing
  /// the same project on every one of its O(n) comparisons.
  static Map<String, Set<String>> buildTitleTokenIndex(List<Project> projects) {
    return {for (final p in projects) p.id: titleTokens(p)};
  }

  static Set<String> _tokensFor(Project p, Map<String, Set<String>>? tokenIndex) {
    return tokenIndex?[p.id] ?? titleTokens(p);
  }

  static int sharedTitleWordCount(
    Project a,
    Project b, {
    Map<String, Set<String>>? tokenIndex,
  }) {
    return _tokensFor(a, tokenIndex).intersection(_tokensFor(b, tokenIndex)).length;
  }

  /// Jaccard similarity (0.0-1.0) between two projects' title token sets.
  static double titleJaccard(
    Project a,
    Project b, {
    Map<String, Set<String>>? tokenIndex,
  }) {
    final ta = _tokensFor(a, tokenIndex);
    final tb = _tokensFor(b, tokenIndex);
    if (ta.isEmpty || tb.isEmpty) return 0.0;
    final intersection = ta.intersection(tb).length;
    final union = ta.union(tb).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// Groups projects into clusters of near-identically-worded titles.
  /// Uses union-find (transitive) exactly like
  /// [ProjectSimilarity.buildClusters], but the pairwise test requires
  /// BOTH [minSharedTitleWords] and [minTitleJaccard] — see class doc for
  /// why a raw shared-count alone is unsafe for title vocabulary.
  static List<TitleSimilarCluster> buildTitleClusters(
    List<Project> projects, {
    Map<String, Set<String>>? tokenIndex,
  }) {
    if (projects.length < 2) return [];

    final index = tokenIndex ?? buildTitleTokenIndex(projects);
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
      if (rx != ry) parent[rx] = ry;
    }

    for (int i = 0; i < n; i++) {
      final aTokens = index[projects[i].id] ?? const {};
      if (aTokens.isEmpty) continue; // placeholder title — never matches
      for (int j = i + 1; j < n; j++) {
        final bTokens = index[projects[j].id] ?? const {};
        if (bTokens.isEmpty) continue;
        final interCount = aTokens.intersection(bTokens).length;
        if (interCount < minSharedTitleWords) continue;
        final unionCount = aTokens.length + bTokens.length - interCount;
        if (unionCount == 0) continue;
        if (interCount / unionCount >= minTitleJaccard) {
          union(i, j);
        }
      }
    }

    final clusterMap = <int, List<int>>{};
    for (int i = 0; i < n; i++) {
      clusterMap.putIfAbsent(find(i), () => []).add(i);
    }

    final clusters = clusterMap.values
        .where((indices) => indices.length >= 2)
        .map((indices) {
          final members = indices.map((i) => projects[i]).toList(growable: false);
          var intersection = index[members.first.id] ?? const {};
          for (final m in members.skip(1)) {
            intersection = intersection.intersection(index[m.id] ?? const {});
          }
          final sharedWords = intersection.toList()..sort();
          return TitleSimilarCluster(
            projects: members,
            sharedWords: sharedWords,
            impliedCategories: _impliedCategories(members),
          );
        })
        // Same transitivity gap as ProjectSimilarity.buildClusters: union-
        // find only guarantees each PAIR met the threshold, not that any
        // word survives intersection across the whole group — drop a
        // cluster left with no words common to every member.
        .where((c) => c.sharedWords.isNotEmpty)
        .toList()
      ..sort((a, b) => b.projects.length.compareTo(a.projects.length));

    return clusters;
  }

  /// Combines this class's title-based signal with [ProjectSimilarity]'s
  /// category-tag-based signal into ONE set of "N similar" counts, so a
  /// project that only matches via title wording (or only via tech-stack
  /// category) is reflected identically wherever a count drives UI — the
  /// Browse-tab badge and the Unique/Has Similar filter — matching what the
  /// Redundancy Report's two cluster sections already show independently.
  /// Without this, a pair meeting the title-similarity criterion but
  /// sharing fewer than [ProjectSimilarity.minSharedCategoriesForCluster]
  /// categories would appear together in the report's title-cluster section
  /// while each row is still marked "Unique" and hidden by "Has Similar".
  ///
  /// Runs a single combined O(n^2) pass — rather than computing the two
  /// signals' counts separately and summing them — because a pair that
  /// satisfies BOTH signals must still only increment each project's count
  /// once; summing separate counts would double-count such pairs.
  static Map<String, int> computeCombinedSimilarityCounts(
    List<Project> projects, {
    Map<String, Set<String>>? categoryTagIndex,
    Map<String, Set<String>>? titleTokenIndex,
  }) {
    final catIndex =
        categoryTagIndex ?? ProjectSimilarity.buildCategoryTagIndex(projects);
    final titleIndex = titleTokenIndex ?? buildTitleTokenIndex(projects);
    final counts = <String, int>{for (final p in projects) p.id: 0};
    for (int i = 0; i < projects.length; i++) {
      for (int j = i + 1; j < projects.length; j++) {
        final a = projects[i];
        final b = projects[j];
        final tagSimilar = ProjectSimilarity.sharedTagCount(a, b,
                tagIndex: catIndex) >=
            ProjectSimilarity.minSharedCategoriesForCluster;
        final titleSimilar = tagSimilar
            ? false
            : sharedTitleWordCount(a, b, tokenIndex: titleIndex) >=
                    minSharedTitleWords &&
                titleJaccard(a, b, tokenIndex: titleIndex) >= minTitleJaccard;
        if (tagSimilar || titleSimilar) {
          counts[a.id] = (counts[a.id] ?? 0) + 1;
          counts[b.id] = (counts[b.id] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  /// The categories every member's FULL title independently infers to
  /// (via [ProjectSimilarity.titleInferredCategoryTags]), intersected —
  /// i.e. "what topic do all of these titles agree on". Deliberately NOT
  /// computed by joining [sharedWords] and re-running the keyword matcher
  /// on that: the matcher relies on adjacent multi-word phrases ("machine
  /// learning", "intrusion detection"), and an alphabetically-sorted bag
  /// of shared words scrambles that word order, breaking phrase matches
  /// (e.g. sorted "detection intrusion" no longer contains the phrase
  /// "intrusion detection"). Running inference on each member's real,
  /// correctly-ordered title and intersecting avoids that entirely.
  static Set<String> _impliedCategories(List<Project> members) {
    if (members.isEmpty) return const {};
    var result = ProjectSimilarity.titleInferredCategoryTags(members.first);
    for (final m in members.skip(1)) {
      result = result.intersection(ProjectSimilarity.titleInferredCategoryTags(m));
    }
    return result;
  }
}

/// A group of projects whose titles are near-identically worded (see
/// [TitleSimilarity.buildTitleClusters]).
class TitleSimilarCluster {
  final List<Project> projects;
  final List<String> sharedWords;
  final Set<String> impliedCategories;

  const TitleSimilarCluster({
    required this.projects,
    required this.sharedWords,
    required this.impliedCategories,
  });

  int get count => projects.length;
}
