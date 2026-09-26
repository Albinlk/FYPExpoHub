/// A request to change a record's supervisor (`fyp_supervisor_change_requests`),
/// decided by the coordinator (FYP Text Book: only through the coordinator).
class SupervisorChangeRequest {
  const SupervisorChangeRequest({
    required this.id,
    required this.fypRecordId,
    required this.reason,
    required this.status,
    this.currentSupervisorId,
    this.proposedSupervisorId,
    this.decisionComment,
    this.projectTitle,
    this.matricId,
    this.createdAt,
  });

  /// A row, optionally with the embedded `fyp_records` it belongs to.
  factory SupervisorChangeRequest.fromJson(Map<String, dynamic> json) {
    final r = json['fyp_records'];
    final record = r is Map ? Map<String, dynamic>.from(r) : const <String, dynamic>{};
    return SupervisorChangeRequest(
      id: json['id'] as String? ?? '',
      fypRecordId: json['fyp_record_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      currentSupervisorId: json['current_supervisor_id'] as String?,
      proposedSupervisorId: json['proposed_supervisor_id'] as String?,
      decisionComment: json['decision_comment'] as String?,
      projectTitle: record['project_title'] as String?,
      matricId: record['matric_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  final String id;
  final String fypRecordId;
  final String reason;

  /// pending | approved | rejected
  final String status;
  final String? currentSupervisorId;
  final String? proposedSupervisorId;
  final String? decisionComment;
  final String? projectTitle;
  final String? matricId;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';
}

/// A supervisor / examiner nomination awaiting the PU (`list_pending_nominations`).
class PendingNomination {
  const PendingNomination({
    required this.assignmentId,
    required this.fypRecordId,
    required this.academicRole,
    this.lecturerName,
    this.studentName,
    this.matricId,
    this.programmeCode,
    this.courseCode,
    this.projectTitle,
  });

  factory PendingNomination.fromJson(Map<String, dynamic> json) => PendingNomination(
        assignmentId: json['assignment_id'] as String? ?? '',
        fypRecordId: json['fyp_record_id'] as String? ?? '',
        academicRole: json['academic_role'] as String? ?? '',
        lecturerName: json['lecturer_name'] as String?,
        studentName: json['student_name'] as String?,
        matricId: json['matric_id'] as String?,
        programmeCode: json['programme_code'] as String?,
        courseCode: json['course_code'] as String?,
        projectTitle: json['project_title'] as String?,
      );

  final String assignmentId;
  final String fypRecordId;

  /// supervisor | co_supervisor | examiner
  final String academicRole;
  final String? lecturerName;
  final String? studentName;
  final String? matricId;
  final String? programmeCode;
  final String? courseCode;
  final String? projectTitle;

  String get roleLabel => switch (academicRole) {
        'co_supervisor' => 'Co-supervisor',
        'examiner' => 'Examiner',
        _ => 'Supervisor',
      };
}
