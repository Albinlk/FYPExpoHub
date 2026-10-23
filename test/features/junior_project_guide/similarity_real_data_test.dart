import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/supabase/row_mappers.dart';
import 'package:fyp_expo_hub/features/junior_project_guide/domain/csp600_csv_loader.dart';
import 'package:fyp_expo_hub/features/junior_project_guide/domain/project_similarity.dart';
import 'package:fyp_expo_hub/features/junior_project_guide/domain/title_similarity.dart';

/// The Past Projects Guide's similarity on the real bundled data (the
/// offline CSP650 catalogue plus the CSP600 proposals CSV), checked against
/// a plain compare-every-pair reference.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Project> corpus;
  late Map<String, Set<String>> categories;
  late Map<String, Set<String>> titles;

  setUpAll(() async {
    final json = jsonDecode(File('assets/data/offline_fallback.json').readAsStringSync())
        as Map<String, dynamic>;
    final csp650 = (json['projects'] as List).cast<Map<String, dynamic>>().map(projectFromRow);
    corpus = [...csp650, ...await Csp600CsvLoader.load()];
    categories = ProjectSimilarity.buildCategoryTagIndex(corpus);
    titles = TitleSimilarity.buildTitleTokenIndex(corpus);
  });

  bool categorySimilar(Project a, Project b) =>
      categories[a.id]!.intersection(categories[b.id]!).length >=
      ProjectSimilarity.minSharedCategoriesForCluster;

  bool titleSimilar(Project a, Project b) {
    final x = titles[a.id]!, y = titles[b.id]!;
    final shared = x.intersection(y).length;
    final union = x.length + y.length - shared;
    return shared >= TitleSimilarity.minSharedTitleWords &&
        union > 0 &&
        shared / union >= TitleSimilarity.minTitleJaccard;
  }

  test('the corpus is the real one', () {
    expect(corpus.length, greaterThan(400));
  });

  test('"N similar" counts match comparing every pair', () {
    final expected = {for (final p in corpus) p.id: 0};
    for (var i = 0; i < corpus.length; i++) {
      for (var j = i + 1; j < corpus.length; j++) {
        if (categorySimilar(corpus[i], corpus[j]) || titleSimilar(corpus[i], corpus[j])) {
          expected[corpus[i].id] = expected[corpus[i].id]! + 1;
          expected[corpus[j].id] = expected[corpus[j].id]! + 1;
        }
      }
    }
    final actual = TitleSimilarity.computeCombinedSimilarityCounts(
      corpus,
      categoryTagIndex: categories,
      titleTokenIndex: titles,
    );
    expect(actual, expected);
  });

  test('every tech-stack match shows up in a report group whose members all '
      'share the listed categories', () {
    final clusters = ProjectSimilarity.buildClusters(
      corpus,
      tagIndex: categories,
      minShared: ProjectSimilarity.minSharedCategoriesForCluster,
    );
    final together = <String>{};
    for (final cluster in clusters) {
      expect(cluster.sharedTags.length,
          greaterThanOrEqualTo(ProjectSimilarity.minSharedCategoriesForCluster));
      for (final p in cluster.projects) {
        expect(categories[p.id], containsAll(cluster.sharedTags));
      }
      for (final a in cluster.projects) {
        for (final b in cluster.projects) {
          together.add('${a.id}|${b.id}');
        }
      }
    }
    for (var i = 0; i < corpus.length; i++) {
      for (var j = i + 1; j < corpus.length; j++) {
        if (categorySimilar(corpus[i], corpus[j])) {
          expect(together, contains('${corpus[i].id}|${corpus[j].id}'),
              reason: '${corpus[i].title} / ${corpus[j].title}');
        }
      }
    }
  });

  test('title groups match transitive grouping of every matching pair', () {
    final n = corpus.length;
    final parent = List<int>.generate(n, (i) => i);
    int find(int x) => parent[x] == x ? x : (parent[x] = find(parent[x]));
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        if (titleSimilar(corpus[i], corpus[j])) parent[find(i)] = find(j);
      }
    }
    final groups = <int, List<String>>{};
    for (var i = 0; i < n; i++) {
      groups.putIfAbsent(find(i), () => []).add(corpus[i].id);
    }
    final expected = groups.values.where((g) => g.length > 1).map((g) => (g..sort()).join(',')).toSet();

    final actual = TitleSimilarity.buildTitleClusters(corpus, tokenIndex: titles)
        .map((c) => (c.projects.map((p) => p.id).toList()..sort()).join(','))
        .toSet();
    expect(actual, expected);
  });
}
