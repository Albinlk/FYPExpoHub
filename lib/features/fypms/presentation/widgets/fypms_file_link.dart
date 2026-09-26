import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/state/state_providers.dart';

/// Opens a private FYPMS file in a new tab through a short-lived signed URL
/// (the buckets are private; storage RLS decides who may read the path).
class FypmsFileLink extends ConsumerWidget {
  const FypmsFileLink({super.key, required this.label, required this.bucket, required this.path});

  final String label;
  final String bucket;
  final String path;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final storage = ref.read(supabaseStorageServiceProvider);
    final url = await storage.createSignedUrl(bucket: bucket, path: path, expiresInSeconds: 300);
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the file (no access or it was removed).')),
        );
      }
      return;
    }
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => _open(context, ref),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
    );
  }
}
