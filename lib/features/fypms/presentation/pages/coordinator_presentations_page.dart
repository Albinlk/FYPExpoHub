import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_presentation_session.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../widgets/create_session_dialog.dart';
import '../widgets/fypms_loading_widget.dart';
import '../../../../core/widgets/async_state.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/busy_button.dart';
import '../../../../core/layout/responsive.dart';

/// Presentation sessions and slots, for the coordinator (all courses) and
/// the CSP lecturers (their own course offerings, per RLS).
class CoordinatorPresentationsPage extends ConsumerWidget {
  const CoordinatorPresentationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(fypPresentationSessionsProvider);
    final offerings = ref.watch(
          ref.watch(isFypCoordinatorProvider) ? fypmsOfferingsProvider : myFypmsOfferingsProvider,
        ).value ??
        const [];

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Presentations',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: offerings.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => CreateSessionDialog(offerings: offerings),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New Session'),
            ),
      body: sessions.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypPresentationSessionsProvider), what: 'this page'),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No presentation sessions scheduled yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: list.length,
            itemBuilder: (context, itemIndex) {
              final session = list[itemIndex];
                return Card(
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
                    trailing: PopupMenuButton<String>(
                      key: Key('session-menu-${session.sessionCode}'),
                      tooltip: 'Session actions',
                      onSelected: (a) => a == 'edit'
                          ? showDialog<void>(
                              context: context,
                              builder: (_) => CreateSessionDialog(offerings: offerings, session: session),
                            )
                          : _deleteSession(context, ref, session),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit…')),
                        PopupMenuItem(value: 'delete', child: Text('Delete…')),
                      ],
                    ),
                    onTap: () => _showSessionDetail(context, ref, session.id),
                  ),
                );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteSession(BuildContext context, WidgetRef ref, FypPresentationSession session) async {
    final ok = await confirmAction(
      context,
      title: 'Delete session',
      message: 'Delete ${session.sessionCode} — ${session.sessionTitle}? Its scheduled slots are removed too.',
      confirmLabel: 'Delete',
    );
    if (!ok || !context.mounted) return;
    await runAdminWrite(context, () async {
      await ref.read(supabaseRpcServiceProvider).deletePresentationSession(sessionId: session.id);
      ref.invalidate(fypPresentationSessionsProvider);
    }, success: 'Session deleted.');
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
            width: dialogWidth(context, 480),
            child: Consumer(
              builder: (context, ref, _) {
                final slots = ref.watch(fypPresentationSlotsProvider(sessionId));
                return slots.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypPresentationSlotsProvider(sessionId)), what: 'this section'),
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
                            trailing: IconButton(
                              tooltip: 'Remove slot',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final ok = await confirmDelete(context, 'slot ${slot.slotNumber}');
                                if (!ok || !context.mounted) return;
                                await runAdminWrite(context, () async {
                                  await ref.read(supabaseRpcServiceProvider).deletePresentationSlot(slotId: slot.id);
                                  ref.invalidate(fypPresentationSlotsProvider(sessionId));
                                }, success: 'Slot removed.');
                              },
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
    var busy = false;
    String? error;

    showDialog<void>(
      context: context,
      // A stray tap outside must not discard what was entered.
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickStart() async {
              final t = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay.fromDateTime(startAt),
              );
              if (t != null) {
                setState(() {
                  startAt = DateTime(baseDate.year, baseDate.month, baseDate.day, t.hour, t.minute);
                });
              }
            }

            Future<void> pickEnd() async {
              final t = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay.fromDateTime(endAt),
              );
              if (t != null) {
                setState(() {
                  endAt = DateTime(baseDate.year, baseDate.month, baseDate.day, t.hour, t.minute);
                });
              }
            }

            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('Schedule Slot', style: DesignSystem.h2),
              content: SizedBox(
                width: dialogWidth(dialogContext, 400),
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final records = ref.watch(fypRecordsProvider);
                        return records.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypRecordsProvider), what: 'this section'),
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    if (error != null) ...[
                      const SizedBox(height: DesignSystem.spaceSm),
                      Semantics(
                        liveRegion: true,
                        child: Text(error!, style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
                      ),
                    ],
                  ],
                ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                BusyButton(
                  label: 'Schedule',
                  busyLabel: 'Scheduling…',
                  busy: busy,
                  onPressed: recordId == null || slotController.text.trim().isEmpty
                      ? null
                      : () async {
                          final slotNumber = int.tryParse(slotController.text.trim());
                          if (slotNumber == null || slotNumber < 1) {
                            setState(() => error = 'Enter a slot number of 1 or more.');
                            return;
                          }
                          if (!endAt.isAfter(startAt)) {
                            setState(() => error = 'The end time must be after the start time.');
                            return;
                          }
                          setState(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            await ref.read(schedulePresentationSlotProvider)(
                              session.id,
                              recordId!,
                              slotNumber,
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
                              setState(() {
                                busy = false;
                                error = 'Could not schedule the slot: ${friendlyError(e)}';
                              });
                            }
                          }
                        },
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
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}';
  }
}
