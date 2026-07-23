// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => _AuditLog(
  id: json['id'] as String,
  actorUid: json['actorUid'] as String,
  action: json['action'] as String,
  targetType: json['targetType'] as String,
  targetId: json['targetId'] as String,
  importId: json['importId'] as String?,
  metadataSafe: json['metadataSafe'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AuditLogToJson(_AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'actorUid': instance.actorUid,
  'action': instance.action,
  'targetType': instance.targetType,
  'targetId': instance.targetId,
  'importId': instance.importId,
  'metadataSafe': instance.metadataSafe,
  'createdAt': instance.createdAt.toIso8601String(),
};
