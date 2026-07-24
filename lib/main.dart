import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/router.dart';
import 'app/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  // On admin domain root, redirect to main public site
  final host = Uri.base.host;
  final path = Uri.base.path;
  if (host == 'admin.fskmjasinfypexhibition.site' && (path == '/' || path.isEmpty)) {
    final location = globalContext['location'] as JSObject;
    location['href'] = 'https://fskmjasinfypexhibition.site/'.toJS;
    return;
  }

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus',
        appId: '1:825089478411:web:1dcd07362fdf636d9ddc0e',
        messagingSenderId: '825089478411',
        projectId: 'fyp-expo-hub',
        authDomain: 'fyp-expo-hub.firebaseapp.com',
        storageBucket: 'fyp-expo-hub.firebasestorage.app',
      ),
    );
  } catch (e) {
    print('Firebase init error: $e');
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
