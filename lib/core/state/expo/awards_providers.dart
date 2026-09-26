import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/award.dart';
import '../../domain/models/award_category.dart';
import '../../supabase/row_mappers.dart';
import '../../utils/logger.dart';
import 'load_status.dart';
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
    var remoteFailed = false;
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
      remoteFailed = true;
      logDebug('Awards load from Supabase warning: $e');
    }
    // G-31: let public pages tell loading, offline data and failure apart.
    if (publishedOnly && ref.mounted) {
      ref
          .read(publicLoadStatusProvider(PublicDataset.awards).notifier)
          .set(loadOutcome(remoteFailed: remoteFailed, hasRows: state.isNotEmpty));
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

/// Award categories in display order (admins see hidden ones too).
final awardCategoriesProvider = FutureProvider<List<AwardCategoryItem>>((ref) async {
  final rows = await ref.read(supabaseDbServiceProvider).getAwardCategoriesOnce();
  return rows.map(AwardCategoryItem.fromRow).toList();
});
