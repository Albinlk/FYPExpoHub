import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Human-readable reason a write failed, without a stack trace or the raw
/// PostgREST envelope.
String friendlyError(Object e) {
  if (e is PostgrestException) {
    if (e.code == '42501') return 'You don\'t have permission to do that.';
    return e.message.isEmpty ? 'The database rejected the change.' : e.message;
  }
  if (e is AuthException) return e.message;
  final text = e.toString();
  if (_looksLikeNetworkFailure(text)) {
    return 'Could not reach the server. Check your connection and try again.';
  }
  return text.replaceFirst(RegExp(r'^(Exception|StateError|Bad state): '), '');
}

bool _looksLikeNetworkFailure(String text) =>
    text.contains('Failed to fetch') ||
    text.contains('ClientException') ||
    text.contains('SocketException') ||
    text.contains('XMLHttpRequest') ||
    text.contains('TimeoutException');

/// Awaits an admin write, then shows [success] only if it actually
/// persisted, or the real error if it didn't. Returns whether it succeeded.
Future<bool> runAdminWrite(
  BuildContext context,
  Future<void> Function() write, {
  required String success,
}) async {
  // Captured up front: the widget may be gone by the time the write returns.
  final messenger = ScaffoldMessenger.of(context);
  final errorColor = Theme.of(context).colorScheme.error;
  try {
    await write();
    messenger.showSnackBar(SnackBar(content: Text(success)));
    return true;
  } catch (e) {
    messenger.showSnackBar(SnackBar(
      content: Text('Not saved: ${friendlyError(e)}'),
      backgroundColor: errorColor,
      duration: const Duration(seconds: 6),
    ));
    return false;
  }
}

/// Asks before a delete; resolves to false if dismissed.
Future<bool> confirmDelete(BuildContext context, String what) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Delete $what?'),
      content: const Text('This can\'t be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Asks before an action with public or bulk effect; resolves to false if
/// dismissed.
///
/// [destructive] paints the confirm button in the error colour (use it for
/// anything that cannot be reversed from the UI).
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Shows [message] with an Undo action for a few seconds. [onUndo] runs only
/// if the user taps Undo; use it for fast, reversible changes where a confirm
/// dialog would be heavy-handed.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required Future<void> Function() onUndo,
  Duration duration = const Duration(seconds: 8),
}) {
  final messenger = ScaffoldMessenger.of(context);
  final errorColor = Theme.of(context).colorScheme.error;
  messenger.showSnackBar(SnackBar(
    content: Text(message),
    duration: duration,
    showCloseIcon: true,
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () async {
        try {
          await onUndo();
        } catch (e) {
          messenger.showSnackBar(SnackBar(
            content: Text('Could not undo: ${friendlyError(e)}'),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 6),
          ));
        }
      },
    ),
  ));
}

/// Confirms taking an item off the public site (publishing needs no prompt).
Future<bool> confirmUnpublish(BuildContext context, String what) => confirmAction(
      context,
      title: 'Unpublish $what?',
      message: 'It will disappear from the public site until you publish it again.',
      confirmLabel: 'Unpublish',
    );
