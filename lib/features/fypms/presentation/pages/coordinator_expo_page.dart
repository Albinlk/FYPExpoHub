import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CoordinatorExpoPage extends ConsumerWidget {
  const CoordinatorExpoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publications = ref.watch(fypExpoPublicationsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Expo Publications',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: publications.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pubs) => ListView(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          children: [
            FilledButton.icon(
              onPressed: () => _showPrepareDialog(context, ref),
              style: FilledButton.styleFrom(
                backgroundColor: DesignSystem.secondary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Prepare Publication'),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            if (pubs.isEmpty)
              const Center(child: Text('No publications prepared yet.'))
            else
              for (final pub in pubs)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                    leading: Icon(
                      pub.status == 'published' ? Icons.public : Icons.public_off,
                      size: 40,
                      color: pub.status == 'published' ? DesignSystem.secondary : DesignSystem.primary,
                    ),
                    title: Text(
                      (pub.payload['title'] as String?)?.isNotEmpty == true
                          ? pub.payload['title'] as String
                          : 'Untitled Project',
                      style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: ${pub.status} | ${pub.eventId}',
                      style: DesignSystem.bodySm,
                    ),
                    trailing: pub.status == 'ready'
                        ? FilledButton(
                            onPressed: () => _publish(context, ref, pub.id),
                            style: FilledButton.styleFrom(
                              backgroundColor: DesignSystem.secondary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Publish'),
                          )
                        : null,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _showPrepareDialog(BuildContext context, WidgetRef ref) {
    String? recordId;
    String? eventId;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('Prepare Publication', style: DesignSystem.h2),
              content: Column(
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
                  Consumer(
                    builder: (context, ref, _) {
                      final events = ref.watch(fypPublishedEventsProvider);
                      return events.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                        data: (items) => DropdownButtonFormField<String>(
                          initialValue: eventId,
                          decoration: const InputDecoration(labelText: 'Event'),
                          items: [
                            for (final e in items)
                              DropdownMenuItem(
                                value: e['id'] as String?,
                                child: Text(
                                  e['title'] as String? ?? 'Event',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(() => eventId = v),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: recordId == null || eventId == null
                      ? null
                      : () async {
                          try {
                            await ref.read(prepareExpoPublicationProvider)(
                              recordId!,
                              eventId!,
                              null,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Publication prepared.')),
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
                  child: const Text('Prepare'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _publish(BuildContext context, WidgetRef ref, String publicationId) async {
    try {
      await ref.read(publishFypRecordToExpoProvider)(publicationId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Published to Expo.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}
