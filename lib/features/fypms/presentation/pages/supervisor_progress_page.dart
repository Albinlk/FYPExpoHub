import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class SupervisorProgressPage extends ConsumerWidget {
  const SupervisorProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Supervisors view logs for their assigned records.
    // We'll list all logs across all assigned records.
    final assigned = ref.watch(assignedFypRecordsProvider(null));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Progress Reviews',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: assigned.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('No records assigned to you.'));
          }
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final record in records)
                _RecordProgressSection(record: record),
            ],
          );
        },
      ),
    );
  }
}

class _RecordProgressSection extends ConsumerWidget {
  final FypRecord record;

  const _RecordProgressSection({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(fypProgressLogsProvider(record.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceSm),
          child: Text(
            record.projectTitle ?? 'Untitled Project',
            style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
          ),
        ),
        logs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No progress logs submitted.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                for (final log in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: Text('W${log.weekNumber}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                      title: Text(log.summary, style: DesignSystem.bodySm),
                      subtitle: Text(
                        'Status: ${log.status.replaceAll('_', ' ')}',
                        style: DesignSystem.bodySm,
                      ),
                      trailing: log.status == 'submitted'
                          ? FilledButton(
                              onPressed: () => _showReviewDialog(context, ref, record.id, log.id),
                              child: const Text('Review'),
                            )
                          : const Icon(Icons.check_circle, color: DesignSystem.secondary),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: DesignSystem.spaceLg),
      ],
    );
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, String recordId, String logId) {
    final decisionController = TextEditingController();
    String decision = 'validated';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: DesignSystem.surfaceContainerLowest,
          title: Text('Review Progress Log', style: DesignSystem.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: decision,
                decoration: const InputDecoration(labelText: 'Decision'),
                items: const [
                  DropdownMenuItem(value: 'validated', child: Text('Validate')),
                  DropdownMenuItem(value: 'rejected', child: Text('Reject')),
                ],
                onChanged: (v) => decision = v!,
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              TextField(
                controller: decisionController,
                decoration: const InputDecoration(labelText: 'Validation Comment (optional)'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(validateProgressLogProvider)(
                    logId,
                    decision,
                    decisionController.text.trim().isEmpty
                        ? null
                        : decisionController.text.trim(),
                    recordId,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Log ${decision.toLowerCase()}.')),
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
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
