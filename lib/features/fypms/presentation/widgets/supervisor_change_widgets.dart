import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/fypms_supervisor_change.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';

/// Minimum reason length the server requires.
const kSupervisorChangeReasonMin = 20;

/// id → name from the public supervisor directory.
Map<String, String> _names(List<Map<String, dynamic>> directory) => {
      for (final s in directory)
        if (s['id'] is String) s['id'] as String: (s['display_name'] as String? ?? ''),
    };

/// Student: ask the coordinator for a different supervisor (textbook:
/// discouraged, and only through the coordinator).
class RequestSupervisorChangeDialog extends ConsumerStatefulWidget {
  const RequestSupervisorChangeDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<RequestSupervisorChangeDialog> createState() => _RequestSupervisorChangeDialogState();
}

class _RequestSupervisorChangeDialogState extends ConsumerState<RequestSupervisorChangeDialog> {
  final _reason = TextEditingController();
  String? _proposed;
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await ref.read(requestSupervisorChangeProvider)(widget.record.id, _reason.text.trim(), _proposed);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Request sent to the FYP coordinator.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final directory = ref.watch(supervisorsDirectoryProvider).value ?? const <Map<String, dynamic>>[];
    final options = [
      for (final e in _names(directory).entries)
        if (e.key != widget.record.mainSupervisorId && e.key != widget.record.examinerId) e,
    ];
    final ready = _reason.text.trim().length >= kSupervisorChangeReasonMin && !_busy;
    return AlertDialog(
      title: const Text('Request supervisor change'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Changing supervisor is discouraged and needs the FYP coordinator\'s approval. '
                'Explain why the change is needed.',
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
              TextField(
                key: const Key('change-reason'),
                controller: _reason,
                onChanged: (_) => setState(() {}),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  helperText: 'At least $kSupervisorChangeReasonMin characters',
                ),
              ),
              DropdownButtonFormField<String?>(
                key: const Key('change-proposed'),
                initialValue: _proposed,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Proposed supervisor (optional)'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Let the coordinator decide')),
                  for (final e in options)
                    DropdownMenuItem<String?>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _proposed = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _submit : null, child: const Text('Send request')),
      ],
    );
  }
}

/// Student: the latest change request's status, or a button to make one.
class SupervisorChangeSection extends ConsumerWidget {
  const SupervisorChangeSection({super.key, required this.record});

  final FypRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(fypSupervisorChangesProvider(record.id)).value?.firstOrNull;
    final pending = latest?.isPending ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignSystem.gutter, 0, DesignSystem.gutter, DesignSystem.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (latest != null)
            Text(
              switch (latest.status) {
                'pending' => 'Supervisor change requested — waiting for the FYP coordinator.',
                'approved' => 'Supervisor change approved.',
                _ => 'Supervisor change rejected${latest.decisionComment == null ? '' : ': ${latest.decisionComment}'}',
              },
              key: const Key('change-status'),
              style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w600),
            ),
          if (!pending)
            TextButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => RequestSupervisorChangeDialog(record: record),
              ),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Request supervisor change'),
            ),
        ],
      ),
    );
  }
}

/// Coordinator: pending supervisor change requests with Approve (choosing the
/// new supervisor) / Reject (with a reason). Renders nothing when empty.
class SupervisorChangeRequestsPanel extends ConsumerWidget {
  const SupervisorChangeRequestsPanel({super.key});

  Future<void> _approve(BuildContext context, WidgetRef ref, SupervisorChangeRequest r, Map<String, String> names) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (_) => _PickSupervisorDialog(
        names: {for (final e in names.entries) if (e.key != r.currentSupervisorId) e.key: e.value},
        initial: r.proposedSupervisorId,
      ),
    );
    if (chosen == null || !context.mounted) return;
    await _run(context, ref, r, 'approved', newSupervisorId: chosen);
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, SupervisorChangeRequest r) async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _ReasonDialog());
    if (reason == null || !context.mounted) return;
    await _run(context, ref, r, 'rejected', comment: reason);
  }

  Future<void> _run(BuildContext context, WidgetRef ref, SupervisorChangeRequest r, String decision,
      {String? comment, String? newSupervisorId}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(decideSupervisorChangeProvider)(
        requestId: r.id,
        fypRecordId: r.fypRecordId,
        decision: decision,
        comment: comment,
        newSupervisorId: newSupervisorId,
      );
      messenger.showSnackBar(SnackBar(content: Text(decision == 'approved' ? 'Supervisor changed.' : 'Request rejected.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSupervisorChangesProvider).value ?? const <SupervisorChangeRequest>[];
    if (pending.isEmpty) return const SizedBox.shrink();
    final names = _names(ref.watch(supervisorsDirectoryProvider).value ?? const []);
    return Card(
      margin: const EdgeInsets.fromLTRB(DesignSystem.gutter, DesignSystem.gutter, DesignSystem.gutter, 0),
      color: DesignSystem.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supervisor change requests (${pending.length})',
                style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold)),
            for (final r in pending) ...[
              const Divider(),
              Text(
                '${r.projectTitle ?? 'Untitled'}${r.matricId == null ? '' : ' · ${r.matricId}'}',
                style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'From ${names[r.currentSupervisorId] ?? 'current supervisor'}'
                '${r.proposedSupervisorId == null ? '' : ' to ${names[r.proposedSupervisorId] ?? 'proposed supervisor'}'}',
                style: DesignSystem.bodySm,
              ),
              Text(r.reason, style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
              Wrap(
                spacing: DesignSystem.spaceSm,
                children: [
                  TextButton(onPressed: () => _reject(context, ref, r), child: const Text('Reject')),
                  FilledButton(onPressed: () => _approve(context, ref, r, names), child: const Text('Approve…')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PickSupervisorDialog extends StatefulWidget {
  const _PickSupervisorDialog({required this.names, this.initial});

  final Map<String, String> names;
  final String? initial;

  @override
  State<_PickSupervisorDialog> createState() => _PickSupervisorDialogState();
}

class _PickSupervisorDialogState extends State<_PickSupervisorDialog> {
  late String? _id = widget.names.containsKey(widget.initial) ? widget.initial : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New supervisor'),
      content: SizedBox(
        width: 420,
        child: DropdownButtonFormField<String>(
          key: const Key('new-supervisor'),
          initialValue: _id,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Supervisor'),
          items: [
            for (final e in widget.names.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _id = v),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _id == null ? null : () => Navigator.pop(context, _id), child: const Text('Approve')),
      ],
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog();

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reason'),
      content: TextField(
        key: const Key('decision-reason'),
        controller: _c,
        autofocus: true,
        maxLines: 2,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'Reason (shown to the requester)'),
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

/// PU workspace: supervisor / examiner nominations awaiting approval.
class PuNominationsPage extends ConsumerWidget {
  const PuNominationsPage({super.key});

  Future<void> _decide(BuildContext context, WidgetRef ref, PendingNomination n, String decision) async {
    String? comment;
    if (decision == 'rejected') {
      comment = await showDialog<String>(context: context, builder: (_) => const _ReasonDialog());
      if (comment == null) return;
    }
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(decideNominationProvider)(n.assignmentId, decision, comment);
      messenger.showSnackBar(SnackBar(content: Text(decision == 'approved' ? 'Nomination approved.' : 'Nomination rejected.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nominations = ref.watch(pendingNominationsProvider);
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text('Nominations', style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: nominations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No nominations are waiting for your approval.'))
            : ListView(
                padding: const EdgeInsets.all(DesignSystem.gutter),
                children: [
                  for (final n in list)
                    Card(
                      margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                      child: Padding(
                        padding: const EdgeInsets.all(DesignSystem.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${n.roleLabel}: ${n.lecturerName ?? '—'}',
                              style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${n.projectTitle ?? 'Untitled'} · ${n.studentName ?? ''}'
                              '${n.matricId == null ? '' : ' (${n.matricId})'}',
                              style: DesignSystem.bodySm,
                            ),
                            Text('${n.programmeCode ?? ''} · ${n.courseCode ?? ''}',
                                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
                            Wrap(
                              spacing: DesignSystem.spaceSm,
                              children: [
                                TextButton(onPressed: () => _decide(context, ref, n, 'rejected'), child: const Text('Reject')),
                                FilledButton(onPressed: () => _decide(context, ref, n, 'approved'), child: const Text('Approve')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
