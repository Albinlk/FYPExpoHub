import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/layout/responsive.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/widgets/async_state.dart';
import 'package:fyp_expo_hub/core/widgets/project_card.dart';
import 'package:fyp_expo_hub/features/admin_auth/mfa.dart';
import 'package:fyp_expo_hub/features/admin_auth/presentation/pages/sign_in_page.dart';

/// Phone-sized smoke tests: 360×640 at the largest text scale the app allows
/// (1.3×, set in main.dart's MaterialApp builder). Any RenderFlex overflow
/// fails the test.
void main() {
  Future<void> phone(WidgetTester tester, {double textScale = 1.3}) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget scaled(Widget child, {double textScale = 1.3}) => MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 640),
          textScaler: TextScaler.linear(textScale),
        ),
        child: child,
      );

  testWidgets('sign-in card fits a 360px phone at 1.3x text', (tester) async {
    await phone(tester);
    final client = SupabaseClient(
      'https://placeholder-project.supabase.co',
      'placeholder-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((_) async => http.Response(jsonEncode({}), 400)),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(client),
        currentAuthUserProvider.overrideWith((ref) => null),
      ],
      child: MaterialApp(builder: (context, child) => scaled(child!), home: const SignInPage()),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final card = tester.getRect(find.byType(Card).first);
    expect(card.right, lessThanOrEqualTo(360), reason: 'card must not run off the screen');
    expect(card.left, greaterThanOrEqualTo(0));
  });

  testWidgets('two-step code screen has no overflow on a phone', (tester) async {
    await phone(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: [mfaStateProvider.overrideWith((ref) async => const MfaState(enabledFactorId: 'f1', needsChallenge: true))],
      child: MaterialApp(builder: (context, child) => scaled(child!), home: const MfaGate(child: Text('workspace'))),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('6-digit code'), findsOneWidget);
  });

  testWidgets('error view fits and stays scrollable in a very short space', (tester) async {
    await phone(tester);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => scaled(child!),
      home: Scaffold(
        body: SizedBox(
          height: 120,
          child: AsyncErrorView(error: Exception('ClientException: Failed to fetch'), onRetry: () {}),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('project grid row height grows with the font size', (tester) async {
    final normal = ProjectCard.gridDelegate(360, textScale: 1.0) as SliverGridDelegateWithFixedCrossAxisCount;
    final large = ProjectCard.gridDelegate(360, textScale: 1.3) as SliverGridDelegateWithFixedCrossAxisCount;
    expect(normal.crossAxisCount, 1);
    expect(large.mainAxisExtent! > normal.mainAxisExtent!, isTrue);
    // The cover stays 180px; only the text body scales.
    expect(normal.mainAxisExtent, 290);
    // A scale below 1 never shrinks the card below its designed height.
    final small = ProjectCard.gridDelegate(360, textScale: 0.9) as SliverGridDelegateWithFixedCrossAxisCount;
    expect(small.mainAxisExtent, 290);
  });

  testWidgets('breakpoints classify a phone, a tablet and a desktop', (tester) async {
    late BuildContext captured;
    Future<void> at(double w) async {
      tester.view.physicalSize = Size(w, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
        captured = c;
        return const SizedBox();
      })));
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await at(360);
    expect([Breakpoints.isNarrow(captured), Breakpoints.isCompact(captured), Breakpoints.isDesktop(captured)], [true, true, false]);
    await at(768);
    expect([Breakpoints.isNarrow(captured), Breakpoints.isCompact(captured), Breakpoints.isDesktop(captured)], [false, false, true]);
    await at(1280);
    expect(Breakpoints.isWide(captured), isTrue);
  });
}
