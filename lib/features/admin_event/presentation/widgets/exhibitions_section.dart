import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/supabase/supabase_database_service.dart' show ActiveEvent;
import '../../../../core/widgets/admin_actions.dart';
import '../../../public_archive/archive_data.dart';

/// Admin: every exhibition, which one is current, and a new one (backlog S6).
/// Switching keeps the old exhibition's data; it moves to the archive.
class ExhibitionsSection extends ConsumerWidget {
  const ExhibitionsSection({super.key});

  /// Re-reads every list that is scoped to the current exhibition.
  static void refreshScopedData(WidgetRef ref) {
    for (final p in [
      projectsProvider,
      publicProjectsProvider,
      boothsProvider,
      publicBoothsProvider,
      scheduleProvider,
      publicScheduleProvider,
      announcementsProvider,
      publicAnnouncementsProvider,
      awardsProvider,
      publicAwardsProvider,
    ]) {
      ref.invalidate(p);
    }
    ref.invalidate(eventProvider);
    ref.invalidate(awardCategoriesProvider);
    ref.invalidate(exhibitionsProvider);
  }

  Future<void> _makeCurrent(BuildContext context, WidgetRef ref, ExhibitionSummary e) async {
    final ok = await confirmAction(
      context,
      title: 'Switch the current exhibition',
      message: 'Make "${e.title}" the exhibition the public site and admin show? '
          'The current one keeps its data and moves to Past exhibitions.',
      confirmLabel: 'Switch',
    );
    if (!ok || !context.mounted) return;
    await runAdminWrite(context, () async {
      await ref.read(supabaseClientProvider).rpc<dynamic>('set_current_event', params: {'p_event_id': e.id});
      ActiveEvent.slug = e.slug;
      refreshScopedData(ref);
    }, success: '${e.title} is now the current exhibition.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(exhibitionsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Exhibitions', style: DesignSystem.h3Mobile.copyWith(color: DesignSystem.primary))),
                TextButton.icon(
                  onPressed: () => showDialog<void>(context: context, builder: (_) => const _NewExhibitionDialog()),
                  icon: const Icon(Icons.add),
                  label: const Text('New exhibition'),
                ),
              ],
            ),
            events.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Could not load exhibitions: ${friendlyError(e)}'),
              data: (list) => Column(
                children: [
                  for (final e in list)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(e.isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: e.isCurrent ? DesignSystem.secondary : DesignSystem.onSurfaceVariant),
                      title: Text(e.title),
                      subtitle: Text('${e.slug} · ${e.year}${e.isCurrent ? ' · current' : ''}'),
                      trailing: e.isCurrent
                          ? null
                          : OutlinedButton(
                              key: Key('make-current-${e.slug}'),
                              onPressed: () => _makeCurrent(context, ref, e),
                              child: const Text('Make current'),
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewExhibitionDialog extends ConsumerStatefulWidget {
  const _NewExhibitionDialog();

  @override
  ConsumerState<_NewExhibitionDialog> createState() => _NewExhibitionDialogState();
}

class _NewExhibitionDialogState extends ConsumerState<_NewExhibitionDialog> {
  final _slug = TextEditingController();
  final _title = TextEditingController();
  final _venue = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _slug.dispose();
    _title.dispose();
    _venue.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: (start ? _start : _end) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => start ? _start = d : _end = d);
  }

  /// 09:00 on the first day to 17:00 on the last, Malaysia time.
  static String _myt(DateTime day, int hour) =>
      DateTime.utc(day.year, day.month, day.day, hour - 8).toIso8601String();

  Future<void> _create() async {
    final nav = Navigator.of(context);
    final ok = await runAdminWrite(context, () async {
      await ref.read(supabaseClientProvider).rpc<dynamic>('create_exhibition_event', params: {
        'p_slug': _slug.text.trim(),
        'p_title': _title.text.trim(),
        'p_start_at': _myt(_start!, 9),
        'p_end_at': _myt(_end!, 17),
        'p_venue': _venue.text.trim().isEmpty ? null : _venue.text.trim(),
      });
      ref.invalidate(exhibitionsProvider);
    }, success: 'Exhibition created. Make it current when it is ready.');
    if (ok) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ready = RegExp(r'^[a-z0-9][a-z0-9-]{2,59}$').hasMatch(_slug.text.trim()) &&
        _title.text.trim().isNotEmpty &&
        _start != null &&
        _end != null &&
        !_end!.isBefore(_start!);
    return AlertDialog(
      title: const Text('New exhibition'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('exhibition-slug'),
              controller: _slug,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Slug (e.g. fskm-fyp-2027)'),
            ),
            TextField(
              key: const Key('exhibition-title'),
              controller: _title,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(controller: _venue, decoration: const InputDecoration(labelText: 'Venue (optional)')),
            const SizedBox(height: DesignSystem.spaceSm),
            Wrap(
              spacing: DesignSystem.spaceSm,
              children: [
                OutlinedButton(onPressed: () => _pick(true), child: Text(_start == null ? 'First day' : 'From ${_start!.day}/${_start!.month}/${_start!.year}')),
                OutlinedButton(onPressed: () => _pick(false), child: Text(_end == null ? 'Last day' : 'To ${_end!.day}/${_end!.month}/${_end!.year}')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _create : null, child: const Text('Create')),
      ],
    );
  }
}
