import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseDatabaseService {
  final SupabaseClient _client;

  SupabaseDatabaseService(this._client);

  // ---------------------------------------------------
  // PROJECTS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getProjectsOnce({
    bool publishedOnly = false,
    int? limit,
    int? offset,
    String eventId = 'fskm-fyp-2026',
  }) async {
    try {
      var filter = _client.from('projects').select();
      if (publishedOnly) {
        filter = filter.eq('publication_status', 'published');
      }
      var transform = filter.order('created_at', ascending: true);
      if (limit != null && offset != null) {
        transform = transform.range(offset, offset + limit - 1);
      }
      final response = await transform;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logDebug('Supabase getProjectsOnce error: $e');
      rethrow;
    }
  }

  Future<void> setProject(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('projects').upsert(data);
    } catch (e) {
      logDebug('Supabase setProject error: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _client.from('projects').delete().eq('id', id);
    } catch (e) {
      logDebug('Supabase deleteProject error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // SCHEDULE ITEMS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getScheduleOnce({
    bool publishedOnly = false,
    String eventId = 'fskm-fyp-2026',
  }) async {
    try {
      var filter = _client.from('schedule_items').select();
      if (publishedOnly) {
        filter = filter
            .eq('publication_status', 'published')
            .eq('access_type', 'public');
      }
      final transform = filter
          .order('event_date', ascending: true)
          .order('start_at', ascending: true);
      final response = await transform;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logDebug('Supabase getScheduleOnce error: $e');
      rethrow;
    }
  }

  Future<void> setScheduleItem(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('schedule_items').upsert(data);
    } catch (e) {
      logDebug('Supabase setScheduleItem error: $e');
      rethrow;
    }
  }

  Future<void> deleteScheduleItem(String id) async {
    try {
      await _client.from('schedule_items').delete().eq('id', id);
    } catch (e) {
      logDebug('Supabase deleteScheduleItem error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // BOOTHS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getBoothsOnce({
    bool publishedOnly = false,
  }) async {
    try {
      var filter = _client.from('booths').select();
      if (publishedOnly) {
        filter = filter.eq('publication_status', 'published');
      }
      final transform = filter.order('booth_number', ascending: true);
      final response = await transform;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logDebug('Supabase getBoothsOnce error: $e');
      rethrow;
    }
  }

  Future<void> setBooth(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('booths').upsert(data);
    } catch (e) {
      logDebug('Supabase setBooth error: $e');
      rethrow;
    }
  }

  Future<void> deleteBooth(String id) async {
    try {
      await _client.from('booths').delete().eq('id', id);
    } catch (e) {
      logDebug('Supabase deleteBooth error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // ANNOUNCEMENTS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getAnnouncementsOnce({
    bool publishedOnly = false,
  }) async {
    try {
      var filter = _client.from('announcements').select();
      if (publishedOnly) {
        filter = filter.eq('publication_status', 'published');
      }
      final transform = filter
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);
      final response = await transform;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logDebug('Supabase getAnnouncementsOnce error: $e');
      rethrow;
    }
  }

  Future<void> setAnnouncement(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('announcements').upsert(data);
    } catch (e) {
      logDebug('Supabase setAnnouncement error: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _client.from('announcements').delete().eq('id', id);
    } catch (e) {
      logDebug('Supabase deleteAnnouncement error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // AWARD WINNERS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getAwardWinnersOnce({
    bool publishedOnly = false,
  }) async {
    try {
      var filter = _client.from('award_winners').select();
      if (publishedOnly) {
        filter = filter.eq('publication_status', 'published');
      }
      final transform = filter.order('created_at', ascending: true);
      final response = await transform;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logDebug('Supabase getAwardWinnersOnce error: $e');
      rethrow;
    }
  }

  Future<void> setAwardWinner(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('award_winners').upsert(data);
    } catch (e) {
      logDebug('Supabase setAwardWinner error: $e');
      rethrow;
    }
  }

  Future<void> deleteAwardWinner(String id) async {
    try {
      await _client.from('award_winners').delete().eq('id', id);
    } catch (e) {
      logDebug('Supabase deleteAwardWinner error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // EVENTS
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> getEvent(String eventId) async {
    try {
      final data = await _client.from('events').select().eq('id', eventId).maybeSingle();
      return data;
    } catch (e) {
      logDebug('Supabase getEvent error: $e');
      return null;
    }
  }

  Future<void> setEvent(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('events').upsert(data);
    } catch (e) {
      logDebug('Supabase setEvent error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // SETTINGS
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> getSetting(String key) async {
    try {
      final data = await _client.from('settings').select().eq('key', key).maybeSingle();
      return data != null ? (data['value'] as Map<String, dynamic>?) : null;
    } catch (e) {
      logDebug('Supabase getSetting error: $e');
      return null;
    }
  }

  Future<void> setSetting(String key, Map<String, dynamic> value) async {
    try {
      await _client.from('settings').upsert({
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      logDebug('Supabase setSetting error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // IMPORTS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getImportsOnce() async {
    try {
      final response = await _client.from('imports').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logDebug('Supabase getImportsOnce error: $e');
      return [];
    }
  }

  Future<void> setImport(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('imports').upsert(data);
    } catch (e) {
      logDebug('Supabase setImport error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduleCandidates(String importId) async {
    try {
      final res = await _client.from('import_schedule_candidates').select().eq('import_id', importId).order('row_number', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getScheduleCandidates error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAwardCandidates(String importId) async {
    try {
      final res = await _client.from('import_award_candidates').select().eq('import_id', importId).order('row_number', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getAwardCandidates error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getValidationIssues(String importId) async {
    try {
      final res = await _client.from('import_validation_issues').select().eq('import_id', importId).order('row_number', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getValidationIssues error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPrivacySkips(String importId) async {
    try {
      final res = await _client.from('import_privacy_skips').select().eq('import_id', importId).order('row_number', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getPrivacySkips error: $e');
      return [];
    }
  }

  Future<void> insertScheduleCandidates(List<Map<String, dynamic>> list) async {
    if (list.isEmpty) return;
    try {
      await _client.from('import_schedule_candidates').insert(list);
    } catch (e) {
      logDebug('Supabase insertScheduleCandidates error: $e');
      rethrow;
    }
  }

  Future<void> insertAwardCandidates(List<Map<String, dynamic>> list) async {
    if (list.isEmpty) return;
    try {
      await _client.from('import_award_candidates').insert(list);
    } catch (e) {
      logDebug('Supabase insertAwardCandidates error: $e');
      rethrow;
    }
  }

  Future<void> insertValidationIssues(List<Map<String, dynamic>> list) async {
    if (list.isEmpty) return;
    try {
      await _client.from('import_validation_issues').insert(list);
    } catch (e) {
      logDebug('Supabase insertValidationIssues error: $e');
      rethrow;
    }
  }

  Future<void> insertPrivacySkips(List<Map<String, dynamic>> list) async {
    if (list.isEmpty) return;
    try {
      await _client.from('import_privacy_skips').insert(list);
    } catch (e) {
      logDebug('Supabase insertPrivacySkips error: $e');
      rethrow;
    }
  }

  Future<void> insertReviewDecisions(List<Map<String, dynamic>> list) async {
    if (list.isEmpty) return;
    try {
      await _client.from('import_review_decisions').insert(list);
    } catch (e) {
      logDebug('Supabase insertReviewDecisions error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // LECTURERS (Profiles with role = 'lecturer')
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getLecturersOnce() async {
    try {
      final res = await _client.from('profiles').select().eq('role', 'lecturer').order('display_name', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getLecturersOnce error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLecturer(String uid) async {
    try {
      final res = await _client.from('profiles').select().eq('id', uid).maybeSingle();
      return res;
    } catch (e) {
      logDebug('Supabase getLecturer error: $e');
      return null;
    }
  }

  Future<void> setLecturer(String uid, Map<String, dynamic> data) async {
    try {
      await _client.from('profiles').upsert(data);
    } catch (e) {
      logDebug('Supabase setLecturer error: $e');
      rethrow;
    }
  }

  Future<void> deleteLecturer(String uid) async {
    try {
      await _client.from('profiles').delete().eq('id', uid);
    } catch (e) {
      logDebug('Supabase deleteLecturer error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // PROJECT LECTURER ASSIGNMENTS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getAssignmentsOnce() async {
    try {
      final res = await _client.from('lecturer_assignments').select().order('assigned_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getAssignmentsOnce error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAssignment(String id) async {
    try {
      final res = await _client.from('lecturer_assignments').select().eq('id', id).maybeSingle();
      return res;
    } catch (e) {
      logDebug('Supabase getAssignment error: $e');
      return null;
    }
  }

  Future<void> setAssignment(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('lecturer_assignments').upsert(data);
    } catch (e) {
      logDebug('Supabase setAssignment error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------
  // STUDENT PROJECT VISITS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getVisitsOnce({int limit = 1000}) async {
    try {
      final res = await _client.from('student_project_visits').select().order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getVisitsOnce error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getVisit(String id) async {
    try {
      final res = await _client.from('student_project_visits').select().eq('id', id).maybeSingle();
      return res;
    } catch (e) {
      logDebug('Supabase getVisit error: $e');
      return null;
    }
  }

  // ---------------------------------------------------
  // AUDIT LOGS
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getAuditLogsOnce({int limit = 200}) async {
    try {
      final res = await _client.from('audit_logs').select().order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getAuditLogsOnce error: $e');
      return [];
    }
  }

  // ---------------------------------------------------
  // FEEDBACK ENTRIES
  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getFeedbackEntriesOnce() async {
    try {
      final res = await _client.from('feedback_entries').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      logDebug('Supabase getFeedbackEntriesOnce error: $e');
      return [];
    }
  }

  Future<void> setFeedbackEntry(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('feedback_entries').upsert(data);
    } catch (e) {
      logDebug('Supabase setFeedbackEntry error: $e');
      rethrow;
    }
  }

  Future<void> deleteFeedbackEntry(String id) async {
    try {
      await _client.from('feedback_entries').delete().eq('id', id);
    } catch (e) {
      logDebug('Supabase deleteFeedbackEntry error: $e');
      rethrow;
    }
  }
}
