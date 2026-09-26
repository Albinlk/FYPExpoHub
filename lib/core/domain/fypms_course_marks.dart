/// A record's course marks as computed by `compute_fyp_course_marks`: each
/// evaluator's share of the grade times their evaluation percentage.
class CourseMarks {
  const CourseMarks({
    required this.courseCode,
    required this.total,
    required this.allocated,
    required this.grade,
    required this.complete,
    required this.components,
    required this.missing,
  });

  factory CourseMarks.fromJson(Map<String, dynamic> json) => CourseMarks(
        courseCode: json['course_code'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0,
        allocated: (json['allocated'] as num?)?.toDouble() ?? 0,
        grade: json['grade'] as String?,
        complete: json['complete'] as bool? ?? false,
        components: [
          for (final c in (json['components'] as List? ?? const []))
            MarkComponent.fromJson(Map<String, dynamic>.from(c as Map)),
        ],
        missing: [
          for (final c in (json['missing'] as List? ?? const []))
            MarkComponent.fromJson(Map<String, dynamic>.from(c as Map)),
        ],
      );

  final String courseCode;

  /// Sum of contributions, 0–100.
  final double total;

  /// Sum of all shares for the course (100 when the allocation is complete).
  final double allocated;
  final String? grade;

  /// Every share has at least one evaluation, so marks can be finalized.
  final bool complete;
  final List<MarkComponent> components;
  final List<MarkComponent> missing;
}

/// One evaluator's share of one form (optionally one CLO group).
class MarkComponent {
  const MarkComponent({
    required this.formCode,
    required this.role,
    required this.share,
    this.clo,
    this.percent,
    this.contribution,
    this.evaluations = 0,
    this.reason,
  });

  factory MarkComponent.fromJson(Map<String, dynamic> json) => MarkComponent(
        formCode: json['form_code'] as String? ?? '',
        role: json['role'] as String? ?? '',
        share: (json['share'] as num?)?.toDouble() ?? 0,
        clo: json['clo'] as String?,
        percent: (json['percent'] as num?)?.toDouble(),
        contribution: (json['contribution'] as num?)?.toDouble(),
        evaluations: (json['evaluations'] as num?)?.toInt() ?? 0,
        reason: json['reason'] as String?,
      );

  final String formCode;

  /// lecturer | supervisor | examiner | coordinator
  final String role;
  final double share;
  final String? clo;

  /// Average evaluation percentage for this role (null when missing).
  final double? percent;

  /// share × percent ÷ 100 (null when missing).
  final double? contribution;
  final int evaluations;

  /// For missing components: `no_submission` or `not_evaluated`.
  final String? reason;

  /// e.g. "F11 CLO1 · Supervisor"
  String get label {
    final who = role == 'lecturer' ? 'Course lecturer' : '${role[0].toUpperCase()}${role.substring(1)}';
    return '${[formCode, ?clo].join(' ')} · $who';
  }
}
