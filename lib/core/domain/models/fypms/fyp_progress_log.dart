import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_progress_log.freezed.dart';
part 'fyp_progress_log.g.dart';

@freezed
abstract class FypProgressLog with _$FypProgressLog {
  const factory FypProgressLog({
    required String id,
    required String fypRecordId,
    required int weekNumber,
    required DateTime progressDate,
    required String summary,
    String? challenges,
    String? nextPlan,
    required String status, // 'draft', 'submitted', 'validated', 'rejected'
    String? submittedBy,
    DateTime? submittedAt,
    String? validatedBy,
    DateTime? validatedAt,
    String? validationComment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypProgressLog;

  factory FypProgressLog.fromJson(Map<String, dynamic> json) =>
      _$FypProgressLogFromJson(json);
}