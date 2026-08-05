import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';
import '../../core/domain/models/project.dart';
import '../widgets/project_cover_image.dart';

/// Standardized project card used across all pages (projects, home, lecturer,
/// lecturer-visits). Matches the `/projects` card style: cover image on top
/// with overlays, full project details below.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.imageHeight,
    this.imageOverlay,
    this.trailingContent,
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

  String? get _day => project.presentationDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: project.calonIndustri ? DesignSystem.tertiaryContainer.withValues(alpha: 0.15) : null,
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
                  Text(
                    project.programmeCode,
                    style: DesignSystem.labelCaps.copyWith(
                      color: DesignSystem.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  if (_day != null) ...[
                    const SizedBox(height: 6),
                    _buildDayChip(),
                  ],
                  const SizedBox(height: 6),
                  if (project.boothNumber != null) ...[
                    Row(
                      children: [
                        Icon(Icons.room, size: 14, color: DesignSystem.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${project.boothNumber}${project.boothZone != null ? ' • ${project.boothZone}' : ''}',
                          style: DesignSystem.bodySm.copyWith(
                            color: DesignSystem.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Student(s): ${project.teamDisplayNames.join(', ')}',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Supervisor: ${project.supervisorDisplayName}',
                    style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (project.examinerDisplayName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Examiner: ${project.examinerDisplayName}',
                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  Widget _buildImageArea() {
    final cover = Stack(
      fit: imageHeight == null ? StackFit.expand : StackFit.passthrough,
      children: [
        ProjectCoverImage(
          title: project.title,
          category: project.category,
          imageUrl: project.coverImageUrl,
          fit: BoxFit.cover,
        ),
        if (project.calonIndustri)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DesignSystem.tertiary,
                borderRadius: DesignSystem.radiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, size: 13, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Industry Candidate',
                    style: DesignSystem.labelCaps.copyWith(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: DesignSystem.radiusSm,
                ),
                child: Text(
                  project.category,
                  style: DesignSystem.labelCaps.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),
              if (project.boothNumber != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: DesignSystem.secondaryContainer,
                    borderRadius: DesignSystem.radiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.room, size: 14, color: DesignSystem.onSecondaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        project.boothNumber!,
                        style: DesignSystem.bodySm.copyWith(
                          color: DesignSystem.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (imageOverlay != null)
          Positioned(bottom: 8, right: 8, child: imageOverlay!),
      ],
    );

    if (imageHeight != null) {
      return SizedBox(height: imageHeight, width: double.infinity, child: cover);
    }
    return Expanded(child: cover);
  }

  Widget _buildDayChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: DesignSystem.secondaryContainer,
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 13, color: DesignSystem.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            _day!,
            style: DesignSystem.labelCaps.copyWith(
              color: DesignSystem.onSecondaryContainer,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}