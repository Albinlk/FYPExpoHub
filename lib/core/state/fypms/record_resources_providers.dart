import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_scope.dart';
import '../../domain/models/fypms/fyp_correction_item.dart';
import '../../domain/models/fypms/fyp_deliverable.dart';
import '../../domain/models/fypms/fyp_form_submission.dart';
import '../../domain/models/fypms/fyp_lean_canvas.dart';
import '../../domain/models/fypms/fyp_marks_summary.dart';
import '../../domain/models/fypms/fyp_milestone.dart';
import '../../domain/models/fypms/fyp_progress_log.dart';
import '../../domain/models/fypms/fyp_record_assignment.dart';
import '../../domain/models/fypms/fyp_report_submission.dart';
import '../../domain/models/fypms/fyp_rubric_template.dart';
import '../../domain/models/fypms/fyp_supervision_request.dart';
import '../../domain/models/fypms/fyp_expo_publication.dart';
import '../../supabase/fypms_database_service.dart';
import '../../utils/fypms_key_normalizer.dart';
import '../expo/service_providers.dart';

// ==============================================================================
// RECORD-SCOPED SUB-RESOURCES
// ==============================================================================

final fypRecordAssignmentsProvider =
    FutureProvider.family<List<FypRecordAssignment>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getAssignmentsForRecordOnce(recordId);
  return data
      .map((m) => FypRecordAssignment.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

final fypSupervisionRequestsProvider =
    FutureProvider.family<List<FypSupervisionRequest>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getSupervisionRequestsForRecordOnce(recordId);
  return data
      .map((m) => FypSupervisionRequest.fromJson(normalizeFypmsKeys(m)))
      .toList();
});

final fypProgressLogsProvider =
    FutureProvider.family<List<FypProgressLog>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getProgressLogsForRecordOnce(recordId);
  return data.map((m) => FypProgressLog.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypFormSubmissionsProvider =
    FutureProvider.family<List<FypFormSubmission>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getFormSubmissionsForRecordOnce(recordId);
  return data.map((m) => FypFormSubmission.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypReportSubmissionsProvider =
    FutureProvider.family<List<FypReportSubmission>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getReportSubmissionsForRecordOnce(recordId);
  return data.map((m) => FypReportSubmission.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Deliverables checklist for a record (FYPMS deliverables, distinct from the
/// public Expo Hub `projects` catalogue).
final fypDeliverablesProvider =
    FutureProvider.family<List<FypDeliverable>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getDeliverablesForRecordOnce(recordId);
  return data.map((m) => FypDeliverable.fromJson(normalizeFypmsKeys(m))).toList();
});

/// Latest Lean Canvas revision (F13) for a record, if one exists.
final fypLeanCanvasProvider =
    FutureProvider.family<FypLeanCanvas?, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getLeanCanvasForRecordOnce(recordId);
  if (data == null) return null;
  return FypLeanCanvas.fromJson(normalizeFypmsKeys(data));
});

final fypMilestonesProvider =
    FutureProvider.family<List<FypMilestone>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getMilestonesForRecordOnce(recordId);
  return data.map((m) => FypMilestone.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypCorrectionItemsProvider =
    FutureProvider.family<List<FypCorrectionItem>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getCorrectionItemsForRecordOnce(recordId);
  return data.map((m) => FypCorrectionItem.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypMarksSummariesProvider =
    FutureProvider.family<List<FypMarksSummary>, String>((ref, recordId) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getMarksSummariesForRecordOnce(recordId);
  return data.map((m) => FypMarksSummary.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypExpoPublicationsProvider =
    FutureProvider<List<FypExpoPublication>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getExpoPublicationsOnce();
  return data.map((m) => FypExpoPublication.fromJson(normalizeFypmsKeys(m))).toList();
});

final fypRubricTemplatesProvider =
    FutureProvider<List<FypRubricTemplate>>((ref) async {
  ref.watch(fypmsUserScopeProvider);
  final db = ref.watch(supabaseDbServiceProvider);
  final data = await db.getRubricTemplatesOnce();
  return data.map((m) => FypRubricTemplate.fromJson(normalizeFypmsKeys(m))).toList();
});

/// The rubric a form is scored with (latest active version), or null when the
/// form has none.
final fypActiveRubricProvider =
    FutureProvider.family<FypRubricTemplate?, String>((ref, formCode) async {
  final all = await ref.watch(fypRubricTemplatesProvider.future);
  FypRubricTemplate? best;
  for (final t in all) {
    if (t.formCode == formCode && t.isActive && (best == null || t.version > best.version)) {
      best = t;
    }
  }
  return best;
});
