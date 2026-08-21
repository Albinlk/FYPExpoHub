import 'package:freezed_annotation/freezed_annotation.dart';

part 'fyp_audit_log.freezed.dart';
part 'fyp_audit_log.g.dart';

@freezed
abstract class FypAuditLog with _$FypAuditLog {
  const factory FypAuditLog({
    required String id,
    String? actorUid,
    String? actorRole,
    required String action,
    required String targetType,
    String? targetId,
    required Map<String, dynamic> metadataSafe,
    required String source,
    required DateTime createdAt,
  }) = _FypAuditLog;

  factory FypAuditLog.fromJson(Map<String, dynamic> json) =>
      _$FypAuditLogFromJson(json);
}