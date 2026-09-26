import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_correction_item.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/correction_evidence_dialog.dart';
import '../widgets/fypms_file_link.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentCorrectionsPage extends ConsumerWidget {
  const StudentCorrectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Corrections',
      builder: (context, ref, record) {
        final items = ref.watch(fypCorrectionItemsProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Correction Items', style: DesignSystem.h2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No corrections required.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    itemCount: list.length,
                    itemBuilder: (context, itemIndex) {
                      final item = list[itemIndex];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                            leading: Icon(
                              item.severity == 'major' ? Icons.warning_amber : Icons.fact_check,
                              size: 40,
                              color: item.severity == 'major'
                                  ? DesignSystem.error
                                  : DesignSystem.primary,
                            ),
                            title: Text(
                              '${item.itemCode ?? 'Correction'} — ${item.severity}',
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description, style: DesignSystem.bodySm),
                                const SizedBox(height: DesignSystem.spaceXs),
                                Text(
                                  'Status: ${item.status.replaceAll('_', ' ')}',
                                  style: DesignSystem.bodySm.copyWith(
                                    color: _statusColor(item.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.evidenceNote?.isNotEmpty == true)
                                  Text('Your note: ${item.evidenceNote}', style: DesignSystem.bodySm),
                                if (item.evidenceUrl != null)
                                  FypmsFileLink(label: 'Evidence file', bucket: kCorrectionEvidenceBucket, path: item.evidenceUrl!),
                              ],
                            ),
                            trailing: _trailingFor(context, ref, record, item),
                          ),
                        );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _trailingFor(
    BuildContext context,
    WidgetRef ref,
    FypRecord record,
    FypCorrectionItem item,
  ) {
    if (item.status == 'confirmed' || item.status == 'closed') {
      return const Icon(Icons.check_circle, color: DesignSystem.secondary);
    }
    if (item.status == 'evidence_submitted') {
      return Chip(
        label: const Text('Awaiting review'),
        backgroundColor: DesignSystem.surfaceContainerHighest,
        labelStyle: DesignSystem.bodySm,
      );
    }
    return FilledButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => CorrectionEvidenceDialog(record: record, item: item),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: DesignSystem.secondary,
        foregroundColor: Colors.white,
      ),
      child: const Text('Submit Evidence'),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'closed':
        return DesignSystem.secondary;
      case 'evidence_submitted':
        return DesignSystem.error;
      default:
        return DesignSystem.primary;
    }
  }

}
