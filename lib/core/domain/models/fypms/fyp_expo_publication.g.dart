// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_expo_publication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypExpoPublication _$FypExpoPublicationFromJson(Map<String, dynamic> json) =>
    _FypExpoPublication(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      eventId: json['eventId'] as String,
      status: json['status'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      publishedProjectId: json['publishedProjectId'] as String?,
      preparedBy: json['preparedBy'] as String?,
      preparedAt: json['preparedAt'] == null
          ? null
          : DateTime.parse(json['preparedAt'] as String),
      publishedBy: json['publishedBy'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypExpoPublicationToJson(_FypExpoPublication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'eventId': instance.eventId,
      'status': instance.status,
      'payload': instance.payload,
      'publishedProjectId': instance.publishedProjectId,
      'preparedBy': instance.preparedBy,
      'preparedAt': instance.preparedAt?.toIso8601String(),
      'publishedBy': instance.publishedBy,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
