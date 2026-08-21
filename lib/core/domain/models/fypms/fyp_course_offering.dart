import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_course_offering.freezed.dart';
part 'fyp_course_offering.g.dart';

@freezed
abstract class FypCourseOffering with _$FypCourseOffering {
  const factory FypCourseOffering({
    required String id,
    required String academicSemesterId,
    required String courseCode,
    String? lecturerId,
    required bool isActive,
    int? maxStudents,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypCourseOffering;

  factory FypCourseOffering.fromJson(Map<String, dynamic> json) =>
      _$FypCourseOfferingFromJson(json);
}