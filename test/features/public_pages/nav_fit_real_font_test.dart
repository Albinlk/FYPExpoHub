import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/widgets/public_shell.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

/// With the real fonts loaded (tests normally draw text with a wide
/// placeholder font), the full desktop menu must fit between the wordmark
/// and Sign In at [kNavAllLinksWidth], and five links must fit at
/// [kNavFiveLinksWidth].
Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadFont('Inter', ['Inter-Regular.ttf', 'Inter-Medium.ttf', 'Inter-SemiBold.ttf', 'Inter-Bold.ttf']);
    await _loadFont('Fraunces', ['Fraunces-SemiBold.ttf', 'Fraunces-Bold.ttf']);
    await _loadFont('JetBrains Mono', ['JetBrainsMono-Medium.ttf']);
  });

  Future<void> pumpShell(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const PublicShell(child: SizedBox.shrink()))],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        )),
        authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
        currentAuthUserProvider.overrideWith((ref) => null),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  /// Gap between the end of the links (More) and the Sign In button.
  double gap(WidgetTester tester) {
    final more = tester.getRect(find.byKey(const Key('nav-more')));
    final signIn = tester.getRect(find.widgetWithText(ElevatedButton, 'Sign In'));
    return signIn.left - more.right;
  }

  for (final width in [kNavAllLinksWidth, kNavFiveLinksWidth]) {
    testWidgets('menu clears Sign In at ${width.toInt()} px with real fonts', (tester) async {
      await pumpShell(tester, width);
      expect(gap(tester), greaterThanOrEqualTo(16), reason: 'gap ${gap(tester).toStringAsFixed(1)} px');
    });
  }
}
