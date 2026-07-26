import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_visit.freezed.dart';
part 'student_visit.g.dart';

@freezed
abstract class StudentVisit with _$StudentVisit {
  const factory StudentVisit({
    required String id,
    required String eventId,
    required String projectId,
    required String assignmentId,
    required String lecturerId,
    required String visitRole,
    String? boothNumberSnapshot,
    String? boothZoneSnapshot,
    required DateTime visitedAt,
    String? visitNote,
    @Default('completed') String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? voidedAt,
    String? voidedBy,
    String? voidReason,
    @Default('lecturer') String source,
  }) = _StudentVisit;

  factory StudentVisit.fromJson(Map<String, dynamic> json) =>
      _$StudentVisitFromJson(json);
}
