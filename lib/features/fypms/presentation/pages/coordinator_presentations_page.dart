import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_presentation_session.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CoordinatorPresentationsPage extends ConsumerWidget {
  const CoordinatorPresentationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(fypPresentationSessionsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Presentations',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: sessions.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No presentation sessions scheduled yet.'));
          }
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final session in list)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                    leading: const Icon(Icons.event, size: 40, color: DesignSystem.primary),
                    title: Text(
                      '${session.sessionCode} — ${session.sessionTitle}',
                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${session.sessionType.toUpperCase()} | ${_formatDate(session.eventDate)} | '
                      '${session.venue ?? 'TBC'}',
                      style: DesignSystem.bodySm,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showSessionDetail(context, ref, session.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showSessionDetail(BuildContext context, WidgetRef ref, String sessionId) {
    final sessions = ref.read(fypPresentationSessionsProvider);
    final session = sessions.value?.where((s) => s.id == sessionId).firstOrNull;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: DesignSystem.surfaceContainerLowest,
          title: Text('Presentation Slots', style: DesignSystem.h2),
          content: SizedBox(
            width: 480,
            child: Consumer(
              builder: (context, ref, _) {
                final slots = ref.watch(fypPresentationSlotsProvider(sessionId));
                return slots.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (slotList) {
                    if (slotList.isEmpty) {
                      return const Text('No slots scheduled for this session yet.');
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final slot in slotList)
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.schedule, color: DesignSystem.primary),
                            title: Text('Slot ${slot.slotNumber}', style: DesignSystem.bodyMd),
                            subtitle: Text(
                              '${_formatTime(slot.startAt)} - ${_formatTime(slot.endAt)}'
                              '${slot.room != null ? ' | ${slot.room}' : ''}',
                              style: DesignSystem.bodySm,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            if (session != null)
              FilledButton.icon(
                onPressed: () => _showScheduleSlotDialog(context, ref, session),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Schedule Slot'),
              ),
          ],
        );
      },
    );
  }

  void _showScheduleSlotDialog(
      BuildContext context, WidgetRef ref, FypPresentationSession session) {
    String? recordId;
    final slotController = TextEditingController();
    final roomController = TextEditingController();
    final baseDate = session.eventDate.toLocal();
    var startAt = DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0);
    var endAt = DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 30);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        Future<void> pickStart() async {
          final t = await showTimePicker(
            context: dialogContext,
            initialTime: TimeOfDay.fromDateTime(startAt),
          );
          if (t != null) {
            startAt = DateTime(baseDate.year, baseDate.month, baseDate.day, t.hour, t.minute);
          }
        }

        Future<void> pickEnd() async {
          final t = await showTimePicker(
            context: dialogContext,
            initialTime: TimeOfDay.fromDateTime(endAt),
          );
          if (t != null) {
            endAt = DateTime(baseDate.year, baseDate.month, baseDate.day, t.hour, t.minute);
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('Schedule Slot', style: DesignSystem.h2),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final records = ref.watch(fypRecordsProvider);
                        return records.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                          data: (items) => DropdownButtonFormField<String>(
                            initialValue: recordId,
                            decoration: const InputDecoration(labelText: 'FYP Record'),
                            items: [
                              for (final r in items)
                                DropdownMenuItem(
                                  value: r.id,
                                  child: Text(
                                    r.projectTitle?.isNotEmpty == true
                                        ? r.projectTitle!
                                        : 'Untitled (${r.currentCourseCode})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (v) => setState(() => recordId = v),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: slotController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(labelText: 'Slot Number'),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: pickStart,
                            child: Text('Start: ${_formatTime(startAt)}'),
                          ),
                        ),
                        const SizedBox(width: DesignSystem.spaceSm),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: pickEnd,
                            child: Text('End: ${_formatTime(endAt)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: roomController,
                      decoration: const InputDecoration(labelText: 'Room (optional)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: recordId == null || slotController.text.trim().isEmpty
                      ? null
                      : () async {
                          try {
                            await ref.read(schedulePresentationSlotProvider)(
                              session.id,
                              recordId!,
                              int.parse(slotController.text.trim()),
                              startAt,
                              endAt,
                              roomController.text.trim().isEmpty
                                  ? null
                                  : roomController.text.trim(),
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Slot scheduled.')),
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          }
                        },
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}-${local.month.toString().padLeft(2, '0')}-${local.year}';
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}';
  }
}
