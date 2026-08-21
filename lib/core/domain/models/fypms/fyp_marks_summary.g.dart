// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fyp_marks_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FypMarksSummary _$FypMarksSummaryFromJson(Map<String, dynamic> json) =>
    _FypMarksSummary(
      id: json['id'] as String,
      fypRecordId: json['fypRecordId'] as String,
      academicSemesterId: json['academicSemesterId'] as String,
      courseCode: json['courseCode'] as String,
      marks: json['marks'] as Map<String, dynamic>,
      weightedTotal: (json['weightedTotal'] as num).toDouble(),
      grade: json['grade'] as String?,
      isFinalized: json['isFinalized'] as bool,
      finalizedBy: json['finalizedBy'] as String?,
      finalizedAt: json['finalizedAt'] == null
          ? null
          : DateTime.parse(json['finalizedAt'] as String),
      exportPayload: json['exportPayload'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FypMarksSummaryToJson(_FypMarksSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fypRecordId': instance.fypRecordId,
      'academicSemesterId': instance.academicSemesterId,
      'courseCode': instance.courseCode,
      'marks': instance.marks,
      'weightedTotal': instance.weightedTotal,
      'grade': instance.grade,
      'isFinalized': instance.isFinalized,
      'finalizedBy': instance.finalizedBy,
      'finalizedAt': instance.finalizedAt?.toIso8601String(),
      'exportPayload': instance.exportPayload,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
