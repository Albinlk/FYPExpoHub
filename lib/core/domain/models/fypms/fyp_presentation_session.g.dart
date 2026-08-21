// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_presentation_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypPresentationSession _$FypPresentationSessionFromJson(
  Map<String, dynamic> json,
) => _FypPresentationSession(
  id: json['id'] as String,
  offeringId: json['offeringId'] as String?,
  sessionCode: json['sessionCode'] as String,
  sessionTitle: json['sessionTitle'] as String,
  eventDate: DateTime.parse(json['eventDate'] as String),
  startAt: DateTime.parse(json['startAt'] as String),
  endAt: DateTime.parse(json['endAt'] as String),
  venue: json['venue'] as String?,
  sessionType: json['sessionType'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FypPresentationSessionToJson(
  _FypPresentationSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'offeringId': instance.offeringId,
  'sessionCode': instance.sessionCode,
  'sessionTitle': instance.sessionTitle,
  'eventDate': instance.eventDate.toIso8601String(),
  'startAt': instance.startAt.toIso8601String(),
  'endAt': instance.endAt.toIso8601String(),
  'venue': instance.venue,
  'sessionType': instance.sessionType,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
