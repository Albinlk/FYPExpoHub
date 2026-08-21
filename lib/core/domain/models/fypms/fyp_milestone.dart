import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_milestone.freezed.dart';
part 'fyp_milestone.g.dart';

@freezed
abstract class FypMilestone with _$FypMilestone {
  const factory FypMilestone({
    required String id,
    required String fypRecordId,
    required String milestoneCode,
    required String milestoneTitle,
    String? description,
    DateTime? targetDate,
    required String status, // 'pending', 'in_progress', 'completed', 'overdue'
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypMilestone;

  factory FypMilestone.fromJson(Map<String, dynamic> json) =>
      _$FypMilestoneFromJson(json);
}