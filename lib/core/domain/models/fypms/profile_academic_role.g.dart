// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_academic_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileAcademicRole _$ProfileAcademicRoleFromJson(Map<String, dynamic> json) =>
    _ProfileAcademicRole(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      roleCode: json['roleCode'] as String,
      programmeCode: json['programmeCode'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProfileAcademicRoleToJson(
  _ProfileAcademicRole instance,
) => <String, dynamic>{
  'id': instance.id,
  'profileId': instance.profileId,
  'roleCode': instance.roleCode,
  'programmeCode': instance.programmeCode,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
