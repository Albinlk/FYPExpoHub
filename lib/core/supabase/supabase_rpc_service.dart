import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseRpcService {
  final SupabaseClient _client;

  SupabaseRpcService(this._client);

  /// 1. Mark a student project visit as completed
  Future<Map<String, dynamic>> markStudentProjectVisited({
    required String assignmentId,
    String? visitNote,
  }) async {
    try {
      final response = await _client.rpc(
        'mark_student_project_visited',
        params: {
          'p_assignment_id': assignmentId,
          if (visitNote != null && visitNote.isNotEmpty)
            'p_visit_note': visitNote,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      logDebug('Supabase markStudentProjectVisited RPC error: $e');
      rethrow;
    }
  }

  /// 2. Void a student project visit (with required reason & 30-min window check)
  Future<Map<String, dynamic>> voidStudentProjectVisit({
    required String visitId,
    required String reason,
  }) async {
    try {
      final response = await _client.rpc(
        'void_student_project_visit',
        params: {
          'p_visit_id': visitId,
          'p_reason': reason.trim(),
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      logDebug('Supabase voidStudentProjectVisit RPC error: $e');
      rethrow;
    }
  }

  /// 3. Publish approved import changes (admin only)
  Future<Map<String, dynamic>> publishApprovedImportChanges({
    required String importId,
  }) async {
    try {
      final response = await _client.rpc(
        'publish_approved_import_changes',
        params: {
          'p_import_id': importId,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      logDebug('Supabase publishApprovedImportChanges RPC error: $e');
      rethrow;
    }
  }

  /// 4. Create or update lecturer account profile (admin only)
  Future<Map<String, dynamic>> createLecturerAccountProfile({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      final response = await _client.rpc(
        'create_lecturer_account_profile',
        params: {
          'p_user_id': userId,
          'p_email': email.trim().toLowerCase(),
          'p_display_name': displayName.trim().toUpperCase(),
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      logDebug('Supabase createLecturerAccountProfile RPC error: $e');
      rethrow;
    }
  }

  /// 5. Update event configuration (admin only)
  Future<Map<String, dynamic>> updateEventConfiguration({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _client.rpc(
        'update_event_configuration',
        params: {
          'p_event_id': eventId,
          'p_payload': payload,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      logDebug('Supabase updateEventConfiguration RPC error: $e');
      rethrow;
    }
  }
}
