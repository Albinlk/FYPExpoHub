import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LecturerSignInPage extends ConsumerStatefulWidget {
  final String displayName;

  const LecturerSignInPage({super.key, required this.displayName});

  @override
  ConsumerState<LecturerSignInPage> createState() => _LecturerSignInPageState();
}

class _LecturerSignInPageState extends ConsumerState<LecturerSignInPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/admin/sign-in');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
