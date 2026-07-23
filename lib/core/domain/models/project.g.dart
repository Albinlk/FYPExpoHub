// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  slug: json['slug'] as String,
  title: json['title'] as String,
  matricId: json['matricId'] as String?,
  programmeCode: json['programmeCode'] as String,
  programmeName: json['programmeName'] as String,
  shortDescription: json['shortDescription'] as String,
  category: json['category'] as String,
  technologyTags: (json['technologyTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  boothId: json['boothId'] as String?,
  boothNumber: json['boothNumber'] as String?,
  boothZone: json['boothZone'] as String?,
  coverImageUrl: json['coverImageUrl'] as String,
  posterUrl: json['posterUrl'] as String?,
  teamDisplayNames: (json['teamDisplayNames'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  supervisorDisplayName: json['supervisorDisplayName'] as String,
  examinerDisplayName: json['examinerDisplayName'] as String?,
  demoUrl: json['demoUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  repositoryUrl: json['repositoryUrl'] as String?,
  featured: json['featured'] as bool,
  publicationStatus: json['publicationStatus'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'slug': instance.slug,
  'title': instance.title,
  'matricId': instance.matricId,
  'programmeCode': instance.programmeCode,
  'programmeName': instance.programmeName,
  'shortDescription': instance.shortDescription,
  'category': instance.category,
  'technologyTags': instance.technologyTags,
  'boothId': instance.boothId,
  'boothNumber': instance.boothNumber,
  'boothZone': instance.boothZone,
  'coverImageUrl': instance.coverImageUrl,
  'posterUrl': instance.posterUrl,
  'teamDisplayNames': instance.teamDisplayNames,
  'supervisorDisplayName': instance.supervisorDisplayName,
  'examinerDisplayName': instance.examinerDisplayName,
  'demoUrl': instance.demoUrl,
  'videoUrl': instance.videoUrl,
  'repositoryUrl': instance.repositoryUrl,
  'featured': instance.featured,
  'publicationStatus': instance.publicationStatus,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'publishedAt': instance.publishedAt?.toIso8601String(),
};
