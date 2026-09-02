import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';

/// A compact, collapsible filter panel for mobile layouts.
///
/// Keeps [alwaysVisible] controls (search, primary chips/dropdowns) on one
/// row, hiding the remaining filter controls behind a "Filters" toggle with
/// an active-count badge. Expands/collapses with a smooth animation.
///
/// Desktop layouts should keep their single-row filter bars — this panel is
/// only wired into the mobile branches.
class CollapsibleFilterPanel extends StatelessWidget {
  /// Controls shown on the always-visible header row (e.g. search field).
  final Widget header;

  /// Compact controls shown next to the toggle on the header row
  /// (e.g. section pills). Optional.
  final Widget? headerTrailing;

  /// The collapsible area's controls, laid out in a 2-column grid.
  final List<Widget> filterFields;

  /// How many of the collapsed filters are currently active (non-default).
  final int activeCount;

  /// Whether the collapsible area is expanded.
  final bool expanded;

  /// Toggles [expanded].
  final VoidCallback onToggle;

  /// Optional reset control rendered inside the collapsible area (full-width).
  final Widget? resetControl;

  const CollapsibleFilterPanel({
    super.key,
    required this.header,
    required this.filterFields,
    required this.activeCount,
    required this.expanded,
    required this.onToggle,
    this.headerTrailing,
    this.resetControl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            const SizedBox(height: DesignSystem.spaceSm),
            if (headerTrailing != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: headerTrailing!,
              ),
              const SizedBox(height: DesignSystem.spaceSm),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: _FilterToggle(
                activeCount: activeCount,
                expanded: expanded,
                onPressed: onToggle,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: DesignSystem.spaceSm),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2-column grid: pairs fields row by row; an odd
                          // final field stretches full width.
                          for (var i = 0; i < filterFields.length; i += 2)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i + 2 < filterFields.length
                                    ? DesignSystem.spaceSm
                                    : 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: filterFields[i]),
                                  if (i + 1 < filterFields.length) ...[
                                    const SizedBox(width: DesignSystem.spaceSm),
                                    Expanded(child: filterFields[i + 1]),
                                  ],
                                ],
                              ),
                            ),
                          if (resetControl != null) ...[
                            const SizedBox(height: DesignSystem.spaceSm),
                            SizedBox(width: double.infinity, child: resetControl!),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final int activeCount;
  final bool expanded;
  final VoidCallback onPressed;

  const _FilterToggle({
    required this.activeCount,
    required this.expanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasActive = activeCount > 0;
    return Semantics(
      button: true,
      label: expanded
          ? 'Hide filters'
          : 'Show filters${hasActive ? ' ($activeCount active)' : ''}',
      child: ActionChip(
        onPressed: onPressed,
        avatar: Badge(
          isLabelVisible: hasActive,
          label: Text('$activeCount'),
          backgroundColor: DesignSystem.secondary,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          child: Icon(
            expanded ? Icons.expand_less : Icons.filter_list,
            size: 18,
            color: hasActive
                ? DesignSystem.secondary
                : DesignSystem.onSurfaceVariant,
          ),
        ),
        label: Text(
          hasActive ? 'Filters · $activeCount' : 'Filters',
          style: DesignSystem.bodySm.copyWith(
            color: hasActive
                ? DesignSystem.secondary
                : DesignSystem.onSurfaceVariant,
            fontWeight: hasActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: hasActive
            ? DesignSystem.secondaryContainer.withValues(alpha: 0.25)
            : DesignSystem.surfaceContainerLowest,
        side: BorderSide(
          color: hasActive
              ? DesignSystem.secondaryContainer
              : DesignSystem.outlineVariant,
        ),
      ),
    );
  }
}
