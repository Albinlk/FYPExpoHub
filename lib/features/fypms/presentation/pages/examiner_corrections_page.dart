import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/fypms_loading_widget.dart';

class ExaminerCorrectionsPage extends ConsumerWidget {
  const ExaminerCorrectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigned = ref.watch(assignedFypRecordsProvider('examiner'));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Examiner Corrections',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: assigned.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('No records assigned for examination.'));
          }
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final record in records)
                _RecordCorrectionsSection(record: record),
            ],
          );
        },
      ),
    );
  }
}

class _RecordCorrectionsSection extends ConsumerWidget {
  final FypRecord record;

  const _RecordCorrectionsSection({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final corrections = ref.watch(fypCorrectionItemsProvider(record.id));

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
                onPressed: () => _showCreateCorrectionDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Correction'),
              ),
            ],
          ),
        ),
        corrections.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No correction items listed.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                for (final item in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        item.severity == 'major' ? Icons.warning_amber : Icons.fact_check,
                        color: item.severity == 'major' ? DesignSystem.error : DesignSystem.primary,
                      ),
                      title: Text(
                        '${item.itemCode ?? 'Correction'} — ${item.severity}',
                        style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.description, style: DesignSystem.bodySm),
                      trailing: _trailingFor(context, ref, item),
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

  Widget? _trailingFor(BuildContext context, WidgetRef ref, dynamic item) {
    final status = item.status as String;
    if (status == 'confirmed' || status == 'closed') {
      return const Icon(Icons.check_circle, color: DesignSystem.secondary);
    }
    if (status == 'evidence_submitted') {
      return FilledButton.icon(
        onPressed: () => _showConfirmDialog(context, ref, item.id as String),
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Confirm'),
        style: FilledButton.styleFrom(
          backgroundColor: DesignSystem.secondary,
          foregroundColor: Colors.white,
        ),
      );
    }
    return FypStatusBadge.correction(status);
  }

  void _showConfirmDialog(BuildContext context, WidgetRef ref, String itemId) {
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('Confirm Correction', style: DesignSystem.h2),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Confirm that the student\'s evidence is satisfactory. '
                    'This marks the correction as confirmed.',
                  ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            await ref.read(confirmCorrectionProvider)(
                              itemId,
                              'confirmed',
                              notesController.text.trim().isEmpty
                                  ? null
                                  : notesController.text.trim(),
                              record.id,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Correction confirmed.')),
                              );
                            }
                          } catch (e) {
                            setState(() => isSubmitting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignSystem.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateCorrectionDialog(BuildContext context, WidgetRef ref) {
    String? formSubmissionId;
    final correctionController = TextEditingController();
    String severity = 'minor';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('New Correction Item', style: DesignSystem.h2),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: correctionController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Correction'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  DropdownButtonFormField<String>(
                    initialValue: severity,
                    decoration: const InputDecoration(labelText: 'Severity'),
                    items: const [
                      DropdownMenuItem(value: 'minor', child: Text('Minor')),
                      DropdownMenuItem(value: 'major', child: Text('Major')),
                    ],
                    onChanged: (v) => setState(() => severity = v!),
                  ),
                  const SizedBox(height: DesignSystem.spaceMd),
                  Consumer(
                    builder: (context, ref, _) {
                      final submissions = ref.watch(fypFormSubmissionsProvider(record.id));
                      return submissions.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                        data: (items) => DropdownButtonFormField<String?>(
                          initialValue: formSubmissionId,
                          decoration: const InputDecoration(labelText: 'Form Submission (optional)'),
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('None')),
                            for (final s in items)
                              DropdownMenuItem<String?>(
                                value: s.id,
                                child: Text('Form ${s.formCode} (${s.status.replaceAll('_', ' ')})'),
                              ),
                          ],
                          onChanged: (v) => setState(() => formSubmissionId = v),
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
                  onPressed: correctionController.text.trim().isEmpty
                      ? null
                      : () async {
                          try {
                            await ref.read(createCorrectionItemProvider)(
                              record.id,
                              formSubmissionId,
                              correctionController.text.trim(),
                              severity,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Correction item created.')),
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
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
