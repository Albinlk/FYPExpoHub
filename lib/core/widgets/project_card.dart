import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';
import '../../core/domain/models/project.dart';
import '../widgets/project_cover_image.dart';

/// Standardized project card used across all pages (projects, home, lecturer,
/// lecturer-visits). Cover image on top carrying category and booth, then the
/// title, one meta line and the student names.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.imageHeight,
    this.imageOverlay,
    this.trailingContent,
    this.heroTag,
    this.showStaff = false,
  });

  final Project project;

  /// Navigation callback preserving per-page routing.
  final VoidCallback onTap;

  /// If null the image area expands to fill available height (grid cells).
  /// Provide a fixed height for full-width list rows.
  final double? imageHeight;

  /// Optional overlay rendered at the bottom-right of the image (e.g. visits status chip).
  final Widget? imageOverlay;

  /// Optional trailing chips row rendered below the standard details.
  final Widget? trailingContent;

  /// When set, the cover flies to the detail page's cover (see
  /// projectCoverHeroTag). Only pass it where each project appears once on
  /// screen: two Heroes with one tag in the same route crash.
  final String? heroTag;

  /// Show supervisor / examiner lines. Off for public browsing (the detail
  /// page has them); on where staff assignment is the point (lecturer views).
  final bool showStaff;

  /// Grid layout for cards: fixed row height (not an aspect ratio) so the
  /// cover keeps ~180px at every width instead of shrinking to a sliver
  /// when columns get narrow. [extraBodyHeight] covers staff lines or
  /// trailing chips.
  static SliverGridDelegate gridDelegate(double width, {double extraBodyHeight = 0}) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: width >= 1100 ? 3 : (width >= 768 ? 2 : 1),
      crossAxisSpacing: DesignSystem.spaceMd,
      mainAxisSpacing: DesignSystem.spaceMd,
      mainAxisExtent: 290 + extraBodyHeight,
    );
  }

  String? get _day => project.presentationDay;

  @override
  Widget build(BuildContext context) {
    final detailStyle = DesignSystem.bodySm.copyWith(
      color: DesignSystem.onSurfaceVariant,
      height: 1.3,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      color: project.calonIndustri
          ? DesignSystem.tertiaryContainer.withValues(alpha: 0.15)
          : null,
      surfaceTintColor: project.calonIndustri ? DesignSystem.tertiary : null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageArea(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: DesignSystem.bodyMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildMetaLine(),
                  const SizedBox(height: 4),
                  Text(
                    project.teamDisplayNames.join(', '),
                    style: detailStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showStaff) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Supervisor: ${project.supervisorDisplayName}',
                      style: detailStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.examinerDisplayName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Examiner: ${project.examinerDisplayName}',
                        style: detailStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                  if (trailingContent != null) ...[
                    const SizedBox(height: 8),
                    trailingContent!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _withHero(Widget cover) {
    final tag = heroTag;
    return tag == null ? cover : Hero(tag: tag, child: cover);
  }

  Widget _buildImageArea() {
    final cover = Stack(
      fit: imageHeight == null ? StackFit.expand : StackFit.passthrough,
      children: [
        _withHero(
          ProjectCoverImage(
            title: project.title,
            category: project.category,
            imageUrl: project.coverImageUrl,
            fit: BoxFit.cover,
          ),
        ),
        if (project.calonIndustri)
          Positioned(
            top: 8,
            left: 8,
            child: _chip(
              color: DesignSystem.tertiary,
              icon: Icons.workspace_premium,
              iconColor: Colors.white,
              label: Text(
                'Industry Candidate',
                style: DesignSystem.labelCaps.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: _chip(
            color: Colors.black54,
            label: Text(
              project.category,
              style: DesignSystem.labelCaps.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
        if (project.boothNumber != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: _chip(
              color: DesignSystem.secondaryContainer,
              icon: Icons.room,
              iconColor: DesignSystem.onSecondaryContainer,
              label: Text(
                project.boothNumber!,
                style: DesignSystem.bodySm.copyWith(
                  color: DesignSystem.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        if (imageOverlay != null)
          Positioned(bottom: 8, right: 8, child: imageOverlay!),
      ],
    );

    if (imageHeight != null) {
      return SizedBox(
        height: imageHeight,
        width: double.infinity,
        child: cover,
      );
    }
    return Expanded(child: cover);
  }

  Widget _chip({
    required Color color,
    required Widget label,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
          ],
          label,
        ],
      ),
    );
  }

  /// Programme and presentation day on one line. The booth sits on the
  /// cover, so it isn't repeated here.
  Widget _buildMetaLine() {
    return Text(
      [project.programmeCode, ?_day].join(' • '),
      style: DesignSystem.labelCaps.copyWith(
        color: DesignSystem.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
