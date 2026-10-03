import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/layout/responsive.dart';

/// Record fields the coordinator may correct (`admin_override_fyp_record_field`;
/// supervisor / examiner changes go through Assignments instead).
const Map<String, String> kOverridableRecordFields = {
  'project_title': 'Project title',
  'project_description': 'Project description',
  'project_type': 'Project type',
  'external_industry_partner': 'Industry partner',
  'matric_id': 'Matric ID',
  'programme_code': 'Programme code',
};

String? _currentValue(FypRecord r, String field) => switch (field) {
      'project_title' => r.projectTitle,
      'project_description' => r.projectDescription,
      'project_type' => r.projectType,
      'external_industry_partner' => r.externalIndustryPartner,
      'matric_id' => r.matricId,
      'programme_code' => r.programmeCode,
      _ => null,
    };

/// Coordinator corrects one record field; the reason is mandatory and goes
/// to the audit log.
class OverrideRecordFieldDialog extends ConsumerStatefulWidget {
  const OverrideRecordFieldDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<OverrideRecordFieldDialog> createState() => _OverrideRecordFieldDialogState();
}

class _OverrideRecordFieldDialogState extends ConsumerState<OverrideRecordFieldDialog> {
  String _field = kOverridableRecordFields.keys.first;
  late final _value = TextEditingController(text: _currentValue(widget.record, _field) ?? '');
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _value.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(overrideFypRecordFieldProvider)(
        widget.record.id,
        _field,
        _value.text.trim(),
        _reason.text.trim(),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text('${kOverridableRecordFields[_field]} updated.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final changed = _value.text.trim() != (_currentValue(widget.record, _field) ?? '');
    final ready = changed && _reason.text.trim().isNotEmpty && !_busy;
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Edit Record Field', style: DesignSystem.h2),
      content: SizedBox(
        width: dialogWidth(context, 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _field,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Field'),
                items: [
                  for (final e in kOverridableRecordFields.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _field = v;
                    _value.text = _currentValue(widget.record, v) ?? '';
                  });
                },
              ),
              TextField(
                key: const Key('override-value'),
                controller: _value,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'New value'),
                maxLines: _field == 'project_description' ? 4 : 1,
              ),
              TextField(
                key: const Key('override-reason'),
                controller: _reason,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Reason (kept in the audit log)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _save : null, child: const Text('Save')),
      ],
    );
  }
}

/// Coordinator archives a record (e.g. withdrawn or completed long ago).
class ArchiveRecordDialog extends ConsumerStatefulWidget {
  const ArchiveRecordDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<ArchiveRecordDialog> createState() => _ArchiveRecordDialogState();
}

class _ArchiveRecordDialogState extends ConsumerState<ArchiveRecordDialog> {
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _archive() async {
    setState(() => _busy = true);
    try {
      await ref.read(archiveFypRecordProvider)(widget.record.id, _reason.text.trim());
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Record archived.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Archive Record', style: DesignSystem.h2),
      content: SizedBox(
        width: dialogWidth(context, 440),
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '“${widget.record.projectTitle ?? 'Untitled Project'}” will be marked archived. '
              'It stays readable but leaves the active workflow.',
              style: DesignSystem.bodySm,
            ),
            TextField(
              key: const Key('archive-reason'),
              controller: _reason,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        )),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: DesignSystem.error),
          onPressed: _reason.text.trim().isEmpty || _busy ? null : _archive,
          child: const Text('Archive'),
        ),
      ],
    );
  }
}

/// Workflow statuses that put a record on hold (backlog F4).
const kHeldStatuses = {'withdrawn', 'incomplete'};

/// Coordinator marks a record withdrawn / incomplete (TL), or reinstates it
/// ([action] is 'withdrawn', 'incomplete' or 'reinstate').
class RecordStandingDialog extends ConsumerStatefulWidget {
  const RecordStandingDialog({super.key, required this.record, required this.action});

  final FypRecord record;
  final String action;

  @override
  ConsumerState<RecordStandingDialog> createState() => _RecordStandingDialogState();
}

class _RecordStandingDialogState extends ConsumerState<RecordStandingDialog> {
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  (String, String, String) get _copy => switch (widget.action) {
        'withdrawn' => (
            'Mark Withdrawn',
            'The student has left the course. The record leaves the active workflow until reinstated.',
            'Record marked withdrawn.',
          ),
        'incomplete' => (
            'Mark Incomplete (TL)',
            'The course is carried over (Tidak Lengkap). The record is paused until reinstated.',
            'Record marked incomplete.',
          ),
        _ => (
            'Reinstate Record',
            'The record goes back to the status it had before it was put on hold.',
            'Record reinstated.',
          ),
      };

  Future<void> _save() async {
    setState(() => _busy = true);
    final done = _copy.$3;
    try {
      final standing = ref.read(recordStandingProvider);
      if (widget.action == 'reinstate') {
        await standing.reinstate(widget.record.id, _reason.text.trim());
      } else {
        await standing.hold(widget.record.id, widget.action, _reason.text.trim());
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, explain, _) = _copy;
    final ready = _reason.text.trim().length >= 5 && !_busy;
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text(title, style: DesignSystem.h2),
      content: SizedBox(
        width: dialogWidth(context, 440),
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('“${widget.record.projectTitle ?? 'Untitled Project'}”. $explain', style: DesignSystem.bodySm),
            TextField(
              key: const Key('standing-reason'),
              controller: _reason,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Reason (kept in the audit log)'),
            ),
          ],
        )),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: widget.action == 'withdrawn' ? FilledButton.styleFrom(backgroundColor: DesignSystem.error) : null,
          onPressed: ready ? _save : null,
          child: Text(widget.action == 'reinstate' ? 'Reinstate' : 'Confirm'),
        ),
      ],
    );
  }
}

/// Coordinator unlocks finalized course marks so they can be corrected
/// (backlog F3). The lecturer finalizes again afterwards.
class ReopenMarksDialog extends ConsumerStatefulWidget {
  const ReopenMarksDialog({super.key, required this.record});

  final FypRecord record;

  @override
  ConsumerState<ReopenMarksDialog> createState() => _ReopenMarksDialogState();
}

class _ReopenMarksDialogState extends ConsumerState<ReopenMarksDialog> {
  late String _course = widget.record.currentCourseCode == 'CSP650' ? 'CSP650' : 'CSP600';
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(recordStandingProvider).reopenMarks(widget.record.id, _course, _reason.text.trim());
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text('$_course marks reopened. The course lecturer has been notified.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _reason.text.trim().length >= 10 && !_busy;
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Reopen Finalized Marks', style: DesignSystem.h2),
      content: SizedBox(
        width: dialogWidth(context, 460),
        child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The grade is unlocked so evaluations can be corrected; the course lecturer then finalizes again. '
              'The previous total and grade are kept in the audit log.',
              style: DesignSystem.bodySm,
            ),
            DropdownButtonFormField<String>(
              initialValue: _course,
              decoration: const InputDecoration(labelText: 'Course'),
              items: const [
                DropdownMenuItem(value: 'CSP600', child: Text('CSP600')),
                DropdownMenuItem(value: 'CSP650', child: Text('CSP650')),
              ],
              onChanged: (v) => setState(() => _course = v ?? _course),
            ),
            TextField(
              key: const Key('reopen-reason'),
              controller: _reason,
              onChanged: (_) => setState(() {}),
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Reason (at least 10 characters)'),
            ),
          ],
        )),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: ready ? _save : null, child: const Text('Reopen')),
      ],
    );
  }
}
