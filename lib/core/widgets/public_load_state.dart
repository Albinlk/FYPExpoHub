import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme.dart';
import '../state/expo/load_status.dart';

/// Marks [dataset] as loading again and runs [reload] (usually
/// `ref.invalidate(<the list provider>)`).
void retryPublicDataset(WidgetRef ref, String dataset, VoidCallback reload) {
  ref.read(publicLoadStatusProvider(dataset).notifier).set(DataLoadStatus.loading);
  reload();
}

/// What to show where a public list would be when it has no rows (G-31):
/// a spinner while the first load is in flight, an error with Retry when
/// the server could not be reached, and otherwise [empty] (a genuine
/// "nothing here yet").
class PublicListPlaceholder extends ConsumerWidget {
  const PublicListPlaceholder({
    super.key,
    required this.dataset,
    required this.onRetry,
    required this.empty,
    this.what = 'this page',
  });

  final String dataset;
  final VoidCallback onRetry;
  final Widget empty;

  /// e.g. "projects" — used in the error text.
  final String what;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(publicLoadStatusProvider(dataset))) {
      DataLoadStatus.loading => Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceXl),
          child: Center(
            child: Semantics(
              label: 'Loading $what',
              liveRegion: true,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      DataLoadStatus.failed => Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceXl, horizontal: DesignSystem.spaceMd),
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 40, color: DesignSystem.onSurfaceVariant),
                  const SizedBox(height: DesignSystem.spaceSm),
                  Text(
                    "Couldn't load $what. Check your connection and try again.",
                    key: const Key('public-load-failed'),
                    textAlign: TextAlign.center,
                    style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: DesignSystem.spaceSm),
                  OutlinedButton.icon(
                    onPressed: () => retryPublicDataset(ref, dataset, onRetry),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      _ => empty,
    };
  }
}

/// A slim notice while bundled offline data is showing because the server
/// could not be reached. Renders nothing otherwise.
class PublicOfflineBanner extends ConsumerWidget {
  const PublicOfflineBanner({super.key, required this.dataset, required this.onRetry});

  final String dataset;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(publicLoadStatusProvider(dataset)) != DataLoadStatus.offline) {
      return const SizedBox.shrink();
    }
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('public-offline-banner'),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceMd, vertical: DesignSystem.spaceXs),
        decoration: BoxDecoration(
          color: DesignSystem.surfaceContainerHighest,
          borderRadius: DesignSystem.radiusLg,
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, size: 18, color: DesignSystem.onSurfaceVariant),
            const SizedBox(width: DesignSystem.spaceSm),
            Expanded(
              child: Text(
                "Can't reach the server — showing saved exhibition data.",
                style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => retryPublicDataset(ref, dataset, onRetry),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
