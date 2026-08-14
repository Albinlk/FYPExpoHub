import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router.dart';
import 'app/theme/theme.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  // Supabase credentials injected at build time via --dart-define.
  // Never hardcode or commit secret service-role keys to source code.
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey, // ignore: deprecated_member_use
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  } catch (e) {
    logDebug('Supabase initialization warning (running in fallback/offline mode): $e');
  }

  runApp(
    const ProviderScope(
      child: FYPExpoHubApp(),
    ),
  );
}

class FYPExpoHubApp extends ConsumerWidget {
  const FYPExpoHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'FYP Expo Hub',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
