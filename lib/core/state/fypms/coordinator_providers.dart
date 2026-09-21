import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fypms/fyp_audit_log.dart';
import '../../domain/models/fypms/fyp_presentation_session.dart';
import '../../domain/models/fypms/fyp_presentation_slot.dart';
import '../../domain/models/fypms/fyp_supervision_request.dart';
import '../../supabase/fypms_database_service.dart';
import '../../supabase/fypms_rpc_service.dart';
import '../../utils/fypms_key_normalizer.dart';
import '../expo/service_providers.dart';

// ==============================================================================
// COORDINATOR DATA (list helpers + admin-scoped queries)
// ==============================================================================

/// Active student profiles with programme codes (via SECURITY DEFINER RPC).
final fypStudentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return rpc.listFypStudents();
});

/// Active staff profiles for the given academic roles (via SECURITY DEFINER RPC).
final fypStaffProvider =
    FutureProvider.family<List<Map<String, dynamic>>, List<String>>((ref, roles) async {
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return rpc.listFypStaff(roleCodes: roles);
});

/// Public-safe supervisor directory (id + display name) for the student
/// supervision-request picker (via SECURITY DEFINER RPC; no emails).
final supervisorsDirectoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return rpc.listSupervisorsPublic();
});

/// Pending supervision requests across all records (coordinator view).
final fypPendingSupervisionRequestsProvider =
    FutureProvider<List<FypSupervisionRequest>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getPendingSupervisionRequestsOnce();
  return data
      .map((m) => FypSupervisionRequest.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

/// Presentation sessions (coordinator view).
final fypPresentationSessionsProvider =
    FutureProvider<List<FypPresentationSession>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getPresentationSessionsOnce();
  return data
      .map((m) => FypPresentationSession.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

/// Presentation slots for a session.
final fypPresentationSlotsProvider =
    FutureProvider.family<List<FypPresentationSlot>, String>((ref, sessionId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getPresentationSlotsForSessionOnce(sessionId);
  return data
      .map((m) => FypPresentationSlot.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

/// Audit logs (read-only; coordinator/admin).
final fypAuditLogsProvider = FutureProvider<List<FypAuditLog>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFypAuditLogsOnce();
  return data.map((m) => FypAuditLog.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Published events (targets for expo publication).
final fypPublishedEventsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  return db.getPublishedEventsOnce();
});
