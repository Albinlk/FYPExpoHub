import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/award.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import 'service_providers.dart';

// ==========================================
// PUBLISHED AWARD WINNERS STATE
// ==========================================
class AwardsNotifier extends Notifier<List<PublishedAwardWinner>> {
  AwardsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<PublishedAwardWinner> build() {
    _loadAwards();
    return [];
  }

  void _loadAwards() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getAwardWinnersOnce(publishedOnly: publishedOnly);
      state = data.map((m) => PublishedAwardWinner.fromJson(normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Awards load from Supabase warning: $e');
    }
  }

  void addWinner(PublishedAwardWinner winner) {
    state = [...state, winner];
    ref.read(supabaseDbServiceProvider).setAwardWinner(winner.id, winner.toJson());
  }

  void updateWinner(PublishedAwardWinner updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final w in state)
        if (w.id == updated.id) data else w,
    ];
    ref.read(supabaseDbServiceProvider).setAwardWinner(updated.id, data.toJson());
  }

  void deleteWinner(String id) {
    state = state.where((w) => w.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteAwardWinner(id);
  }
}

final awardsProvider =
    NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(
      () => AwardsNotifier(),
    );

final publicAwardsProvider =
    NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(
      () => AwardsNotifier(publishedOnly: true),
    );
