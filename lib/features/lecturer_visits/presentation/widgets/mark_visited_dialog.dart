import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';
import '../../../../core/widgets/busy_button.dart';

/// Asks the lecturer to confirm a visit. When [onSubmit] is given the dialog
/// stays open while it runs, shows a spinner, and on failure shows
/// [describeError]'s text inline with the typed note kept, so nothing is lost
/// if the network drops at the booth. It pops with `{'note': ...}` on success.
Future<Map<String, String>?> showMarkVisitedDialog(
  BuildContext context,
  Project project,
  String role, {
  Future<void> Function(String note)? onSubmit,
  String Function(Object error)? describeError,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    // A stray tap outside must not throw away a typed note.
    barrierDismissible: false,
    builder: (ctx) => _MarkVisitedDialog(
      project: project,
      role: role,
      onSubmit: onSubmit,
      describeError: describeError,
    ),
  );
}

class _MarkVisitedDialog extends StatefulWidget {
  const _MarkVisitedDialog({
    required this.project,
    required this.role,
    this.onSubmit,
    this.describeError,
  });

  final Project project;
  final String role;
  final Future<void> Function(String note)? onSubmit;
  final String Function(Object error)? describeError;

  @override
  State<_MarkVisitedDialog> createState() => _MarkVisitedDialogState();
}

class _MarkVisitedDialogState extends State<_MarkVisitedDialog> {
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _note.text.trim();
    final onSubmit = widget.onSubmit;
    if (onSubmit == null) {
      Navigator.pop(context, {'note': note});
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await onSubmit(note);
      if (mounted) Navigator.pop(context, {'note': note});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = widget.describeError?.call(e) ?? 'Could not save the visit. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final role = widget.role;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      title: Text('Mark as Visited', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Project', project.title),
            const SizedBox(height: DesignSystem.spaceSm),
            _infoRow('Student', project.teamDisplayNames.join(', ')),
            if (project.boothNumber != null) ...[
              const SizedBox(height: DesignSystem.spaceSm),
              _infoRow('Booth', project.boothNumber!),
            ],
            const SizedBox(height: DesignSystem.spaceSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: role == 'supervisor'
                    ? DesignSystem.primary.withValues(alpha: 0.1)
                    : DesignSystem.tertiary.withValues(alpha: 0.1),
                borderRadius: DesignSystem.radiusSm,
              ),
              child: Text(
                role == 'supervisor' ? 'Role: Supervisor (SV)' : 'Role: Examiner (EX)',
                style: DesignSystem.labelCaps.copyWith(
                  color: role == 'supervisor' ? DesignSystem.primary : DesignSystem.tertiary,
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            TextField(
              controller: _note,
              maxLines: 3,
              enabled: !_busy,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: DesignSystem.spaceSm),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  key: const Key('mark-visited-error'),
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text('Not Now', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
        ),
        BusyButton(
          label: 'Confirm Visit',
          busyLabel: 'Saving…',
          busy: _busy,
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: DesignSystem.primary,
            foregroundColor: DesignSystem.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          ),
        ),
      ],
    );
  }
}

Widget _infoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 72,
        child: Text('$label:', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
      ),
      Expanded(
        child: Text(value, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w500)),
      ),
    ],
  );
}
