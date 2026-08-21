import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../domain/project_similarity.dart';

class ProjectRowWidget extends ConsumerWidget {
  final Project project;
  final List<Project> allProjects;
  final bool showSection;
  final String? section;

  const ProjectRowWidget({
    super.key,
    required this.project,
    required this.allProjects,
    this.showSection = false,
    this.section,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final simCount = ProjectSimilarity.similarCount(project, allProjects);
    final isUnique = simCount == 0;

    return InkWell(
      onTap: () => context.go('/projects/${project.slug}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: isDesktop
            ? _buildDesktopRow(simCount, isUnique)
            : _buildMobileRow(simCount, isUnique),
      ),
    );
  }

  Widget _buildDesktopRow(int simCount, bool isUnique) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSection && section != null)
              Container(
                margin: const EdgeInsets.only(right: 8, top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: section == 'CSP650'
                      ? DesignSystem.secondaryContainer
                      : DesignSystem.tertiaryContainer,
                  borderRadius: DesignSystem.radiusSm,
                ),
                child: Text(
                  section!,
                  style: DesignSystem.labelCaps.copyWith(
                    color: section == 'CSP650'
                        ? DesignSystem.onSecondaryContainer
                        : DesignSystem.onTertiaryContainer,
                    fontSize: 9,
                  ),
                ),
              ),
            Expanded(
              flex: 3,
              child: Text(
                project.title,
                style: DesignSystem.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.primary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                project.supervisorDisplayName,
                style: DesignSystem.bodySm
                    .copyWith(color: DesignSystem.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                project.programmeCode,
                style: DesignSystem.bodySm
                    .copyWith(color: DesignSystem.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: project.technologyTags.take(4).map<Widget>((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: DesignSystem.surfaceContainer,
                      borderRadius: DesignSystem.radiusSm,
                    ),
                    child: Text(
                      tag,
                      style: DesignSystem.labelCaps.copyWith(
                        color: DesignSystem.onSurfaceVariant,
                        fontSize: 9,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList()
                  ..addAll(
                    project.technologyTags.length > 4
                        ? [
                            Text(
                              '+${project.technologyTags.length - 4} more',
                              style: DesignSystem.bodySm.copyWith(
                                color: DesignSystem.onSurfaceVariant,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          ]
                        : [],
                  ),
              ),
            ),
            SizedBox(
              width: 120,
              child: _buildSimilarityBadge(simCount, isUnique),
            ),
          ],
        ),
        if (project.shortDescription.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              project.shortDescription,
              style: DesignSystem.bodySm.copyWith(
                color: DesignSystem.onSurfaceVariant,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildMobileRow(int simCount, bool isUnique) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                project.title,
                style: DesignSystem.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.primary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildSimilarityBadge(simCount, isUnique),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${project.supervisorDisplayName} \u2022 ${project.programmeCode}',
          style: DesignSystem.bodySm
              .copyWith(color: DesignSystem.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 2,
          children: project.technologyTags.map((tag) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: DesignSystem.surfaceContainer,
                borderRadius: DesignSystem.radiusSm,
              ),
              child: Text(
                tag,
                style: DesignSystem.labelCaps.copyWith(
                  color: DesignSystem.onSurfaceVariant,
                  fontSize: 9,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
        ),
        if (showSection && section != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              section!,
              style: DesignSystem.labelCaps.copyWith(
                color: section == 'CSP650'
                    ? DesignSystem.onSecondaryContainer
                    : DesignSystem.onTertiaryContainer,
                fontSize: 9,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSimilarityBadge(int count, bool isUnique) {
    if (isUnique) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: DesignSystem.radiusSm,
          border: Border.all(color: Colors.green.shade200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.check_circle,
                size: 12, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Unique',
              style: DesignSystem.labelCaps.copyWith(
                color: Colors.green.shade700,
                fontSize: 9,
              ),
            ),
          ],
        ),
      );
    }
    final label = '$count similar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesignSystem.errorContainer,
        borderRadius: DesignSystem.radiusSm,
        border: Border.all(color: DesignSystem.error, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.warning_amber, size: 12, color: DesignSystem.error),
          const SizedBox(width: 4),
          Text(
            label,
            style: DesignSystem.labelCaps.copyWith(
              color: DesignSystem.error,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
