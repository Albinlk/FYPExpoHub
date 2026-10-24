import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../domain/project_similarity.dart';
import '../../domain/title_similarity.dart';
import 'redundancy_cluster_widget.dart';
import 'title_similar_cluster_widget.dart';

/// Cross-cohort clusters (a CSP600 proposal overlapping a completed CSP650
/// project) are the highest-value signal the report can show — they sort
/// ahead of same-cohort clusters; ties fall back to size, largest first.
int _crossCohortFirst(
  List<Project> a,
  int aCount,
  List<Project> b,
  int bCount,
  Map<String, String> idToSection,
) {
  final aCross = isCrossCohortCluster(a, idToSection) ? 1 : 0;
  final bCross = isCrossCohortCluster(b, idToSection) ? 1 : 0;
  final cross = bCross - aCross;
  return cross != 0 ? cross : bCount.compareTo(aCount);
}

/// Groups of projects sharing 2+ technology categories, cross-cohort first.
/// The O(n^2) pass the page caches until the project lists change.
List<RedundancyCluster> buildGuideTagClusters(
  List<Project> projList,
  Map<String, Set<String>> categoryTagIndex,
  Map<String, String> idToSection,
) {
  // buildClusters already sorts by size descending; this is a stable
  // secondary key on top of that.
  return ProjectSimilarity.buildClusters(
    projList,
    tagIndex: categoryTagIndex,
    minShared: ProjectSimilarity.minSharedCategoriesForCluster,
  )..sort((a, b) => _crossCohortFirst(a.projects, a.count, b.projects, b.count, idToSection));
}

/// Groups of projects with near-identical titles, cross-cohort first.
/// Title-based redundancy is a separate signal from tag/category overlap —
/// two projects can be worded almost identically while sharing zero tags,
/// or share tags while being worded completely differently.
List<TitleSimilarCluster> buildGuideTitleClusters(
  List<Project> projList,
  Map<String, Set<String>> titleTokenIndex,
  Map<String, String> idToSection,
) {
  return TitleSimilarity.buildTitleClusters(
    projList,
    tokenIndex: titleTokenIndex,
  )..sort((a, b) => _crossCohortFirst(a.projects, a.count, b.projects, b.count, idToSection));
}

/// The Redundancy Report tab's slivers: one section per kind of cluster, or
/// a "No Redundant Clusters Found" state.
List<Widget> guideReportSlivers({
  required List<RedundancyCluster> tagClusters,
  required List<TitleSimilarCluster> titleClusters,
  required Map<String, int> similarityCounts,
  required Map<String, Set<String>> categoryTagIndex,
  required Map<String, String> idToSection,
  required bool isDesktop,
}) {
  if (tagClusters.isEmpty && titleClusters.isEmpty) {
    return [SliverFillRemaining(hasScrollBody: false, child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop
              ? DesignSystem.marginDesktop
              : DesignSystem.marginMobile,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: DesignSystem.outlineVariant,
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(
              'No Redundant Clusters Found',
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                  .copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'No groups of projects share 2+ technology categories or '
              'near-identical titles.',
              style: DesignSystem.bodyMd
                  .copyWith(color: DesignSystem.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ))];
  }

  final padding = isDesktop
      ? DesignSystem.marginDesktop
      : DesignSystem.marginMobile;

  return [SliverPadding(
    padding: EdgeInsets.symmetric(
      horizontal: padding,
      vertical: DesignSystem.spaceLg,
    ),
    sliver: SliverList.list(children: [
      if (tagClusters.isNotEmpty) ...[
        GuideReportSectionHeader(
          title: 'Similar by Tech Stack',
          subtitle: '${tagClusters.length} ${tagClusters.length == 1 ? 'group shares' : 'groups share'} 2+ technology categories',
          isDesktop: isDesktop,
        ),
        const SizedBox(height: DesignSystem.spaceSm),
        for (final cluster in tagClusters)
          RedundancyClusterWidget(
            cluster: cluster,
            similarityCounts: similarityCounts,
            categoryTagIndex: categoryTagIndex,
            idToSection: idToSection,
            isDesktop: isDesktop,
          ),
        const SizedBox(height: DesignSystem.spaceMd),
      ],
      if (titleClusters.isNotEmpty) ...[
        GuideReportSectionHeader(
          title: 'Similar by Project Title',
          subtitle: '${titleClusters.length} ${titleClusters.length == 1 ? 'group has' : 'groups have'} near-identical wording',
          isDesktop: isDesktop,
        ),
        const SizedBox(height: DesignSystem.spaceSm),
        for (final cluster in titleClusters)
          TitleSimilarClusterWidget(
            cluster: cluster,
            similarityCounts: similarityCounts,
            idToSection: idToSection,
            isDesktop: isDesktop,
          ),
      ],
    ]),
  )];
}

/// A report section's title and one-line count.
class GuideReportSectionHeader extends StatelessWidget {
  const GuideReportSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDesktop,
  });

  final String title;
  final String subtitle;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (isDesktop ? DesignSystem.h2 : DesignSystem.h2Mobile)
                .copyWith(color: DesignSystem.primary),
          ),
          Text(
            subtitle,
            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
