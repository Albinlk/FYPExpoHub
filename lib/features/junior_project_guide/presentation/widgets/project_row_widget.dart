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
  final int? rowIndex; // for alternating stripe

  const ProjectRowWidget({
    super.key,
    required this.project,
    required this.allProjects,
    this.showSection = false,
    this.section,
    this.rowIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final simCount = ProjectSimilarity.similarCount(project, allProjects);
    final isUnique = simCount == 0;
    final bg = (rowIndex != null && rowIndex! % 2 == 1)
        ? DesignSystem.surfaceContainerLow
        : DesignSystem.surfaceContainerLowest;

    return InkWell(
      onTap: () => context.go('/projects/${project.slug}'),
      borderRadius: DesignSystem.radiusLg,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: DesignSystem.radiusLg,
          border: Border.all(color: DesignSystem.surfaceContainer, width: 1),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 12 : 14,
          horizontal: isDesktop ? 12 : 14,
        ),
        child: isDesktop
            ? _buildDesktopRow(simCount, isUnique)
            : _buildMobileRow(simCount, isUnique),
      ),
    );
  }

  // ── Desktop: 5 aligned columns with consistent typography ──
  Widget _buildDesktopRow(int simCount, bool isUnique) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Section pill
            if (showSection && section != null)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: section == 'CSP650'
                      ? DesignSystem.secondaryContainer
                      : DesignSystem.tertiaryContainer,
                  borderRadius: DesignSystem.radiusFull,
                ),
                child: Text(
                  section!,
                  style: DesignSystem.labelCaps.copyWith(
                    color: section == 'CSP650'
                        ? DesignSystem.onSecondaryContainer
                        : DesignSystem.onTertiaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
            // Title + category
            Expanded(
              flex: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: DesignSystem.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: DesignSystem.primary,
                      height: 1.35,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DesignSystem.primary.withValues(alpha: 0.06),
                          borderRadius: DesignSystem.radiusSm,
                        ),
                        child: Text(
                          project.category,
                          style: DesignSystem.labelCaps.copyWith(
                            color: DesignSystem.primary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          project.teamDisplayNames.join(', '),
                          style: DesignSystem.bodySm.copyWith(
                            color: DesignSystem.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Supervisor
            Expanded(
              flex: 18,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: DesignSystem.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline, size: 12, color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      project.supervisorDisplayName,
                      style: DesignSystem.bodySm.copyWith(
                        color: DesignSystem.onBackground,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Programme
            SizedBox(
              width: 88,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: DesignSystem.surfaceContainer,
                  borderRadius: DesignSystem.radiusFull,
                  border: Border.all(color: DesignSystem.outlineVariant, width: 0.6),
                ),
                child: Text(
                  project.programmeCode,
                  style: DesignSystem.labelCaps.copyWith(
                    color: DesignSystem.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tech tags (effective — handles legacy ["FYP"] placeholder)
            Expanded(
              flex: 28,
              child: Builder(builder: (context) {
                final tags = ProjectSimilarity.displayTags(project);
                return Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    ...tags.take(3).map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: DesignSystem.primary.withValues(alpha: 0.07),
                          borderRadius: DesignSystem.radiusFull,
                          border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.12), width: 1),
                        ),
                        child: Text(
                          tag,
                          style: DesignSystem.labelCaps.copyWith(
                            color: DesignSystem.primary,
                            fontSize: 9,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    if (tags.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: DesignSystem.surfaceContainer,
                          borderRadius: DesignSystem.radiusFull,
                        ),
                        child: Text(
                          '+${tags.length - 3}',
                          style: DesignSystem.labelCaps.copyWith(
                            color: DesignSystem.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(width: 12),
            // Redundancy badge (fixed width)
            SizedBox(
              width: 110,
              child: _buildSimilarityBadge(simCount, isUnique),
            ),
          ],
        ),
      ],
    );
  }

  // ── Mobile: compact card hierarchy ──
  Widget _buildMobileRow(int simCount, bool isUnique) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                project.title,
                style: DesignSystem.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DesignSystem.primary,
                  height: 1.35,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            _buildSimilarityBadge(simCount, isUnique),
          ],
        ),
        const SizedBox(height: 8),
        // Supervisor + programme + section
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 13, color: DesignSystem.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  project.supervisorDisplayName,
                  style: DesignSystem.bodySm.copyWith(
                    color: DesignSystem.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: DesignSystem.surfaceContainer,
                borderRadius: DesignSystem.radiusFull,
              ),
              child: Text(
                project.programmeCode,
                style: DesignSystem.labelCaps.copyWith(
                  color: DesignSystem.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
            if (showSection && section != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: section == 'CSP650'
                      ? DesignSystem.secondaryContainer
                      : DesignSystem.tertiaryContainer,
                  borderRadius: DesignSystem.radiusFull,
                ),
                child: Text(
                  section!,
                  style: DesignSystem.labelCaps.copyWith(
                    color: section == 'CSP650'
                        ? DesignSystem.onSecondaryContainer
                        : DesignSystem.onTertiaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: DesignSystem.primary.withValues(alpha: 0.06),
                borderRadius: DesignSystem.radiusSm,
              ),
              child: Text(
                project.category,
                style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary, fontSize: 9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tech tags (effective)
        Builder(builder: (context) {
          final tags = ProjectSimilarity.displayTags(project);
          return Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withValues(alpha: 0.07),
                  borderRadius: DesignSystem.radiusFull,
                  border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.12), width: 1),
                ),
                child: Text(
                  tag,
                  style: DesignSystem.labelCaps.copyWith(
                    color: DesignSystem.primary,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          );
        }),
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
