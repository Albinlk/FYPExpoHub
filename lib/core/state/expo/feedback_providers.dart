import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/feedback_entry.dart';
import '../../supabase/row_mappers.dart';
import '../../supabase/supabase_client_provider.dart';
import '../../utils/logger.dart';
import 'optimistic_list.dart';
import 'service_providers.dart';

// ==========================================
// FEEDBACK ENTRIES STATE
// ==========================================
class FeedbackEntriesNotifier extends Notifier<List<FeedbackEntry>>
    with OptimisticList<FeedbackEntry> {
  @override
  List<FeedbackEntry> build() {
    _loadFeedback();
    return [];
  }

  List<FeedbackEntry> _parse(List<Map<String, dynamic>> rows) {
    final out = <FeedbackEntry>[];
    for (final m in rows) {
      try {
        out.add(feedbackFromRow(m));
      } catch (e) {
        logDebug('Skipping unparseable feedback row ${m['id']}: $e');
      }
    }
    return out;
  }

  void _loadFeedback() async {
    try {
      await loadRemote(() async {
        final db = ref.read(supabaseDbServiceProvider);
        return _parse(await db.getFeedbackEntriesOnce());
      });
    } catch (e) {
      logDebug('Feedback load warning: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      state = _parse(await db.getFeedbackEntriesOnce());
    } catch (e) {
      logDebug('Feedback refresh failed: $e');
    }
  }

  /// A visitor's submission. Awaited so the form can tell the visitor
  /// whether it actually arrived; only the columns visitors may set are
  /// sent (see [feedbackSubmissionRow]).
  Future<void> submit(FeedbackEntry entry) async {
    final db = ref.read(supabaseDbServiceProvider);
    final eventId = await db.resolveEventId(entry.eventId);
    await db.submitFeedbackEntry(feedbackSubmissionRow(entry, eventId: eventId));
  }

  Future<void> _save(FeedbackEntry f) async {
    final db = ref.read(supabaseDbServiceProvider);
    final eventId =
        f.eventId.isEmpty ? null : await db.resolveEventId(f.eventId);
    await db.setFeedbackEntry(f.id, feedbackToRow(f, eventId: eventId));
  }

  Future<void> updateFeedbackEntry(FeedbackEntry updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    return commit(
      [for (final f in state) if (f.id == updated.id) data else f],
      () => _save(data),
    );
  }

  Future<void> deleteFeedbackEntry(String id) => commit(
        state.where((f) => f.id != id).toList(),
        () => ref.read(supabaseDbServiceProvider).deleteFeedbackEntry(id),
      );

  Future<void> setStatus(String id, String status) async {
    final idx = state.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    await updateFeedbackEntry(state[idx].copyWith(status: status));
  }

  Future<void> setAdminNote(String id, String note) async {
    final idx = state.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    await updateFeedbackEntry(state[idx].copyWith(adminNote: note));
  }
}

final feedbackEntriesProvider =
    NotifierProvider<FeedbackEntriesNotifier, List<FeedbackEntry>>(
      () => FeedbackEntriesNotifier(),
    );

final myFeedbackProvider = Provider<List<FeedbackEntry>>((ref) {
  final uid = ref.watch(currentAuthUserProvider)?.id;
  if (uid == null) return const [];
  return ref.watch(feedbackEntriesProvider).where((f) => f.userId == uid).toList();
});
