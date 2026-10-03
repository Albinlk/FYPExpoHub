import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../mfa.dart';
import '../../password_reset.dart';
import '../../../../core/widgets/admin_actions.dart';
import '../../../../core/layout/responsive.dart';

/// Saves the caller's display name (`update_my_display_name`, backlog F2).
final updateMyDisplayNameProvider = Provider<Future<void> Function(String name)>((ref) {
  return (name) async {
    await ref.read(supabaseClientProvider).rpc<dynamic>('update_my_display_name', params: {'p_display_name': name});
    ref.invalidate(currentProfileProvider);
  };
});

/// Changes the signed-in user's password after re-checking the current one.
final changeMyPasswordProvider = Provider<Future<void> Function(String current, String next)>((ref) {
  return (current, next) async {
    final auth = ref.read(supabaseClientProvider).auth;
    final email = auth.currentUser?.email;
    if (email == null) throw const AuthException('You are not signed in.');
    try {
      await auth.signInWithPassword(email: email, password: current);
    } on AuthException {
      throw const AuthException('Your current password is not correct.');
    }
    await auth.updateUser(UserAttributes(password: next));
  };
});

/// Opens the My Account dialog.
Future<void> showMyAccountDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const MyAccountDialog());

/// App-bar entry showing who is signed in; opens [MyAccountDialog].
class MyAccountButton extends ConsumerWidget {
  const MyAccountButton({super.key, this.compact = false});

  /// Icon only (phone app bars).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentAuthUserProvider)?.email ?? 'My account';
    if (compact) {
      return IconButton(
        key: const Key('my-account'),
        tooltip: 'My account',
        icon: const Icon(Icons.account_circle),
        onPressed: () => showMyAccountDialog(context),
      );
    }
    return TextButton.icon(
      key: const Key('my-account'),
      onPressed: () => showMyAccountDialog(context),
      icon: const Icon(Icons.account_circle, color: Colors.white70),
      label: Text(email, style: DesignSystem.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }
}

class MyAccountDialog extends ConsumerStatefulWidget {
  const MyAccountDialog({super.key});

  @override
  ConsumerState<MyAccountDialog> createState() => _MyAccountDialogState();
}

class _MyAccountDialogState extends ConsumerState<MyAccountDialog> {
  final _name = TextEditingController();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _nameLoaded = false;
  bool _busy = false;
  String? _nameMessage;
  String? _passwordMessage;
  bool _passwordOk = false;

  @override
  void dispose() {
    for (final c in [_name, _current, _next, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _name.text.trim();
    if (name.length < 2 || name.length > 80) {
      setState(() => _nameMessage = 'Use a name of 2–80 characters.');
      return;
    }
    setState(() {
      _busy = true;
      _nameMessage = null;
    });
    try {
      await ref.read(updateMyDisplayNameProvider)(name);
      if (mounted) setState(() => _nameMessage = 'Name saved.');
    } catch (e) {
      if (mounted) setState(() => _nameMessage = 'Could not save: ${_clean(e)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changePassword() async {
    final problem = _current.text.isEmpty
        ? 'Enter your current password.'
        : validateNewPassword(_next.text, _confirm.text);
    if (problem != null) {
      setState(() {
        _passwordOk = false;
        _passwordMessage = problem;
      });
      return;
    }
    setState(() {
      _busy = true;
      _passwordMessage = null;
    });
    try {
      await ref.read(changeMyPasswordProvider)(_current.text, _next.text);
      for (final c in [_current, _next, _confirm]) {
        c.clear();
      }
      if (mounted) {
        setState(() {
          _passwordOk = true;
          _passwordMessage = 'Password changed.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordOk = false;
          _passwordMessage = _clean(e);
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _clean(Object e) {
    if (e is AuthException) return e.message;
    if (e is PostgrestException) return e.message.replaceFirst(RegExp(r'^[a-z-]+: '), '');
    return friendlyError(e);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    if (!_nameLoaded && profile != null) {
      _name.text = profile.displayName;
      _nameLoaded = true;
    }
    final email = ref.watch(currentAuthUserProvider)?.email ?? profile?.email ?? '';
    return AlertDialog(
      title: const Text('My Account'),
      content: SizedBox(
        width: dialogWidth(context, 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(email, style: DesignSystem.bodySm),
              const SizedBox(height: DesignSystem.spaceMd),
              Text('Display name', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                key: const Key('account-name'),
                controller: _name,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              ),
              if (_nameMessage != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_nameMessage!)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _busy ? null : _saveName, child: const Text('Save name')),
              ),
              const Divider(),
              Text('Change password', style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: DesignSystem.spaceSm),
              for (final (key, label, c) in [
                ('account-current', 'Current password', _current),
                ('account-new', 'New password', _next),
                ('account-confirm', 'Confirm new password', _confirm),
              ]) ...[
                TextField(
                  key: Key(key),
                  controller: c,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: DesignSystem.spaceSm),
              ],
              Text('At least $kMinNewPasswordLength characters, with letters and numbers.', style: DesignSystem.bodySm),
              if (_passwordMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _passwordMessage!,
                    style: TextStyle(color: _passwordOk ? DesignSystem.secondary : Theme.of(context).colorScheme.error),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _busy ? null : _changePassword, child: const Text('Change password')),
              ),
              const Divider(),
              const MfaSettingsSection(),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    );
  }
}
