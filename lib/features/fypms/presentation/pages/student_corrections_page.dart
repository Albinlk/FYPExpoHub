import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/fypms_rpc_service.dart';
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Correction Items', style: DesignSystem.h2),
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
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final item in list)
                        Card(
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
                                Text('Status: ${item.status.replaceAll('_', ' ')}', style: DesignSystem.bodySm),
                              ],
                            ),
                            trailing: item.status == 'confirmed' || item.status == 'closed'
                                ? const Icon(Icons.check_circle, color: DesignSystem.secondary)
                                : FilledButton(
                                    onPressed: () => _confirmCorrection(context, ref, item.id),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: DesignSystem.secondary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Confirm'),
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

  Future<void> _confirmCorrection(
      BuildContext context, WidgetRef ref, String correctionItemId) async {
    try {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.confirmFypCorrections(correctionItemId: correctionItemId);
      if (context.mounted) {
        ref.invalidate(fypCorrectionItemsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correction confirmed.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm: $e')),
        );
      }
    }
  }
}
