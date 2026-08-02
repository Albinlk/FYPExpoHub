// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedbackEntry _$FeedbackEntryFromJson(Map<String, dynamic> json) =>
    _FeedbackEntry(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      eventId: json['eventId'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      rating: (json['rating'] as num?)?.toInt(),
      userAgent: json['userAgent'] as String?,
      status: json['status'] as String? ?? 'new',
      adminNote: json['adminNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FeedbackEntryToJson(_FeedbackEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'eventId': instance.eventId,
      'subject': instance.subject,
      'message': instance.message,
      'rating': instance.rating,
      'userAgent': instance.userAgent,
      'status': instance.status,
      'adminNote': instance.adminNote,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
