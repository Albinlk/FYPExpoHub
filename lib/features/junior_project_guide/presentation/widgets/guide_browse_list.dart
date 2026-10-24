import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../guide_filter_values.dart';
import 'project_row_widget.dart';

/// "CSP650: N projects  CSP600: N proposals" under the Browse filters, or a
/// one-line note when nothing matches.
class GuideSectionSummary extends StatelessWidget {
  const GuideSectionSummary({super.key, required this.visible, required this.isDesktop});

  final List<SectionedProject> visible;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final csp650Count = visible.where((sp) => sp.section == 'CSP650').length;
    final csp600Count = visible.where((sp) => sp.section == 'CSP600').length;

    final padding = EdgeInsets.symmetric(
      horizontal:
          isDesktop ? DesignSystem.marginDesktop : DesignSystem.marginMobile,
      vertical: 8,
    );

    if (csp650Count == 0 && csp600Count == 0) {
      return Padding(
        padding: padding,
        child: Text(
          'No projects match your filters.',
          style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (csp650Count > 0)
            _summaryBadge('CSP650', csp650Count, DesignSystem.secondaryContainer,
                DesignSystem.onSecondaryContainer, 'projects'),
          if (csp600Count > 0)
            _summaryBadge('CSP600', csp600Count, DesignSystem.tertiaryContainer,
                DesignSystem.onTertiaryContainer, 'proposals'),
        ],
      ),
    );
  }

  Widget _summaryBadge(
    String label,
    int count,
    Color bg,
    Color fg,
    String noun,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Text(
        '$label: $count $noun',
        style: DesignSystem.labelCaps.copyWith(
          color: fg,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// The Browse tab's slivers: a column header (desktop) and one row per
/// [visible] project, or an empty state when the filters match nothing.
/// [onOpenSimilar] is the STATUS badge's "N similar" tap action.
List<Widget> guideBrowseSlivers({
  required List<SectionedProject> visible,
  required Map<String, int> similarityCounts,
  required bool isDesktop,
  required void Function(Project project) onOpenSimilar,
}) {
  if (visible.isEmpty) {
    return [
      SliverFillRemaining(hasScrollBody: false, child: _GuideEmptyState(isDesktop: isDesktop)),
    ];
  }

  final padding = isDesktop
      ? DesignSystem.marginDesktop
      : DesignSystem.marginMobile;

  return [
    if (isDesktop) SliverToBoxAdapter(child: _GuideTableHeader(horizontalPadding: padding)),
    SliverPadding(
      padding: EdgeInsets.only(
        left: padding,
        right: padding,
        bottom: DesignSystem.spaceLg,
        top: isDesktop ? 8 : 4,
      ),
      sliver: SliverList.separated(
        itemCount: visible.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final sp = visible[index];
          final simCount = similarityCounts[sp.project.id] ?? 0;
          return ProjectRowWidget(
            project: sp.project,
            simCount: simCount,
            showSection: true,
            section: sp.section,
            rowIndex: index,
            onStatusTap: simCount > 0 ? () => onOpenSimilar(sp.project) : null,
          );
        },
      ),
    ),
  ];
}

class _GuideTableHeader extends StatelessWidget {
  const _GuideTableHeader({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    // Mirrors the flex ratios in ProjectRowWidget._buildDesktopRow
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainer,
        borderRadius: DesignSystem.radiusLg,
        border: Border.all(color: DesignSystem.outlineVariant, width: 0.7),
      ),
      child: Row(
        children: [
          const SizedBox(width: 56), // offset for section pill
          Expanded(
            flex: 34,
            child: _headerLabel('PROJECT TITLE', Icons.article_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 18,
            child: _headerLabel('SUPERVISOR', Icons.person_outline),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: _headerLabel('PROGRAMME', Icons.school_outlined, center: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 28,
            child: _headerLabel('TECH STACK', Icons.memory_outlined),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: _headerLabel('STATUS', Icons.verified_outlined, center: true),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(String text, IconData icon, {bool center = false}) {
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: DesignSystem.onSurfaceVariant),
        const SizedBox(width: 4),
        // Narrow fixed columns (PROGRAMME is 88px) shrink the label rather
        // than overflow.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              style: DesignSystem.labelCaps.copyWith(
                color: DesignSystem.onSurfaceVariant,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
    return center ? Center(child: label) : label;
  }
}

class _GuideEmptyState extends StatelessWidget {
  const _GuideEmptyState({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 64,
              color: DesignSystem.outlineVariant,
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Text(
              'No Projects Found',
              textAlign: TextAlign.center,
              style: (isDesktop ? DesignSystem.h3 : DesignSystem.h3Mobile)
                  .copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your search keywords or reset filters.',
              textAlign: TextAlign.center,
              style: DesignSystem.bodySm.copyWith(
                color: DesignSystem.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
