// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_correction_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypCorrectionItem _$FypCorrectionItemFromJson(Map<String, dynamic> json) =>
    _FypCorrectionItem(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      itemCode: json['itemCode'] as String?,
      description: json['description'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypCorrectionItemToJson(_FypCorrectionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'itemCode': instance.itemCode,
      'description': instance.description,
      'severity': instance.severity,
      'status': instance.status,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
