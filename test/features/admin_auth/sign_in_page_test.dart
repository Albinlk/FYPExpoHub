import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/admin_auth/presentation/pages/sign_in_page.dart';

/// The only sign-in path for admins, lecturers and FYPMS users. Drives the
/// real page against a mocked Supabase Auth HTTP endpoint.
void main() {
  late List<http.Request> requests;

  SupabaseClient client() => SupabaseClient(
        'https://placeholder-project.supabase.co',
        'placeholder-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({
              'error': 'invalid_grant',
              'error_description': 'Invalid login credentials',
              'code': 'invalid_credentials',
              'msg': 'Invalid login credentials',
            }),
            400,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(client()),
          currentAuthUserProvider.overrideWith((ref) => null),
        ],
        child: const MaterialApp(home: SignInPage()),
      ),
    );
    await tester.pump();
  }

  setUp(() => requests = []);

  testWidgets('password is sent exactly as typed (not trimmed); email is '
      'normalised', (tester) async {
    await pumpPage(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '  Admin@UiTM.edu.my ');
    await tester.enterText(fields.at(1), ' secret with spaces ');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final tokenCall = requests.singleWhere((r) => r.url.path.endsWith('/auth/v1/token'));
    final body = jsonDecode(tokenCall.body) as Map<String, dynamic>;
    expect(body['password'], ' secret with spaces ',
        reason: 'trimming made accounts with edge spaces impossible to sign in to');
    expect(body['email'], 'admin@uitm.edu.my');
  });

  testWidgets('wrong credentials show a friendly message, not a raw error',
      (tester) async {
    await pumpPage(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'admin@uitm.edu.my');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Invalid email or password'), findsOneWidget);
  });
}
