import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_milestone.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/fypms_loading_widget.dart';

class CspMilestonesPage extends ConsumerStatefulWidget {
  const CspMilestonesPage({super.key});

  @override
  ConsumerState<CspMilestonesPage> createState() => _CspMilestonesPageState();
}

class _CspMilestonesPageState extends ConsumerState<CspMilestonesPage> {
  String? _selectedRecordId;

  @override
  Widget build(BuildContext context) {
    // CSP lecturers manage milestones per FYP record; a selector lets them
    // pick which record's milestone set they are editing.
    final records = ref.watch(fypRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Course Milestones',
          style: DesignSystem.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No records found to manage milestones.'),
            );
          }
          final selectedId = _selectedRecordId ?? list.first.id;
          final selected =
              list.firstWhere((r) => r.id == selectedId, orElse: () => list.first);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignSystem.gutter, DesignSystem.spaceSm, DesignSystem.gutter, 0),
                child: Row(
                  children: [
                    Text('Record: ', style: DesignSystem.bodyMd),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selected.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                        ),
                        items: [
                          for (final r in list)
                            DropdownMenuItem(
                              value: r.id,
                              child: Text(
                                '${r.projectTitle ?? 'Untitled'} (${r.currentCourseCode})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _selectedRecordId = v),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _MilestonesList(recordId: selected.id)),
            ],
          );
        },
      ),
    );
  }
}

class _MilestonesList extends ConsumerWidget {
  final String recordId;

  const _MilestonesList({required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(fypMilestonesProvider(recordId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Course Milestones', style: DesignSystem.h2),
              FilledButton.icon(
                onPressed: () => _showMilestoneDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: milestones.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (list) {
              if (list.isEmpty) {
                return const Center(child: Text('No milestones defined.'));
              }
              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.gutter,
                ),
                children: [
                  for (final m in list)
                    Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(
                        bottom: DesignSystem.spaceMd,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignSystem.radiusXl,
                      ),
                      color: DesignSystem.surfaceContainerLowest,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(
                          DesignSystem.spaceMd,
                        ),
                        leading: const Icon(
                          Icons.flag,
                          color: DesignSystem.primary,
                        ),
                        title: Text(
                          '${m.milestoneCode} — ${m.milestoneTitle}',
                          style: DesignSystem.bodyLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Target: ${m.targetDate != null ? formatFypDate(m.targetDate!) : 'TBD'}',
                          style: DesignSystem.bodySm,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FypStatusBadge.milestone(m.status),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () =>
                                  _showMilestoneDialog(context, ref, m),
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
  }

  void _showMilestoneDialog(
    BuildContext context,
    WidgetRef ref, [
    FypMilestone? milestone,
  ]) {
    final codeController = TextEditingController(
      text: milestone?.milestoneCode,
    );
    final titleController = TextEditingController(
      text: milestone?.milestoneTitle,
    );
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
              title: Text(
                milestone == null ? 'New Milestone' : 'Edit Milestone',
                style: DesignSystem.h2,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Milestone Code',
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Target Date: ${formatFypDate(selectedDate)}',
                        style: DesignSystem.bodySm,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null)
                            setState(() => selectedDate = picked);
                        },
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spaceMd),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'overdue',
                          child: Text('Overdue'),
                        ),
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
                  onPressed:
                      codeController.text.trim().isEmpty ||
                          titleController.text.trim().isEmpty
                      ? null
                      : () async {
                          try {
                            final rpc = ref.read(supabaseRpcServiceProvider);
                            await rpc.createOrUpdateMilestone(
                              fypRecordId: recordId,
                              milestoneCode: codeController.text.trim(),
                              milestoneTitle: titleController.text.trim(),
                              description: descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim(),
                              targetDate: selectedDate,
                              status: status,
                            );
                            if (dialogContext.mounted)
                              Navigator.pop(dialogContext);
                            ref.invalidate(fypMilestonesProvider(recordId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Milestone saved.'),
                                ),
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
