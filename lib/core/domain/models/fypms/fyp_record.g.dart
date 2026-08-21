// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypRecord _$FypRecordFromJson(Map<String, dynamic> json) => _FypRecord(
  id: json['id'] as String,
  academicSemesterId: json['academicSemesterId'] as String,
  studentId: json['studentId'] as String,
  currentCourseCode: json['currentCourseCode'] as String,
  programmeCode: json['programmeCode'] as String,
  matricId: json['matricId'] as String?,
  projectTitle: json['projectTitle'] as String?,
  projectDescription: json['projectDescription'] as String?,
  projectType: json['projectType'] as String?,
  externalIndustryPartner: json['externalIndustryPartner'] as String?,
  mainSupervisorId: json['mainSupervisorId'] as String?,
  coSupervisorId: json['coSupervisorId'] as String?,
  examinerId: json['examinerId'] as String?,
  previousRecordId: json['previousRecordId'] as String?,
  workflowStatus: json['workflowStatus'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FypRecordToJson(_FypRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'academicSemesterId': instance.academicSemesterId,
      'studentId': instance.studentId,
      'currentCourseCode': instance.currentCourseCode,
      'programmeCode': instance.programmeCode,
      'matricId': instance.matricId,
      'projectTitle': instance.projectTitle,
      'projectDescription': instance.projectDescription,
      'projectType': instance.projectType,
      'externalIndustryPartner': instance.externalIndustryPartner,
      'mainSupervisorId': instance.mainSupervisorId,
      'coSupervisorId': instance.coSupervisorId,
      'examinerId': instance.examinerId,
      'previousRecordId': instance.previousRecordId,
      'workflowStatus': instance.workflowStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
