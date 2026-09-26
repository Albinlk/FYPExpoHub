// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_rubric_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypRubricTemplate _$FypRubricTemplateFromJson(Map<String, dynamic> json) =>
    _FypRubricTemplate(
      id: json['id'] as String,
      rubricCode: json['rubricCode'] as String,
      rubricName: json['rubricName'] as String,
      formCode: json['formCode'] as String,
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      evaluatorShares:
          json['evaluatorShares'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      version: (json['version'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypRubricTemplateToJson(_FypRubricTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rubricCode': instance.rubricCode,
      'rubricName': instance.rubricName,
      'formCode': instance.formCode,
      'criteria': instance.criteria,
      'evaluatorShares': instance.evaluatorShares,
      'version': instance.version,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
