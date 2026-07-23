// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FaqItem _$FaqItemFromJson(Map<String, dynamic> json) => _FaqItem(
  question: json['question'] as String,
  answer: json['answer'] as String,
);

Map<String, dynamic> _$FaqItemToJson(_FaqItem instance) => <String, dynamic>{
  'question': instance.question,
  'answer': instance.answer,
};

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  title: json['title'] as String,
  sessionLabel: json['sessionLabel'] as String,
  startAt: DateTime.parse(json['startAt'] as String),
  endAt: DateTime.parse(json['endAt'] as String),
  dailyHours: json['dailyHours'] as String,
  venue: json['venue'] as String,
  locationDetails: json['locationDetails'] as String,
  mapUrl: json['mapUrl'] as String?,
  description: json['description'] as String,
  objectives: (json['objectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  heroImageUrl: json['heroImageUrl'] as String,
  posterUrl: json['posterUrl'] as String,
  publicContactEmail: json['publicContactEmail'] as String,
  faqItems: (json['faqItems'] as List<dynamic>)
      .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  publicationStatus: json['publicationStatus'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'sessionLabel': instance.sessionLabel,
  'startAt': instance.startAt.toIso8601String(),
  'endAt': instance.endAt.toIso8601String(),
  'dailyHours': instance.dailyHours,
  'venue': instance.venue,
  'locationDetails': instance.locationDetails,
  'mapUrl': instance.mapUrl,
  'description': instance.description,
  'objectives': instance.objectives,
  'status': instance.status,
  'heroImageUrl': instance.heroImageUrl,
  'posterUrl': instance.posterUrl,
  'publicContactEmail': instance.publicContactEmail,
  'faqItems': instance.faqItems,
  'publicationStatus': instance.publicationStatus,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'publishedAt': instance.publishedAt?.toIso8601String(),
};
