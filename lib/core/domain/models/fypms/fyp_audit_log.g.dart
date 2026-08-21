// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypAuditLog _$FypAuditLogFromJson(Map<String, dynamic> json) => _FypAuditLog(
  id: json['id'] as String,
  actorUid: json['actorUid'] as String?,
  actorRole: json['actorRole'] as String?,
  action: json['action'] as String,
  targetType: json['targetType'] as String,
  targetId: json['targetId'] as String?,
  metadataSafe: json['metadataSafe'] as Map<String, dynamic>,
  source: json['source'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FypAuditLogToJson(_FypAuditLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actorUid': instance.actorUid,
      'actorRole': instance.actorRole,
      'action': instance.action,
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'metadataSafe': instance.metadataSafe,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
    };
