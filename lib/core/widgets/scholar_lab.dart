import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// "Scholar + Lab" building blocks (see DESIGN.md): graph paper behind
/// heroes, numbered section headers, mono stats and code tags, and the
/// FYP Expo Hub wordmark.

/// A faint engineering-paper grid behind [child]. Heroes and empty states
/// only, never behind body text.
class GraphPaper extends StatelessWidget {
  const GraphPaper({super.key, required this.child, this.cell = 24, this.color = DesignSystem.background});

  final Widget child;
  final double cell;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(cell: cell, background: color),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.cell, required this.background});

  final double cell;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final line = Paint()
      ..color = DesignSystem.gridLine
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.cell != cell || old.background != background;
}

/// "01  Featured projects ────────  View all →": a mono number in
/// terracotta, a serif title, a hairline rule and an optional action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.number, required this.title, this.action});

  final String number;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(number, style: DesignSystem.kicker.copyWith(color: DesignSystem.secondary, fontSize: 14)),
          const SizedBox(width: DesignSystem.spaceMd),
          Flexible(
            child: Text(
              title,
              style: (isDesktop ? DesignSystem.h2 : DesignSystem.h2Mobile).copyWith(color: DesignSystem.primary),
            ),
          ),
          const SizedBox(width: DesignSystem.spaceMd),
          const Expanded(child: Divider(color: DesignSystem.rule, thickness: 1, height: 1)),
          if (action != null) ...[
            const SizedBox(width: DesignSystem.spaceMd),
            action!,
          ],
        ],
      ),
    );
  }
}

/// A big mono number with a mono label above it.
class StatBlock extends StatelessWidget {
  const StatBlock({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: DesignSystem.kicker.copyWith(color: DesignSystem.onSurfaceVariant)),
          const SizedBox(height: DesignSystem.spaceSm),
          Text(value, style: (isDesktop ? DesignSystem.stat : DesignSystem.statMobile).copyWith(color: DesignSystem.primary)),
        ],
      ),
    );
  }
}

/// A mono chip for codes: booth BK1-07, programme CS266, form F6b.
class CodeTag extends StatelessWidget {
  const CodeTag(this.text, {super.key, this.icon, this.winner = false});

  final String text;
  final IconData? icon;

  /// Apricot "winner" variant.
  final bool winner;

  @override
  Widget build(BuildContext context) {
    final fg = winner ? DesignSystem.onSecondaryContainer : DesignSystem.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceSm, vertical: 3),
      decoration: BoxDecoration(
        color: winner ? DesignSystem.secondaryContainer : DesignSystem.surfaceContainerLow,
        borderRadius: DesignSystem.radiusSm,
        border: Border.all(color: winner ? DesignSystem.secondaryContainer : DesignSystem.rule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: DesignSystem.spaceXs),
          ],
          Text(text, style: DesignSystem.code.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// The wordmark: serif "FYP" with a small mono "EXPO·HUB" (and an optional
/// subtitle, e.g. "Workspace · CSP600 · CSP650").
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.color = DesignSystem.primary, this.subtitle});

  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FYP Expo Hub',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('FYP', style: DesignSystem.h1Mobile.copyWith(fontSize: 26, color: color, height: 1)),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXPO·HUB', style: DesignSystem.kicker.copyWith(color: DesignSystem.secondary, fontSize: 11)),
              if (subtitle != null)
                Text(subtitle!, style: DesignSystem.kicker.copyWith(color: color.withValues(alpha: 0.75), fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
