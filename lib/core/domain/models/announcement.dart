import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

@freezed
abstract class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String eventId,
    required String title,
    required String body,
    required String category,
    required bool pinned,
    required String publicationStatus, // 'draft', 'published', 'archived'
    required DateTime publishedAt,
    DateTime? expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);
}
