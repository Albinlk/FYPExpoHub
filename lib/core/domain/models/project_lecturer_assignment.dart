import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_lecturer_assignment.freezed.dart';
part 'project_lecturer_assignment.g.dart';

@freezed
abstract class ProjectLecturerAssignment with _$ProjectLecturerAssignment {
  const factory ProjectLecturerAssignment({
    required String id,
    required String eventId,
    required String projectId,
    required String lecturerDisplayName,
    String? lecturerId,
    required String role,
    @Default('active') String status,
    required DateTime assignedAt,
    required DateTime updatedAt,
  }) = _ProjectLecturerAssignment;

  factory ProjectLecturerAssignment.fromJson(Map<String, dynamic> json) =>
      _$ProjectLecturerAssignmentFromJson(json);
}
