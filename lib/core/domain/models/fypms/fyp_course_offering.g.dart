// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_course_offering.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypCourseOffering _$FypCourseOfferingFromJson(Map<String, dynamic> json) =>
    _FypCourseOffering(
      id: json['id'] as String,
      academicSemesterId: json['academicSemesterId'] as String,
      courseCode: json['courseCode'] as String,
      lecturerId: json['lecturerId'] as String?,
      isActive: json['isActive'] as bool,
      maxStudents: (json['maxStudents'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypCourseOfferingToJson(_FypCourseOffering instance) =>
    <String, dynamic>{
      'id': instance.id,
      'academicSemesterId': instance.academicSemesterId,
      'courseCode': instance.courseCode,
      'lecturerId': instance.lecturerId,
      'isActive': instance.isActive,
      'maxStudents': instance.maxStudents,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
