import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String eventId,
    required String slug,
    required String title,
    String? matricId,
    required String programmeCode,
    required String programmeName,
    required String shortDescription,
    required String category,
    required List<String> technologyTags,
    String? boothId,
    String? boothNumber,
    String? boothZone,
    required String coverImageUrl,
    String? posterUrl,
    required List<String> teamDisplayNames,
    required String supervisorDisplayName,
    String? examinerDisplayName,
    String? demoUrl,
    String? videoUrl,
    String? repositoryUrl,
    required bool featured,
    required String publicationStatus, // 'draft', 'published', 'archived'
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? publishedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}
