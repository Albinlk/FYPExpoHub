import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_milestone_extension.freezed.dart';
part 'fyp_milestone_extension.g.dart';

@freezed
abstract class FypMilestoneExtension with _$FypMilestoneExtension {
  const factory FypMilestoneExtension({
    required String id,
    required String milestoneId,
    required String requestedBy,
    String? reason,
    DateTime? requestedDueDate,
    required String status, // 'pending', 'approved', 'rejected'
    String? decidedBy,
    DateTime? decidedAt,
    String? decisionComment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypMilestoneExtension;

  factory FypMilestoneExtension.fromJson(Map<String, dynamic> json) =>
      _$FypMilestoneExtensionFromJson(json);
}