// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_progress_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypProgressLog _$FypProgressLogFromJson(Map<String, dynamic> json) =>
    _FypProgressLog(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      weekNumber: (json['weekNumber'] as num).toInt(),
      progressDate: DateTime.parse(json['progressDate'] as String),
      summary: json['summary'] as String,
      challenges: json['challenges'] as String?,
      nextPlan: json['nextPlan'] as String?,
      status: json['status'] as String,
      submittedBy: json['submittedBy'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      validatedBy: json['validatedBy'] as String?,
      validatedAt: json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
      validationComment: json['validationComment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypProgressLogToJson(_FypProgressLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'weekNumber': instance.weekNumber,
      'progressDate': instance.progressDate.toIso8601String(),
      'summary': instance.summary,
      'challenges': instance.challenges,
      'nextPlan': instance.nextPlan,
      'status': instance.status,
      'submittedBy': instance.submittedBy,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'validatedBy': instance.validatedBy,
      'validatedAt': instance.validatedAt?.toIso8601String(),
      'validationComment': instance.validationComment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
