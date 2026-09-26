import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/award.dart';
import '../../supabase/row_mappers.dart';
import '../../utils/logger.dart';
import 'optimistic_list.dart';
import 'service_providers.dart';

// ==========================================
// PUBLISHED AWARD WINNERS STATE
// ==========================================
class AwardsNotifier extends Notifier<List<PublishedAwardWinner>>
    with OptimisticList<PublishedAwardWinner> {
  AwardsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<PublishedAwardWinner> build() {
    _loadAwards();
    return [];
  }

  void _loadAwards() async {
    try {
      await loadRemote(() async {
        final db = ref.read(supabaseDbServiceProvider);
        final data = await db.getAwardWinnersOnce(publishedOnly: publishedOnly);
        final out = <PublishedAwardWinner>[];
        for (final m in data) {
          try {
            out.add(awardWinnerFromRow(m));
          } catch (e) {
            logDebug('Skipping unparseable award row ${m['id']}: $e');
          }
        }
        return out;
      });
    } catch (e) {
      logDebug('Awards load from Supabase warning: $e');
    }
  }

  Future<void> _save(PublishedAwardWinner w) async {
    final db = ref.read(supabaseDbServiceProvider);
    final eventId = await db.resolveEventId(w.eventId);
    await db.setAwardWinner(w.id, awardWinnerToRow(w, eventId: eventId));
    if (!publishedOnly) ref.invalidate(publicAwardsProvider);
  }

  Future<void> addWinner(PublishedAwardWinner winner) =>
      commit([...state, winner], () => _save(winner));

  Future<void> updateWinner(PublishedAwardWinner updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    return commit(
      [for (final w in state) if (w.id == updated.id) data else w],
      () => _save(data),
    );
  }

  Future<void> deleteWinner(String id) => commit(
        state.where((w) => w.id != id).toList(),
        () async {
          await ref.read(supabaseDbServiceProvider).deleteAwardWinner(id);
          if (!publishedOnly) ref.invalidate(publicAwardsProvider);
        },
      );
}

final awardsProvider =
    NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(
      () => AwardsNotifier(),
    );

final publicAwardsProvider =
    NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(
      () => AwardsNotifier(publishedOnly: true),
    );
