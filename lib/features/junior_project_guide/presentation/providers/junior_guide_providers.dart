import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/state/state_providers.dart';
import '../../domain/csp600_csv_loader.dart';
import '../../domain/project_similarity.dart';
import '../../domain/title_similarity.dart';

final csp600ProposalsProvider = FutureProvider<List<Project>>((ref) async {
  return await Csp600CsvLoader.load();
});

/// Every project the guide compares: published CSP650 projects plus the
/// CSP600 CSV proposals (empty until/unless the CSV loads).
final juniorGuideCorpusProvider = Provider<List<Project>>((ref) {
  final csp650 = ref.watch(publicProjectsProvider);
  final csp600 =
      ref.watch(csp600ProposalsProvider).asData?.value ?? const <Project>[];
  return [...csp650, ...csp600];
});

final _guideIndicesProvider =
    Provider<(Map<String, Set<String>>, Map<String, Set<String>>)>((ref) {
  final corpus = ref.watch(juniorGuideCorpusProvider);
  return (
    ProjectSimilarity.buildCategoryTagIndex(corpus),
    TitleSimilarity.buildTitleTokenIndex(corpus),
  );
});

/// The project with [projectId] and everything flagged similar to it, by
/// the same test the Browse tab's "N similar" count uses. `null` data means
/// the id doesn't exist; loading while the CSP600 CSV is still loading.
final similarProjectsProvider = Provider.family<
    AsyncValue<(Project, List<SimilarProjectMatch>)?>, String>((ref, projectId) {
  final csp600 = ref.watch(csp600ProposalsProvider);
  final corpus = ref.watch(juniorGuideCorpusProvider);
  final target = corpus.where((p) => p.id == projectId).firstOrNull;
  if (target == null) {
    return csp600.isLoading || corpus.isEmpty
        ? const AsyncValue.loading()
        : const AsyncValue.data(null);
  }
  final (categoryIndex, titleIndex) = ref.watch(_guideIndicesProvider);
  return AsyncValue.data((
    target,
    TitleSimilarity.findCombinedSimilar(
      target,
      corpus,
      categoryTagIndex: categoryIndex,
      titleTokenIndex: titleIndex,
    ),
  ));
});
