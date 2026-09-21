import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/feedback_entry.dart';
import '../../supabase/supabase_client_provider.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import 'service_providers.dart';

// ==========================================
// FEEDBACK ENTRIES STATE
// ==========================================
class FeedbackEntriesNotifier extends Notifier<List<FeedbackEntry>> {
  @override
  List<FeedbackEntry> build() {
    _loadFeedback();
    return [];
  }

  void _loadFeedback() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getFeedbackEntriesOnce();
      state = data.map((m) => FeedbackEntry.fromJson(normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Feedback load warning: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getFeedbackEntriesOnce();
      state = data.map((m) => FeedbackEntry.fromJson(normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Feedback refresh failed: $e');
    }
  }

  void addFeedbackEntry(FeedbackEntry entry) {
    state = [entry, ...state];
    ref.read(supabaseDbServiceProvider).setFeedbackEntry(entry.id, entry.toJson());
  }

  void updateFeedbackEntry(FeedbackEntry updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final f in state)
        if (f.id == updated.id) data else f,
    ];
    ref.read(supabaseDbServiceProvider).setFeedbackEntry(updated.id, data.toJson());
  }

  void deleteFeedbackEntry(String id) {
    state = state.where((f) => f.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteFeedbackEntry(id);
  }

  void setStatus(String id, String status) {
    final idx = state.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    final updated = state[idx].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    updateFeedbackEntry(updated);
  }

  void setAdminNote(String id, String note) {
    final idx = state.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    final updated = state[idx].copyWith(
      adminNote: note,
      updatedAt: DateTime.now(),
    );
    updateFeedbackEntry(updated);
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
