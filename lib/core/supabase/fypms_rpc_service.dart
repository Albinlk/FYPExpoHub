import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'supabase_rpc_service.dart';

/// FYPMS RPC calls. Each method maps 1:1 to a SECURITY DEFINER function
/// defined in `20260817000004_fypms_rpc.sql`.
extension FypmsRpcService on SupabaseRpcService {
  Future<Map<String, dynamic>> createFypRecord({
    required String academicSemesterId,
    required String studentId,
    required String currentCourseCode,
    required String programmeCode,
    String? matricId,
    String? projectTitle,
    String? projectDescription,
    String? projectType,
    String? externalIndustryPartner,
    String? previousRecordId,
  }) async {
    return _rpc('create_fyp_record', {
      'p_academic_semester_id': academicSemesterId,
      'p_student_id': studentId,
      'p_current_course_code': currentCourseCode,
      'p_programme_code': programmeCode,
      if (matricId != null) 'p_matric_id': matricId,
      if (projectTitle != null) 'p_project_title': projectTitle,
      if (projectDescription != null) 'p_project_description': projectDescription,
      if (projectType != null) 'p_project_type': projectType,
      if (externalIndustryPartner != null) 'p_external_industry_partner': externalIndustryPartner,
      if (previousRecordId != null) 'p_previous_record_id': previousRecordId,
    });
  }

  Future<Map<String, dynamic>> submitSupervisionRequest({
    required String fypRecordId,
    String? preferredSupervisorId,
    String? rationale,
  }) async {
    return _rpc('submit_supervision_request', {
      'p_fyp_record_id': fypRecordId,
      if (preferredSupervisorId != null) 'p_preferred_supervisor_id': preferredSupervisorId,
      if (rationale != null) 'p_rationale': rationale,
    });
  }

  Future<Map<String, dynamic>> decideSupervisionRequest({
    required String requestId,
    required String decision,
    String? decisionReason,
  }) async {
    return _rpc('decide_supervision_request', {
      'p_request_id': requestId,
      'p_decision': decision,
      if (decisionReason != null) 'p_decision_reason': decisionReason,
    });
  }

  Future<Map<String, dynamic>> updateFypRecordField({
    required String fypRecordId,
    required String field,
    required String value,
  }) async {
    return _rpc('update_fyp_record_field', {
      'p_fyp_record_id': fypRecordId,
      'p_field': field,
      'p_value': value,
    });
  }

  Future<Map<String, dynamic>> adminOverrideFypRecordField({
    required String fypRecordId,
    required String field,
    required String value,
    required String reason,
  }) async {
    return _rpc('admin_override_fyp_record_field', {
      'p_fyp_record_id': fypRecordId,
      'p_field': field,
      'p_value': value,
      'p_reason': reason,
    });
  }

  Future<Map<String, dynamic>> submitProgressLog({
    required String fypRecordId,
    required int weekNumber,
    required String summary,
    String? challenges,
    String? nextPlan,
    DateTime? progressDate,
  }) async {
    return _rpc('submit_progress_log', {
      'p_fyp_record_id': fypRecordId,
      'p_week_number': weekNumber,
      'p_summary': summary,
      if (challenges != null) 'p_challenges': challenges,
      if (nextPlan != null) 'p_next_plan': nextPlan,
      if (progressDate != null) 'p_progress_date': progressDate.toIso8601String().substring(0, 10),
    });
  }

  Future<Map<String, dynamic>> submitFypForm({
    required String fypRecordId,
    required String formCode,
    required Map<String, dynamic> payload,
    String? fileUrl,
    double? similarityIndex,
  }) async {
    return _rpc('submit_fyp_form', {
      'p_fyp_record_id': fypRecordId,
      'p_form_code': formCode,
      'p_payload': payload,
      if (fileUrl != null) 'p_file_url': fileUrl,
      if (similarityIndex != null) 'p_similarity_index': similarityIndex,
    });
  }

  /// Saves a Lean Canvas revision (F13). Each save creates a new versioned row.
  Future<Map<String, dynamic>> saveLeanCanvas({
    required String fypRecordId,
    required Map<String, dynamic> blocks,
  }) async {
    return _rpc('save_lean_canvas', {
      'p_fyp_record_id': fypRecordId,
      'p_blocks': blocks,
    });
  }

  /// Submits (or re-submits) a deliverable for the record. Re-submitting the
  /// same deliverable type bumps the version.
  Future<Map<String, dynamic>> submitDeliverable({
    required String fypRecordId,
    required String deliverableType,
    required String title,
    String? description,
    String? fileUrl,
  }) async {
    return _rpc('submit_deliverable', {
      'p_fyp_record_id': fypRecordId,
      'p_deliverable_type': deliverableType,
      'p_title': title,
      if (description != null) 'p_description': description,
      if (fileUrl != null) 'p_file_url': fileUrl,
    });
  }

  Future<Map<String, dynamic>> submitReportVersion({
    required String fypRecordId,
    required String reportType,
    required String fileUrl,
    double? similarityIndex,
  }) async {
    return _rpc('submit_report_version', {
      'p_fyp_record_id': fypRecordId,
      'p_report_type': reportType,
      'p_file_url': fileUrl,
      if (similarityIndex != null) 'p_similarity_index': similarityIndex,
    });
  }

  Future<Map<String, dynamic>> submitFormEvaluation({
    required String formSubmissionId,
    required Map<String, dynamic> scores,
    String? comments,
    String decision = 'approved',
  }) async {
    return _rpc('submit_form_evaluation', {
      'p_form_submission_id': formSubmissionId,
      'p_criteria_scores': scores,
      if (comments != null) 'p_comments': comments,
      'p_decision': decision,
    });
  }

  Future<Map<String, dynamic>> assignSupervisorToFypRecord({
    required String fypRecordId,
    required String supervisorId,
    String role = 'supervisor',
  }) async {
    return _rpc('assign_supervisor_to_fyp_record', {
      'p_fyp_record_id': fypRecordId,
      'p_supervisor_id': supervisorId,
      'p_role': role,
    });
  }

  Future<Map<String, dynamic>> reviewProgressLog({
    required String progressLogId,
    required String decision,
    String? validationComment,
  }) async {
    return _rpc('review_progress_log', {
      'p_progress_log_id': progressLogId,
      'p_decision': decision,
      if (validationComment != null) 'p_validation_comment': validationComment,
    });
  }

  Future<Map<String, dynamic>> validateProgressLog({
    required String progressLogId,
    required String status,
    String? validationComment,
  }) async {
    return _rpc('validate_progress_log', {
      'p_progress_log_id': progressLogId,
      'p_status': status,
      if (validationComment != null) 'p_validation_comment': validationComment,
    });
  }

  Future<Map<String, dynamic>> createOrUpdateMilestone({
    required String fypRecordId,
    required String milestoneCode,
    required String milestoneTitle,
    String? description,
    DateTime? targetDate,
    String status = 'pending',
  }) async {
    return _rpc('create_or_update_milestone', {
      'p_fyp_record_id': fypRecordId,
      'p_milestone_code': milestoneCode,
      'p_milestone_title': milestoneTitle,
      if (description != null) 'p_description': description,
      if (targetDate != null) 'p_target_date': targetDate.toIso8601String().substring(0, 10),
      'p_status': status,
    });
  }

  Future<Map<String, dynamic>> grantMilestoneExtension({
    required String milestoneId,
    String? requestedBy,
    String? reason,
    DateTime? requestedDueDate,
    String decision = 'pending',
  }) async {
    return _rpc('grant_milestone_extension', {
      'p_milestone_id': milestoneId,
      if (requestedBy != null) 'p_requested_by': requestedBy,
      if (reason != null) 'p_reason': reason,
      if (requestedDueDate != null) 'p_requested_due_date': requestedDueDate.toIso8601String().substring(0, 10),
      'p_decision': decision,
    });
  }

  Future<Map<String, dynamic>> schedulePresentationSlot({
    required String sessionId,
    required String fypRecordId,
    required int slotNumber,
    required DateTime startAt,
    required DateTime endAt,
    String? room,
  }) async {
    return _rpc('schedule_presentation_slot', {
      'p_session_id': sessionId,
      'p_fyp_record_id': fypRecordId,
      'p_slot_number': slotNumber,
      'p_start_at': startAt.toUtc().toIso8601String(),
      'p_end_at': endAt.toUtc().toIso8601String(),
      if (room != null) 'p_room': room,
    });
  }

  Future<Map<String, dynamic>> finalizeMarks({
    required String fypRecordId,
    required String courseCode,
    required Map<String, dynamic> componentBreakdown,
  }) async {
    return _rpc('finalize_marks', {
      'p_fyp_record_id': fypRecordId,
      'p_course_code': courseCode,
      'p_component_breakdown': componentBreakdown,
    });
  }

  Future<Map<String, dynamic>> assignExaminer({
    required String fypRecordId,
    required String examinerId,
  }) async {
    return _rpc('assign_examiner', {
      'p_fyp_record_id': fypRecordId,
      'p_examiner_id': examinerId,
    });
  }

  Future<Map<String, dynamic>> createCorrectionItem({
    required String fypRecordId,
    String? formSubmissionId,
    required String correctionText,
    String severity = 'minor',
  }) async {
    return _rpc('create_correction_item', {
      'p_fyp_record_id': fypRecordId,
      if (formSubmissionId != null) 'p_form_submission_id': formSubmissionId,
      'p_correction_text': correctionText,
      'p_severity': severity,
    });
  }

  Future<Map<String, dynamic>> confirmCorrection({
    required String correctionItemId,
    required String confirmationStatus,
    String? notes,
  }) async {
    return _rpc('confirm_correction', {
      'p_correction_item_id': correctionItemId,
      'p_confirmation_status': confirmationStatus,
      if (notes != null) 'p_notes': notes,
    });
  }

  Future<Map<String, dynamic>> confirmFypCorrections({
    required String correctionItemId,
    String? comment,
  }) async {
    return _rpc('confirm_fyp_corrections', {
      'p_correction_item_id': correctionItemId,
      if (comment != null) 'p_comment': comment,
    });
  }

  Future<Map<String, dynamic>> prepareExpoPublication({
    required String fypRecordId,
    required String eventId,
    Map<String, dynamic>? payload,
  }) async {
    return _rpc('prepare_expo_publication', {
      'p_fyp_record_id': fypRecordId,
      'p_event_id': eventId,
      if (payload != null) 'p_payload': payload,
    });
  }

  Future<Map<String, dynamic>> publishFypRecordToExpo({
    required String publicationId,
  }) async {
    return _rpc('publish_fyp_record_to_expo', {
      'p_publication_id': publicationId,
    });
  }

  Future<Map<String, dynamic>> archiveFypRecord({
    required String fypRecordId,
    String? reason,
  }) async {
    return _rpc('archive_fyp_record', {
      'p_fyp_record_id': fypRecordId,
      if (reason != null) 'p_reason': reason,
    });
  }

  Future<Map<String, dynamic>> createStudentAccountProfile({
    required String userId,
    required String email,
    required String displayName,
    required String programmeCode,
    String? matricId,
  }) async {
    return _rpc('create_student_account_profile', {
      'p_user_id': userId,
      'p_email': email.trim().toLowerCase(),
      'p_display_name': displayName.trim().toUpperCase(),
      'p_programme_code': programmeCode,
      if (matricId != null) 'p_matric_id': matricId,
    });
  }

  /// SECURITY DEFINER helper: active student profiles with programme codes
  /// (coordinators/admin only; RLS prevents direct profiles reads).
  Future<List<Map<String, dynamic>>> listFypStudents() async {
    try {
      final client = Supabase.instance.client;
      final response = await client.rpc('list_fyp_students');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      logDebug('Supabase FYPMS RPC list_fyp_students error: $e');
      rethrow;
    }
  }

  /// SECURITY DEFINER helper: active staff profiles holding the given roles
  /// (coordinators/admin only; RLS prevents direct profiles reads).
  Future<List<Map<String, dynamic>>> listFypStaff({
    List<String> roleCodes = const ['supervisor', 'co_supervisor', 'examiner'],
  }) async {
    try {
      final client = Supabase.instance.client;
      final response = await client.rpc('list_fyp_staff', params: {
        'p_role_codes': roleCodes,
      });
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      logDebug('Supabase FYPMS RPC list_fyp_staff error: $e');
      rethrow;
    }
  }

  /// SECURITY DEFINER helper: active coordinators.
  Future<List<Map<String, dynamic>>> listFypCoordinators() async {
    try {
      final client = Supabase.instance.client;
      final response = await client.rpc('list_fyp_coordinators');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      logDebug('Supabase FYPMS RPC list_fyp_coordinators error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _rpc(
    String fn,
    Map<String, dynamic> params,
  ) async {
    try {
      final client = Supabase.instance.client;
      final response = await client.rpc(fn, params: params);
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      logDebug('Supabase FYPMS RPC $fn error: $e');
      rethrow;
    }
  }
}