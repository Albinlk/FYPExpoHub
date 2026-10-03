import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';
import '../widgets/supervision_request_card.dart';
import '../../../../core/widgets/async_state.dart';

/// Pending F1 requests for monitoring. Per the FYP Text Book the course lecturer
/// instructs students to submit F1 but the chosen supervisor signs it, so
/// this view is read-only.
class CspRequestsPage extends ConsumerWidget {
  const CspRequestsPage({super.key});

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
        error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypPendingSupervisionRequestsProvider), what: 'this page'),
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
                canDecide: false,
              );
            },
          );
        },
      ),
    );
  }
}
