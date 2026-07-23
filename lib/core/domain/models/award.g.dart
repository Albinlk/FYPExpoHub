// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'award.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AwardCategory _$AwardCategoryFromJson(Map<String, dynamic> json) =>
    _AwardCategory(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      publicationStatus: json['publicationStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$AwardCategoryToJson(_AwardCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'name': instance.name,
      'description': instance.description,
      'publicationStatus': instance.publicationStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

_PublishedAwardWinner _$PublishedAwardWinnerFromJson(
  Map<String, dynamic> json,
) => _PublishedAwardWinner(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  awardCategoryId: json['awardCategoryId'] as String,
  projectId: json['projectId'] as String?,
  projectTitle: json['projectTitle'] as String,
  programmeCode: json['programmeCode'] as String?,
  teamDisplayName: json['teamDisplayName'] as String?,
  supervisorDisplayName: json['supervisorDisplayName'] as String?,
  publicationStatus: json['publicationStatus'] as String,
  sourceImportId: json['sourceImportId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$PublishedAwardWinnerToJson(
  _PublishedAwardWinner instance,
) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'awardCategoryId': instance.awardCategoryId,
  'projectId': instance.projectId,
  'projectTitle': instance.projectTitle,
  'programmeCode': instance.programmeCode,
  'teamDisplayName': instance.teamDisplayName,
  'supervisorDisplayName': instance.supervisorDisplayName,
  'publicationStatus': instance.publicationStatus,
  'sourceImportId': instance.sourceImportId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'publishedAt': instance.publishedAt?.toIso8601String(),
};
