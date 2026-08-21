import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../domain/project_similarity.dart';
import 'project_row_widget.dart';

class RedundancyClusterWidget extends ConsumerWidget {
  final RedundancyCluster cluster;
  final List<Project> allProjects;
  final bool showSection;
  final bool isDesktop;

  const RedundancyClusterWidget({
    super.key,
    required this.cluster,
    required this.allProjects,
    this.showSection = false,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedTagsStr = cluster.sharedTags.join(', ');
    final headerColor = DesignSystem.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
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
                  : 'Shared technology tags',
              style: DesignSystem.bodySm.copyWith(color: headerColor),
              softWrap: true,
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
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: DesignSystem.spaceMd),
                  child: ProjectRowWidget(
                    project: p,
                    allProjects: allProjects,
                    showSection: showSection,
                  ),
                );
              },
            ),
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
