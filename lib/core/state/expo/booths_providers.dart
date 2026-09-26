import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_fallback.dart';
import '../../domain/models/booth.dart';
import '../../supabase/row_mappers.dart';
import '../../utils/logger.dart';
import 'optimistic_list.dart';
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

  /// Same pattern as ProjectsNotifier: fallback asset fills state first,
  /// live Supabase rows overwrite it when they arrive (remote wins). The
  /// admin instance skips the fallback — those rows can't be saved.
  void _loadBooths() async {
    final remote = _fetchRemoteBooths().catchError(
      (Object e) => <Map<String, dynamic>>[],
    );
    if (publishedOnly) {
      try {
        final data = await OfflineFallback.load();
        final fallback = _parse(data['booths'] ?? const []);
        if (state.isEmpty && fallback.isNotEmpty) {
          state = fallback;
        }
      } catch (e) {
        logDebug('Booths fallback asset warning: $e');
      }
    }
    try {
      var first = true;
      await loadRemote(() async {
        final data = first ? await remote : await _fetchRemoteBooths();
        first = false;
        return data.isEmpty ? null : _parse(data);
      });
    } catch (e) {
      logDebug('Booths load from Supabase warning: $e');
    }
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
