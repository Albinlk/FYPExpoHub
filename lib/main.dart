import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/router.dart';
import 'app/theme/theme.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  // Firebase credentials are injected at build time via --dart-define.
  // They are never stored in source code or committed to version control.
  // Pass them as build args in docker-compose.yml or your CI/CD pipeline.
  const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  const firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  const firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: firebaseApiKey,
        appId: firebaseAppId,
        messagingSenderId: firebaseMessagingSenderId,
        projectId: firebaseProjectId,
        authDomain: firebaseAuthDomain,
        storageBucket: firebaseStorageBucket,
      ),
    );
    // Enable Firestore offline persistence for faster subsequent loads
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    logDebug('Firebase init error: $e');
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
