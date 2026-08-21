import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class SupervisorEvaluationsPage extends ConsumerWidget {
  const SupervisorEvaluationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigned = ref.watch(assignedFypRecordsProvider(null));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Evaluations',
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
                _RecordEvaluationSection(record: record),
            ],
          );
        },
      ),
    );
  }
}

class _RecordEvaluationSection extends ConsumerWidget {
  final FypRecord record;

  const _RecordEvaluationSection({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = ref.watch(fypFormSubmissionsProvider(record.id));

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
        submissions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No form submissions available for evaluation.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                for (final sub in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.description, color: DesignSystem.primary),
                      title: Text('Form ${sub.formCode}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Submitted: ${_formatDate(sub.createdAt)}', style: DesignSystem.bodySm),
                      trailing: FilledButton(
                        onPressed: () => _showEvaluationDialog(context, ref, sub.id),
                        child: const Text('Evaluate'),
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

  void _showEvaluationDialog(BuildContext context, WidgetRef ref, String submissionId) {
    final scoresController = TextEditingController();
    final commentsController = TextEditingController();
    String decision = 'approved';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: DesignSystem.surfaceContainerLowest,
          title: Text('Evaluate Submission', style: DesignSystem.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: decision,
                decoration: const InputDecoration(labelText: 'Decision'),
                items: const [
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  DropdownMenuItem(value: 'resubmission_required', child: Text('Resubmission Required')),
                ],
                onChanged: (v) => decision = v!,
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              TextField(
                controller: scoresController,
                decoration: const InputDecoration(
                  labelText: 'Scores (JSON format, e.g. {"criteria1": 8, "criteria2": 7})',
                  hintText: '{"rubric_item_1": 5, "rubric_item_2": 4}',
                ),
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              TextField(
                controller: commentsController,
                decoration: const InputDecoration(labelText: 'Comments'),
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
                  final scores = jsonDecode(scoresController.text);
                  if (scores is! Map<String, dynamic>) throw Exception('Invalid scores format.');

                  await ref.read(submitFormEvaluationProvider)(
                    submissionId,
                    scores,
                    commentsController.text.trim().isEmpty
                        ? null
                        : commentsController.text.trim(),
                    decision,
                    record.id,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evaluation submitted.')),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
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

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}-${local.month.toString().padLeft(2, '0')}-${local.year}';
  }
}
