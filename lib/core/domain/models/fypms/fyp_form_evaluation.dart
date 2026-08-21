import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_form_evaluation.freezed.dart';
part 'fyp_form_evaluation.g.dart';

@freezed
abstract class FypFormEvaluation with _$FypFormEvaluation {
  const factory FypFormEvaluation({
    required String id,
    required String formSubmissionId,
    String? rubricTemplateId,
    required String evaluatorId,
    required Map<String, dynamic> scores,
    required double weightedTotal,
    String? comments,
    required String status, // 'draft', 'submitted', 'completed'
    DateTime? evaluatedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypFormEvaluation;

  factory FypFormEvaluation.fromJson(Map<String, dynamic> json) =>
      _$FypFormEvaluationFromJson(json);
}