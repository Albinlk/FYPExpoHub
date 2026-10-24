import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_fallback.dart';
import '../../domain/models/schedule_item.dart';
import '../../supabase/row_mappers.dart';
import '../../utils/logger.dart';
import 'load_status.dart';
import 'optimistic_list.dart';
import '../../supabase/supabase_database_service.dart' show ActiveEvent;
import 'service_providers.dart';

// ==========================================
// DAILY SCHEDULE STATE
// ==========================================
class ScheduleNotifier extends Notifier<List<ScheduleItem>>
    with OptimisticList<ScheduleItem> {
  ScheduleNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<ScheduleItem> build() {
    _loadSchedule();
    return const [];
  }

  List<ScheduleItem> _parse(List<Map<String, dynamic>> rows) {
    final out = <ScheduleItem>[];
    for (final m in rows) {
      try {
        out.add(scheduleItemFromRow(m));
      } catch (e) {
        logDebug('Skipping unparseable schedule row ${m['id']}: $e');
      }
    }
    return out;
  }

  /// Same pattern as ProjectsNotifier: the fallback asset is fetched only
  /// when the live request is slow, fails or answers empty, and live
  /// Supabase rows overwrite it when they arrive (remote wins). The admin
  /// instance skips the fallback — those rows can't be saved.
  void _loadSchedule() async {
    var remoteFailed = false;
    final remote = _fetchRemoteSchedule().catchError((Object e) {
      remoteFailed = true;
      return <Map<String, dynamic>>[];
    });
    // The bundled data is the default event's; never show it for another.
    final canFallback = publishedOnly && ActiveEvent.usesBundledData;
    // A slow request: past the timeout the bundled copy fills the list
    // meanwhile (live rows still replace it). A fast answer cancels this,
    // so a normal visit never downloads the asset.
    final slow = canFallback
        ? Timer(OfflineFallback.slowLiveTimeout, () => unawaited(_applyFallback(() => remoteFailed)))
        : null;
    if (slow != null) ref.onDispose(slow.cancel);
    try {
      var first = true;
      await loadRemote(() async {
        final data = first ? await remote : await _fetchRemoteSchedule();
        first = false;
        return data.isEmpty ? null : _parse(data);
      });
    } catch (e) {
      remoteFailed = true;
      logDebug('Schedule load from Supabase warning: $e');
    }
    slow?.cancel();
    _reportLoad(remoteFailed: remoteFailed);
    // A failed or empty answer with nothing showing: fetch the bundled copy
    // now (a failure then moves on from "failed" to "offline" when it lands).
    if (canFallback && ref.mounted && state.isEmpty) {
      unawaited(_applyFallback(() => remoteFailed));
    }
  }

  /// Fills state from the bundled offline data if nothing has arrived yet.
  Future<void> _applyFallback(bool Function() remoteFailed) async {
    if (!ref.mounted || state.isNotEmpty) return;
    try {
      final data = await OfflineFallback.load();
      final fallback = _parse(data['scheduleItems'] ?? const []);
      if (ref.mounted && state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
        // The request already failed: this saved copy is all there is.
        if (remoteFailed()) _reportLoad(remoteFailed: true);
      }
    } catch (e) {
      logDebug('Schedule fallback asset warning: $e');
    }
  }

  /// G-31: lets public pages tell loading, offline data and failure apart.
  void _reportLoad({required bool remoteFailed}) {
    if (!publishedOnly || !ref.mounted) return;
    ref
        .read(publicLoadStatusProvider(PublicDataset.schedule).notifier)
        .set(loadOutcome(remoteFailed: remoteFailed, hasRows: state.isNotEmpty));
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteSchedule() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getScheduleOnce(publishedOnly: publishedOnly);
  }

  Future<void> _save(ScheduleItem s) async {
    final db = ref.read(supabaseDbServiceProvider);
    final eventId = await db.resolveEventId(s.eventId);
    await db.setScheduleItem(s.id, scheduleItemToRow(s, eventId: eventId));
    if (!publishedOnly) ref.invalidate(publicScheduleProvider);
  }

  Future<void> addScheduleItem(ScheduleItem item) =>
      commit([...state, item], () => _save(item));

  Future<void> updateScheduleItem(ScheduleItem updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    return commit(
      [for (final s in state) if (s.id == updated.id) data else s],
      () => _save(data),
    );
  }

  Future<void> deleteScheduleItem(String id) => commit(
        state.where((s) => s.id != id).toList(),
        () async {
          await ref.read(supabaseDbServiceProvider).deleteScheduleItem(id);
          if (!publishedOnly) ref.invalidate(publicScheduleProvider);
        },
      );

  Future<void> togglePublish(String id) async {
    final idx = state.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final s = state[idx];
    final toggled = s.copyWith(
      publicationStatus: s.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: s.publicationStatus != 'published' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    await commit(
      [for (final item in state) if (item.id == id) toggled else item],
      () => _save(toggled),
    );
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(
  () => ScheduleNotifier(),
);

final publicScheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(
  () => ScheduleNotifier(publishedOnly: true),
);
