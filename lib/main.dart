import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/router.dart';
import 'app/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up clean path URLs instead of Hash (#) URLs in browser history
  usePathUrlStrategy();

  // Try to initialize Firebase if configurations are present.
  // In development/test mode under Emulator Suite, we can capture errors gracefully.
  try {
    await Firebase.initializeApp(
      // Options will be injected by flutterfire configure or can be omitted
      // when running locally with standard configurations.
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
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
