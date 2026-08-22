import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseRealtimeService {
  final SupabaseClient _client;

  SupabaseRealtimeService(this._client);

  /// Exposes the underlying client for multiplex extensions without
  /// reaching for the global `Supabase.instance`.
  SupabaseClient getClient() => _client;

  /// Subscribes to published announcements with minimal bandwidth
  RealtimeChannel subscribeToAnnouncements({
    required void Function(Map<String, dynamic> record) onInsert,
    required void Function(Map<String, dynamic> record) onUpdate,
    required void Function(Map<String, dynamic> record) onDelete,
  }) {
    final channel = _client.channel('public:announcements');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'announcements',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'announcements',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'announcements',
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe((status, [error]) {
          logDebug('Announcements realtime status: $status ${error ?? ""}');
        });
    return channel;
  }

  /// Subscribes to visits for real-time monitoring on admin dashboard
  RealtimeChannel subscribeToVisits({
    required void Function(Map<String, dynamic> record) onVisitChange,
  }) {
    final channel = _client.channel('public:student_project_visits');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'student_project_visits',
          callback: (payload) => onVisitChange(payload.newRecord),
        )
        .subscribe((status, [error]) {
          logDebug('Visits realtime status: $status ${error ?? ""}');
        });
    return channel;
  }

  /// Multiplexed public channel — one websocket for announcements + visits
  RealtimeChannel subscribeToPublicLive({
    required void Function(Map<String, dynamic> record) onAnnouncement,
    required void Function(Map<String, dynamic> record) onVisit,
  }) {
    final channel = _client.channel('public:live');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'announcements',
          callback: (payload) => onAnnouncement(payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'student_project_visits',
          callback: (payload) => onVisit(payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord),
        )
        .subscribe((status, [error]) {
          logDebug('Public realtime (multiplex) status: $status ${error ?? ""}');
        });
    return channel;
  }

  /// Unsubscribe a channel safely
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
