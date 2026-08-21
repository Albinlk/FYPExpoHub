import 'package:freezed_annotation/freezed_annotation.dart';

part 'academic_course.freezed.dart';
part 'academic_course.g.dart';

@freezed
abstract class AcademicCourse with _$AcademicCourse {
  const factory AcademicCourse({
    required String code,
    required String name,
    required String stage, // 'formulation', 'project'
    required int creditHours,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AcademicCourse;

  factory AcademicCourse.fromJson(Map<String, dynamic> json) =>
      _$AcademicCourseFromJson(json);
}