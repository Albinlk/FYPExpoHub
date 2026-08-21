import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_record_assignment.freezed.dart';
part 'fyp_record_assignment.g.dart';

@freezed
abstract class FypRecordAssignment with _$FypRecordAssignment {
  const factory FypRecordAssignment({
    required String id,
    required String fypRecordId,
    required String academicRole, // 'supervisor', 'co_supervisor', 'examiner'
    required String lecturerId,
    required bool isActive,
    String? assignedBy,
    required DateTime assignedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypRecordAssignment;

  factory FypRecordAssignment.fromJson(Map<String, dynamic> json) =>
      _$FypRecordAssignmentFromJson(json);
}