// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_deliverable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypDeliverable _$FypDeliverableFromJson(Map<String, dynamic> json) =>
    _FypDeliverable(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      deliverableType: json['deliverableType'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['fileUrl'] as String?,
      version: (json['version'] as num).toInt(),
      isRequired: json['isRequired'] as bool,
      submittedBy: json['submittedBy'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypDeliverableToJson(_FypDeliverable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'deliverableType': instance.deliverableType,
      'title': instance.title,
      'description': instance.description,
      'fileUrl': instance.fileUrl,
      'version': instance.version,
      'isRequired': instance.isRequired,
      'submittedBy': instance.submittedBy,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
