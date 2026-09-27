import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/domain/models/award.dart';
import '../../core/domain/models/project.dart';
import '../../core/state/state_providers.dart';
import '../../core/supabase/row_mappers.dart';

/// One exhibition (an `events` row) as listed in the archive and the admin
/// Exhibitions section (backlog S6, S7).
class ExhibitionSummary {
  const ExhibitionSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.startAt,
    this.venue,
    this.isCurrent = false,
  });

  factory ExhibitionSummary.fromRow(Map<String, dynamic> m) => ExhibitionSummary(
        id: m['id'] as String? ?? '',
        slug: m['slug'] as String? ?? '',
        title: m['title'] as String? ?? '',
        startAt: DateTime.tryParse(m['start_at'] as String? ?? '') ?? DateTime(1970),
        venue: m['venue'] as String?,
        isCurrent: m['is_current'] as bool? ?? false,
      );

  final String id;
  final String slug;
  final String title;
  final DateTime startAt;
  final String? venue;
  final bool isCurrent;

  /// The exhibition's year in Malaysia time.
  int get year => startAt.toUtc().add(const Duration(hours: 8)).year;
}

/// Every exhibition the viewer may see, newest first.
final exhibitionsProvider = FutureProvider<List<ExhibitionSummary>>((ref) async {
  final rows = await ref.read(supabaseDbServiceProvider).getEventsOnce();
  return rows.map(ExhibitionSummary.fromRow).toList();
});

/// A past exhibition's published projects and award winners.
final archivedEventProvider =
    FutureProvider.family<(ExhibitionSummary, List<Project>, List<PublishedAwardWinner>), String>((ref, slug) async {
  final events = await ref.watch(exhibitionsProvider.future);
  final event = events.firstWhere((e) => e.slug == slug, orElse: () => throw StateError('Exhibition not found.'));
  final db = ref.read(supabaseDbServiceProvider);
  final projects = <Project>[];
  for (final m in await db.getEventProjectsOnce(event.id)) {
    try {
      projects.add(projectFromRow(m));
    } catch (_) {
      // One malformed row shouldn't hide the rest of the archive.
    }
  }
  final winners = <PublishedAwardWinner>[];
  for (final m in await db.getEventAwardWinnersOnce(event.id)) {
    try {
      winners.add(awardWinnerFromRow(m));
    } catch (_) {}
  }
  return (event, projects, winners);
});
