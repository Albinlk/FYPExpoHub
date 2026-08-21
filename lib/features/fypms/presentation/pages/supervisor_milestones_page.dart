import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_milestone.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';

class SupervisorMilestonesPage extends ConsumerWidget {
  const SupervisorMilestonesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigned = ref.watch(assignedFypRecordsProvider(null));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Milestones',
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
                _RecordMilestonesSection(record: record),
            ],
          );
        },
      ),
    );
  }
}

class _RecordMilestonesSection extends ConsumerWidget {
  final FypRecord record;

  const _RecordMilestonesSection({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(fypMilestonesProvider(record.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceSm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.projectTitle ?? 'Untitled Project',
                style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
              ),
              FilledButton.icon(
                onPressed: () => _showMilestoneDialog(context, ref, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Milestone'),
              ),
            ],
          ),
        ),
        milestones.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No milestones defined.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                for (final m in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.flag, color: DesignSystem.primary),
                      title: Text('${m.milestoneCode} — ${m.milestoneTitle}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Target: ${m.targetDate?.toLocal().toString().split(' ')[0] ?? 'TBD'} | Status: ${m.status}',
                        style: DesignSystem.bodySm,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showMilestoneDialog(context, ref, m),
                      ),
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

  void _showMilestoneDialog(BuildContext context, WidgetRef ref, FypMilestone? milestone) {
    final codeController = TextEditingController(text: milestone?.milestoneCode);
    final titleController = TextEditingController(text: milestone?.milestoneTitle);
    final descController = TextEditingController(text: milestone?.description);
    DateTime selectedDate = milestone?.targetDate ?? DateTime.now();
    String status = milestone?.status ?? 'pending';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text(milestone == null ? 'New Milestone' : 'Edit Milestone', style: DesignSystem.h2),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Milestone Code (e.g. M1)'),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Target Date: ${selectedDate.toLocal().toString().split(' ')[0]}', style: DesignSystem.bodySm),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => selectedDate = picked);
                        },
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                      ],
                      onChanged: (v) => setState(() => status = v!),
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
                  onPressed: codeController.text.trim().isEmpty || titleController.text.trim().isEmpty
                      ? null
                      : () async {
                          try {
                            final rpc = ref.read(supabaseRpcServiceProvider);
                            await rpc.createOrUpdateMilestone(
                              fypRecordId: record.id,
                              milestoneCode: codeController.text.trim(),
                              milestoneTitle: titleController.text.trim(),
                              description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                              targetDate: selectedDate,
                              status: status,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            ref.invalidate(fypMilestonesProvider(record.id));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Milestone saved.')),
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
