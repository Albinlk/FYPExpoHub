import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentSupervisionPage extends ConsumerWidget {
  const StudentSupervisionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Supervision Requests',
      builder: (context, ref, record) {
        final requests = ref.watch(fypSupervisionRequestsProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Supervision Requests', style: DesignSystem.h2),
                  FilledButton.icon(
                    onPressed: () =>
                        _showNewRequestDialog(context, ref, record.id),
                    icon: const Icon(Icons.add),
                    label: const Text('New Request'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: requests.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No supervision requests yet.\nSubmit one to begin the approval process.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final req in items)
                        Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                            leading: const Icon(Icons.supervisor_account, size: 40, color: DesignSystem.primary),
                            title: Text(
                              'Status: ${req.status.replaceAll('_', ' ')}',
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (req.preferredSupervisorId != null)
                                  Text(
                                    'Preferred: ${req.preferredSupervisorId}',
                                    style: DesignSystem.bodySm,
                                  ),
                                if (req.rationale?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                    child: Text(req.rationale!, style: DesignSystem.bodySm),
                                  ),
                                if (req.decisionReason?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                    child: Text(
                                      'Decision: ${req.decisionReason}',
                                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                    ),
                                  ),
                                const SizedBox(height: DesignSystem.spaceSm),
                                Text(
                                  'Submitted ${req.createdAt.toLocal()}'.replaceFirst(' 00:00:00', ''),
                                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                ),
                              ],
                            ),
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

  void _showNewRequestDialog(
      BuildContext context, WidgetRef ref, String fypRecordId) {
    final preferredController = TextEditingController();
    final rationaleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(
                'Submit Supervision Request',
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)
                    .copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: preferredController,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Supervisor (optional)',
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: rationaleController,
                        decoration: const InputDecoration(
                          labelText: 'Rationale / Notes',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    try {
                      final rpc = ref.read(supabaseRpcServiceProvider);
                      await rpc.submitSupervisionRequest(
                        fypRecordId: fypRecordId,
                        preferredSupervisorId: preferredController.text.trim().isEmpty
                            ? null
                            : preferredController.text.trim(),
                        rationale: rationaleController.text.trim().isEmpty
                            ? null
                            : rationaleController.text.trim(),
                      );
                      if (context.mounted) {
                        ref.invalidate(fypSupervisionRequestsProvider(fypRecordId));
                        ref.invalidate(myFypRecordsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Supervision request submitted.')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
