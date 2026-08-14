import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/state/state_providers.dart';

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
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) throw Exception('Sign-in failed');

      ref.invalidate(currentProfileProvider);
      ref.invalidate(isAdminProvider);
      ref.invalidate(isLecturerProvider);

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        final isAdmin = await ref.read(isAdminProvider.future);
        if (isAdmin) {
          if (mounted) context.go('/admin');
          return;
        }

        final lecturer = ref.read(lecturerAuthProvider);
        if (lecturer != null) {
          if (mounted) context.go('/lecturer/visits');
          return;
        }

        // Default redirect based on profile check
        final profile = await ref.read(currentProfileProvider.future);
        if (profile?.role == 'lecturer') {
          if (mounted) context.go('/lecturer/visits');
          return;
        }

        if (mounted) context.go('/admin');
      }
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
                      const SizedBox(height: 24),

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
