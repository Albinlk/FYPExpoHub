import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_record.dart';
import '../../../../core/state/fypms_state_providers.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
        width: 480,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DesignSystem.surfaceContainerLowest,
      title: Text('Archive Record', style: DesignSystem.h2),
      content: SizedBox(
        width: 440,
        child: Column(
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
        ),
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
