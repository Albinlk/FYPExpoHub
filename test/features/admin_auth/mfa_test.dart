import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/features/admin_auth/mfa.dart';

class _FakeMfa extends MfaService {
  _FakeMfa(super.ref, this.calls);
  final List<String> calls;

  @override
  Future<MfaEnrolment> enrol() async {
    calls.add('enrol');
    return const MfaEnrolment(factorId: 'f-new', qrSvg: '<svg xmlns="http://www.w3.org/2000/svg"/>', secret: 'ABCDEF123456');
  }

  @override
  Future<void> verify(String factorId, String code) async {
    calls.add('verify $factorId $code');
    if (code == '000000') throw Exception('bad code');
  }

  @override
  Future<void> disable(String factorId) async => calls.add('disable $factorId');
}

Widget _app(List<String> calls, MfaState state, Widget child) => ProviderScope(
      overrides: [
        mfaServiceProvider.overrideWith((ref) => _FakeMfa(ref, calls)),
        mfaStateProvider.overrideWith((ref) async => state),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('F8 gate passes through without a pending challenge', (tester) async {
    await tester.pumpWidget(_app(
      [],
      const MfaState(enabledFactorId: 'f1', needsChallenge: false),
      const MfaGate(child: Text('workspace')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('workspace'), findsOneWidget);
  });

  testWidgets('F8 gate asks for the code after a password-only sign-in', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(_app(
      calls,
      const MfaState(enabledFactorId: 'f1', needsChallenge: true),
      const MfaGate(child: Text('workspace')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('workspace'), findsNothing);
    expect(find.text('Two-step verification'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('mfa-code')), '000000');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    expect(find.textContaining('did not work'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('mfa-code')), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    expect(calls.last, 'verify f1 123456');
  });

  testWidgets('F8 enrolment shows the key and confirms with a code', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(_app(
      calls,
      const MfaState(enabledFactorId: null, needsChallenge: false),
      const Scaffold(body: SingleChildScrollView(child: MfaSettingsSection())),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mfa-enable')));
    await tester.pumpAndSettle();
    expect(find.text('Or enter this key: ABCDEF123456'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('mfa-enrol-code')), '654321');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(calls, ['enrol', 'verify f-new 654321']);
    expect(find.text('Two-step verification is on.'), findsOneWidget);
  });
}
