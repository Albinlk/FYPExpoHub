import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_supervision_request.freezed.dart';
part 'fyp_supervision_request.g.dart';

@freezed
abstract class FypSupervisionRequest with _$FypSupervisionRequest {
  const factory FypSupervisionRequest({
    required String id,
    required String fypRecordId,
    String? preferredSupervisorId,
    String? rationale,
    required String status, // 'pending', 'approved', 'rejected', 'withdrawn'
    String? decidedBy,
    DateTime? decidedAt,
    String? decisionReason,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypSupervisionRequest;

  factory FypSupervisionRequest.fromJson(Map<String, dynamic> json) =>
      _$FypSupervisionRequestFromJson(json);
}