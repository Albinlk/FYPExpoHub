import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/announcement.dart';
import '../../supabase/row_mappers.dart';
import '../../utils/logger.dart';
import 'optimistic_list.dart';
import 'service_providers.dart';

// ==========================================
// ANNOUNCEMENTS STATE
// ==========================================
class AnnouncementsNotifier extends Notifier<List<Announcement>>
    with OptimisticList<Announcement> {
  AnnouncementsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<Announcement> build() {
    _loadAnnouncements();
    return [];
  }

  void _loadAnnouncements() async {
    try {
      await loadRemote(() async {
        final db = ref.read(supabaseDbServiceProvider);
        final data = await db.getAnnouncementsOnce(publishedOnly: publishedOnly);
        final out = <Announcement>[];
        for (final m in data) {
          try {
            out.add(announcementFromRow(m));
          } catch (e) {
            logDebug('Skipping unparseable announcement row ${m['id']}: $e');
          }
        }
        return out;
      });
    } catch (e) {
      logDebug('Announcements load from Supabase warning: $e');
    }
  }

  Future<void> _save(Announcement a) async {
    final db = ref.read(supabaseDbServiceProvider);
    final eventId = await db.resolveEventId(a.eventId);
    await db.setAnnouncement(a.id, announcementToRow(a, eventId: eventId));
    if (!publishedOnly) ref.invalidate(publicAnnouncementsProvider);
  }

  Future<void> addAnnouncement(Announcement ann) =>
      commit([...state, ann], () => _save(ann));

  Future<void> updateAnnouncement(Announcement updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    return commit(
      [for (final a in state) if (a.id == updated.id) data else a],
      () => _save(data),
    );
  }

  Future<void> deleteAnnouncement(String id) => commit(
        state.where((a) => a.id != id).toList(),
        () async {
          await ref.read(supabaseDbServiceProvider).deleteAnnouncement(id);
          if (!publishedOnly) ref.invalidate(publicAnnouncementsProvider);
        },
      );

  Future<void> togglePinned(String id) async {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final toggled = state[idx].copyWith(
      pinned: !state[idx].pinned,
      updatedAt: DateTime.now(),
    );
    await commit(
      [for (final a in state) if (a.id == id) toggled else a],
      () => _save(toggled),
    );
  }

  Future<void> togglePublish(String id) async {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final a = state[idx];
    final toggled = a.copyWith(
      publicationStatus: a.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: a.publicationStatus != 'published' ? DateTime.now() : a.publishedAt,
      updatedAt: DateTime.now(),
    );
    await commit(
      [for (final item in state) if (item.id == id) toggled else item],
      () => _save(toggled),
    );
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
