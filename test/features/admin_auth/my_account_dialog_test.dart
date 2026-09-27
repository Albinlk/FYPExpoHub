import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/admin_auth/presentation/widgets/my_account_dialog.dart';

void main() {
  testWidgets('F2 My Account saves the name and validates before changing the password', (tester) async {
    final names = <String>[];
    final passwords = <(String, String)>[];
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentAuthUserProvider.overrideWith((ref) => null),
        currentProfileProvider.overrideWith((ref) async => const UserProfile(
              id: 'u1',
              email: 'lecturer@example.edu',
              displayName: 'Old Name',
              role: 'lecturer',
            )),
        updateMyDisplayNameProvider.overrideWithValue((name) async => names.add(name)),
        changeMyPasswordProvider.overrideWithValue((current, next) async => passwords.add((current, next))),
      ],
      child: const MaterialApp(home: Scaffold(body: MyAccountDialog())),
    ));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Old Name'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('account-name')), 'New Name');
    await tester.tap(find.text('Save name'));
    await tester.pumpAndSettle();
    expect(names, ['New Name']);
    expect(find.text('Name saved.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('account-current')), 'old-secret1');
    await tester.enterText(find.byKey(const Key('account-new')), 'short');
    await tester.enterText(find.byKey(const Key('account-confirm')), 'short');
    await tester.tap(find.widgetWithText(TextButton, 'Change password'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(passwords, isEmpty);

    await tester.enterText(find.byKey(const Key('account-new')), 'newsecret42');
    await tester.enterText(find.byKey(const Key('account-confirm')), 'newsecret42');
    await tester.tap(find.widgetWithText(TextButton, 'Change password'));
    await tester.pumpAndSettle();
    expect(passwords, [('old-secret1', 'newsecret42')]);
    expect(find.text('Password changed.'), findsOneWidget);
  });
}
