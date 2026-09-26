import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../domain/csp600_csv_loader.dart';
import '../../domain/project_similarity.dart';

class ProjectRowWidget extends ConsumerWidget {
  final Project project;
  final int simCount;
  final bool showSection;
  final String? section;
  final int? rowIndex; // for alternating stripe

  /// Max pairwise Jaccard similarity (0.0-1.0) against other members of the
  /// same redundancy cluster. Null in the plain Browse tab (keeps today's
  /// simple badge there); non-null when rendered inside a
  /// RedundancyClusterWidget, where it appends a qualitative overlap label.
  final double? strength;

  /// Opens the full list of projects this one was flagged similar to.
  /// Only wired up (and only rendered as tappable) when [simCount] > 0 —
  /// there is nothing to show for a project marked "Unique".
  final VoidCallback? onStatusTap;

  const ProjectRowWidget({
    super.key,
    required this.project,
    required this.simCount,
    this.showSection = false,
    this.section,
    this.rowIndex,
    this.strength,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final isUnique = simCount == 0;
    final bg = (rowIndex != null && rowIndex! % 2 == 1)
        ? DesignSystem.surfaceContainerLow
        : DesignSystem.surfaceContainerLowest;

    return InkWell(
      // CSP600 proposals have no detail page (they only exist in the CSV),
      // so their rows aren't links to a "Project not found" screen.
      onTap: Csp600CsvLoader.isCsp600(project)
          ? null
          : () => context.go('/projects/${project.slug}'),
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
            // Redundancy badge (fixed width) — centered to match the
            // STATUS column header, which is itself centered.
            SizedBox(
              width: 110,
              child: _buildSimilarityBadge(simCount, isUnique, center: true),
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
            ConstrainedBox(
              // Cap the supervisor row so long names ellipsize instead of
              // overflowing the card on narrow screens.
              constraints: const BoxConstraints(maxWidth: 220),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 13, color: DesignSystem.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      project.supervisorDisplayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DesignSystem.bodySm.copyWith(
                        color: DesignSystem.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
                // Cap chip width so a single very long tag wraps instead of
                // overflowing the card on narrow screens.
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withValues(alpha: 0.07),
                  borderRadius: DesignSystem.radiusFull,
                  border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.12), width: 1),
                ),
                child: Text(
                  tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  /// Bands the cluster-relative strength (0.0-1.0 Jaccard) into a short
  /// qualitative suffix. Provisional cutoffs — not yet validated against
  /// the real cohesion-value distribution.
  String? _strengthSuffix() {
    if (strength == null) return null;
    if (strength! >= 0.5) return 'High overlap';
    if (strength! >= 0.25) return 'Medium overlap';
    return 'Low overlap';
  }

  // The pill (Unique / N similar) is its own line, with the qualitative
  // overlap-strength label — when present — stacked as a smaller caption
  // underneath rather than appended onto the same line. Concatenating
  // "N similar · High overlap" into one string forced a long line into the
  // fixed-width STATUS column, which either wrapped mid-word or overflowed;
  // stacking keeps each piece legible at the column's actual width.
  // [center]: true for the desktop table's fixed-width STATUS column (whose
  // header is itself centered — see _buildTableHeader), false (the
  // pre-existing right-aligned look) for the mobile card, where the badge
  // sits inline next to the title rather than in its own column.
  Widget _buildSimilarityBadge(int count, bool isUnique, {bool center = false}) {
    final pill = _buildStatusPill(count, isUnique, center: center);
    final suffix = _strengthSuffix();
    final content = suffix == null
        ? pill
        : Column(
            crossAxisAlignment:
                center ? CrossAxisAlignment.center : CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              pill,
              const SizedBox(height: 3),
              Text(
                suffix,
                style: DesignSystem.labelCaps.copyWith(
                  color: DesignSystem.onSurfaceVariant,
                  fontSize: 8,
                ),
              ),
            ],
          );

    if (isUnique || onStatusTap == null) return content;
    return InkWell(
      onTap: onStatusTap,
      borderRadius: DesignSystem.radiusSm,
      child: content,
    );
  }

  Widget _buildStatusPill(int count, bool isUnique, {bool center = false}) {
    final alignment =
        center ? MainAxisAlignment.center : MainAxisAlignment.end;
    if (isUnique) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: DesignSystem.radiusSm,
          border: Border.all(color: Colors.green.shade200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: alignment,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesignSystem.errorContainer,
        borderRadius: DesignSystem.radiusSm,
        border: Border.all(color: DesignSystem.error, width: 1),
      ),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Icon(Icons.warning_amber, size: 12, color: DesignSystem.error),
          const SizedBox(width: 4),
          Text(
            '$count similar',
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
