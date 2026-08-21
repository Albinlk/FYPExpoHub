// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_presentation_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypPresentationSlot _$FypPresentationSlotFromJson(Map<String, dynamic> json) =>
    _FypPresentationSlot(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      fypRecordId: json['fypRecordId'] as String,
      slotNumber: (json['slotNumber'] as num).toInt(),
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      room: json['room'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypPresentationSlotToJson(
  _FypPresentationSlot instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'fypRecordId': instance.fypRecordId,
  'slotNumber': instance.slotNumber,
  'startAt': instance.startAt.toIso8601String(),
  'endAt': instance.endAt.toIso8601String(),
  'room': instance.room,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
