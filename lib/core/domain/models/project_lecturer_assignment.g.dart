// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_lecturer_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectLecturerAssignment _$ProjectLecturerAssignmentFromJson(
  Map<String, dynamic> json,
) => _ProjectLecturerAssignment(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  projectId: json['projectId'] as String,
  lecturerDisplayName: json['lecturerDisplayName'] as String,
  lecturerId: json['lecturerId'] as String?,
  role: json['role'] as String,
  status: json['status'] as String? ?? 'active',
  assignedAt: DateTime.parse(json['assignedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProjectLecturerAssignmentToJson(
  _ProjectLecturerAssignment instance,
) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'projectId': instance.projectId,
  'lecturerDisplayName': instance.lecturerDisplayName,
  'lecturerId': instance.lecturerId,
  'role': instance.role,
  'status': instance.status,
  'assignedAt': instance.assignedAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
