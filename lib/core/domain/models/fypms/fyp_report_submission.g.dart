// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_report_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypReportSubmission _$FypReportSubmissionFromJson(Map<String, dynamic> json) =>
    _FypReportSubmission(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      reportType: json['reportType'] as String,
      version: (json['version'] as num).toInt(),
      fileUrl: json['fileUrl'] as String,
      similarityIndex: (json['similarityIndex'] as num?)?.toDouble(),
      status: json['status'] as String,
      submittedBy: json['submittedBy'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewComment: json['reviewComment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypReportSubmissionToJson(
  _FypReportSubmission instance,
) => <String, dynamic>{
  'id': instance.id,
  'fypRecordId': instance.fypRecordId,
  'reportType': instance.reportType,
  'version': instance.version,
  'fileUrl': instance.fileUrl,
  'similarityIndex': instance.similarityIndex,
  'status': instance.status,
  'submittedBy': instance.submittedBy,
  'submittedAt': instance.submittedAt.toIso8601String(),
  'reviewedBy': instance.reviewedBy,
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'reviewComment': instance.reviewComment,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
