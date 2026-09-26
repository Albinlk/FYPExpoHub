import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../password_reset.dart';

void _goToMainSite() {
  launchUrlString('https://fskmjasinfypexhibition.site/');
}

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client.auth.signInWithPassword(
        email: _emailController.text.trim().toLowerCase(),
        // Not trimmed: a password may legitimately start or end with a space,
        // and trimming made such an account impossible to sign in to.
        password: _passwordController.text,
      );

      final user = response.user;
      if (user == null) throw Exception('Sign-in failed');

      ref.invalidate(currentProfileProvider);
      ref.invalidate(isAdminProvider);
      ref.invalidate(isLecturerProvider);

      // The router's post-login guard picks the destination — back to the
      // `?from=` deep link if there was one, else the user's own workspace
      // (admin, lecturer, or FYPMS role). One source of truth instead of a
      // second copy of that logic here.
      if (mounted) GoRouter.of(context).refresh();
    } on AuthException catch (e) {
      String userMsg = 'Sign in failed. Please check your credentials.';
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        userMsg = 'Invalid email or password. Please try again.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        userMsg = 'Please confirm your email address before signing in.';
      } else {
        userMsg = e.message;
      }
      setState(() {
        _errorMessage = userMsg;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign in failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(DesignSystem.spaceXl),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spaceLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'FYP Expo Hub',
                          style: DesignSystem.h3.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Sign In',
                          style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                        ),
                      ),
                      const Divider(height: 32),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DesignSystem.errorContainer,
                            borderRadius: DesignSystem.radiusLg,
                          ),
                          child: Text(
                            _errorMessage!,
                            style: DesignSystem.bodySm.copyWith(color: DesignSystem.onErrorContainer),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Text('Official Email', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'e.g. admin@uitm.edu.my',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!value.contains('@')) return 'Invalid email format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Text('Password', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 6) return 'Please enter at least 6 characters';
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text('Sign In', style: DesignSystem.button),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _goToMainSite,
                          child: Text(
                            'Back to Homepage',
                            style: DesignSystem.bodySm.copyWith(color: DesignSystem.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks for the account email and sends the recovery link. The confirmation
/// is the same whether or not the address is registered.
class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool get _valid => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sendPasswordResetProvider)(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (e) {
      // Rate limits are worth showing; "user not found" style errors are not.
      final rateLimited = e.statusCode == '429' || e.message.toLowerCase().contains('rate limit');
      if (mounted) {
        setState(() => rateLimited ? _error = 'Too many requests. Please try again in a few minutes.' : _sent = true);
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not send the email. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: SizedBox(
        width: 400,
        child: _sent
            ? const Text(
                'If an account exists for that email, a password reset link is on its way. '
                'The link works once and expires after an hour.',
                key: Key('reset-sent'),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter your account email and we will send you a reset link.'),
                  TextField(
                    key: const Key('reset-email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_error!, style: DesignSystem.bodySm.copyWith(color: DesignSystem.error)),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(_sent ? 'Close' : 'Cancel')),
        if (!_sent)
          FilledButton(onPressed: _valid && !_busy ? _send : null, child: const Text('Send link')),
      ],
    );
  }
}
