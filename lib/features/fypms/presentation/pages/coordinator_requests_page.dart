import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/domain/models/fypms/fyp_supervision_request.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CoordinatorRequestsPage extends ConsumerWidget {
  const CoordinatorRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(fypPendingSupervisionRequestsProvider);
    final records = ref.watch(fypRecordsProvider);

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
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final request in pending)
                _RequestCard(
                  request: request,
                  record: records.value?.where((r) => r.id == request.fypRecordId).firstOrNull,
                  onDecide: (decision, reason) =>
                      _decide(context, ref, request.id, decision, reason),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String decision,
    String? reason,
  ) async {
    try {
      await ref.read(decideSupervisionRequestProvider)(requestId, decision, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request ${decision.toLowerCase()}.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}

class _RequestCard extends ConsumerWidget {
  final FypSupervisionRequest request;
  final FypRecord? record;
  final void Function(String decision, String? reason) onDecide;

  const _RequestCard({
    required this.request,
    required this.record,
    required this.onDecide,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      color: DesignSystem.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record?.projectTitle?.isNotEmpty == true
                  ? record!.projectTitle!
                  : 'Untitled Project',
              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
            ),
            if (record != null)
              Text(
                '${record!.currentCourseCode} | ${record!.programmeCode}',
                style: DesignSystem.bodySm,
              ),
            const SizedBox(height: DesignSystem.spaceSm),
            if (request.rationale != null && request.rationale!.isNotEmpty)
              Text('Rationale: ${request.rationale}', style: DesignSystem.bodySm),
            const SizedBox(height: DesignSystem.spaceSm),
            Consumer(
              builder: (context, ref, _) {
                final staff = ref.watch(fypStaffProvider(const ['supervisor', 'co_supervisor']));
                final preferred = staff.value?.where(
                  (s) => s['id'] == request.preferredSupervisorId,
                ).firstOrNull;
                return Text(
                  preferred != null
                      ? 'Preferred supervisor: ${preferred['display_name']} (${preferred['email']})'
                      : 'Preferred supervisor: ${request.preferredSupervisorId ?? 'not specified'}',
                  style: DesignSystem.bodySm,
                );
              },
            ),
            const SizedBox(height: DesignSystem.spaceSm),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Decision reason (optional)'),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => onDecide(
                    'rejected',
                    reasonController.text.trim().isEmpty
                        ? null
                        : reasonController.text.trim(),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignSystem.error,
                    side: const BorderSide(color: DesignSystem.error),
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: DesignSystem.spaceSm),
                FilledButton(
                  onPressed: () => onDecide(
                    'approved',
                    reasonController.text.trim().isEmpty
                        ? null
                        : reasonController.text.trim(),
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
