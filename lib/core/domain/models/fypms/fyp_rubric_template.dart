import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_rubric_template.freezed.dart';
part 'fyp_rubric_template.g.dart';

@freezed
abstract class FypRubricTemplate with _$FypRubricTemplate {
  const factory FypRubricTemplate({
    required String id,
    required String rubricCode,
    required String rubricName,
    required String formCode,
    required List<Map<String, dynamic>> criteria,

    /// Each evaluator's share of the course grade (textbook mark allocation).
    @Default(<String, dynamic>{}) Map<String, dynamic> evaluatorShares,
    required int version,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypRubricTemplate;

  factory FypRubricTemplate.fromJson(Map<String, dynamic> json) =>
      _$FypRubricTemplateFromJson(json);
}