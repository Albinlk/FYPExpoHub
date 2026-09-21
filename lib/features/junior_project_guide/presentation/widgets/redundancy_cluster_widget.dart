import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../domain/project_similarity.dart';
import 'project_row_widget.dart';

/// Whether [cluster] spans more than one section (e.g. CSP650 and CSP600)
/// — the highest-value signal this report can show, since it means a
/// junior's proposed topic overlaps with a completed senior project.
/// A free function (not a widget method) so it's usable from both this
/// widget and the page's cluster-sorting logic, and unit-testable without
/// Flutter widget-test infra.
bool isCrossCohortCluster(
  RedundancyCluster cluster,
  Map<String, String> idToSection,
) {
  final sections = cluster.projects
      .map((p) => idToSection[p.id])
      .whereType<String>()
      .toSet();
  return sections.length > 1;
}

class RedundancyClusterWidget extends ConsumerWidget {
  final RedundancyCluster cluster;
  final Map<String, int> similarityCounts;
  final Map<String, Set<String>> categoryTagIndex;
  final Map<String, String> idToSection;
  final bool isDesktop;

  const RedundancyClusterWidget({
    super.key,
    required this.cluster,
    required this.similarityCounts,
    required this.categoryTagIndex,
    required this.idToSection,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedTagsStr = cluster.sharedTags.join(', ');
    final headerColor = DesignSystem.primary;
    final crossCohort = isCrossCohortCluster(cluster, idToSection);
    final cohesion = ProjectSimilarity.clusterCohesion(
      cluster.projects,
      tagIndex: categoryTagIndex,
    );

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
              'Cluster — ${cluster.count} projects share: $sharedTagsStr',
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                  .copyWith(color: DesignSystem.primary),
            ),
            const SizedBox(height: 2),
            Text(
              sharedTagsStr.isEmpty
                  ? 'No common tags across all members'
                  : 'Shared technology categories',
              style: DesignSystem.bodySm.copyWith(color: headerColor),
              softWrap: true,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (crossCohort)
                  Tooltip(
                    message:
                        'A junior proposal overlaps with a completed senior project.',
                    child: _pill(
                      'Cross-cohort overlap',
                      icon: Icons.compare_arrows,
                      color: Colors.orange.shade800,
                      background: Colors.orange.shade50,
                      border: Colors.orange.shade200,
                    ),
                  ),
                Tooltip(
                  message: '${(cohesion * 100).round()}% average tag overlap',
                  child: _pill(
                    _cohesionLabel(cohesion),
                    icon: Icons.donut_large,
                    color: DesignSystem.onSurfaceVariant,
                    background: DesignSystem.surfaceContainer,
                    border: DesignSystem.outlineVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: CircleLeading(
          count: cluster.count,
          isDesktop: isDesktop,
        ),
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
                final strength = _maxPairwiseStrength(p);
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: DesignSystem.spaceMd),
                  child: ProjectRowWidget(
                    project: p,
                    simCount: similarityCounts[p.id] ?? 0,
                    showSection: idToSection.containsKey(p.id),
                    section: idToSection[p.id],
                    strength: strength,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Max pairwise Jaccard similarity of [p] against the other members of
  /// this (small) cluster — cheap, since clusters are single-digit in size.
  double _maxPairwiseStrength(Project p) {
    var max = 0.0;
    for (final other in cluster.projects) {
      if (other.id == p.id) continue;
      final s = ProjectSimilarity.jaccardSimilarity(
        p,
        other,
        tagIndex: categoryTagIndex,
      );
      if (s > max) max = s;
    }
    return max;
  }

  String _cohesionLabel(double cohesion) {
    if (cohesion >= 0.5) return 'High overlap';
    if (cohesion >= 0.25) return 'Medium overlap';
    return 'Low overlap';
  }

  Widget _pill(
    String label, {
    required IconData icon,
    required Color color,
    required Color background,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: DesignSystem.radiusFull,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: DesignSystem.labelCaps.copyWith(color: color, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class CircleLeading extends StatelessWidget {
  final int count;
  final bool isDesktop;

  const CircleLeading({super.key, required this.count, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: DesignSystem.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile).copyWith(
            color: DesignSystem.onSecondaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 18 : 16,
          ),
        ),
      ),
    );
  }
}
