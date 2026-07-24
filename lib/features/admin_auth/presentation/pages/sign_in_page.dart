import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/firebase/firebase_providers.dart';

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
      final auth = ref.read(firebaseAuthProvider);
      await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Force refresh token and check admin claim directly
      final user = auth.currentUser;
      bool isAdmin = false;
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult(true);
        isAdmin = idTokenResult.claims?['admin'] == true;
      }

      if (mounted) {
        if (isAdmin) {
          ref.invalidate(isAdminProvider);
          // Small delay to allow auth state to propagate through StreamProvider
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) context.go('/admin');
        } else {
          // Sign out if not an admin
          await auth.signOut();
          setState(() {
            _errorMessage = 'Ralat: Akaun ini tidak mempunyai akses pentadbir (Admin claim).';
          });
        }
      }
    } catch (e) {
      final msg = e.toString();
      String userMsg = 'Gagal log masuk. Sila periksa e-mel dan kata laluan anda.';
      if (msg.contains('invalid-login-credentials') || msg.contains('INVALID_LOGIN_CREDENTIALS')) {
        userMsg = 'E-mel atau kata laluan tidak sah. Sila cuba lagi.';
      } else if (msg.contains('invalid-email')) {
        userMsg = 'Format e-mel tidak sah.';
      } else if (msg.contains('user-disabled')) {
        userMsg = 'Akaun ini telah dilumpuhkan.';
      } else if (msg.contains('too-many-requests')) {
        userMsg = 'Terlalu banyak percubaan. Sila cuba sebentar lagi.';
      } else if (msg.contains('network-request-failed')) {
        userMsg = 'Ralat rangkaian. Sila periksa sambungan internet anda.';
      }
      setState(() {
        _errorMessage = userMsg;
      });
      print('Firebase Auth error: $e');
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
                          'Log Masuk Pentadbir CMS',
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

                      Text('E-mel Rasmi', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'e.g. admin@uitm.edu.my',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'E-mel wajib diisi';
                          if (!value.contains('@')) return 'Format e-mel tidak sah';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Text('Kata Laluan', style: DesignSystem.labelCaps.copyWith(color: DesignSystem.primary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan kata laluan anda',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Kata laluan wajib diisi';
                          if (value.length < 6) return 'Sila masukkan sekurang-kurangnya 6 aksara';
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
                              : Text('Log Masuk Portal', style: DesignSystem.button),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/'),
                          child: Text(
                            'Kembali ke Laman Utama',
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
