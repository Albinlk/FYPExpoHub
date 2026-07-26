// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentVisit _$StudentVisitFromJson(Map<String, dynamic> json) =>
    _StudentVisit(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      projectId: json['projectId'] as String,
      assignmentId: json['assignmentId'] as String,
      lecturerId: json['lecturerId'] as String,
      visitRole: json['visitRole'] as String,
      boothNumberSnapshot: json['boothNumberSnapshot'] as String?,
      boothZoneSnapshot: json['boothZoneSnapshot'] as String?,
      visitedAt: DateTime.parse(json['visitedAt'] as String),
      visitNote: json['visitNote'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      voidedAt: json['voidedAt'] == null
          ? null
          : DateTime.parse(json['voidedAt'] as String),
      voidedBy: json['voidedBy'] as String?,
      voidReason: json['voidReason'] as String?,
      source: json['source'] as String? ?? 'lecturer',
    );

Map<String, dynamic> _$StudentVisitToJson(_StudentVisit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'projectId': instance.projectId,
      'assignmentId': instance.assignmentId,
      'lecturerId': instance.lecturerId,
      'visitRole': instance.visitRole,
      'boothNumberSnapshot': instance.boothNumberSnapshot,
      'boothZoneSnapshot': instance.boothZoneSnapshot,
      'visitedAt': instance.visitedAt.toIso8601String(),
      'visitNote': instance.visitNote,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'voidedAt': instance.voidedAt?.toIso8601String(),
      'voidedBy': instance.voidedBy,
      'voidReason': instance.voidReason,
      'source': instance.source,
    };
