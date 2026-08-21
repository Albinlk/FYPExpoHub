import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_report_submission.freezed.dart';
part 'fyp_report_submission.g.dart';

@freezed
abstract class FypReportSubmission with _$FypReportSubmission {
  const factory FypReportSubmission({
    required String id,
    required String fypRecordId,
    required String reportType, // 'proposal', 'final'
    required int version,
    required String fileUrl,
    double? similarityIndex,
    required String status, // 'submitted', 'under_review', 'approved', 'rejected'
    String? submittedBy,
    required DateTime submittedAt,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewComment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypReportSubmission;

  factory FypReportSubmission.fromJson(Map<String, dynamic> json) =>
      _$FypReportSubmissionFromJson(json);
}