import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_record.freezed.dart';
part 'fyp_record.g.dart';

@freezed
abstract class FypRecord with _$FypRecord {
  const factory FypRecord({
    required String id,
    required String academicSemesterId,
    required String studentId,
    required String currentCourseCode,
    required String programmeCode,
    String? matricId,
    String? projectTitle,
    String? projectDescription,
    String? projectType,
    String? externalIndustryPartner,
    String? mainSupervisorId,
    String? coSupervisorId,
    String? examinerId,
    String? previousRecordId,
    required String workflowStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypRecord;

  factory FypRecord.fromJson(Map<String, dynamic> json) =>
      _$FypRecordFromJson(json);
}