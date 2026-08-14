import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/project.dart';

Future<Map<String, String>?> showMarkVisitedDialog(
  BuildContext context,
  Project project,
  String role,
) {
  final noteController = TextEditingController();
  bool isSubmitting = false;

  return showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
            title: Text('Mark as Visited', style: DesignSystem.h3.copyWith(color: DesignSystem.primary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Project', project.title),
                const SizedBox(height: DesignSystem.spaceSm),
                _infoRow('Student', project.teamDisplayNames.join(', ')),
                const SizedBox(height: DesignSystem.spaceSm),
                if (project.boothNumber != null) _infoRow('Booth', project.boothNumber!),
                const SizedBox(height: DesignSystem.spaceSm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: role == 'supervisor' ? DesignSystem.primary.withOpacity(0.1) : DesignSystem.tertiary.withOpacity(0.1),
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
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Note (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: Text('Cancel', style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        setDialogState(() => isSubmitting = true);
                        Navigator.pop(ctx, {
                          'note': noteController.text.trim(),
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primary,
                  foregroundColor: DesignSystem.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                ),
                child: isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Confirm Visit', style: DesignSystem.button),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _infoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 60,
        child: Text('$label:', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant)),
      ),
      Expanded(
        child: Text(value, style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.w500)),
      ),
    ],
  );
}
