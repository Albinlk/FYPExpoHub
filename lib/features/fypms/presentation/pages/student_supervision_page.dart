import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/utils/fypms_format.dart';
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
        final directory = ref.watch(supervisorsDirectoryProvider);
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
                  final nameById = <String, String>{
                    for (final s in directory.asData?.value ?? [])
                      if (s['id'] is String) s['id'] as String: (s['display_name'] as String? ?? ''),
                  };
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
                                    'Preferred: ${nameById[req.preferredSupervisorId] ?? 'Supervisor pending assignment'}',
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
                                  'Submitted ${formatFypDate(req.createdAt)}',
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
    final rationaleController = TextEditingController();
    String? selectedSupervisorId;
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            final directory = ref.watch(supervisorsDirectoryProvider);
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
                      directory.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(DesignSystem.spaceMd),
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, _) => Text(
                          'Could not load supervisors. You can still submit without a preference.',
                          style: DesignSystem.bodySm
                              .copyWith(color: DesignSystem.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        data: (supervisors) => DropdownButtonFormField<String>(
                          value: selectedSupervisorId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Preferred Supervisor (optional)',
                            prefixIcon: Icon(Icons.supervisor_account),
                          ),
                          items: [
                            for (final s in supervisors)
                              if ((s['role_code'] as String? ?? 'supervisor') ==
                                  'supervisor')
                                DropdownMenuItem(
                                  value: s['id'] as String,
                                  child: Text(
                                    s['display_name'] as String? ?? 'Supervisor',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                          ],
                          onChanged: (v) =>
                              setState(() => selectedSupervisorId = v),
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
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            final rpc = ref.read(supabaseRpcServiceProvider);
                            await rpc.submitSupervisionRequest(
                              fypRecordId: fypRecordId,
                              preferredSupervisorId: selectedSupervisorId,
                              rationale: rationaleController.text.trim().isEmpty
                                  ? null
                                  : rationaleController.text.trim(),
                            );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            ref.invalidate(fypSupervisionRequestsProvider(fypRecordId));
                            ref.invalidate(myFypRecordsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Supervision request submitted.')),
                              );
                            }
                          } catch (e) {
                            setState(() => isSubmitting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Failed to submit: $e')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
