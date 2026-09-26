import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/admin_auth/password_reset.dart';
import 'package:fyp_expo_hub/features/admin_auth/presentation/pages/reset_password_page.dart';
import 'package:fyp_expo_hub/features/admin_auth/presentation/pages/sign_in_page.dart';

User _user() => User(
      id: 'uid-1',
      email: 'lecturer@uitm.edu.my',
      aud: 'authenticated',
      appMetadata: const {},
      userMetadata: const {},
      createdAt: DateTime(2026, 9, 1).toIso8601String(),
    );

Future<void> _pump(WidgetTester tester, Widget home, List<Override> overrides) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: home)));
  await tester.pumpAndSettle();
}

Widget _dialogHost() => Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDialog<void>(context: context, builder: (_) => const ForgotPasswordDialog()),
          child: const Text('open'),
        ),
      ),
    );

void main() {
  test('new passwords need 8+ characters, letters and digits, and must match', () {
    expect(validateNewPassword('short1', 'short1'), contains('8'));
    expect(validateNewPassword('onlyletters', 'onlyletters'), contains('letters and numbers'));
    expect(validateNewPassword('abcd1234', 'abcd1235'), contains('do not match'));
    expect(validateNewPassword('abcd1234', 'abcd1234'), isNull);
  });

  testWidgets('G-32 forgot password sends the link and answers neutrally', (tester) async {
    final sent = <String>[];
    await _pump(tester, _dialogHost(), [
      sendPasswordResetProvider.overrideWithValue((email) async => sent.add(email)),
    ]);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final send = find.widgetWithText(FilledButton, 'Send link');
    await tester.enterText(find.byKey(const Key('reset-email')), 'not-an-email');
    await tester.pump();
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('reset-email')), 'Lecturer@UiTM.edu.my');
    await tester.pump();
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(sent, ['Lecturer@UiTM.edu.my']);
    expect(find.byKey(const Key('reset-sent')), findsOneWidget);
  });

  testWidgets('G-32 an unknown-account error still reads as sent; a rate limit does not', (tester) async {
    var error = const AuthException('User not found', statusCode: '400');
    await _pump(tester, _dialogHost(), [
      sendPasswordResetProvider.overrideWithValue((email) async => throw error),
    ]);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('reset-email')), 'nobody@uitm.edu.my');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Send link'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reset-sent')), findsOneWidget, reason: 'no account enumeration');

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    error = const AuthException('Email rate limit exceeded', statusCode: '429');
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('reset-email')), 'nobody@uitm.edu.my');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Send link'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Too many requests'), findsOneWidget);
  });

  testWidgets('G-32 reset page without a recovery session says the link expired', (tester) async {
    await _pump(tester, const ResetPasswordPage(), [
      currentAuthUserProvider.overrideWith((ref) => null),
    ]);
    expect(find.byKey(const Key('reset-link-expired')), findsOneWidget);
  });

  testWidgets('G-32 reset page validates, then updates the password', (tester) async {
    final updated = <String>[];
    await _pump(tester, const ResetPasswordPage(), [
      currentAuthUserProvider.overrideWith((ref) => _user()),
      updatePasswordProvider.overrideWithValue((p) async => updated.add(p)),
    ]);
    expect(find.text('Account: lecturer@uitm.edu.my'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('new-password')), 'newpass123');
    await tester.enterText(find.byKey(const Key('confirm-password')), 'newpass124');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reset-error')), findsOneWidget);
    expect(updated, isEmpty);

    await tester.enterText(find.byKey(const Key('confirm-password')), 'newpass123');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();
    expect(updated, ['newpass123']);
    expect(find.text('Your password has been updated.'), findsOneWidget);
  });
}
