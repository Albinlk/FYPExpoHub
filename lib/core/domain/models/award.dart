import 'package:freezed_annotation/freezed_annotation.dart';

part 'award.freezed.dart';
part 'award.g.dart';

@freezed
abstract class AwardCategory with _$AwardCategory {
  const factory AwardCategory({
    required String id,
    required String eventId,
    required String name,
    required String description,
    required String publicationStatus, // 'draft', 'published', 'archived'
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? publishedAt,
  }) = _AwardCategory;

  factory AwardCategory.fromJson(Map<String, dynamic> json) => _$AwardCategoryFromJson(json);
}

@freezed
abstract class PublishedAwardWinner with _$PublishedAwardWinner {
  const factory PublishedAwardWinner({
    required String id,
    required String eventId,
    required String awardCategoryId,
    String? projectId,
    required String projectTitle,
    String? programmeCode,
    String? teamDisplayName,
    String? supervisorDisplayName,
    required String publicationStatus, // 'draft', 'published', 'archived'
    String? sourceImportId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? publishedAt,
  }) = _PublishedAwardWinner;

  factory PublishedAwardWinner.fromJson(Map<String, dynamic> json) => _$PublishedAwardWinnerFromJson(json);
}
