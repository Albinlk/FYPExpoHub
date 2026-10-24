import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'select_columns.dart';
import 'supabase_database_service.dart';

/// FYPMS database read queries. These map to the RLS-protected tables created
/// in `20260817000001_fypms_core_tables.sql`.
extension FypmsDatabaseService on SupabaseDatabaseService {
  // ---------------------------------------------------
  // ACADEMIC SEMESTERS / COURSES / OFFERINGS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getAcademicSemestersOnce() async {
    try {
      final res = await Supabase.instance.client
          .from('academic_semesters')
          .select(SelectColumns.academicSemesters)
          .order('start_date', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getAcademicSemestersOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAcademicCoursesOnce() async {
    try {
      final res = await Supabase.instance.client
          .from('academic_courses')
          .select(SelectColumns.academicCourses)
          .eq('is_active', true)
          .order('code', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getAcademicCoursesOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFypCourseOfferingsOnce() async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_course_offerings')
          .select(SelectColumns.fypCourseOfferings)
          .eq('is_active', true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getFypCourseOfferingsOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // FYP RECORDS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getMyFypRecordsOnce(String studentId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_records')
          .select(SelectColumns.fypRecords)
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getMyFypRecordsOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFypRecordsOnce({String? workflowStatus}) async {
    try {
      var filter = Supabase.instance.client.from('fyp_records').select(SelectColumns.fypRecords);
      if (workflowStatus != null) {
        filter = filter.eq('workflow_status', workflowStatus);
      }
      final res = await filter.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getFypRecordsOnce error: $e');
      return [];
    }
  }

  /// Fetch only the given FYP records by id — avoids N+1 full-table fetch
  /// used by [assignedFypRecordsProvider].
  Future<List<Map<String, dynamic>>> getFypRecordsByIdsOnce(Set<String> ids) async {
    if (ids.isEmpty) return const [];
    try {
      final res = await Supabase.instance.client
          .from('fyp_records')
          .select(SelectColumns.fypRecords)
          .inFilter('id', ids.toList())
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getFypRecordsByIdsOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // FYP RECORD ASSIGNMENTS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getAssignmentsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_record_assignments')
          .select(SelectColumns.fypRecordAssignments)
          .eq('fyp_record_id', fypRecordId)
          .eq('is_active', true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getAssignmentsForRecordOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecordsAssignedToLecturerOnce(String lecturerId, {String? role}) async {
    try {
      var filter = Supabase.instance.client
          .from('fyp_record_assignments')
          .select(SelectColumns.fypRecordAssignmentRefs)
          .eq('lecturer_id', lecturerId)
          .eq('is_active', true);
      if (role != null) {
        filter = filter.eq('academic_role', role);
      }
      final res = await filter;
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getRecordsAssignedToLecturerOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // SUPERVISION REQUESTS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getSupervisionRequestsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_supervision_requests')
          .select(SelectColumns.fypSupervisionRequests)
          .eq('fyp_record_id', fypRecordId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getSupervisionRequestsForRecordOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSupervisionRequestsOnce() async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_supervision_requests')
          .select(SelectColumns.fypSupervisionRequests)
          .eq('status', 'pending')
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getPendingSupervisionRequestsOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // PROGRESS LOGS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getProgressLogsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_progress_logs')
          .select(SelectColumns.fypProgressLogs)
          .eq('fyp_record_id', fypRecordId)
          .order('week_number', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getProgressLogsForRecordOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // FORM SUBMISSIONS & EVALUATIONS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getFormSubmissionsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_form_submissions')
          .select(SelectColumns.fypFormSubmissions)
          .eq('fyp_record_id', fypRecordId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getFormSubmissionsForRecordOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEvaluationsForSubmissionOnce(String formSubmissionId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_form_evaluations')
          .select(SelectColumns.fypFormEvaluations)
          .eq('form_submission_id', formSubmissionId);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getEvaluationsForSubmissionOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRubricTemplatesOnce({String? formCode}) async {
    try {
      var filter = Supabase.instance.client
          .from('fyp_rubric_templates')
          .select(SelectColumns.fypRubricTemplates)
          .eq('is_active', true);
      if (formCode != null) {
        filter = filter.eq('form_code', formCode);
      }
      final res = await filter.order('rubric_code', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getRubricTemplatesOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // REPORT SUBMISSIONS & DELIVERABLES
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getReportSubmissionsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_report_submissions')
          .select(SelectColumns.fypReportSubmissions)
          .eq('fyp_record_id', fypRecordId)
          .order('version', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getReportSubmissionsForRecordOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDeliverablesForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_deliverables')
          .select(SelectColumns.fypDeliverables)
          .eq('fyp_record_id', fypRecordId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getDeliverablesForRecordOnce error: $e');
      return [];
    }
  }

  /// Latest Lean Canvas revision (F13) for the record, if any.
  Future<Map<String, dynamic>?> getLeanCanvasForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_lean_canvases')
          .select(SelectColumns.fypLeanCanvases)
          .eq('fyp_record_id', fypRecordId)
          .eq('is_latest', true)
          .order('canvas_version', ascending: false)
          .limit(1)
          .maybeSingle();
      return res;
    } catch (e) {
      logDebug('Supabase getLeanCanvasForRecordOnce error: $e');
      return null;
    }
  }

  // ---------------------------------------------------
  // MILESTONES
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getMilestonesForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_milestones')
          .select(SelectColumns.fypMilestones)
          .eq('fyp_record_id', fypRecordId)
          .order('target_date', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getMilestonesForRecordOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // CORRECTIONS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getCorrectionItemsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_correction_items')
          .select(SelectColumns.fypCorrectionItems)
          .eq('fyp_record_id', fypRecordId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getCorrectionItemsForRecordOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCorrectionConfirmationsForItemOnce(String correctionItemId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_correction_confirmations')
          .select()
          .eq('correction_item_id', correctionItemId)
          .order('confirmed_at', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getCorrectionConfirmationsForItemOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // PRESENTATIONS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getPresentationSessionsOnce({String? offeringId}) async {
    try {
      var filter = Supabase.instance.client
          .from('fyp_presentation_sessions')
          .select(SelectColumns.fypPresentationSessions);
      if (offeringId != null) {
        filter = filter.eq('offering_id', offeringId);
      }
      final res = await filter.order('event_date', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getPresentationSessionsOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPresentationSlotsForSessionOnce(String sessionId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_presentation_slots')
          .select(SelectColumns.fypPresentationSlots)
          .eq('session_id', sessionId)
          .order('slot_number', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getPresentationSlotsForSessionOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // MILESTONE EXTENSIONS / PRESENTATION SCHEDULE
  // ---------------------------------------------------
  /// Extension requests on a record's milestones, newest first, each with
  /// its milestone code and title.
  Future<List<Map<String, dynamic>>> getMilestoneExtensionsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_milestone_extensions')
          .select(SelectColumns.fypMilestoneExtensions)
          .eq('fyp_milestones.fyp_record_id', fypRecordId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getMilestoneExtensionsForRecordOnce error: $e');
      return [];
    }
  }

  /// A record's presentation slots with their sessions.
  Future<List<Map<String, dynamic>>> getPresentationSlotsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_presentation_slots')
          .select(SelectColumns.fypPresentationSlotsWithSession)
          .eq('fyp_record_id', fypRecordId)
          .order('start_at');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getPresentationSlotsForRecordOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // SUPERVISOR CHANGE REQUESTS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getSupervisorChangeRequestsForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_supervisor_change_requests')
          .select(SelectColumns.fypSupervisorChangeRequests)
          .eq('fyp_record_id', fypRecordId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getSupervisorChangeRequestsForRecordOnce error: $e');
      return [];
    }
  }

  /// Pending change requests with their record (coordinator).
  Future<List<Map<String, dynamic>>> getPendingSupervisorChangesOnce() async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_supervisor_change_requests')
          .select(SelectColumns.fypSupervisorChangeRequestsWithRecord)
          .eq('status', 'pending')
          .order('created_at');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getPendingSupervisorChangesOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // SPECIAL EVALUATION (F14)
  // ---------------------------------------------------
  /// The record's F14 qualification row, or null when not assessed yet.
  Future<Map<String, dynamic>?> getSpecialEvaluationForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_special_evaluations')
          .select(SelectColumns.fypSpecialEvaluations)
          .eq('fyp_record_id', fypRecordId)
          .maybeSingle();
      return res == null ? null : Map<String, dynamic>.from(res);
    } catch (e) {
      logDebug('Supabase getSpecialEvaluationForRecordOnce error: $e');
      return null;
    }
  }

  // ---------------------------------------------------
  // MARKS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getMarksSummariesForRecordOnce(String fypRecordId) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_marks_summaries')
          .select(SelectColumns.fypMarksSummaries)
          .eq('fyp_record_id', fypRecordId);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getMarksSummariesForRecordOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // EXPO PUBLICATIONS & AUDIT LOGS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getExpoPublicationsOnce({String? status}) async {
    try {
      var filter = Supabase.instance.client
          .from('fyp_expo_publications')
          .select(SelectColumns.fypExpoPublications);
      if (status != null) {
        filter = filter.eq('status', status);
      }
      final res = await filter.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getExpoPublicationsOnce error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFypAuditLogsOnce({int limit = 200}) async {
    try {
      final res = await Supabase.instance.client
          .from('fyp_audit_logs')
          .select(SelectColumns.fypAuditLogs)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getFypAuditLogsOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // EVENTS (published, for expo publication targeting)
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getPublishedEventsOnce() async {
    try {
      final res = await Supabase.instance.client
          .from('events')
          .select(SelectColumns.eventSummaries)
          .eq('publication_status', 'published')
          .order('title', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getPublishedEventsOnce error: $e');
      return [];
    }
  }
}