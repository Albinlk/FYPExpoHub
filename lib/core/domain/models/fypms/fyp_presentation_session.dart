import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_presentation_session.freezed.dart';
part 'fyp_presentation_session.g.dart';

@freezed
abstract class FypPresentationSession with _$FypPresentationSession {
  const factory FypPresentationSession({
    required String id,
    String? offeringId,
    required String sessionCode,
    required String sessionTitle,
    required DateTime eventDate,
    required DateTime startAt,
    required DateTime endAt,
    String? venue,
    required String sessionType, // 'defence', 'expo'
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FypPresentationSession;

  factory FypPresentationSession.fromJson(Map<String, dynamic> json) =>
      _$FypPresentationSessionFromJson(json);
}