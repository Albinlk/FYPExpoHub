// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_supervision_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypSupervisionRequest _$FypSupervisionRequestFromJson(
  Map<String, dynamic> json,
) => _FypSupervisionRequest(
  id: json['id'] as String,
  fypRecordId: json['fypRecordId'] as String,
  preferredSupervisorId: json['preferredSupervisorId'] as String?,
  preferredCoSupervisorId: json['preferredCoSupervisorId'] as String?,
  projectArea: json['projectArea'] as String?,
  projectTitle: json['projectTitle'] as String?,
  rationale: json['rationale'] as String?,
  status: json['status'] as String,
  decidedBy: json['decidedBy'] as String?,
  decidedAt: json['decidedAt'] == null
      ? null
      : DateTime.parse(json['decidedAt'] as String),
  decisionReason: json['decisionReason'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FypSupervisionRequestToJson(
  _FypSupervisionRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'fypRecordId': instance.fypRecordId,
  'preferredSupervisorId': instance.preferredSupervisorId,
  'preferredCoSupervisorId': instance.preferredCoSupervisorId,
  'projectArea': instance.projectArea,
  'projectTitle': instance.projectTitle,
  'rationale': instance.rationale,
  'status': instance.status,
  'decidedBy': instance.decidedBy,
  'decidedAt': instance.decidedAt?.toIso8601String(),
  'decisionReason': instance.decisionReason,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
