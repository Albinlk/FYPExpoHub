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

    /// Storage path of the original plagiarism report (F6).
    String? plagiarismReportUrl,

    /// Textbook minimums (proposal 30 pages / 15 refs, final 50 / 30; half academic).
    int? pageCount,
    int? referenceCount,
    int? academicReferenceCount,

    /// REC ethics form, required with a proposal involving human subjects.
    @Default(false) bool involvesHumanSubjects,
    String? ethicsFormUrl,
    String? endorsedBy,
    DateTime? endorsedAt,
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