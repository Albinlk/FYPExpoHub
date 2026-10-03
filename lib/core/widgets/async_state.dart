import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme.dart';
import 'admin_actions.dart';

/// Centered error message with a Retry button. Announced to screen readers.
///
/// Use it wherever a screen would otherwise print `Error: $e`: it hides the
/// raw exception, says what to do next, and lets the user try again.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.what = 'this page',
  });

  final Object error;
  final VoidCallback? onRetry;

  /// e.g. "the audit log" — used in the heading.
  final String what;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DesignSystem.spaceXl,
        horizontal: DesignSystem.spaceMd,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: DesignSystem.onSurfaceVariant,
                ),
                const SizedBox(height: DesignSystem.spaceSm),
                Text(
                  "Couldn't load $what.",
                  key: const Key('async-error-title'),
                  textAlign: TextAlign.center,
                  style: DesignSystem.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceXs),
                Text(
                  friendlyError(error),
                  key: const Key('async-error-detail'),
                  textAlign: TextAlign.center,
                  style: DesignSystem.bodySm.copyWith(
                    color: DesignSystem.onSurfaceVariant,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: DesignSystem.spaceMd),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered spinner with an accessible name.
class AsyncLoadingView extends StatelessWidget {
  const AsyncLoadingView({super.key, this.what = 'content'});

  final String what;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceXl),
      child: Center(
        child: Semantics(
          label: 'Loading $what',
          liveRegion: true,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

extension AsyncValueUi<T> on AsyncValue<T> {
  /// `when` with the standard loading and error views, so a loading or failed
  /// provider is never shown as an empty list or a "0" count.
  ///
  /// [onRetry] is usually `() => ref.invalidate(theProvider)`.
  Widget whenUi({
    required Widget Function(T data) data,
    required VoidCallback onRetry,
    String what = 'this page',
    Widget? loading,
  }) {
    return when(
      data: data,
      loading: () => loading ?? AsyncLoadingView(what: what),
      error: (e, _) => AsyncErrorView(error: e, onRetry: onRetry, what: what),
    );
  }
}
