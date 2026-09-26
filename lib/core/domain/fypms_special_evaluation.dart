/// F14 special-evaluation qualification (FYP Text Book, 4th ed.): the CSP650
/// lecturer checks four conditions per student; only a qualified student's
/// F15 / F16 can be submitted and scored.
library;

/// Progress (F9, 10 %) + LMC (F13, 5 %) marks a student needs.
const double kSpecialEvaluationProgressRequired = 7.5;

/// A record's stored F14 decision (`fyp_special_evaluations`).
class SpecialEvaluation {
  const SpecialEvaluation({
    required this.fypRecordId,
    required this.progressLmcMarks,
    required this.chaptersComplete,
    required this.presentedAtExhibition,
    required this.finalSemesterCoursesPassed,
    required this.eligible,
    this.note,
    this.assessedAt,
  });

  factory SpecialEvaluation.fromJson(Map<String, dynamic> json) => SpecialEvaluation(
        fypRecordId: json['fyp_record_id'] as String? ?? '',
        progressLmcMarks: (json['progress_lmc_marks'] as num?)?.toDouble() ?? 0,
        chaptersComplete: json['chapters_complete'] as bool? ?? false,
        presentedAtExhibition: json['presented_at_exhibition'] as bool? ?? false,
        finalSemesterCoursesPassed: json['final_semester_courses_passed'] as bool? ?? false,
        eligible: json['eligible'] as bool? ?? false,
        note: json['note'] as String?,
        assessedAt: DateTime.tryParse(json['assessed_at'] as String? ?? ''),
      );

  final String fypRecordId;
  final double progressLmcMarks;
  final bool chaptersComplete;
  final bool presentedAtExhibition;
  final bool finalSemesterCoursesPassed;
  final bool eligible;
  final String? note;
  final DateTime? assessedAt;

  bool get progressMet => progressLmcMarks >= kSpecialEvaluationProgressRequired;
}

/// What the system can tell about the four checks
/// (`get_special_evaluation_checks`), plus the current decision.
class SpecialEvaluationChecks {
  const SpecialEvaluationChecks({
    required this.progressLmcMarks,
    required this.progressLmcComplete,
    required this.finalReportSubmitted,
    required this.exhibitionVisitRecorded,
    this.assessment,
  });

  factory SpecialEvaluationChecks.fromJson(Map<String, dynamic> json) {
    final a = json['assessment'];
    return SpecialEvaluationChecks(
      progressLmcMarks: (json['progress_lmc_marks'] as num?)?.toDouble() ?? 0,
      progressLmcComplete: json['progress_lmc_complete'] as bool? ?? false,
      finalReportSubmitted: json['final_report_submitted'] as bool? ?? false,
      exhibitionVisitRecorded: json['exhibition_visit_recorded'] as bool? ?? false,
      assessment: a is Map ? SpecialEvaluation.fromJson(Map<String, dynamic>.from(a)) : null,
    );
  }

  final double progressLmcMarks;

  /// Both F9 and F13 have been evaluated (otherwise the figure may rise).
  final bool progressLmcComplete;
  final bool finalReportSubmitted;

  /// A supervisor / examiner visit was recorded at the exhibition.
  final bool exhibitionVisitRecorded;
  final SpecialEvaluation? assessment;

  bool get progressMet => progressLmcMarks >= kSpecialEvaluationProgressRequired;
}
