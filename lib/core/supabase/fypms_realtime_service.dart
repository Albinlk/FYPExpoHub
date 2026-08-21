import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'supabase_realtime_service.dart';

/// FYPMS realtime subscriptions. Only the tables that benefit from live
/// updates are subscribed (progress logs, supervision requests, correction
/// items, presentation slots).
extension FypmsRealtimeService on SupabaseRealtimeService {
  RealtimeChannel subscribeToFypmsChanges({
    required String table,
    required void Function(Map<String, dynamic> record) onInsert,
    required void Function(Map<String, dynamic> record) onUpdate,
    required void Function(Map<String, dynamic> record) onDelete,
  }) {
    final channel = Supabase.instance.client.channel('public:$table');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe((status, [error]) {
          logDebug('FYPMS realtime ($table) status: $status ${error ?? ""}');
        });
    return channel;
  }
}

/// Owns the channels opened by the FYPMS realtime bridge so they can be torn
/// down when the owning Riverpod scope is disposed. Supplied client is the one
/// the channels were created from, so removal is safe when the app is live.
class FypmsRealtimeSubscriptions {
  final SupabaseClient? _client;
  final List<RealtimeChannel> _channels = [];

  FypmsRealtimeSubscriptions([this._client]);

  void add(RealtimeChannel channel) => _channels.add(channel);

  Future<void> dispose() async {
    for (final channel in _channels) {
      try {
        await _client?.removeChannel(channel);
      } catch (e) {
        logDebug('FYPMS realtime dispose error: $e');
      }
    }
    _channels.clear();
  }
}