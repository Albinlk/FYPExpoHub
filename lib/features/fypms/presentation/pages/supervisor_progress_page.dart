import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';
import '../widgets/consultation_attendance_banner.dart';
import '../widgets/fypms_loading_widget.dart';
import '../../../../core/widgets/async_state.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/widgets/busy_button.dart';

class SupervisorProgressPage extends ConsumerWidget {
  const SupervisorProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Supervisors view logs for their assigned records.
    // We'll list all logs across all assigned records.
    final assigned = ref.watch(assignedFypRecordsProvider(null));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Progress Reviews',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: assigned.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(assignedFypRecordsProvider(null)), what: 'this page'),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('No records assigned to you.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            itemCount: records.length,
            itemBuilder: (context, itemIndex) {
              final record = records[itemIndex];
                return _RecordProgressSection(record: record);
            },
          );
        },
      ),
    );
  }
}

class _RecordProgressSection extends ConsumerWidget {
  final FypRecord record;

  const _RecordProgressSection({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(fypProgressLogsProvider(record.id));

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
        logs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AsyncErrorView(error: e, onRetry: () => ref.invalidate(fypProgressLogsProvider(record.id)), what: 'this section'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: DesignSystem.spaceMd),
                child: Text('No progress logs submitted.', style: DesignSystem.bodySm),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                  child: ConsultationAttendanceBanner(record: record, logs: list),
                ),
                for (final log in list)
                  Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                    shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                    color: DesignSystem.surfaceContainerLowest,
                    child: ListTile(
                      dense: true,
                      leading: Text('W${log.weekNumber}', style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold)),
                      title: Text(log.summary, style: DesignSystem.bodySm),
                      subtitle: Text(
                        [
                          '${formatFypDate(log.progressDate)} · ${log.status.replaceAll('_', ' ')}',
                          if (log.nextPlan?.isNotEmpty == true) 'Next: ${log.nextPlan}',
                        ].join('\n'),
                        style: DesignSystem.bodySm,
                      ),
                      trailing: log.status == 'submitted'
                          ? FilledButton(
                              onPressed: () => _showReviewDialog(context, ref, record.id, log.id),
                              child: const Text('Review'),
                            )
                          : const Icon(Icons.check_circle, color: DesignSystem.secondary),
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

  void _showReviewDialog(BuildContext context, WidgetRef ref, String recordId, String logId) {
    showDialog<String>(
      context: context,
      // A stray tap outside must not discard a typed comment.
      barrierDismissible: false,
      builder: (_) => _ReviewProgressDialog(recordId: recordId, logId: logId),
    ).then((decision) {
      if (decision != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Log ${decision.toLowerCase()}.')),
        );
      }
    });
  }
}

class _ReviewProgressDialog extends ConsumerStatefulWidget {
  const _ReviewProgressDialog({required this.recordId, required this.logId});

  final String recordId;
  final String logId;

  @override
  ConsumerState<_ReviewProgressDialog> createState() => _ReviewProgressDialogState();
}

class _ReviewProgressDialogState extends ConsumerState<_ReviewProgressDialog> {
  final _comment = TextEditingController();
  String _decision = 'validated';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _needsReason => _decision == 'rejected';

  Future<void> _submit() async {
    final comment = _comment.text.trim();
    if (_needsReason && comment.isEmpty) {
      setState(() => _error = 'Tell the student why the log is not accepted so they know what to fix.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(validateProgressLogProvider)(
        widget.logId,
        _decision,
        comment.isEmpty ? null : comment,
        widget.recordId,
      );
      if (mounted) Navigator.pop(context, _decision);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not submit the review: ${friendlyError(e)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Review Progress Log', style: DesignSystem.h2),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _decision,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Decision'),
              items: const [
                DropdownMenuItem(value: 'validated', child: Text('Validate')),
                DropdownMenuItem(value: 'rejected', child: Text('Reject')),
              ],
              onChanged: _busy ? null : (v) => setState(() => _decision = v!),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            TextField(
              controller: _comment,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: _needsReason ? 'Reason For Rejecting (required)' : 'Validation Comment (optional)',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: DesignSystem.spaceSm),
              Semantics(
                liveRegion: true,
                child: Text(_error!, style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BusyButton(
          label: 'Submit',
          busyLabel: 'Submitting…',
          busy: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
