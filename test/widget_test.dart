import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/main.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test initializes correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockClient = SupabaseClient(
      'https://placeholder-project.supabase.co',
      'placeholder-anon-key',
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockClient),
          // Avoid realtime/auth network connections in the test environment:
          // onAuthStateChange would attempt a WebSocket to the mock URL and hang.
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
          currentAuthUserProvider.overrideWith((ref) => null),
        ],
        child: const FYPExpoHubApp(),
      ),
    );

    expect(find.byType(FYPExpoHubApp), findsOneWidget);
  });
}
