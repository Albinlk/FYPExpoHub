import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/fypms_loading_widget.dart';

/// Milestones of the supervisor's students, read-only: the course lecturer or
/// coordinator sets them (create_or_update_milestone), so offering add/edit
/// here only produced permission errors.
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
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: records.length,
            itemBuilder: (context, itemIndex) {
              final record = records[itemIndex];
                return _RecordMilestonesSection(record: record);
            },
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
              Flexible(
                child: Text(
                  record.projectTitle ?? 'Untitled Project',
                  style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold, color: DesignSystem.primary),
                ),
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
                        'Target: ${m.targetDate != null ? formatFypDate(m.targetDate!) : 'TBD'}',
                        style: DesignSystem.bodySm,
                      ),
                      trailing: FypStatusBadge.milestone(m.status),
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
}
