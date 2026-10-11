import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../site_hosts.dart';
import '../theme/theme.dart';

/// Hops to another of our sites (exhibition ↔ FYP Workspace). Only https
/// URLs on [allowedRedirectHosts] are followed, so `/go?to=` cannot be used
/// as an open redirect.
class ExternalRedirectPage extends ConsumerStatefulWidget {
  const ExternalRedirectPage({super.key, required this.to});

  final String? to;

  @override
  ConsumerState<ExternalRedirectPage> createState() => _ExternalRedirectPageState();
}

class _ExternalRedirectPageState extends ConsumerState<ExternalRedirectPage> {
  Uri? _target;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.to ?? '');
    final allowed = allowedRedirectHosts(ref.read(cspHostProvider));
    if (uri != null && uri.scheme == 'https' && allowed.contains(uri.host)) {
      _target = uri;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        launchUrl(uri, webOnlyWindowName: '_self');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _target;
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.gutter),
          child: target == null
              ? Text('This link does not lead to one of our sites.', style: DesignSystem.bodyMd)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: DesignSystem.spaceMd),
                    Text('Opening ${target.host}…', style: DesignSystem.bodyMd),
                    TextButton(
                      onPressed: () => launchUrl(target, webOnlyWindowName: '_self'),
                      child: const Text('Open It Now'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
