import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_expo_publication.freezed.dart';
part 'fyp_expo_publication.g.dart';

@freezed
abstract class FypExpoPublication with _$FypExpoPublication {
  const factory FypExpoPublication({
    required String id,
    required String fypRecordId,
    required String eventId,
    required String status, // 'draft', 'ready', 'published', 'failed'
    required Map<String, dynamic> payload,
    String? publishedProjectId,
    String? preparedBy,
    DateTime? preparedAt,
    String? publishedBy,
    DateTime? publishedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypExpoPublication;

  factory FypExpoPublication.fromJson(Map<String, dynamic> json) =>
      _$FypExpoPublicationFromJson(json);
}