import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_fallback.dart';
import '../../domain/models/schedule_item.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import 'service_providers.dart';

// ==========================================
// DAILY SCHEDULE STATE
// ==========================================
class ScheduleNotifier extends Notifier<List<ScheduleItem>> {
  ScheduleNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<ScheduleItem> build() {
    _loadSchedule();
    return const [];
  }

  /// Same pattern as ProjectsNotifier: fallback asset fills state first,
  /// live Supabase rows overwrite it when they arrive (remote wins).
  void _loadSchedule() async {
    final remote = _fetchRemoteSchedule().catchError(
      (Object e) => <Map<String, dynamic>>[],
    );
    try {
      final data = await OfflineFallback.load();
      final fallback = (data['scheduleItems'] ?? const [])
          .map((m) => ScheduleItem.fromJson(normalizeKeys(m)))
          .toList();
      if (state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
      }
    } catch (e) {
      logDebug('Schedule fallback asset warning: $e');
    }
    try {
      final data = await remote;
      if (data.isNotEmpty) {
        state = data.map((m) => ScheduleItem.fromJson(normalizeKeys(m))).toList();
      }
    } catch (e) {
      logDebug('Schedule load from Supabase warning: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteSchedule() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getScheduleOnce(publishedOnly: publishedOnly);
  }

  void addScheduleItem(ScheduleItem item) {
    state = [...state, item];
    ref.read(supabaseDbServiceProvider).setScheduleItem(item.id, item.toJson());
  }

  void updateScheduleItem(ScheduleItem updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final s in state)
        if (s.id == updated.id) data else s,
    ];
    ref.read(supabaseDbServiceProvider).setScheduleItem(updated.id, data.toJson());
  }

  void deleteScheduleItem(String id) {
    state = state.where((s) => s.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteScheduleItem(id);
  }

  void togglePublish(String id) {
    final idx = state.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final s = state[idx];
    final toggled = s.copyWith(
      publicationStatus: s.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: s.publicationStatus != 'published' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final item in state)
        if (item.id == id) toggled else item,
    ];
    ref.read(supabaseDbServiceProvider).setScheduleItem(id, toggled.toJson());
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(
  () => ScheduleNotifier(),
);

final publicScheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(
  () => ScheduleNotifier(publishedOnly: true),
);
