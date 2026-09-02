import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentProgressPage extends ConsumerWidget {
  const StudentProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Progress Logs',
      builder: (context, ref, record) {
        final logs = ref.watch(fypProgressLogsProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weekly Progress Logs', style: DesignSystem.h2),
                  FilledButton.icon(
                    onPressed: () => _showAddLogDialog(context, ref, record.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Log'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: logs.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No progress logs yet.\nSubmit your first weekly log.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final log in items)
                        Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                            leading: const Icon(Icons.timeline, size: 40, color: DesignSystem.primary),
                            title: Text(
                              'Week ${log.weekNumber}',
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${log.status.replaceAll('_', ' ')}', style: DesignSystem.bodySm),
                                const SizedBox(height: DesignSystem.spaceXs),
                                Text(log.summary, style: DesignSystem.bodySm),
                                if (log.challenges?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                    child: Text(
                                      'Challenges: ${log.challenges}',
                                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                                    ),
                                  ),
                                if (log.validationComment?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                    child: Text(
                                      'Feedback: ${log.validationComment}',
                                      style: DesignSystem.bodySm.copyWith(color: DesignSystem.secondary),
                                    ),
                                  ),
                                const SizedBox(height: DesignSystem.spaceSm),
                                Text(
                                  'Date: ${formatFypDate(log.progressDate)}',
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

  void _showAddLogDialog(BuildContext context, WidgetRef ref, String fypRecordId) {
    final summaryController = TextEditingController();
    final challengesController = TextEditingController();
    final nextPlanController = TextEditingController();
    int weekNumber = DateTime.now().isBefore(DateTime(DateTime.now().year, 3, 1))
        ? 1
        : ((DateTime.now().difference(DateTime(DateTime.now().year, 3, 1)).inDays / 7).floor() + 1).clamp(1, 16);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(
                'Add Progress Log',
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
                        controller: summaryController,
                        decoration: const InputDecoration(labelText: 'Work Summary'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: challengesController,
                        decoration: const InputDecoration(labelText: 'Challenges (optional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: nextPlanController,
                        decoration: const InputDecoration(labelText: 'Next Plan (optional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      Row(
                        children: [
                          Text('Week Number', style: DesignSystem.bodyMd),
                          const SizedBox(width: DesignSystem.spaceSm),
                          DropdownButton<int>(
                            value: weekNumber,
                            underline: const SizedBox.shrink(),
                            items: [
                              for (var w = 1; w <= 16; w++)
                                DropdownMenuItem(value: w, child: Text('$w')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => weekNumber = v);
                              }
                            },
                          ),
                        ],
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
                    if (summaryController.text.trim().isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    try {
                      final rpc = ref.read(supabaseRpcServiceProvider);
                      await rpc.submitProgressLog(
                        fypRecordId: fypRecordId,
                        weekNumber: weekNumber,
                        summary: summaryController.text.trim(),
                        challenges: challengesController.text.trim().isEmpty
                            ? null
                            : challengesController.text.trim(),
                        nextPlan: nextPlanController.text.trim().isEmpty
                            ? null
                            : nextPlanController.text.trim(),
                      );
                      if (context.mounted) {
                        ref.invalidate(fypProgressLogsProvider(fypRecordId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Progress log submitted.')),
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
