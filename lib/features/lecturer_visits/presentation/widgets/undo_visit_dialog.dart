import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';

Future<String?> showUndoVisitDialog(BuildContext context) {
  final reasonController = TextEditingController();
  bool isSubmitting = false;

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
            title: Text('Cancel Visit', style: DesignSystem.h3.copyWith(color: DesignSystem.error)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The visit will be recorded as cancelled. You can mark it as visited again later.',
                  style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(
                    // The server refuses a cancellation without a reason.
                    labelText: 'Cancellation reason *',
                    hintText: 'Example: Student not at booth',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: Text('Close', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: isSubmitting || reasonController.text.trim().isEmpty
                    ? null
                    : () {
                        setDialogState(() => isSubmitting = true);
                        Navigator.pop(ctx, reasonController.text.trim());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.error,
                  foregroundColor: DesignSystem.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                ),
                child: isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Cancel Visit', style: DesignSystem.button),
              ),
            ],
          );
        },
      );
    },
  );
}
