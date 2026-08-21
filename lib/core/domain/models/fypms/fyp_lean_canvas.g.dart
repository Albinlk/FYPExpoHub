// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_lean_canvas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypLeanCanvas _$FypLeanCanvasFromJson(Map<String, dynamic> json) =>
    _FypLeanCanvas(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      canvasVersion: (json['canvasVersion'] as num).toInt(),
      blocks: json['blocks'] as Map<String, dynamic>,
      isLatest: json['isLatest'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypLeanCanvasToJson(_FypLeanCanvas instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'canvasVersion': instance.canvasVersion,
      'blocks': instance.blocks,
      'isLatest': instance.isLatest,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
