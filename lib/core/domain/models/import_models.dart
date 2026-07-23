import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_models.freezed.dart';
part 'import_models.g.dart';

@freezed
abstract class ImportRecord with _$ImportRecord {
  const factory ImportRecord({
    required String id,
    String? eventId,
    required String sourceFilePath,
    required String sourceFileName,
    required String sourceFileHash,
    required String uploadedBy,
    required DateTime uploadedAt,
    required String parserVersion,
    required String status, // 'processing', 'pending_review', 'completed', 'error', 'cancelled'
    required Map<String, int> summary, // e.g., {'tentatif': 12, 'pemenang': 4}
    required Map<String, int> warningCounts, // e.g., {'overlap': 1, 'privacy': 3}
    String? errorSummary,
    DateTime? completedAt,
    DateTime? publishedAt,
  }) = _ImportRecord;

  factory ImportRecord.fromJson(Map<String, dynamic> json) => _$ImportRecordFromJson(json);
}

@freezed
abstract class EventMetadataCandidate with _$EventMetadataCandidate {
  const factory EventMetadataCandidate({
    required String id,
    required String title,
    required String sessionLabel,
    required String tentativeDateRange,
  }) = _EventMetadataCandidate;

  factory EventMetadataCandidate.fromJson(Map<String, dynamic> json) => _$EventMetadataCandidateFromJson(json);
}

@freezed
abstract class ScheduleCandidate with _$ScheduleCandidate {
  const factory ScheduleCandidate({
    required String id,
    required DateTime date,
    required String startAt,
    required String endAt,
    required String title,
    required String venue,
    required String audience,
    required String classification, // 'publicCandidate', 'internal', 'needsReview', 'invalid', 'duplicateCandidate'
    required String comparisonStatus, // 'new', 'updated', 'unchanged', 'duplicateCandidate', 'invalid', 'skippedForPrivacy'
    required bool isDuplicate,
    required bool isOverlapping,
  }) = _ScheduleCandidate;

  factory ScheduleCandidate.fromJson(Map<String, dynamic> json) => _$ScheduleCandidateFromJson(json);
}

@freezed
abstract class AwardCandidate with _$AwardCandidate {
  const factory AwardCandidate({
    required String id,
    required String awardCategory,
    required String projectTitle,
    String? teamDisplayName,
    String? supervisorDisplayName,
    String? programmeCode,
    required bool isSkip,
  }) = _AwardCandidate;

  factory AwardCandidate.fromJson(Map<String, dynamic> json) => _$AwardCandidateFromJson(json);
}

@freezed
abstract class PrivacySkip with _$PrivacySkip {
  const factory PrivacySkip({
    required String id,
    required String skipType,
    required int count,
    required String reason,
    required String worksheetName,
    required DateTime timestamp,
  }) = _PrivacySkip;

  factory PrivacySkip.fromJson(Map<String, dynamic> json) => _$PrivacySkipFromJson(json);
}

@freezed
abstract class ValidationIssue with _$ValidationIssue {
  const factory ValidationIssue({
    required String id,
    required String issueType, // 'date_conflict', 'unrecognized_worksheet', 'invalid_time', 'missing_title', 'duplicate', 'overlap', 'blank_row'
    required String severity, // 'warning', 'error'
    required String message,
    required String worksheetName,
    int? rowNumber,
  }) = _ValidationIssue;

  factory ValidationIssue.fromJson(Map<String, dynamic> json) => _$ValidationIssueFromJson(json);
}

@freezed
abstract class ReviewDecision with _$ReviewDecision {
  const factory ReviewDecision({
    required String id, // Matches candidate's ID
    required String candidateType, // 'event', 'schedule', 'award'
    required String decision, // 'publish', 'draft', 'mark_internal', 'skip', 'retain_current', 'replace_current'
    required DateTime updatedAt,
    required String updatedBy,
    Map<String, dynamic>? editedData,
  }) = _ReviewDecision;

  factory ReviewDecision.fromJson(Map<String, dynamic> json) => _$ReviewDecisionFromJson(json);
}
