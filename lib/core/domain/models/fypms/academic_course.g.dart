// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcademicCourse _$AcademicCourseFromJson(Map<String, dynamic> json) =>
    _AcademicCourse(
      code: json['code'] as String,
      name: json['name'] as String,
      stage: json['stage'] as String,
      creditHours: (json['creditHours'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AcademicCourseToJson(_AcademicCourse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'stage': instance.stage,
      'creditHours': instance.creditHours,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
