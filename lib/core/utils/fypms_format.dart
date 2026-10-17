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

/// Friendly labels for the 17 fyp_records.workflow_status values plus the
/// `withdrawn` / `incomplete` hold states (fyp_records_workflow_status_check).
const kWorkflowStatusLabels = <String, String>{
  'awaiting_supervisor_assignment': 'Awaiting supervisor',
  'supervision_requested': 'Supervision requested',
  'supervision_approved': 'Supervisor assigned',
  'formulation_in_progress': 'Formulation in progress',
  'proposal_submitted': 'Proposal submitted',
  'proposal_under_review': 'Proposal under review',
  'proposal_revision_required': 'Proposal revision required',
  'proposal_approved': 'Proposal approved',
  'formulation_completed': 'Formulation completed',
  'project_registered': 'Project registered',
  'project_ongoing': 'Project in progress',
  'final_report_submitted': 'Final report submitted',
  'final_report_under_review': 'Final report under review',
  'final_report_approved': 'Final report approved',
  'project_pending_presentation': 'Awaiting presentation',
  'project_completed': 'Completed',
  'project_archived': 'Archived',
  'withdrawn': 'Withdrawn',
  'incomplete': 'Incomplete',
};

/// Friendly labels for fyp_supervision_requests.status. Matches what the
/// supervisor sees on the request card (Accepted / Declined).
const kSupervisionRequestStatusLabels = <String, String>{
  'pending': 'Awaiting decision',
  'approved': 'Accepted',
  'rejected': 'Declined',
  'withdrawn': 'Withdrawn',
};

/// Friendly labels for fyp_form_submissions.status.
const kFormStatusLabels = <String, String>{
  'draft': 'Draft',
  'submitted': 'Submitted',
  'under_review': 'Under review',
  'approved': 'Approved',
  'rejected': 'Rejected',
  'resubmission_required': 'Resubmission required',
};

/// Friendly labels for fyp_correction_items.status.
const kCorrectionStatusLabels = <String, String>{
  'open': 'Open',
  'in_progress': 'In progress',
  'evidence_submitted': 'Evidence submitted',
  'confirmed': 'Confirmed',
  'closed': 'Closed',
};

/// Friendly labels for fyp_milestones.status.
const kMilestoneStatusLabels = <String, String>{
  'pending': 'Pending',
  'in_progress': 'In progress',
  'completed': 'Completed',
  'overdue': 'Overdue',
};

/// Friendly labels for fyp_progress_logs.status (F5).
const kProgressLogStatusLabels = <String, String>{
  'draft': 'Draft',
  'submitted': 'Submitted',
  'validated': 'Validated',
  'rejected': 'Rejected',
};

/// Sentence-case fallback for a snake_case value nobody mapped yet.
String _humanise(String value) {
  final spaced = value.replaceAll('_', ' ').trim();
  if (spaced.isEmpty) return spaced;
  return spaced[0].toUpperCase() + spaced.substring(1);
}

/// Label for a fyp_records.workflow_status value.
String workflowStatusLabel(String status) => kWorkflowStatusLabels[status] ?? _humanise(status);

/// Label for a fyp_supervision_requests.status value.
String supervisionRequestStatusLabel(String status) =>
    kSupervisionRequestStatusLabels[status] ?? _humanise(status);

/// Label for a fyp_form_submissions.status value.
String formStatusLabel(String status) => kFormStatusLabels[status] ?? _humanise(status);

/// Label for a fyp_progress_logs.status value.
String progressLogStatusLabel(String status) => kProgressLogStatusLabels[status] ?? _humanise(status);

/// Human label for any FYPMS status value (workflow, form, correction,
/// milestone or progress log). The tables agree wherever a value is shared;
/// supervision requests use [supervisionRequestStatusLabel] because their
/// `approved` / `rejected` read as Accepted / Declined.
String fypStatusLabel(String status) =>
    kWorkflowStatusLabels[status] ??
    kFormStatusLabels[status] ??
    kCorrectionStatusLabels[status] ??
    kMilestoneStatusLabels[status] ??
    kProgressLogStatusLabels[status] ??
    _humanise(status);

/// Semantic color for the fyp_records.workflow_status values.
Color workflowStatusColor(String status) {
  switch (status) {
    case 'awaiting_supervisor_assignment':
    case 'supervision_requested':
      return DesignSystem.onSurfaceVariant;
    case 'supervision_approved':
    case 'formulation_in_progress':
    case 'proposal_submitted':
    case 'proposal_under_review':
    case 'proposal_revision_required':
    case 'proposal_approved':
    case 'formulation_completed':
      return DesignSystem.tertiary;
    case 'final_report_submitted':
    case 'final_report_under_review':
    case 'final_report_approved':
    case 'project_pending_presentation':
      return DesignSystem.secondary;
    case 'project_completed':
      return const Color(0xFF2E7D32); // success green
    case 'project_archived':
      return DesignSystem.onSurfaceVariant;
    case 'withdrawn':
      return DesignSystem.error;
    case 'incomplete':
      return DesignSystem.tertiary;
    case 'project_registered':
    case 'project_ongoing':
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
  const FypStatusBadge.workflow(this.status, {super.key})
      : colorFor = workflowStatusColor;

  /// Badge for milestone statuses.
  const FypStatusBadge.milestone(this.status, {super.key})
      : colorFor = milestoneStatusColor;

  /// Badge for correction statuses.
  const FypStatusBadge.correction(this.status, {super.key})
      : colorFor = correctionStatusColor;

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

/// Plain name for a presentation session type.
String sessionTypeLabel(String type) => switch (type) {
      'defence' => 'Presentation / Defence',
      'progress' => 'Progress Presentation (F9)',
      'expo' => 'Exhibition',
      _ => type,
    };
