// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_form_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypFormSubmission _$FypFormSubmissionFromJson(Map<String, dynamic> json) =>
    _FypFormSubmission(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      formCode: json['formCode'] as String,
      formVersion: (json['formVersion'] as num).toInt(),
      payload: json['payload'] as Map<String, dynamic>,
      status: json['status'] as String,
      submittedBy: json['submittedBy'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypFormSubmissionToJson(_FypFormSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'formCode': instance.formCode,
      'formVersion': instance.formVersion,
      'payload': instance.payload,
      'status': instance.status,
      'submittedBy': instance.submittedBy,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
