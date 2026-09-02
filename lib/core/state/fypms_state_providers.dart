import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/fypms/academic_course.dart';
import '../domain/models/fypms/academic_semester.dart';
import '../domain/models/fypms/fyp_audit_log.dart';
import '../domain/models/fypms/fyp_correction_item.dart';
import '../domain/models/fypms/fyp_course_offering.dart';
import '../domain/models/fypms/fyp_deliverable.dart';
import '../domain/models/fypms/fyp_expo_publication.dart';
import '../domain/models/fypms/fyp_form_submission.dart';
import '../domain/models/fypms/fyp_lean_canvas.dart';
import '../domain/models/fypms/fyp_marks_summary.dart';
import '../domain/models/fypms/fyp_milestone.dart';
import '../domain/models/fypms/fyp_presentation_session.dart';
import '../domain/models/fypms/fyp_presentation_slot.dart';
import '../domain/models/fypms/fyp_progress_log.dart';
import '../domain/models/fypms/fyp_record.dart';
import '../domain/models/fypms/fyp_record_assignment.dart';
import '../domain/models/fypms/fyp_report_submission.dart';
import '../domain/models/fypms/fyp_rubric_template.dart';
import '../domain/models/fypms/fyp_supervision_request.dart';
import '../supabase/supabase_client_provider.dart';
import '../supabase/fypms_database_service.dart';
import '../supabase/fypms_realtime_service.dart';
import '../supabase/fypms_rpc_service.dart';
import '../supabase/supabase_realtime_service.dart';
import '../utils/fypms_key_normalizer.dart';
import '../utils/logger.dart';
import 'state_providers.dart';

// ==============================================================================
// CURRENT USER'S FYPMS ROLES
// ==============================================================================

/// Resolves the active FYPMS role codes for the current user, based on
/// `profile_academic_roles` (plus `profiles.role` for admin).
final fypmsCurrentRolesProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];

  final client = ref.watch(supabaseClientProvider);
  try {
    final profile = await client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    final roles = <String>{};
    if (profile != null) {
      final profileRole = profile['role'] as String?;
      if (profileRole == 'admin') roles.add('admin');
    }

    final data = await client
        .from('profile_academic_roles')
        .select('role_code')
        .eq('profile_id', user.id)
        .eq('is_active', true);
    for (final row in data) {
      final code = row['role_code'] as String?;
      if (code != null && code.isNotEmpty) roles.add(code);
    }
    return roles.toList();
  } catch (e) {
    logDebug('fypmsCurrentRolesProvider error: $e');
    return const [];
  }
});

/// True when the current user holds the coordinator role (or admin).
final isFypCoordinatorProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('fyp_coordinator') == true ||
      roles.value?.contains('admin') == true;
});

/// True when the current user is an admin.
final isFypAdminProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('admin') == true;
});

/// True when the current user is a student.
final isFypStudentProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('student') == true;
});

/// True when the current user is a supervisor (main or co).
final isFypSupervisorProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('supervisor') == true ||
      roles.value?.contains('co_supervisor') == true;
});

/// True when the current user is an examiner.
final isFypExaminerProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('examiner') == true;
});

/// True when the current user is a CSP lecturer (CSP600 or CSP650).
final isCspLecturerProvider = Provider<bool>((ref) {
  final roles = ref.watch(fypmsCurrentRolesProvider);
  return roles.value?.contains('csp600_lecturer') == true ||
      roles.value?.contains('csp650_lecturer') == true;
});

// ==============================================================================
// FYPMS FEATURE FLAGS (from settings.fypms_features)
// ==============================================================================

class FypmsFeatures {
  final bool specialEvaluationEnabled;
  const FypmsFeatures({this.specialEvaluationEnabled = false});

  factory FypmsFeatures.fromJson(Map<String, dynamic> json) {
    return FypmsFeatures(
      specialEvaluationEnabled:
          (json['special_evaluation_enabled'] as bool?) ?? false,
    );
  }
}

final fypmsFeaturesProvider = FutureProvider<FypmsFeatures>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final raw = await db.getSetting('fypms_features');
  if (raw == null) return const FypmsFeatures();
  return FypmsFeatures.fromJson(raw);
});

/// Form codes that are always available.
const List<String> fypmsAlwaysEnabledFormCodes = [
  'F1', 'F2', 'F3', 'F4', 'F6a', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'F13',
];

/// Form codes that are only available when `special_evaluation_enabled` is true.
const List<String> fypmsSpecialEvaluationFormCodes = ['F14', 'F15', 'F16'];

/// The full list of form codes the current user can submit/see, honouring the
/// `fypms_features.special_evaluation_enabled` flag (F14-F16 gate).
final fypmsAvailableFormCodesProvider = Provider<List<String>>((ref) {
  final features = ref.watch(fypmsFeaturesProvider);
  final specialEnabled = features.value?.specialEvaluationEnabled ?? false;
  return [
    ...fypmsAlwaysEnabledFormCodes,
    if (specialEnabled) ...fypmsSpecialEvaluationFormCodes,
  ];
});

// ==============================================================================
// ACADEMIC REFERENCE DATA
// ==============================================================================

final fypmsSemestersProvider = FutureProvider<List<AcademicSemester>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getAcademicSemestersOnce();
  return data.map((m) => AcademicSemester.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypmsCoursesProvider = FutureProvider<List<AcademicCourse>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getAcademicCoursesOnce();
  return data.map((m) => AcademicCourse.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypmsOfferingsProvider = FutureProvider<List<FypCourseOffering>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFypCourseOfferingsOnce();
  return data.map((m) => FypCourseOffering.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Course offerings belonging to the current lecturer (for the CSP dashboard).
final myFypmsOfferingsProvider =
    FutureProvider<List<FypCourseOffering>>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];
  final all = await ref.watch(fypmsOfferingsProvider.future);
  return all.where((o) => o.lecturerId == user.id).toList();
});

// ==============================================================================
// FYP RECORDS (per current user)
// ==============================================================================

/// All FYP records the current user can see (RLS-scoped).
final fypRecordsProvider = FutureProvider<List<FypRecord>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFypRecordsOnce();
  return data.map((m) => FypRecord.fromJson(normalizeFypmsKeys(m))).toList();
});

/// FYP records owned by the current student.
final myFypRecordsProvider = FutureProvider<List<FypRecord>>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getMyFypRecordsOnce(user.id);
  return data.map((m) => FypRecord.fromJson(normalizeFypmsKeys(m))).toList();
});

/// FYP records assigned to the current lecturer (optionally by role).
/// Optimized: fetches only assigned ids via `inFilter`, not full table.
final assignedFypRecordsProvider =
    FutureProvider.family<List<FypRecord>, String?>((ref, role) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return const [];
  final db = ref.watch(supabaseDbServiceProvider);
  final assignments = await db.getRecordsAssignedToLecturerOnce(user.id, role: role);
  final recordIds = assignments
      .map((m) => m['fyp_record_id'] as String?)
      .whereType<String>()
      .toSet();
  if (recordIds.isEmpty) return const [];
  final rows = await db.getFypRecordsByIdsOnce(recordIds);
  return rows.map((m) => FypRecord.fromJson(normalizeFypmsKeys(m))).toList();
});

// ==============================================================================
// RECORD-SCOPED SUB-RESOURCES
// ==============================================================================

final fypRecordAssignmentsProvider =
    FutureProvider.family<List<FypRecordAssignment>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getAssignmentsForRecordOnce(recordId);
  return data
      .map((m) => FypRecordAssignment.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

final fypSupervisionRequestsProvider =
    FutureProvider.family<List<FypSupervisionRequest>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getSupervisionRequestsForRecordOnce(recordId);
  return data
      .map((m) => FypSupervisionRequest.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

final fypProgressLogsProvider =
    FutureProvider.family<List<FypProgressLog>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getProgressLogsForRecordOnce(recordId);
  return data.map((m) => FypProgressLog.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypFormSubmissionsProvider =
    FutureProvider.family<List<FypFormSubmission>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFormSubmissionsForRecordOnce(recordId);
  return data.map((m) => FypFormSubmission.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypReportSubmissionsProvider =
    FutureProvider.family<List<FypReportSubmission>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getReportSubmissionsForRecordOnce(recordId);
  return data.map((m) => FypReportSubmission.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Deliverables checklist for a record (FYPMS deliverables, distinct from the
/// public Expo Hub `projects` catalogue).
final fypDeliverablesProvider =
    FutureProvider.family<List<FypDeliverable>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getDeliverablesForRecordOnce(recordId);
  return data.map((m) => FypDeliverable.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Latest Lean Canvas revision (F13) for a record, if one exists.
final fypLeanCanvasProvider =
    FutureProvider.family<FypLeanCanvas?, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getLeanCanvasForRecordOnce(recordId);
  if (data == null) return null;
  return FypLeanCanvas.fromJson(normalizeFypmsKeys(data));
});

final fypMilestonesProvider =
    FutureProvider.family<List<FypMilestone>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getMilestonesForRecordOnce(recordId);
  return data.map((m) => FypMilestone.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypCorrectionItemsProvider =
    FutureProvider.family<List<FypCorrectionItem>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getCorrectionItemsForRecordOnce(recordId);
  return data.map((m) => FypCorrectionItem.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypMarksSummariesProvider =
    FutureProvider.family<List<FypMarksSummary>, String>((ref, recordId) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getMarksSummariesForRecordOnce(recordId);
  return data.map((m) => FypMarksSummary.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypExpoPublicationsProvider =
    FutureProvider<List<FypExpoPublication>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getExpoPublicationsOnce();
  return data.map((m) => FypExpoPublication.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypRubricTemplatesProvider =
    FutureProvider<List<FypRubricTemplate>>((ref) async {
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getRubricTemplatesOnce();
  return data.map((m) => FypRubricTemplate.fromJson(normalizeFypmsKeys(m))).toList();
});

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

// ==============================================================================
// MUTATION PROVIDERS (wrap SECURITY DEFINER RPCs; invalidate reads on success)
// ==============================================================================
// Each provider returns a callable closure. Tests override these with
// `overrideWithValue((...) async {})` to stub the RPC layer.

/// Decides a pending supervision request (approve/reject).
final decideSupervisionRequestProvider = Provider<
    Future<void> Function(String requestId, String decision, String? decisionReason)>(
  (ref) {
    return (requestId, decision, decisionReason) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.decideSupervisionRequest(
        requestId: requestId,
        decision: decision,
        decisionReason: decisionReason,
      );
      ref.invalidate(fypPendingSupervisionRequestsProvider);
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Validates (or rejects) a submitted progress log for a record.
final validateProgressLogProvider = Provider<
    Future<void> Function(
        String progressLogId, String status, String? validationComment, String recordId)>(
  (ref) {
    return (progressLogId, status, validationComment, recordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.validateProgressLog(
        progressLogId: progressLogId,
        status: status,
        validationComment: validationComment,
      );
      ref.invalidate(fypProgressLogsProvider(recordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Assigns a supervisor/co-supervisor to a record (coordinator flow).
final assignSupervisorToFypRecordProvider = Provider<
    Future<void> Function(String fypRecordId, String supervisorId, String role)>(
  (ref) {
    return (fypRecordId, supervisorId, role) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.assignSupervisorToFypRecord(
        fypRecordId: fypRecordId,
        supervisorId: supervisorId,
        role: role,
      );
      ref.invalidate(fypRecordAssignmentsProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Assigns an examiner to a record (CSP lecturer / coordinator flow).
final assignExaminerProvider =
    Provider<Future<void> Function(String fypRecordId, String examinerId)>(
  (ref) {
    return (fypRecordId, examinerId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.assignExaminer(fypRecordId: fypRecordId, examinerId: examinerId);
      ref.invalidate(fypRecordAssignmentsProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Submits a form evaluation with a decision for a record.
final submitFormEvaluationProvider = Provider<
    Future<void> Function(String formSubmissionId, Map<String, dynamic> scores,
        String? comments, String decision, String recordId)>(
  (ref) {
    return (formSubmissionId, scores, comments, decision, recordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.submitFormEvaluation(
        formSubmissionId: formSubmissionId,
        scores: scores,
        comments: comments,
        decision: decision,
      );
      ref.invalidate(fypFormSubmissionsProvider(recordId));
    };
  },
);

/// Creates a correction item for a record (optionally linked to a submission).
final createCorrectionItemProvider = Provider<
    Future<void> Function(
        String fypRecordId, String? formSubmissionId, String correctionText, String severity)>(
  (ref) {
    return (fypRecordId, formSubmissionId, correctionText, severity) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.createCorrectionItem(
        fypRecordId: fypRecordId,
        formSubmissionId: formSubmissionId,
        correctionText: correctionText,
        severity: severity,
      );
      ref.invalidate(fypCorrectionItemsProvider(fypRecordId));
    };
  },
);

/// Confirms/closes a correction item for a record.
final confirmCorrectionProvider = Provider<
    Future<void> Function(
        String correctionItemId, String confirmationStatus, String? notes, String recordId)>(
  (ref) {
    return (correctionItemId, confirmationStatus, notes, recordId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.confirmCorrection(
        correctionItemId: correctionItemId,
        confirmationStatus: confirmationStatus,
        notes: notes,
      );
      ref.invalidate(fypCorrectionItemsProvider(recordId));
    };
  },
);

/// Finalizes course marks for a record.
final finalizeMarksProvider = Provider<
    Future<void> Function(
        String fypRecordId, String courseCode, Map<String, dynamic> componentBreakdown)>(
  (ref) {
    return (fypRecordId, courseCode, componentBreakdown) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.finalizeMarks(
        fypRecordId: fypRecordId,
        courseCode: courseCode,
        componentBreakdown: componentBreakdown,
      );
      ref.invalidate(fypMarksSummariesProvider(fypRecordId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Schedules a presentation slot within a session.
final schedulePresentationSlotProvider = Provider<
    Future<void> Function(
        String sessionId, String fypRecordId, int slotNumber, DateTime startAt, DateTime endAt, String? room)>(
  (ref) {
    return (sessionId, fypRecordId, slotNumber, startAt, endAt, room) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.schedulePresentationSlot(
        sessionId: sessionId,
        fypRecordId: fypRecordId,
        slotNumber: slotNumber,
        startAt: startAt,
        endAt: endAt,
        room: room,
      );
      ref.invalidate(fypPresentationSlotsProvider(sessionId));
      ref.invalidate(fypRecordsProvider);
    };
  },
);

/// Prepares an Expo publication for a record/event.
final prepareExpoPublicationProvider = Provider<
    Future<void> Function(
        String fypRecordId, String eventId, Map<String, dynamic>? payload)>(
  (ref) {
    return (fypRecordId, eventId, payload) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.prepareExpoPublication(
        fypRecordId: fypRecordId,
        eventId: eventId,
        payload: payload,
      );
      ref.invalidate(fypExpoPublicationsProvider);
    };
  },
);

/// Publishes a prepared Expo publication.
final publishFypRecordToExpoProvider =
    Provider<Future<void> Function(String publicationId)>(
  (ref) {
    return (publicationId) async {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.publishFypRecordToExpo(publicationId: publicationId);
      ref.invalidate(fypExpoPublicationsProvider);
    };
  },
);

// ==============================================================================
// REFRESH HELPER (call ref.invalidate after any successful RPC mutation)
// ==============================================================================

/// Invalidates every FYPMS provider tied to the given record so the UI
/// refreshes after a mutation. Call via `ref.invalidate(provider)` from widgets;
/// this helper is provided for convenience in tests.
void invalidateFypmsRecordProviders(Ref ref, String recordId) {
  ref.invalidate(fypRecordAssignmentsProvider(recordId));
  ref.invalidate(fypSupervisionRequestsProvider(recordId));
  ref.invalidate(fypProgressLogsProvider(recordId));
  ref.invalidate(fypFormSubmissionsProvider(recordId));
  ref.invalidate(fypReportSubmissionsProvider(recordId));
  ref.invalidate(fypDeliverablesProvider(recordId));
  ref.invalidate(fypLeanCanvasProvider(recordId));
  ref.invalidate(fypMilestonesProvider(recordId));
  ref.invalidate(fypCorrectionItemsProvider(recordId));
  ref.invalidate(fypMarksSummariesProvider(recordId));
  ref.invalidate(fypRecordsProvider);
  ref.invalidate(myFypRecordsProvider);
}

// ==============================================================================
// FYPMS REALTIME (minimal, optional, additive)
// ==============================================================================

/// Bridges Supabase Postgres changes for the five active-workflow tables into
/// provider refreshes. Kept alive by `FypmsShell` while any FYPMS page is
/// mounted and auto-disposed (channels removed) when the shell unmounts.
///
/// Realtime is NOT required for operation: if Supabase is unavailable/offline,
/// channel setup fails and the existing refetch-after-mutation paths remain
/// the refresh mechanism.
final fypmsRealtimeProvider =
    Provider<FypmsRealtimeSubscriptions>((ref) {
  bool isSupabaseReady() {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  if (!isSupabaseReady()) {
    final empty = FypmsRealtimeSubscriptions();
    ref.onDispose(() => empty.dispose());
    return empty;
  }

  final client = ref.watch(supabaseClientProvider);
  final subs = FypmsRealtimeSubscriptions(client);
  ref.onDispose(() => subs.dispose());
  final realtime = SupabaseRealtimeService(client);

  try {
    subs.add(realtime.subscribeToFypmsLive(onTableChange: {
      'fyp_supervision_requests': () {
        ref.invalidate(fypPendingSupervisionRequestsProvider);
        ref.invalidate(fypSupervisionRequestsProvider);
      },
      'fyp_progress_logs': () => ref.invalidate(fypProgressLogsProvider),
      'fyp_form_submissions': () => ref.invalidate(fypFormSubmissionsProvider),
      'fyp_correction_items': () => ref.invalidate(fypCorrectionItemsProvider),
      'fyp_expo_publications': () => ref.invalidate(fypExpoPublicationsProvider),
    }));
  } catch (e) {
    logDebug('FYPMS realtime (multiplex) unavailable - polling fallback active: $e');
  }

  return subs;
});