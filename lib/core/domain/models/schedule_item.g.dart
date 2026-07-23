// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleItem _$ScheduleItemFromJson(Map<String, dynamic> json) =>
    _ScheduleItem(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      date: DateTime.parse(json['date'] as String),
      startAt: json['startAt'] as String,
      endAt: json['endAt'] as String,
      title: json['title'] as String,
      venue: json['venue'] as String,
      audience: json['audience'] as String,
      description: json['description'] as String?,
      visibility: json['visibility'] as String,
      publicationStatus: json['publicationStatus'] as String,
      sourceImportId: json['sourceImportId'] as String?,
      sourceStagingId: json['sourceStagingId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$ScheduleItemToJson(_ScheduleItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'date': instance.date.toIso8601String(),
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'title': instance.title,
      'venue': instance.venue,
      'audience': instance.audience,
      'description': instance.description,
      'visibility': instance.visibility,
      'publicationStatus': instance.publicationStatus,
      'sourceImportId': instance.sourceImportId,
      'sourceStagingId': instance.sourceStagingId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };
