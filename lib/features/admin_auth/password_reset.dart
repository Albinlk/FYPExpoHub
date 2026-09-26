import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client_provider.dart';

/// Where the recovery email sends the user back to (must be listed in the
/// Supabase Auth "Redirect URLs").
String passwordResetRedirectUrl() => '${Uri.base.origin}/reset-password';

/// Minimum length for a new password (the sign-in form accepts older,
/// 6-character passwords; new ones must be stronger).
const int kMinNewPasswordLength = 8;

/// Sends the Supabase password-recovery email. Callers show the same
/// message whether or not the address has an account, so the form cannot be
/// used to discover who is registered.
final sendPasswordResetProvider = Provider<Future<void> Function(String email)>((ref) {
  return (email) => ref
      .read(supabaseClientProvider)
      .auth
      .resetPasswordForEmail(email.trim().toLowerCase(), redirectTo: passwordResetRedirectUrl());
});

/// Sets a new password for the signed-in (recovery) session.
final updatePasswordProvider = Provider<Future<void> Function(String password)>((ref) {
  return (password) async {
    await ref.read(supabaseClientProvider).auth.updateUser(UserAttributes(password: password));
  };
});

/// Checks a new password; null when acceptable.
String? validateNewPassword(String password, String confirm) {
  if (password.length < kMinNewPasswordLength) {
    return 'Use at least $kMinNewPasswordLength characters.';
  }
  if (!RegExp(r'[A-Za-z]').hasMatch(password) || !RegExp(r'\d').hasMatch(password)) {
    return 'Use both letters and numbers.';
  }
  if (password != confirm) return 'The passwords do not match.';
  return null;
}
