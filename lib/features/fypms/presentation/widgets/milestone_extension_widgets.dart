import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_milestone_extension.dart';
import '../../../../core/domain/models/fypms/fyp_milestone.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/utils/fypms_format.dart';

/// Student: ask to move a milestone's target date. The server requires a
/// reason, a date after the current target and not in the past, and allows
/// one pending request per milestone.
class RequestExtensionDialog extends ConsumerStatefulWidget {
  const RequestExtensionDialog({super.key, required this.fypRecordId, required this.milestone});

  final String fypRecordId;
  final FypMilestone milestone;

  @override
  ConsumerState<RequestExtensionDialog> createState() => _RequestExtensionDialogState();
}

class _RequestExtensionDialogState extends ConsumerState<RequestExtensionDialog> {
  final _reason = TextEditingController();
  DateTime? _date;
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  DateTime get _earliest {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = widget.milestone.targetDate;
    final afterTarget = target == null ? today : DateTime(target.year, target.month, target.day + 1);
    return afterTarget.isAfter(today) ? afterTarget : today;
  }

  Future<void> _pick() async {
    final first = _earliest;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await ref.read(requestMilestoneExtensionProvider)(
        fypRecordId: widget.fypRecordId,
        milestoneId: widget.milestone.id,
        reason: _reason.text.trim(),
        requestedDueDate: _date!,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Extension requested.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _date != null && _reason.text.trim().isNotEmpty && !_busy;
    final target = widget.milestone.targetDate;
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Request Extension', style: DesignSystem.h2),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.milestone.milestoneCode} — ${widget.milestone.milestoneTitle}',
                style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold),
              ),
              if (target != null) Text('Current target: ${formatFypDate(target)}', style: DesignSystem.bodySm),
              const SizedBox(height: DesignSystem.spaceMd),
              OutlinedButton.icon(
                key: const Key('extension-date'),
                onPressed: _pick,
                icon: const Icon(Icons.event, size: 18),
                label: Text(_date == null ? 'Choose new date' : 'New date: ${formatFypDate(_date!)}'),
              ),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                key: const Key('extension-reason'),
                controller: _reason,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _submit : null, child: const Text('Request')),
      ],
    );
  }
}

/// The latest extension request on a milestone, as a short status line.
String extensionStatusText(FypMilestoneExtension e) => switch (e.status) {
      'approved' => 'Extension approved to ${formatFypDate(e.requestedDueDate)}',
      'rejected' => 'Extension rejected${e.decisionComment == null ? '' : ': ${e.decisionComment}'}',
      _ => 'Extension to ${formatFypDate(e.requestedDueDate)} pending',
    };

/// CSP lecturer / coordinator: the record's pending extension requests with
/// Approve / Reject. Renders nothing when none are pending.
class ExtensionRequestsPanel extends ConsumerWidget {
  const ExtensionRequestsPanel({super.key, required this.fypRecordId});

  final String fypRecordId;

  Future<void> _decide(BuildContext context, WidgetRef ref, FypMilestoneExtension e, String decision) async {
    String? comment;
    if (decision == 'rejected') {
      comment = await showDialog<String>(context: context, builder: (_) => const _RejectReasonDialog());
      if (comment == null) return;
    }
    try {
      await ref.read(decideMilestoneExtensionProvider)(
        fypRecordId: fypRecordId,
        extensionId: e.id,
        decision: decision,
        comment: comment,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decision == 'approved' ? 'Extension approved.' : 'Extension rejected.')),
        );
      }
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $err')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = [
      for (final e in ref.watch(fypMilestoneExtensionsProvider(fypRecordId)).value ?? const <FypMilestoneExtension>[])
        if (e.isPending) e,
    ];
    if (pending.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignSystem.gutter, DesignSystem.spaceSm, DesignSystem.gutter, 0),
      child: Card(
        color: DesignSystem.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Extension requests (${pending.length})',
                style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.bold),
              ),
              for (final e in pending) ...[
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  '${e.milestoneCode ?? ''} ${e.milestoneTitle ?? ''} → ${formatFypDate(e.requestedDueDate)}',
                  style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(e.reason, style: DesignSystem.bodySm),
                Wrap(
                  spacing: DesignSystem.spaceSm,
                  children: [
                    TextButton(
                      onPressed: () => _decide(context, ref, e, 'rejected'),
                      child: const Text('Reject'),
                    ),
                    FilledButton(
                      onPressed: () => _decide(context, ref, e, 'approved'),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RejectReasonDialog extends StatefulWidget {
  const _RejectReasonDialog();

  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject extension'),
      content: TextField(
        key: const Key('reject-reason'),
        controller: _c,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'Reason for the student'),
        maxLines: 2,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _c.text.trim().isEmpty ? null : () => Navigator.pop(context, _c.text.trim()),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
