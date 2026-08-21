import 'package:freezed_annotation/freezed_annotation.dart';

part 'academic_semester.freezed.dart';
part 'academic_semester.g.dart';

@freezed
abstract class AcademicSemester with _$AcademicSemester {
  const factory AcademicSemester({
    required String id,
    required String code,
    required String label,
    required String status, // 'planned', 'active', 'completed', 'archived'
    required DateTime startDate,
    required DateTime endDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AcademicSemester;

  factory AcademicSemester.fromJson(Map<String, dynamic> json) =>
      _$AcademicSemesterFromJson(json);
}