import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/student_record_workspace.dart';

class StudentMilestonesPage extends ConsumerWidget {
  const StudentMilestonesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudentRecordWorkspace(
      title: 'Milestones',
      builder: (context, ref, record) {
        final milestones = ref.watch(fypMilestonesProvider(record.id));
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignSystem.gutter),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Milestones', style: DesignSystem.h2),
              ),
            ),
            Expanded(
              child: milestones.when(
                loading: () => const FypmsLoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No milestones have been set for this record.',
                        style: DesignSystem.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignSystem.gutter),
                    children: [
                      for (final m in list)
                        Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
                          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
                          color: DesignSystem.surfaceContainerLowest,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(DesignSystem.spaceMd),
                            leading: const Icon(Icons.flag, size: 40, color: DesignSystem.primary),
                            title: Text(
                              m.milestoneTitle,
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Code: ${m.milestoneCode}', style: DesignSystem.bodySm),
                                if (m.description?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                                    child: Text(m.description!, style: DesignSystem.bodySm),
                                  ),
                                if (m.targetDate != null)
                                  Text(
                                    'Target: ${m.targetDate!.toLocal()}'.replaceFirst(' 00:00:00', ''),
                                    style: DesignSystem.bodySm,
                                  ),
                                const SizedBox(height: DesignSystem.spaceSm),
                                _StatusBadge(status: m.status),
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
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceSm, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'completed'
            ? DesignSystem.secondary.withOpacity(0.15)
            : status == 'overdue'
                ? DesignSystem.errorContainer
                : DesignSystem.surfaceContainer,
        borderRadius: DesignSystem.radiusLg,
      ),
      child: Text(
        label.toUpperCase(),
        style: DesignSystem.bodySm.copyWith(
          color: status == 'overdue'
              ? DesignSystem.onErrorContainer
              : DesignSystem.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
