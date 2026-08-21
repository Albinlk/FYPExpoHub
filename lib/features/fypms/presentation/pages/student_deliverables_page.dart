import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_deliverable.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

/// Expected FYP deliverables used for the exhibition-readiness checklist.
/// Each entry maps to the `deliverable_type` column in `fyp_deliverables`.
const List<({String type, String title, bool required})> fypmsDeliverableChecklist = [
  (type: 'proposal', title: 'F1 Supervision Request', required: true),
  (type: 'interim_report', title: 'Interim Report (F6a)', required: true),
  (type: 'final_report', title: 'Final Report (F6b)', required: true),
  (type: 'lean_canvas', title: 'Lean Canvas (F13)', required: true),
  (type: 'project_demo', title: 'Project Demo / Artifact', required: true),
  (type: 'presentation_deck', title: 'Presentation Deck', required: false),
  (type: 'project_video', title: 'Project Video', required: false),
  (type: 'poster', title: 'Exhibition Poster', required: false),
];

class StudentDeliverablesPage extends ConsumerWidget {
  const StudentDeliverablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Deliverables',
      builder: (context, ref, record) {
        final deliverables = ref.watch(fypDeliverablesProvider(record.id));
        return Column(
          children: [
            Expanded(
              child: deliverables.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) => _buildBody(context, ref, record, items),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FypRecord record,
    List<FypDeliverable> items,
  ) {
    final byType = <String, FypDeliverable>{
      for (final d in items) d.deliverableType ?? '': d,
    };
    final readiness = _readiness(byType);

    return ListView(
      padding: const EdgeInsets.all(DesignSystem.gutter),
      children: [
        _ExhibitionReadinessCard(
          record: record,
          readiness: readiness,
          onPreview: () => _showReadinessPreview(context, record, readiness),
        ),
        const SizedBox(height: DesignSystem.spaceMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Deliverables Checklist', style: DesignSystem.h2),
            FilledButton.icon(
              onPressed: () => _showSubmitDialog(context, ref, record.id),
              icon: const Icon(Icons.upload_file),
              label: const Text('Submit Deliverable'),
              style: FilledButton.styleFrom(
                backgroundColor: DesignSystem.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spaceSm),
        for (final item in fypmsDeliverableChecklist)
          _DeliverableTile(
            item: item,
            deliverable: byType[item.type],
          ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: DesignSystem.spaceLg),
            child: Center(
              child: Text(
                'No deliverables submitted yet.\nUse "Submit Deliverable" to begin.',
                style: DesignSystem.bodyMd,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// Computes exhibition-readiness from the submitted deliverables map.
  ({int completed, int total, bool ready}) _readiness(
      Map<String, FypDeliverable> byType) {
    var completed = 0;
    var total = 0;
    for (final item in fypmsDeliverableChecklist) {
      if (!item.required) continue;
      total++;
      final d = byType[item.type];
      if (d != null && d.fileUrl != null) completed++;
    }
    return (completed: completed, total: total, ready: completed >= total);
  }

  void _showReadinessPreview(
    BuildContext context,
    FypRecord record,
    ({int completed, int total, bool ready}) readiness,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDesktop = MediaQuery.of(context).size.width >= 768;
        return AlertDialog(
          title: Text(
            'Exhibition Readiness Preview',
            style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)
                .copyWith(color: DesignSystem.primary),
          ),
          content: SizedBox(
            width: isDesktop ? 460 : MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.projectTitle?.isNotEmpty == true
                      ? record.projectTitle!
                      : 'Untitled Project',
                  style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  'Course: ${record.currentCourseCode}',
                  style: DesignSystem.bodyMd,
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                LinearProgressIndicator(
                  value: readiness.total == 0
                      ? 0
                      : readiness.completed / readiness.total,
                  backgroundColor: DesignSystem.surfaceContainer,
                  color: DesignSystem.secondary,
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  '${readiness.completed}/${readiness.total} required deliverables ready',
                  style: DesignSystem.bodySm,
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DesignSystem.spaceMd),
                  decoration: BoxDecoration(
                    color: readiness.ready
                        ? DesignSystem.secondary.withOpacity(0.15)
                        : DesignSystem.errorContainer.withOpacity(0.4),
                    borderRadius: DesignSystem.radiusLg,
                  ),
                  child: Text(
                    readiness.ready
                        ? 'This record meets the required deliverables for exhibition publication.'
                        : 'This record is NOT yet ready for exhibition publication.',
                    style: DesignSystem.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: readiness.ready
                          ? DesignSystem.onSecondaryContainer
                          : DesignSystem.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitDialog(BuildContext context, WidgetRef ref, String fypRecordId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final fileUrlController = TextEditingController();
    String? selectedType = fypmsDeliverableChecklist.first.type;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;
            return AlertDialog(
              title: Text(
                'Submit Deliverable',
                style: (isDesktop ? DesignSystem.h3 : DesignSystem.bodyLg)
                    .copyWith(color: DesignSystem.primary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(labelText: 'Deliverable Type'),
                        isExpanded: true,
                        items: [
                          for (final item in fypmsDeliverableChecklist)
                            DropdownMenuItem(
                              value: item.type,
                              child: Text('${item.title}${item.required ? ' *' : ''}'),
                            ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => selectedType = v);
                          }
                        },
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description (optional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: DesignSystem.spaceSm),
                      TextField(
                        controller: fileUrlController,
                        decoration: const InputDecoration(
                          labelText: 'File URL (optional)',
                          helperText:
                              'Paste a storage URL after uploading your file.',
                        ),
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
                    final type = selectedType;
                    if (type == null) return;
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    try {
                      final rpc = ref.read(supabaseRpcServiceProvider);
                      await rpc.submitDeliverable(
                        fypRecordId: fypRecordId,
                        deliverableType: type,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        fileUrl: fileUrlController.text.trim().isEmpty
                            ? null
                            : fileUrlController.text.trim(),
                      );
                      if (context.mounted) {
                        ref.invalidate(fypDeliverablesProvider(fypRecordId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deliverable submitted.')),
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

class _ExhibitionReadinessCard extends StatelessWidget {
  final FypRecord record;
  final ({int completed, int total, bool ready}) readiness;
  final VoidCallback onPreview;

  const _ExhibitionReadinessCard({
    required this.record,
    required this.readiness,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: DesignSystem.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  readiness.ready
                      ? Icons.check_circle
                      : Icons.pending_actions,
                  color: readiness.ready
                      ? DesignSystem.secondary
                      : DesignSystem.onSurfaceVariant,
                ),
                const SizedBox(width: DesignSystem.spaceSm),
                Text('Exhibition Readiness', style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            LinearProgressIndicator(
              value: readiness.total == 0
                  ? 0
                  : readiness.completed / readiness.total,
              backgroundColor: DesignSystem.surfaceContainer,
              color: DesignSystem.secondary,
            ),
            const SizedBox(height: DesignSystem.spaceXs),
            Text(
              '${readiness.completed}/${readiness.total} required deliverables submitted',
              style: DesignSystem.bodySm,
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility),
                label: const Text('Preview Readiness'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliverableTile extends StatelessWidget {
  final ({String type, String title, bool required}) item;
  final FypDeliverable? deliverable;

  const _DeliverableTile({required this.item, this.deliverable});

  @override
  Widget build(BuildContext context) {
    final submitted = deliverable != null;
    final version = deliverable?.version ?? 0;
    final fileUrl = deliverable?.fileUrl;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
      color: DesignSystem.surfaceContainerLowest,
      child: ListTile(
        dense: true,
        leading: Icon(
          submitted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: submitted ? DesignSystem.secondary : DesignSystem.onSurfaceVariant,
        ),
        title: Text(
          item.title,
          style: DesignSystem.bodySm.copyWith(
            fontWeight: FontWeight.bold,
            color: submitted ? null : DesignSystem.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          submitted
              ? (fileUrl != null && fileUrl.isNotEmpty
                  ? 'Submitted (v$version) - attached file'
                  : 'Submitted (v$version)')
              : (item.required ? 'Required' : 'Optional'),
          style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
        ),
        trailing: item.required
            ? Icon(
                submitted ? Icons.task_alt : Icons.pending,
                color: submitted ? DesignSystem.secondary : DesignSystem.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}