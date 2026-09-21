import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/announcement.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import 'service_providers.dart';

// ==========================================
// ANNOUNCEMENTS STATE
// ==========================================
class AnnouncementsNotifier extends Notifier<List<Announcement>> {
  AnnouncementsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<Announcement> build() {
    _loadAnnouncements();
    return [];
  }

  void _loadAnnouncements() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getAnnouncementsOnce(publishedOnly: publishedOnly);
      state = data.map((m) => Announcement.fromJson(normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Announcements load from Supabase warning: $e');
    }
  }

  void addAnnouncement(Announcement ann) {
    state = [...state, ann];
    ref.read(supabaseDbServiceProvider).setAnnouncement(ann.id, ann.toJson());
  }

  void updateAnnouncement(Announcement updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final a in state)
        if (a.id == updated.id) data else a,
    ];
    ref.read(supabaseDbServiceProvider).setAnnouncement(updated.id, data.toJson());
  }

  void deleteAnnouncement(String id) {
    state = state.where((a) => a.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteAnnouncement(id);
  }

  void togglePinned(String id) {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final toggled = state[idx].copyWith(
      pinned: !state[idx].pinned,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final a in state)
        if (a.id == id) toggled else a,
    ];
    ref.read(supabaseDbServiceProvider).setAnnouncement(id, toggled.toJson());
  }

  void togglePublish(String id) {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final a = state[idx];
    final toggled = a.copyWith(
      publicationStatus: a.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: a.publicationStatus != 'published' ? DateTime.now() : a.publishedAt,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final item in state)
        if (item.id == id) toggled else item,
    ];
    ref.read(supabaseDbServiceProvider).setAnnouncement(id, toggled.toJson());
  }
}

final announcementsProvider =
    NotifierProvider<AnnouncementsNotifier, List<Announcement>>(
      () => AnnouncementsNotifier(),
    );

final publicAnnouncementsProvider =
    NotifierProvider<AnnouncementsNotifier, List<Announcement>>(
      () => AnnouncementsNotifier(publishedOnly: true),
    );
