import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';

/// Shared FYPMS display helpers: date formatting and status badges.
///
/// Replaces the scattered `toIso8601String().substring(0, 10)` /
/// `'...'.replaceFirst(' 00:00:00', '')` hacks and the raw snake_case
/// status text across FYPMS pages.

/// Formats a date as `dd-MM-yyyy` (local time).
String formatFypDate(DateTime dt) {
  final local = dt.toLocal();
  return '${local.day.toString().padLeft(2, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.year}';
}

/// Formats a date + time as `dd-MM-yyyy HH:mm` (local time).
String formatFypDateTime(DateTime dt) {
  final local = dt.toLocal();
  return '${formatFypDate(local)} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

/// Human label for a snake_case status value.
String fypStatusLabel(String status) => status.replaceAll('_', ' ');

/// Semantic color for the 17 fyp_records.workflow_status values.
Color workflowStatusColor(String status) {
  switch (status) {
    case 'awaiting_supervisor_assignment':
    case 'supervision_requested':
      return DesignSystem.onSurfaceVariant;
    case 'supervision_approved':
    case 'proposal_submitted':
    case 'proposal_reviewed':
    case 'proposal_defended':
      return DesignSystem.tertiary;
    case 'final_report_submitted':
    case 'final_report_reviewed':
    case 'corrections_ongoing':
    case 'corrections_completed':
    case 'project_pending_presentation':
      return DesignSystem.secondary;
    case 'project_completed':
      return const Color(0xFF2E7D32); // success green
    case 'project_archived':
      return DesignSystem.outlineVariant;
    case 'project_registered':
    default:
      return DesignSystem.primary;
  }
}

/// Semantic color for milestone status values.
Color milestoneStatusColor(String status) {
  switch (status) {
    case 'completed':
      return const Color(0xFF2E7D32);
    case 'in_progress':
      return DesignSystem.secondary;
    case 'overdue':
      return DesignSystem.error;
    case 'pending':
    default:
      return DesignSystem.onSurfaceVariant;
  }
}

/// Semantic color for correction status values.
Color correctionStatusColor(String status) {
  switch (status) {
    case 'confirmed':
    case 'closed':
      return DesignSystem.secondary;
    case 'evidence_submitted':
      return DesignSystem.error;
    case 'in_progress':
      return DesignSystem.tertiary;
    case 'open':
    default:
      return DesignSystem.primary;
  }
}

/// Compact colored status badge used across FYPMS pages.
class FypStatusBadge extends StatelessWidget {
  final String status;
  final Color Function(String) colorFor;

  const FypStatusBadge({
    super.key,
    required this.status,
    required this.colorFor,
  });

  /// Badge for the 17 fyp_records workflow statuses.
  const FypStatusBadge.workflow(String status, {super.key})
      : status = status,
        colorFor = workflowStatusColor;

  /// Badge for milestone statuses.
  const FypStatusBadge.milestone(String status, {super.key})
      : status = status,
        colorFor = milestoneStatusColor;

  /// Badge for correction statuses.
  const FypStatusBadge.correction(String status, {super.key})
      : status = status,
        colorFor = correctionStatusColor;

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        fypStatusLabel(status),
        style: DesignSystem.bodySm.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
