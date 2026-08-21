// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_milestone_extension.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypMilestoneExtension _$FypMilestoneExtensionFromJson(
  Map<String, dynamic> json,
) => _FypMilestoneExtension(
  id: json['id'] as String,
  milestoneId: json['milestoneId'] as String,
  requestedBy: json['requestedBy'] as String,
  reason: json['reason'] as String?,
  requestedDueDate: json['requestedDueDate'] == null
      ? null
      : DateTime.parse(json['requestedDueDate'] as String),
  status: json['status'] as String,
  decidedBy: json['decidedBy'] as String?,
  decidedAt: json['decidedAt'] == null
      ? null
      : DateTime.parse(json['decidedAt'] as String),
  decisionComment: json['decisionComment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FypMilestoneExtensionToJson(
  _FypMilestoneExtension instance,
) => <String, dynamic>{
  'id': instance.id,
  'milestoneId': instance.milestoneId,
  'requestedBy': instance.requestedBy,
  'reason': instance.reason,
  'requestedDueDate': instance.requestedDueDate?.toIso8601String(),
  'status': instance.status,
  'decidedBy': instance.decidedBy,
  'decidedAt': instance.decidedAt?.toIso8601String(),
  'decisionComment': instance.decisionComment,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
