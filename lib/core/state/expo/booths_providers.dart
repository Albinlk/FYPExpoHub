import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_fallback.dart';
import '../../domain/models/booth.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import 'service_providers.dart';

// ==========================================
// PHYSICAL BOOTH ALLOCATIONS STATE
// ==========================================
class BoothsNotifier extends Notifier<List<Booth>> {
  BoothsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<Booth> build() {
    _loadBooths();
    return const [];
  }

  /// Same pattern as ProjectsNotifier: fallback asset fills state first,
  /// live Supabase rows overwrite it when they arrive (remote wins).
  void _loadBooths() async {
    final remote = _fetchRemoteBooths().catchError(
      (Object e) => <Map<String, dynamic>>[],
    );
    try {
      final data = await OfflineFallback.load();
      final fallback = (data['booths'] ?? const [])
          .map((m) => Booth.fromJson(normalizeKeys(m)))
          .toList();
      if (state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
      }
    } catch (e) {
      logDebug('Booths fallback asset warning: $e');
    }
    try {
      final data = await remote;
      if (data.isNotEmpty) {
        state = data.map((m) => Booth.fromJson(normalizeKeys(m))).toList();
      }
    } catch (e) {
      logDebug('Booths load from Supabase warning: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteBooths() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getBoothsOnce(publishedOnly: publishedOnly);
  }

  void addBooth(Booth booth) {
    state = [...state, booth];
    ref.read(supabaseDbServiceProvider).setBooth(booth.id, booth.toJson());
  }

  void updateBooth(Booth updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final b in state)
        if (b.id == updated.id) data else b,
    ];
    ref.read(supabaseDbServiceProvider).setBooth(updated.id, data.toJson());
  }

  void deleteBooth(String id) {
    state = state.where((b) => b.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteBooth(id);
  }
}

final boothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(
  () => BoothsNotifier(),
);

final publicBoothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(
  () => BoothsNotifier(publishedOnly: true),
);
