import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_fallback.dart';
import '../../domain/models/booth.dart';
import '../../supabase/row_mappers.dart';
import '../../utils/logger.dart';
import 'load_status.dart';
import 'optimistic_list.dart';
import '../../supabase/supabase_database_service.dart' show ActiveEvent;
import 'service_providers.dart';

// ==========================================
// PHYSICAL BOOTH ALLOCATIONS STATE
// ==========================================
class BoothsNotifier extends Notifier<List<Booth>> with OptimisticList<Booth> {
  BoothsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<Booth> build() {
    _loadBooths();
    return const [];
  }

  List<Booth> _parse(List<Map<String, dynamic>> rows) {
    final out = <Booth>[];
    for (final m in rows) {
      try {
        out.add(boothFromRow(m));
      } catch (e) {
        logDebug('Skipping unparseable booth row ${m['id']}: $e');
      }
    }
    return out;
  }

  /// Same pattern as ProjectsNotifier: the fallback asset is fetched only
  /// when the live request is slow, fails or answers empty, and live
  /// Supabase rows overwrite it when they arrive (remote wins). The admin
  /// instance skips the fallback — those rows can't be saved.
  void _loadBooths() async {
    var remoteFailed = false;
    final remote = _fetchRemoteBooths().catchError((Object e) {
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
        final data = first ? await remote : await _fetchRemoteBooths();
        first = false;
        return data.isEmpty ? null : _parse(data);
      });
    } catch (e) {
      remoteFailed = true;
      logDebug('Booths load from Supabase warning: $e');
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
      final fallback = _parse(data['booths'] ?? const []);
      if (ref.mounted && state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
        // The request already failed: this saved copy is all there is.
        if (remoteFailed()) _reportLoad(remoteFailed: true);
      }
    } catch (e) {
      logDebug('Booths fallback asset warning: $e');
    }
  }

  /// G-31: lets public pages tell loading, offline data and failure apart.
  void _reportLoad({required bool remoteFailed}) {
    if (!publishedOnly || !ref.mounted) return;
    ref
        .read(publicLoadStatusProvider(PublicDataset.booths).notifier)
        .set(loadOutcome(remoteFailed: remoteFailed, hasRows: state.isNotEmpty));
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteBooths() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getBoothsOnce(publishedOnly: publishedOnly);
  }

  Future<void> _save(Booth b) async {
    final db = ref.read(supabaseDbServiceProvider);
    final eventId = await db.resolveEventId(b.eventId);
    await db.setBooth(b.id, boothToRow(b, eventId: eventId));
    if (!publishedOnly) ref.invalidate(publicBoothsProvider);
  }

  Future<void> addBooth(Booth booth) =>
      commit([...state, booth], () => _save(booth));

  Future<void> updateBooth(Booth updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    return commit(
      [for (final b in state) if (b.id == updated.id) data else b],
      () => _save(data),
    );
  }

  Future<void> deleteBooth(String id) => commit(
        state.where((b) => b.id != id).toList(),
        () async {
          await ref.read(supabaseDbServiceProvider).deleteBooth(id);
          if (!publishedOnly) ref.invalidate(publicBoothsProvider);
        },
      );
}

final boothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(
  () => BoothsNotifier(),
);

final publicBoothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(
  () => BoothsNotifier(publishedOnly: true),
);
