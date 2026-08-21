// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_record_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypRecordAssignment _$FypRecordAssignmentFromJson(Map<String, dynamic> json) =>
    _FypRecordAssignment(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      academicRole: json['academicRole'] as String,
      lecturerId: json['lecturerId'] as String,
      isActive: json['isActive'] as bool,
      assignedBy: json['assignedBy'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypRecordAssignmentToJson(
  _FypRecordAssignment instance,
) => <String, dynamic>{
  'id': instance.id,
  'fypRecordId': instance.fypRecordId,
  'academicRole': instance.academicRole,
  'lecturerId': instance.lecturerId,
  'isActive': instance.isActive,
  'assignedBy': instance.assignedBy,
  'assignedAt': instance.assignedAt.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
