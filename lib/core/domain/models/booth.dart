import 'package:freezed_annotation/freezed_annotation.dart';

part 'booth.freezed.dart';
part 'booth.g.dart';

@freezed
abstract class Booth with _$Booth {
  const factory Booth({
    required String id,
    required String eventId,
    required String boothNumber,
    required String zone,
    required String locationNote,
    String? staticFloorPlanUrl,
    String? projectId,
    required String publicationStatus, // 'draft', 'published', 'archived'
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? publishedAt,
  }) = _Booth;

  factory Booth.fromJson(Map<String, dynamic> json) => _$BoothFromJson(json);
}
