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
  return e.toString().replaceFirst(RegExp(r'^(Exception|StateError|Bad state): '), '');
}

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
