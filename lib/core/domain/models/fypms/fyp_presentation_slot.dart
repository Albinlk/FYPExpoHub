import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_presentation_slot.freezed.dart';
part 'fyp_presentation_slot.g.dart';

@freezed
abstract class FypPresentationSlot with _$FypPresentationSlot {
  const factory FypPresentationSlot({
    required String id,
    required String sessionId,
    required String fypRecordId,
    required int slotNumber,
    required DateTime startAt,
    required DateTime endAt,
    String? room,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypPresentationSlot;

  factory FypPresentationSlot.fromJson(Map<String, dynamic> json) =>
      _$FypPresentationSlotFromJson(json);
}