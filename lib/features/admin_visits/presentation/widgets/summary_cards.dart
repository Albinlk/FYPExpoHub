import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';

class AdminSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AdminSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: DesignSystem.spaceSm),
                Expanded(
                  child: Text(title, style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Text(value, style: DesignSystem.h2.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class SummaryCardsRow extends StatelessWidget {
  final int totalRequired;
  final int completed;
  final int pending;
  final int svCompleted;
  final int svTotal;
  final int exCompleted;
  final int exTotal;
  final int visitedToday;
  final int voided;

  const SummaryCardsRow({
    super.key,
    required this.totalRequired,
    required this.completed,
    required this.pending,
    required this.svCompleted,
    required this.svTotal,
    required this.exCompleted,
    required this.exTotal,
    required this.visitedToday,
    required this.voided,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalRequired > 0 ? (completed / totalRequired * 100).toStringAsFixed(1) : '0.0';
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
        const SizedBox(height: DesignSystem.spaceSm),
        isDesktop
            ? Wrap(
                spacing: DesignSystem.spaceMd,
                runSpacing: DesignSystem.spaceMd,
                children: [
                  SizedBox(width: 180, child: AdminSummaryCard(title: 'Total Visited', value: '$completed / $totalRequired', icon: Icons.assignment, color: DesignSystem.primary)),
                  SizedBox(width: 180, child: AdminSummaryCard(title: 'Not Visited', value: '$pending', icon: Icons.pending, color: DesignSystem.secondary)),
                  SizedBox(width: 180, child: AdminSummaryCard(title: 'Percentage', value: '$pct%', icon: Icons.pie_chart, color: DesignSystem.tertiary)),
                  SizedBox(width: 180, child: AdminSummaryCard(title: 'SV Completed', value: '$svCompleted / $svTotal', icon: Icons.person, color: DesignSystem.primary)),
                  SizedBox(width: 180, child: AdminSummaryCard(title: 'EX Completed', value: '$exCompleted / $exTotal', icon: Icons.person_outline, color: DesignSystem.tertiary)),
                  SizedBox(width: 180, child: AdminSummaryCard(title: 'Today', value: '$visitedToday', icon: Icons.today, color: DesignSystem.secondaryContainer)),
                  SizedBox(width: 180, child: AdminSummaryCard(title: 'Voided', value: '$voided', icon: Icons.cancel, color: DesignSystem.error)),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: AdminSummaryCard(title: 'Total Visited', value: '$completed / $totalRequired', icon: Icons.assignment, color: DesignSystem.primary)),
                      const SizedBox(width: DesignSystem.spaceSm),
                      Expanded(child: AdminSummaryCard(title: 'Not Visited', value: '$pending', icon: Icons.pending, color: DesignSystem.secondary)),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Row(
                    children: [
                      Expanded(child: AdminSummaryCard(title: 'Percentage', value: '$pct%', icon: Icons.pie_chart, color: DesignSystem.tertiary)),
                      const SizedBox(width: DesignSystem.spaceSm),
                      Expanded(child: AdminSummaryCard(title: 'Today', value: '$visitedToday', icon: Icons.today, color: DesignSystem.secondaryContainer)),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Row(
                    children: [
                      Expanded(child: AdminSummaryCard(title: 'SV Completed', value: '$svCompleted / $svTotal', icon: Icons.person, color: DesignSystem.primary)),
                      const SizedBox(width: DesignSystem.spaceSm),
                      Expanded(child: AdminSummaryCard(title: 'EX Completed', value: '$exCompleted / $exTotal', icon: Icons.person_outline, color: DesignSystem.tertiary)),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Row(
                    children: [
                      Expanded(child: AdminSummaryCard(title: 'Voided', value: '$voided', icon: Icons.cancel, color: DesignSystem.error)),
                      const SizedBox(width: DesignSystem.spaceSm),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
      ],
    );
  }
}
