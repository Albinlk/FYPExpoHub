import 'package:flutter/material.dart';

/// Shows a dialog that is hard to dismiss by accident.
///
/// A tap outside never closes it (so typed text is not lost), and Esc / the
/// system back gesture close it only when [isDirty] is false or the user
/// confirms discarding. Use for any dialog with free-text input.
Future<T?> showFormDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool Function()? isDirty,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => DirtyGuard(
      isDirty: isDirty ?? () => false,
      child: Builder(builder: builder),
    ),
  );
}

/// Intercepts back / Esc and asks "Discard changes?" while [isDirty] is true.
class DirtyGuard extends StatelessWidget {
  const DirtyGuard({super.key, required this.isDirty, required this.child});

  final bool Function() isDirty;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (!isDirty() || await confirmDiscard(context)) {
          navigator.pop();
        }
      },
      child: child,
    );
  }
}

/// "Discard changes?" confirm; true means discard.
Future<bool> confirmDiscard(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Discard Changes?'),
      content: const Text('You have unsaved changes. If you leave now they will be lost.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep Editing'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
