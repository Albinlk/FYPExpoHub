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
      plagiarismReportUrl: json['plagiarismReportUrl'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      referenceCount: (json['referenceCount'] as num?)?.toInt(),
      academicReferenceCount: (json['academicReferenceCount'] as num?)?.toInt(),
      involvesHumanSubjects: json['involvesHumanSubjects'] as bool? ?? false,
      ethicsFormUrl: json['ethicsFormUrl'] as String?,
      endorsedBy: json['endorsedBy'] as String?,
      endorsedAt: json['endorsedAt'] == null
          ? null
          : DateTime.parse(json['endorsedAt'] as String),
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
  'plagiarismReportUrl': instance.plagiarismReportUrl,
  'pageCount': instance.pageCount,
  'referenceCount': instance.referenceCount,
  'academicReferenceCount': instance.academicReferenceCount,
  'involvesHumanSubjects': instance.involvesHumanSubjects,
  'ethicsFormUrl': instance.ethicsFormUrl,
  'endorsedBy': instance.endorsedBy,
  'endorsedAt': instance.endorsedAt?.toIso8601String(),
  'status': instance.status,
  'submittedBy': instance.submittedBy,
  'submittedAt': instance.submittedAt.toIso8601String(),
  'reviewedBy': instance.reviewedBy,
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'reviewComment': instance.reviewComment,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
