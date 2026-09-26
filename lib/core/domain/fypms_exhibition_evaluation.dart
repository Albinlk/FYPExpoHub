import '../utils/fypms_key_normalizer.dart';
import 'models/fypms/fyp_form_submission.dart';

/// What `get_exhibition_evaluation` says about an Expo project for the
/// signed-in lecturer: whether it came from FYPMS, the lecturer's evaluator
/// role on that record, and the F10 (or F15, for a student qualified on F14)
/// they score at the exhibition.
class ExhibitionEvaluation {
  const ExhibitionEvaluation({
    required this.linked,
    this.fypRecordId,
    this.evaluatorRole,
    this.formCode,
    this.submission,
    this.myWeightedTotal,
  });

  static const unlinked = ExhibitionEvaluation(linked: false);

  factory ExhibitionEvaluation.fromJson(Map<String, dynamic> json) {
    final sub = json['submission'];
    return ExhibitionEvaluation(
      linked: json['linked'] as bool? ?? false,
      fypRecordId: json['fyp_record_id'] as String?,
      evaluatorRole: json['evaluator_role'] as String?,
      formCode: json['form_code'] as String?,
      submission: sub is Map
          ? FypFormSubmission.fromJson(normalizeFypmsKeys(Map<String, dynamic>.from(sub)))
          : null,
      myWeightedTotal: (json['my_weighted_total'] as num?)?.toDouble(),
    );
  }

  /// The project was published from an FYPMS record.
  final bool linked;
  final String? fypRecordId;

  /// supervisor | examiner — null when the lecturer does not evaluate it.
  final String? evaluatorRole;

  /// F10, or F15 when the student qualified for special evaluation.
  final String? formCode;
  final FypFormSubmission? submission;

  /// The lecturer's own score (percentage), null until they score.
  final double? myWeightedTotal;

  bool get canScore => linked && evaluatorRole != null && formCode != null;
}
