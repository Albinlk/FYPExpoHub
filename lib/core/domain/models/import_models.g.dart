// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportRecord _$ImportRecordFromJson(Map<String, dynamic> json) =>
    _ImportRecord(
      id: json['id'] as String,
      eventId: json['eventId'] as String?,
      sourceFilePath: json['sourceFilePath'] as String,
      sourceFileName: json['sourceFileName'] as String,
      sourceFileHash: json['sourceFileHash'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      parserVersion: json['parserVersion'] as String,
      status: json['status'] as String,
      summary: Map<String, int>.from(json['summary'] as Map),
      warningCounts: Map<String, int>.from(json['warningCounts'] as Map),
      errorSummary: json['errorSummary'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$ImportRecordToJson(_ImportRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'sourceFilePath': instance.sourceFilePath,
      'sourceFileName': instance.sourceFileName,
      'sourceFileHash': instance.sourceFileHash,
      'uploadedBy': instance.uploadedBy,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'parserVersion': instance.parserVersion,
      'status': instance.status,
      'summary': instance.summary,
      'warningCounts': instance.warningCounts,
      'errorSummary': instance.errorSummary,
      'completedAt': instance.completedAt?.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

_EventMetadataCandidate _$EventMetadataCandidateFromJson(
  Map<String, dynamic> json,
) => _EventMetadataCandidate(
  id: json['id'] as String,
  title: json['title'] as String,
  sessionLabel: json['sessionLabel'] as String,
  tentativeDateRange: json['tentativeDateRange'] as String,
);

Map<String, dynamic> _$EventMetadataCandidateToJson(
  _EventMetadataCandidate instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'sessionLabel': instance.sessionLabel,
  'tentativeDateRange': instance.tentativeDateRange,
};

_ScheduleCandidate _$ScheduleCandidateFromJson(Map<String, dynamic> json) =>
    _ScheduleCandidate(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startAt: json['startAt'] as String,
      endAt: json['endAt'] as String,
      title: json['title'] as String,
      venue: json['venue'] as String,
      audience: json['audience'] as String,
      classification: json['classification'] as String,
      comparisonStatus: json['comparisonStatus'] as String,
      isDuplicate: json['isDuplicate'] as bool,
      isOverlapping: json['isOverlapping'] as bool,
    );

Map<String, dynamic> _$ScheduleCandidateToJson(_ScheduleCandidate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'title': instance.title,
      'venue': instance.venue,
      'audience': instance.audience,
      'classification': instance.classification,
      'comparisonStatus': instance.comparisonStatus,
      'isDuplicate': instance.isDuplicate,
      'isOverlapping': instance.isOverlapping,
    };

_AwardCandidate _$AwardCandidateFromJson(Map<String, dynamic> json) =>
    _AwardCandidate(
      id: json['id'] as String,
      awardCategory: json['awardCategory'] as String,
      projectTitle: json['projectTitle'] as String,
      teamDisplayName: json['teamDisplayName'] as String?,
      supervisorDisplayName: json['supervisorDisplayName'] as String?,
      programmeCode: json['programmeCode'] as String?,
      isSkip: json['isSkip'] as bool,
    );

Map<String, dynamic> _$AwardCandidateToJson(_AwardCandidate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'awardCategory': instance.awardCategory,
      'projectTitle': instance.projectTitle,
      'teamDisplayName': instance.teamDisplayName,
      'supervisorDisplayName': instance.supervisorDisplayName,
      'programmeCode': instance.programmeCode,
      'isSkip': instance.isSkip,
    };

_PrivacySkip _$PrivacySkipFromJson(Map<String, dynamic> json) => _PrivacySkip(
  id: json['id'] as String,
  skipType: json['skipType'] as String,
  count: (json['count'] as num).toInt(),
  reason: json['reason'] as String,
  worksheetName: json['worksheetName'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$PrivacySkipToJson(_PrivacySkip instance) =>
    <String, dynamic>{
      'id': instance.id,
      'skipType': instance.skipType,
      'count': instance.count,
      'reason': instance.reason,
      'worksheetName': instance.worksheetName,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_ValidationIssue _$ValidationIssueFromJson(Map<String, dynamic> json) =>
    _ValidationIssue(
      id: json['id'] as String,
      issueType: json['issueType'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      worksheetName: json['worksheetName'] as String,
      rowNumber: (json['rowNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ValidationIssueToJson(_ValidationIssue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'issueType': instance.issueType,
      'severity': instance.severity,
      'message': instance.message,
      'worksheetName': instance.worksheetName,
      'rowNumber': instance.rowNumber,
    };

_ReviewDecision _$ReviewDecisionFromJson(Map<String, dynamic> json) =>
    _ReviewDecision(
      id: json['id'] as String,
      candidateType: json['candidateType'] as String,
      decision: json['decision'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
      editedData: json['editedData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReviewDecisionToJson(_ReviewDecision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'candidateType': instance.candidateType,
      'decision': instance.decision,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'editedData': instance.editedData,
    };
