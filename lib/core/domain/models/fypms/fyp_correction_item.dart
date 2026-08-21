import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_correction_item.freezed.dart';
part 'fyp_correction_item.g.dart';

@freezed
abstract class FypCorrectionItem with _$FypCorrectionItem {
  const factory FypCorrectionItem({
    required String id,
    required String fypRecordId,
    String? itemCode,
    required String description,
    required String severity, // 'minor', 'major'
    required String status, // 'open', 'in_progress', 'evidence_submitted', 'confirmed', 'closed'
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypCorrectionItem;

  factory FypCorrectionItem.fromJson(Map<String, dynamic> json) =>
      _$FypCorrectionItemFromJson(json);
}