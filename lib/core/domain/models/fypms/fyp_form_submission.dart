import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_form_submission.freezed.dart';
part 'fyp_form_submission.g.dart';

@freezed
abstract class FypFormSubmission with _$FypFormSubmission {
  const factory FypFormSubmission({
    required String id,
    required String fypRecordId,
    required String formCode, // F1-F16
    required int formVersion,
    required Map<String, dynamic> payload,
    required String status, // 'draft', 'submitted', 'under_review', 'approved', 'rejected', 'resubmission_required'
    String? submittedBy,
    DateTime? submittedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypFormSubmission;

  factory FypFormSubmission.fromJson(Map<String, dynamic> json) =>
      _$FypFormSubmissionFromJson(json);
}