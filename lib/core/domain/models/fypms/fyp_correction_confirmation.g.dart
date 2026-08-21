// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_correction_confirmation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypCorrectionConfirmation _$FypCorrectionConfirmationFromJson(
  Map<String, dynamic> json,
) => _FypCorrectionConfirmation(
  id: json['id'] as String,
  correctionItemId: json['correctionItemId'] as String,
  confirmedBy: json['confirmedBy'] as String,
  confirmedAt: DateTime.parse(json['confirmedAt'] as String),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FypCorrectionConfirmationToJson(
  _FypCorrectionConfirmation instance,
) => <String, dynamic>{
  'id': instance.id,
  'correctionItemId': instance.correctionItemId,
  'confirmedBy': instance.confirmedBy,
  'confirmedAt': instance.confirmedAt.toIso8601String(),
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
