// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_semester.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcademicSemester _$AcademicSemesterFromJson(Map<String, dynamic> json) =>
    _AcademicSemester(
      id: json['id'] as String,
      code: json['code'] as String,
      label: json['label'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AcademicSemesterToJson(_AcademicSemester instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'label': instance.label,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
