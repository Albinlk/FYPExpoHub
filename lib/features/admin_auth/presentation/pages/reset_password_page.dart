import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../../../../app/theme/theme.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../password_reset.dart';

/// Landing page of the password-recovery email. With PKCE, Supabase
/// exchanges the link's code for a short-lived session on load; the user
/// then chooses a new password. Without that session the link has expired
/// or was already used.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final problem = validateNewPassword(_password.text, _confirm.text);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(updatePasswordProvider)(_password.text);
      if (mounted) setState(() => _done = true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not update the password: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAuthUserProvider);
    return Scaffold(
      backgroundColor: DesignSystem.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignSystem.spaceMd),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Set a New Password',
                      textAlign: TextAlign.center,
                      style: DesignSystem.h3.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32),
                    if (_done) ...[
                      const Text('Your password has been updated.', textAlign: TextAlign.center),
                      const SizedBox(height: DesignSystem.spaceMd),
                      FilledButton(
                        onPressed: () => context.go('/admin/sign-in'),
                        child: const Text('Continue'),
                      ),
                    ] else if (user == null) ...[
                      const Text(
                        'This reset link is invalid or has expired. Request a new one from the sign-in page.',
                        key: Key('reset-link-expired'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      FilledButton(
                        onPressed: () => context.go('/admin/sign-in'),
                        child: const Text('Back to sign in'),
                      ),
                    ] else ...[
                      Text('Account: ${user.email ?? ''}', style: DesignSystem.bodySm),
                      const SizedBox(height: DesignSystem.spaceSm),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                          child: Text(
                            _error!,
                            key: const Key('reset-error'),
                            style: DesignSystem.bodySm.copyWith(color: DesignSystem.error),
                          ),
                        ),
                      TextField(
                        key: const Key('new-password'),
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'New password',
                          helperText: 'At least $kMinNewPasswordLength characters, letters and numbers',
                        ),
                      ),
                      TextField(
                        key: const Key('confirm-password'),
                        controller: _confirm,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: const InputDecoration(labelText: 'Confirm new password'),
                        onSubmitted: (_) => _busy ? null : _save(),
                      ),
                      const SizedBox(height: DesignSystem.spaceMd),
                      FilledButton(
                        onPressed: _busy ? null : _save,
                        child: const Text('Update password'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
