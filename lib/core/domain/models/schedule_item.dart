import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_item.freezed.dart';
part 'schedule_item.g.dart';

@freezed
abstract class ScheduleItem with _$ScheduleItem {
  const factory ScheduleItem({
    required String id,
    required String eventId,
    required DateTime date,
    required String startAt,
    required String endAt,
    required String title,
    required String venue,
    required String audience,
    String? description,
    required String visibility, // 'public' or 'internal'
    required String publicationStatus, // 'draft', 'published', 'archived'
    String? sourceImportId,
    String? sourceStagingId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? publishedAt,
  }) = _ScheduleItem;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => _$ScheduleItemFromJson(json);
}
