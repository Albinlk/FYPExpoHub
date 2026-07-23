// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booth _$BoothFromJson(Map<String, dynamic> json) => _Booth(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  boothNumber: json['boothNumber'] as String,
  zone: json['zone'] as String,
  locationNote: json['locationNote'] as String,
  staticFloorPlanUrl: json['staticFloorPlanUrl'] as String?,
  projectId: json['projectId'] as String?,
  publicationStatus: json['publicationStatus'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$BoothToJson(_Booth instance) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'boothNumber': instance.boothNumber,
  'zone': instance.zone,
  'locationNote': instance.locationNote,
  'staticFloorPlanUrl': instance.staticFloorPlanUrl,
  'projectId': instance.projectId,
  'publicationStatus': instance.publicationStatus,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'publishedAt': instance.publishedAt?.toIso8601String(),
};
