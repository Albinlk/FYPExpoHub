import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/busy_button.dart';

/// Asks for the reason a visit is being cancelled. With [onSubmit] the dialog
/// stays open while it runs and shows [describeError] inline on failure (the
/// typed reason is kept); without it, it just pops with the reason.
Future<String?> showUndoVisitDialog(
  BuildContext context, {
  Future<void> Function(String reason)? onSubmit,
  String Function(Object error)? describeError,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _UndoVisitDialog(onSubmit: onSubmit, describeError: describeError),
  );
}

class _UndoVisitDialog extends StatefulWidget {
  const _UndoVisitDialog({this.onSubmit, this.describeError});

  final Future<void> Function(String reason)? onSubmit;
  final String Function(Object error)? describeError;

  @override
  State<_UndoVisitDialog> createState() => _UndoVisitDialogState();
}

class _UndoVisitDialogState extends State<_UndoVisitDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    final onSubmit = widget.onSubmit;
    if (onSubmit == null) {
      Navigator.pop(context, reason);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await onSubmit(reason);
      if (mounted) Navigator.pop(context, reason);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = widget.describeError?.call(e) ?? 'Could not cancel the visit. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      title: Text('Cancel Visit', style: DesignSystem.h3.copyWith(color: DesignSystem.error)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The visit will be recorded as cancelled. You can mark it as visited again later, '
              'but only within the undo window set by the organisers.',
              style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
            ),
            const SizedBox(height: DesignSystem.spaceMd),
            TextField(
              controller: _reason,
              maxLines: 3,
              enabled: !_busy,
              keyboardType: TextInputType.multiline,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                // The server refuses a cancellation without a reason.
                labelText: 'Cancellation reason (required)',
                hintText: 'Example: Student not at booth',
                alignLabelWithHint: true,
              ),
            ),
            if (_reason.text.trim().isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: DesignSystem.spaceXs),
                child: Text(
                  'Enter a reason to enable Cancel Visit.',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: DesignSystem.spaceSm),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  key: const Key('undo-visit-error'),
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
          child: Text('Keep Visit', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
        ),
        BusyButton(
          label: 'Cancel Visit',
          busyLabel: 'Cancelling…',
          busy: _busy,
          onPressed: _reason.text.trim().isEmpty ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: DesignSystem.error,
            foregroundColor: DesignSystem.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
          ),
        ),
      ],
    );
  }
}
