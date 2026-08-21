import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_marks_summary.freezed.dart';
part 'fyp_marks_summary.g.dart';

@freezed
abstract class FypMarksSummary with _$FypMarksSummary {
  const factory FypMarksSummary({
    required String id,
    required String fypRecordId,
    required String academicSemesterId,
    required String courseCode,
    required Map<String, dynamic> marks,
    required double weightedTotal,
    String? grade,
    required bool isFinalized,
    String? finalizedBy,
    DateTime? finalizedAt,
    Map<String, dynamic>? exportPayload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypMarksSummary;

  factory FypMarksSummary.fromJson(Map<String, dynamic> json) =>
      _$FypMarksSummaryFromJson(json);
}