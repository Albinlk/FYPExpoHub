import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record_assignment.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CoordinatorAssignmentsPage extends ConsumerWidget {
  const CoordinatorAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(fypRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Assignments',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No FYP records to assign.'));
          }
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final record in list)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                  color: DesignSystem.surfaceContainerLowest,
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSystem.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.projectTitle?.isNotEmpty == true
                              ? record.projectTitle!
                              : 'Untitled Project',
                          style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: DesignSystem.spaceXs),
                        Text(
                          '${record.currentCourseCode} | ${record.workflowStatus.replaceAll('_', ' ')}',
                          style: DesignSystem.bodySm,
                        ),
                        const SizedBox(height: DesignSystem.spaceSm),
                        _AssignmentsSummary(
                          assignments: ref.watch(fypRecordAssignmentsProvider(record.id)),
                        ),
                        const SizedBox(height: DesignSystem.spaceSm),
                        Wrap(
                          spacing: DesignSystem.spaceSm,
                          children: [
                            _AssignButton(
                              label: 'Supervisor',
                              icon: Icons.supervisor_account,
                              onPressed: () => _showAssignDialog(
                                context, ref, record.id, 'supervisor'),
                            ),
                            _AssignButton(
                              label: 'Co-Supervisor',
                              icon: Icons.group,
                              onPressed: () => _showAssignDialog(
                                context, ref, record.id, 'co_supervisor'),
                            ),
                            _AssignButton(
                              label: 'Examiner',
                              icon: Icons.rate_review,
                              onPressed: () => _showAssignDialog(
                                context, ref, record.id, 'examiner'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showAssignDialog(
      BuildContext context, WidgetRef ref, String recordId, String role) {
    String? staffId;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('Assign $role', style: DesignSystem.h2),
              content: Consumer(
                builder: (context, ref, _) {
                  final staff =
                      ref.watch(fypStaffProvider(const ['supervisor', 'co_supervisor', 'examiner']));
                  return staff.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (items) => DropdownButtonFormField<String>(
                      initialValue: staffId,
                      decoration: const InputDecoration(labelText: 'Staff Member'),
                      items: [
                        for (final s in items)
                          DropdownMenuItem(
                            value: s['id'] as String?,
                            child: Text(
                              '${s['display_name']} (${s['email']})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => staffId = v),
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: staffId == null
                      ? null
                      : () async {
                          try {
                            if (role == 'examiner') {
                              await ref.read(assignExaminerProvider)(recordId, staffId!);
                            } else {
                              await ref.read(assignSupervisorToFypRecordProvider)(
                                recordId,
                                staffId!,
                                role,
                              );
                            }
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$role assigned.')),
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
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AssignmentsSummary extends ConsumerWidget {
  final AsyncValue<List<FypRecordAssignment>> assignments;

  const _AssignmentsSummary({required this.assignments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return assignments.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.spaceSm),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, _) => Text('Error loading assignments', style: DesignSystem.bodySm),
      data: (items) {
        if (items.isEmpty) return Text('No active assignments.', style: DesignSystem.bodySm);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final a in items)
              Text(
                '• ${a.academicRole.replaceAll('_', ' ')}',
                style: DesignSystem.bodySm,
              ),
          ],
        );
      },
    );
  }
}

class _AssignButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _AssignButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignSystem.primary,
        side: const BorderSide(color: DesignSystem.primary),
      ),
    );
  }
}
