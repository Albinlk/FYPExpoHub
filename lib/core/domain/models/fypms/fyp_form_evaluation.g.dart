// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_form_evaluation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypFormEvaluation _$FypFormEvaluationFromJson(Map<String, dynamic> json) =>
    _FypFormEvaluation(
      id: json['id'] as String,
      formSubmissionId: json['formSubmissionId'] as String,
      rubricTemplateId: json['rubricTemplateId'] as String?,
      evaluatorId: json['evaluatorId'] as String,
      scores: json['scores'] as Map<String, dynamic>,
      weightedTotal: (json['weightedTotal'] as num).toDouble(),
      comments: json['comments'] as String?,
      status: json['status'] as String,
      evaluatedAt: json['evaluatedAt'] == null
          ? null
          : DateTime.parse(json['evaluatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypFormEvaluationToJson(_FypFormEvaluation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'formSubmissionId': instance.formSubmissionId,
      'rubricTemplateId': instance.rubricTemplateId,
      'evaluatorId': instance.evaluatorId,
      'scores': instance.scores,
      'weightedTotal': instance.weightedTotal,
      'comments': instance.comments,
      'status': instance.status,
      'evaluatedAt': instance.evaluatedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
