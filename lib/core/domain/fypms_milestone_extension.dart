/// A student's request to move a milestone's target date
/// (`fyp_milestone_extensions`), decided by the CSP lecturer or coordinator.
class FypMilestoneExtension {
  const FypMilestoneExtension({
    required this.id,
    required this.milestoneId,
    required this.reason,
    required this.requestedDueDate,
    required this.status,
    this.milestoneCode,
    this.milestoneTitle,
    this.decisionComment,
    this.decidedAt,
    this.createdAt,
  });

  /// A row, optionally with the embedded `fyp_milestones` it belongs to.
  factory FypMilestoneExtension.fromJson(Map<String, dynamic> json) {
    final m = json['fyp_milestones'];
    final milestone = m is Map ? Map<String, dynamic>.from(m) : const <String, dynamic>{};
    return FypMilestoneExtension(
      id: json['id'] as String? ?? '',
      milestoneId: json['milestone_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      requestedDueDate: DateTime.tryParse(json['requested_due_date'] as String? ?? '') ?? DateTime(1970),
      status: json['status'] as String? ?? 'pending',
      milestoneCode: milestone['milestone_code'] as String?,
      milestoneTitle: milestone['milestone_title'] as String?,
      decisionComment: json['decision_comment'] as String?,
      decidedAt: DateTime.tryParse(json['decided_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  final String id;
  final String milestoneId;
  final String reason;
  final DateTime requestedDueDate;

  /// pending | approved | rejected
  final String status;
  final String? milestoneCode;
  final String? milestoneTitle;
  final String? decisionComment;
  final DateTime? decidedAt;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';
}

/// A presentation slot with its session (`fyp_presentation_slots` +
/// embedded `fyp_presentation_sessions`), for the student's own schedule.
class FypScheduledPresentation {
  const FypScheduledPresentation({
    required this.slotNumber,
    required this.startAt,
    required this.endAt,
    this.room,
    this.sessionCode,
    this.sessionTitle,
    this.sessionType,
    this.venue,
  });

  factory FypScheduledPresentation.fromJson(Map<String, dynamic> json) {
    final s = json['fyp_presentation_sessions'];
    final session = s is Map ? Map<String, dynamic>.from(s) : const <String, dynamic>{};
    return FypScheduledPresentation(
      slotNumber: (json['slot_number'] as num?)?.toInt() ?? 0,
      startAt: DateTime.tryParse(json['start_at'] as String? ?? '') ?? DateTime(1970),
      endAt: DateTime.tryParse(json['end_at'] as String? ?? '') ?? DateTime(1970),
      room: json['room'] as String?,
      sessionCode: session['session_code'] as String?,
      sessionTitle: session['session_title'] as String?,
      sessionType: session['session_type'] as String?,
      venue: session['venue'] as String?,
    );
  }

  final int slotNumber;
  final DateTime startAt;
  final DateTime endAt;
  final String? room;
  final String? sessionCode;
  final String? sessionTitle;

  /// defence | expo
  final String? sessionType;
  final String? venue;
}
