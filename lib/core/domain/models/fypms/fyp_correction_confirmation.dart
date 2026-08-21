import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_correction_confirmation.freezed.dart';
part 'fyp_correction_confirmation.g.dart';

@freezed
abstract class FypCorrectionConfirmation with _$FypCorrectionConfirmation {
  const factory FypCorrectionConfirmation({
    required String id,
    required String correctionItemId,
    required String confirmedBy,
    required DateTime confirmedAt,
    String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypCorrectionConfirmation;

  factory FypCorrectionConfirmation.fromJson(Map<String, dynamic> json) =>
      _$FypCorrectionConfirmationFromJson(json);
}