import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class FaqItem with _$FaqItem {
  const factory FaqItem({
    required String question,
    required String answer,
  }) = _FaqItem;

  factory FaqItem.fromJson(Map<String, dynamic> json) => _$FaqItemFromJson(json);
}

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required String sessionLabel,
    required DateTime startAt,
    required DateTime endAt,
    required String dailyHours,
    required String venue,
    required String locationDetails,
    String? mapUrl,
    required String description,
    required List<String> objectives,
    required String status,
    required String heroImageUrl,
    required String posterUrl,
    required String publicContactEmail,
    required List<FaqItem> faqItems,
    required String publicationStatus,
    required DateTime updatedAt,
    DateTime? publishedAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
