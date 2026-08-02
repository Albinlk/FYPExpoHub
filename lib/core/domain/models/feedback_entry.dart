import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_entry.freezed.dart';
part 'feedback_entry.g.dart';

@freezed
abstract class FeedbackEntry with _$FeedbackEntry {
  const factory FeedbackEntry({
    required String id,
    String? userId,
    required String eventId,
    required String subject,
    required String message,
    int? rating,
    String? userAgent,
    @Default('new') String status,
    String? adminNote,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FeedbackEntry;

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) => _$FeedbackEntryFromJson(json);
}
