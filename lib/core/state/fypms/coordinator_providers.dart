import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_scope.dart';
import '../../domain/fypms_course_marks.dart';
import '../../domain/fypms_exhibition_evaluation.dart';
import '../../domain/fypms_special_evaluation.dart';
import '../../domain/fypms_supervisor_change.dart';
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
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return rpc.listFypStudents();
});

/// Active staff profiles for the given academic roles (via SECURITY DEFINER RPC).
final fypStaffProvider =
    FutureProvider.family<List<Map<String, dynamic>>, List<String>>((ref, roles) async {
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return rpc.listFypStaff(roleCodes: roles);
});

/// Public-safe supervisor directory (id + display name) for the student
/// supervision-request picker (via SECURITY DEFINER RPC; no emails).
final supervisorsDirectoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return rpc.listSupervisorsPublic();
});

/// Pending supervision requests across all records (coordinator view).
final fypPendingSupervisionRequestsProvider =
    FutureProvider<List<FypSupervisionRequest>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getPendingSupervisionRequestsOnce();
  return data
      .map((m) => FypSupervisionRequest.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

/// Presentation sessions (coordinator view).
final fypPresentationSessionsProvider =
    FutureProvider<List<FypPresentationSession>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getPresentationSessionsOnce();
  return data
      .map((m) => FypPresentationSession.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

/// Presentation slots for a session.
final fypPresentationSlotsProvider =
    FutureProvider.family<List<FypPresentationSlot>, String>((ref, sessionId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getPresentationSlotsForSessionOnce(sessionId);
  return data
      .map((m) => FypPresentationSlot.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

/// Audit logs (read-only; coordinator/admin).
final fypAuditLogsProvider = FutureProvider<List<FypAuditLog>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFypAuditLogsOnce();
  return data.map((m) => FypAuditLog.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Published events (targets for expo publication).
final fypPublishedEventsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  return db.getPublishedEventsOnce();
});

/// A record's course marks computed from its rubric evaluations (course
/// lecturer / coordinator only; the server enforces this).
final fypCourseMarksProvider =
    FutureProvider.family<CourseMarks, String>((ref, fypRecordId) async {
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return CourseMarks.fromJson(await rpc.computeFypCourseMarks(fypRecordId: fypRecordId));
});

/// For the Expo visit page: the project's FYPMS record and the F10 / F15
/// the signed-in supervisor or examiner scores at the exhibition. Projects not
/// published from FYPMS (or an older database) read as unlinked.
final exhibitionEvaluationProvider =
    FutureProvider.family<ExhibitionEvaluation, String>((ref, projectId) async {
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  try {
    return ExhibitionEvaluation.fromJson(await rpc.getExhibitionEvaluation(projectId: projectId));
  } catch (_) {
    return ExhibitionEvaluation.unlinked;
  }
});

/// Pending supervisor change requests (coordinator).
final pendingSupervisorChangesProvider = FutureProvider<List<SupervisorChangeRequest>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getPendingSupervisorChangesOnce();
  return data.map(SupervisorChangeRequest.fromJson).toList();
});

/// Nominations awaiting the signed-in PU.
final pendingNominationsProvider = FutureProvider<List<PendingNomination>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return (await rpc.listPendingNominations()).map(PendingNomination.fromJson).toList();
});

/// The F14 checks for a CSP650 record (CSP650 lecturer / coordinator).
final fypSpecialEvaluationChecksProvider =
    FutureProvider.family<SpecialEvaluationChecks, String>((ref, fypRecordId) async {
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  return SpecialEvaluationChecks.fromJson(
    await rpc.getSpecialEvaluationChecks(fypRecordId: fypRecordId),
  );
});

/// An F1 request naming the signed-in lecturer, with the student's details
/// (from `list_my_supervision_requests`).
class MySupervisionRequest {
  const MySupervisionRequest({
    required this.request,
    required this.myRole,
    this.studentName,
    this.courseCode,
    this.programmeCode,
  });

  factory MySupervisionRequest.fromJson(Map<String, dynamic> json) => MySupervisionRequest(
        request: FypSupervisionRequest.fromJson(normalizeFypmsKeys(json)),
        myRole: json['my_role'] as String? ?? 'supervisor',
        studentName: json['student_name'] as String?,
        courseCode: json['course_code'] as String?,
        programmeCode: json['programme_code'] as String?,
      );

  final FypSupervisionRequest request;

  /// `supervisor` (decides) or `co_supervisor` (informed).
  final String myRole;
  final String? studentName;
  final String? courseCode;
  final String? programmeCode;
}

/// F1 requests that name the signed-in lecturer as supervisor or co-supervisor.
final mySupervisionRequestsProvider = FutureProvider<List<MySupervisionRequest>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final rpc = ref.watch(supabaseRpcServiceProvider);
  final rows = await rpc.listMySupervisionRequests();
  return [for (final r in rows) MySupervisionRequest.fromJson(r)];
});
