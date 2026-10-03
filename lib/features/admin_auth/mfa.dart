import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/theme/theme.dart';
import '../../core/supabase/supabase_client_provider.dart';
import '../../core/widgets/admin_actions.dart';
import '../../core/widgets/busy_button.dart';

/// Authenticator-app (TOTP) MFA (backlog F8). Once a verified factor
/// exists, the database only honours admin / coordinator powers in an
/// `aal2` session (20260927000014), and [MfaGate] asks for the code after
/// sign-in or a reload.

/// A pending enrolment: show [qrSvg] / [secret], then verify a code.
class MfaEnrolment {
  const MfaEnrolment({required this.factorId, required this.qrSvg, required this.secret});

  final String factorId;
  final String qrSvg;
  final String secret;
}

class MfaState {
  const MfaState({required this.enabledFactorId, required this.needsChallenge});

  /// The verified TOTP factor, if MFA is on.
  final String? enabledFactorId;

  /// Signed in with a password only while MFA is on.
  final bool needsChallenge;

  bool get enabled => enabledFactorId != null;
}

class MfaService {
  MfaService(this._ref);
  final Ref _ref;

  GoTrueMFAApi get _mfa => _ref.read(supabaseClientProvider).auth.mfa;

  Future<MfaState> state() async {
    final factors = await _mfa.listFactors();
    final aal = _mfa.getAuthenticatorAssuranceLevel();
    return MfaState(
      enabledFactorId: factors.totp.firstOrNull?.id,
      needsChallenge: aal.nextLevel == AuthenticatorAssuranceLevels.aal2 &&
          aal.currentLevel != AuthenticatorAssuranceLevels.aal2,
    );
  }

  Future<MfaEnrolment> enrol() async {
    // A half-finished enrolment blocks a new one; clear unverified factors.
    final factors = await _mfa.listFactors();
    for (final f in factors.all.where((f) => f.status != FactorStatus.verified)) {
      await _mfa.unenroll(f.id);
    }
    final res = await _mfa.enroll(factorType: FactorType.totp, issuer: 'FYP Expo Hub');
    final totp = res.totp;
    if (totp == null) throw const AuthException('The authenticator could not be set up.');
    return MfaEnrolment(factorId: res.id, qrSvg: totp.qrCode, secret: totp.secret);
  }

  /// Checks a 6-digit code (finishing an enrolment or the sign-in step).
  Future<void> verify(String factorId, String code) async {
    await _mfa.challengeAndVerify(factorId: factorId, code: code.replaceAll(RegExp(r'\s'), ''));
    _ref.invalidate(mfaStateProvider);
  }

  Future<void> disable(String factorId) async {
    await _mfa.unenroll(factorId);
    _ref.invalidate(mfaStateProvider);
  }
}

final mfaServiceProvider = Provider<MfaService>((ref) => MfaService(ref));

final mfaStateProvider = FutureProvider<MfaState>((ref) async {
  final uid = ref.watch(currentAuthUserProvider.select((u) => u?.id));
  if (uid == null) return const MfaState(enabledFactorId: null, needsChallenge: false);
  return ref.read(mfaServiceProvider).state();
});

/// Shows [child] unless the session still needs the authenticator code.
class MfaGate extends ConsumerWidget {
  const MfaGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mfaStateProvider).value;
    if (state == null || !state.needsChallenge) return child;
    return MfaChallengeView(factorId: state.enabledFactorId!);
  }
}

class MfaChallengeView extends ConsumerStatefulWidget {
  const MfaChallengeView({super.key, required this.factorId});

  final String factorId;

  @override
  ConsumerState<MfaChallengeView> createState() => _MfaChallengeViewState();
}

class _MfaChallengeViewState extends ConsumerState<MfaChallengeView> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(mfaServiceProvider).verify(widget.factorId, _code.text);
    } catch (_) {
      if (mounted) setState(() => _error = 'That code did not work. Check the time on your phone and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
    ref.invalidate(currentAuthUserProvider);
    if (mounted) context.go('/admin/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phonelink_lock, size: 48, color: DesignSystem.primary),
                const SizedBox(height: DesignSystem.spaceMd),
                Text('Two-step verification', style: DesignSystem.h2),
                const SizedBox(height: DesignSystem.spaceSm),
                Text('Enter the 6-digit code from your authenticator app.',
                    style: DesignSystem.bodyMd, textAlign: TextAlign.center),
                const SizedBox(height: DesignSystem.spaceMd),
                TextField(
                  key: const Key('mfa-code'),
                  controller: _code,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [_sixDigitCode],
                  onSubmitted: (_) => _verify(),
                  decoration: InputDecoration(
                    labelText: '6-digit code',
                    border: const OutlineInputBorder(),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                SizedBox(
                  width: double.infinity,
                  child: BusyButton(label: 'Verify', busyLabel: 'Verifying…', busy: _busy, onPressed: _verify),
                ),
                TextButton(onPressed: _busy ? null : _signOut, child: const Text('Sign out')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// My Account section: turn the authenticator app on or off.
class MfaSettingsSection extends ConsumerStatefulWidget {
  const MfaSettingsSection({super.key});

  @override
  ConsumerState<MfaSettingsSection> createState() => _MfaSettingsSectionState();
}

class _MfaSettingsSectionState extends ConsumerState<MfaSettingsSection> {
  MfaEnrolment? _enrolment;
  final _code = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (e) {
      if (mounted) setState(() => _message = friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mfaStateProvider);
    final enrolment = _enrolment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Two-step verification', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: DesignSystem.spaceSm),
        if (state.isLoading)
          const LinearProgressIndicator()
        else if (state.value?.enabled == true) ...[
          Text('On — sign-in asks for a code from your authenticator app.', style: DesignSystem.bodySm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      final factorId = state.value!.enabledFactorId!;
                      final ok = await confirmAction(
                        context,
                        title: 'Turn Off Two-Step Verification?',
                        message: 'Your account will be protected by your password alone. '
                            'Admin and coordinator powers may stop working until you turn it on again.',
                        confirmLabel: 'Turn Off',
                        destructive: true,
                      );
                      if (!ok || !mounted) return;
                      await _run(() => ref.read(mfaServiceProvider).disable(factorId));
                    },
              child: const Text('Turn off'),
            ),
          ),
        ] else if (enrolment == null) ...[
          Text(
            'Off. Turn it on to require a code from an authenticator app (Google Authenticator, Microsoft '
            'Authenticator…) when you sign in. Recommended for admins and coordinators.',
            style: DesignSystem.bodySm,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('mfa-enable'),
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        final e = await ref.read(mfaServiceProvider).enrol();
                        if (mounted) setState(() => _enrolment = e);
                      }),
              child: const Text('Turn on'),
            ),
          ),
        ] else ...[
          Text('Scan this with your authenticator app, then enter the code it shows.', style: DesignSystem.bodySm),
          const SizedBox(height: DesignSystem.spaceSm),
          Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Image.network(
                semanticLabel: 'QR code to scan with your authenticator app',
                'data:image/svg+xml;base64,${base64Encode(utf8.encode(enrolment.qrSvg))}',
                width: 180,
                height: 180,
                errorBuilder: (_, _, _) => const SizedBox(width: 180, height: 40, child: Text('QR code unavailable')),
              ),
            ),
          ),
          SelectableText('Or enter this key: ${enrolment.secret}', style: DesignSystem.bodySm),
          const SizedBox(height: DesignSystem.spaceSm),
          TextField(
            key: const Key('mfa-enrol-code'),
            controller: _code,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [_sixDigitCode],
            decoration: const InputDecoration(labelText: '6-digit code', border: OutlineInputBorder(), isDense: true),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        await ref.read(mfaServiceProvider).verify(enrolment.factorId, _code.text);
                        if (mounted) {
                          setState(() {
                            _enrolment = null;
                            _message = 'Two-step verification is on.';
                          });
                        }
                      }),
              child: const Text('Confirm'),
            ),
          ),
        ],
        if (_message != null) Text(_message!, style: DesignSystem.bodySm),
      ],
    );
  }
}

/// Keeps digits only and caps at six, so pasting "123 456" from an
/// authenticator app works instead of being truncated at the space.
final TextInputFormatter _sixDigitCode = TextInputFormatter.withFunction((oldValue, newValue) {
  final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
  final capped = digits.length > 6 ? digits.substring(0, 6) : digits;
  return TextEditingValue(
    text: capped,
    selection: TextSelection.collapsed(offset: capped.length),
  );
});
