import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/supervision_request_card.dart';

/// Pending F1 requests across all records; the coordinator may decide on the
/// chosen supervisor's behalf.
class CoordinatorRequestsPage extends ConsumerWidget {
  const CoordinatorRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(fypPendingSupervisionRequestsProvider);
    final records = ref.watch(fypRecordsProvider).value ?? const [];

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Supervision Requests',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: requests.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pending) {
          if (pending.isEmpty) {
            return const Center(child: Text('No pending supervision requests.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final request = pending[index];
              final record = records.where((r) => r.id == request.fypRecordId).firstOrNull;
              return SupervisionRequestCard(
                key: ValueKey(request.id),
                request: request,
                subtitle: record == null ? null : '${record.currentCourseCode} | ${record.programmeCode}',
                fallbackTitle: record?.projectTitle,
                canDecide: true,
              );
            },
          );
        },
      ),
    );
  }
}
