// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_milestone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypMilestone _$FypMilestoneFromJson(Map<String, dynamic> json) =>
    _FypMilestone(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      milestoneCode: json['milestoneCode'] as String,
      milestoneTitle: json['milestoneTitle'] as String,
      description: json['description'] as String?,
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String),
      status: json['status'] as String,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypMilestoneToJson(_FypMilestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'milestoneCode': instance.milestoneCode,
      'milestoneTitle': instance.milestoneTitle,
      'description': instance.description,
      'targetDate': instance.targetDate?.toIso8601String(),
      'status': instance.status,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
