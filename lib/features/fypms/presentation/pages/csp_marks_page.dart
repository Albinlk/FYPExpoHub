import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CspMarksPage extends ConsumerWidget {
  const CspMarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(fypRecordsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Finalize Marks',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: records.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No records found to finalize marks.'));
          }
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final record in list)
                _RecordMarksSection(record: record),
            ],
          );
        },
      ),
    );
  }
}

class _RecordMarksSection extends ConsumerWidget {
  final FypRecord record;

  const _RecordMarksSection({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(fypMarksSummariesProvider(record.id));

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
                onPressed: () => _showFinalizeMarksDialog(context, ref),
                icon: const Icon(Icons.grade, size: 18),
                label: const Text('Finalize'),
              ),
            ],
          ),
        ),
        summaries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No marks finalized yet.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                for (final s in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.analytics, color: DesignSystem.primary),
                      title: Text('${s.courseCode} — Grade: ${s.grade ?? 'N/A'}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Weighted Total: ${s.weightedTotal.toStringAsFixed(2)} / 100', style: DesignSystem.bodySm),
                      trailing: s.isFinalized
                          ? const Icon(Icons.check_circle, color: DesignSystem.secondary)
                          : null,
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

  void _showFinalizeMarksDialog(BuildContext context, WidgetRef ref) {
    final marksController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: DesignSystem.surfaceContainerLowest,
              title: Text('Finalize Course Marks', style: DesignSystem.h2),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: marksController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Component marks JSON (e.g. {"proposal": 20, "report": 40, "viva": 40})',
                      hintText: '{"item1": 10, "item2": 20}',
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
                  onPressed: marksController.text.trim().isEmpty
                      ? null
                      : () async {
                          try {
                            final marks = jsonDecode(marksController.text);
                            if (marks is! Map<String, dynamic>) throw Exception('Invalid marks format.');

                            await ref.read(finalizeMarksProvider)(
                              record.id,
                              record.currentCourseCode,
                              marks,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Marks finalized.')),
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
                  child: const Text('Finalize'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
