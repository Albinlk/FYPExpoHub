import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../domain/title_similarity.dart';
import 'project_row_widget.dart';
import 'redundancy_cluster_widget.dart' show CircleLeading, isCrossCohortCluster;

/// A group of projects flagged as redundant by TITLE wording alone (see
/// [TitleSimilarity.buildTitleClusters]) — a signal separate from and
/// complementary to [RedundancyClusterWidget]'s tag-based clustering.
/// Mirrors that widget's layout/conventions so the two read as one
/// coherent report, just with a distinct accent color so they're never
/// mistaken for each other.
class TitleSimilarClusterWidget extends StatelessWidget {
  final TitleSimilarCluster cluster;
  final Map<String, int> similarityCounts;
  final Map<String, String> idToSection;
  final bool isDesktop;

  const TitleSimilarClusterWidget({
    super.key,
    required this.cluster,
    required this.similarityCounts,
    required this.idToSection,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final crossCohort = isCrossCohortCluster(cluster.projects, idToSection);
    final sharedWordsStr = cluster.sharedWords.join(', ');
    final topicLabel = cluster.impliedCategories.isEmpty
        ? null
        : cluster.impliedCategories.join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      shape: crossCohort
          ? RoundedRectangleBorder(
              borderRadius: DesignSystem.radiusLg,
              side: const BorderSide(color: Colors.orange, width: 1.5),
            )
          : null,
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Similarly worded — ${cluster.count} titles'
              '${topicLabel != null ? ' ($topicLabel)' : ''}',
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                  .copyWith(color: DesignSystem.tertiary),
            ),
            const SizedBox(height: 2),
            Text(
              'Shared title words: $sharedWordsStr',
              style: DesignSystem.bodySm.copyWith(color: DesignSystem.tertiary),
              softWrap: true,
            ),
            if (crossCohort) ...[
              const SizedBox(height: 6),
              Tooltip(
                message:
                    'A junior proposal is worded almost identically to a completed senior project.',
                child: _pill('Cross-cohort overlap'),
              ),
            ],
          ],
        ),
        leading: CircleLeading(count: cluster.count, isDesktop: isDesktop),
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: DesignSystem.surfaceContainer, width: 1),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cluster.projects.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = cluster.projects[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: DesignSystem.spaceMd),
                  child: ProjectRowWidget(
                    project: p,
                    simCount: similarityCounts[p.id] ?? 0,
                    showSection: idToSection.containsKey(p.id),
                    section: idToSection[p.id],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: DesignSystem.radiusFull,
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.compare_arrows, size: 12, color: Colors.orange.shade800),
          const SizedBox(width: 4),
          Text(
            label,
            style: DesignSystem.labelCaps
                .copyWith(color: Colors.orange.shade800, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
