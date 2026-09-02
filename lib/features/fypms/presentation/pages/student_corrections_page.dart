import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_correction_item.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentCorrectionsPage extends ConsumerWidget {
  const StudentCorrectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Corrections',
      builder: (context, ref, record) {
        final items = ref.watch(fypCorrectionItemsProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Correction Items', style: DesignSystem.h2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No corrections required.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final item in list)
                        Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                            leading: Icon(
                              item.severity == 'major' ? Icons.warning_amber : Icons.fact_check,
                              size: 40,
                              color: item.severity == 'major'
                                  ? DesignSystem.error
                                  : DesignSystem.primary,
                            ),
                            title: Text(
                              '${item.itemCode ?? 'Correction'} — ${item.severity}',
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description, style: DesignSystem.bodySm),
                                const SizedBox(height: DesignSystem.spaceXs),
                                Text(
                                  'Status: ${item.status.replaceAll('_', ' ')}',
                                  style: DesignSystem.bodySm.copyWith(
                                    color: _statusColor(item.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: _trailingFor(context, ref, record.id, item),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _trailingFor(
    BuildContext context,
    WidgetRef ref,
    String recordId,
    FypCorrectionItem item,
  ) {
    if (item.status == 'confirmed' || item.status == 'closed') {
      return const Icon(Icons.check_circle, color: DesignSystem.secondary);
    }
    if (item.status == 'evidence_submitted') {
      return Chip(
        label: const Text('Awaiting review'),
        backgroundColor: DesignSystem.surfaceContainerHighest,
        labelStyle: DesignSystem.bodySm,
      );
    }
    return FilledButton(
      onPressed: () => _showEvidenceDialog(context, ref, recordId, item.id),
      style: FilledButton.styleFrom(
        backgroundColor: DesignSystem.secondary,
        foregroundColor: Colors.white,
      ),
      child: const Text('Submit Evidence'),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'closed':
        return DesignSystem.secondary;
      case 'evidence_submitted':
        return DesignSystem.error;
      default:
        return DesignSystem.primary;
    }
  }

  void _showEvidenceDialog(
    BuildContext context,
    WidgetRef ref,
    String recordId,
    String correctionItemId,
  ) {
    final noteController = TextEditingController();
    final fileUrlController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: DesignSystem.surfaceContainerLowest,
          title: Text('Submit Correction Evidence', style: DesignSystem.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirm that the correction has been addressed. Your supervisor '
                'or examiner will review and confirm it.',
                style: DesignSystem.bodySm,
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (what was fixed)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              TextField(
                controller: fileUrlController,
                decoration: const InputDecoration(
                  labelText: 'Evidence file URL (optional)',
                  hintText: 'e.g. link to the updated document',
                ),
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
                  final rpc = ref.read(supabaseRpcServiceProvider);
                  await rpc.submitCorrectionEvidence(
                    correctionItemId: correctionItemId,
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                    fileUrl: fileUrlController.text.trim().isEmpty
                        ? null
                        : fileUrlController.text.trim(),
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  ref.invalidate(fypCorrectionItemsProvider(recordId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evidence submitted. Awaiting staff review.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Failed to submit evidence: $e')),
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
