import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_deliverable.freezed.dart';
part 'fyp_deliverable.g.dart';

@freezed
abstract class FypDeliverable with _$FypDeliverable {
  const factory FypDeliverable({
    required String id,
    required String fypRecordId,
    String? deliverableType,
    required String title,
    String? description,
    String? fileUrl,
    required int version,
    required bool isRequired,
    String? submittedBy,
    DateTime? submittedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypDeliverable;

  factory FypDeliverable.fromJson(Map<String, dynamic> json) =>
      _$FypDeliverableFromJson(json);
}