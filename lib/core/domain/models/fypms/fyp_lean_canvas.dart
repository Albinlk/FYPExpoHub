import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_lean_canvas.freezed.dart';
part 'fyp_lean_canvas.g.dart';

@freezed
abstract class FypLeanCanvas with _$FypLeanCanvas {
  const factory FypLeanCanvas({
    required String id,
    required String fypRecordId,
    required int canvasVersion,
    required Map<String, dynamic> blocks,
    required bool isLatest,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypLeanCanvas;

  factory FypLeanCanvas.fromJson(Map<String, dynamic> json) =>
      _$FypLeanCanvasFromJson(json);
}