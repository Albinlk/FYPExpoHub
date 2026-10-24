import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// One deferred library (`import '...' deferred as x;`).
///
/// Wraps `x.loadLibrary` and remembers when a load finished, so later builds
/// skip the loading frame entirely. Until then every [load] call goes to
/// `loadLibrary` itself, which already de-duplicates the download (dart2js
/// fetches each part file once) — an in-flight future is deliberately not
/// cached here, so a failed load really retries and a load abandoned with
/// its zone (e.g. at the end of a widget test) can't strand later callers.
class DeferredLibrary {
  DeferredLibrary(this._loadLibrary);

  final Future<void> Function() _loadLibrary;
  bool _loaded = false;

  /// True once the library's code is available and its members can be used.
  bool get isLoaded => _loaded;

  /// Loads the library; completes at once if it is already loaded.
  Future<void> load() async {
    if (_loaded) return;
    await _loadLibrary();
    _loaded = true;
  }
}

/// Builds [builder] once [library] has loaded.
///
/// Until then it shows a small centred spinner; if the download fails it
/// shows a short message and a Retry button. When the library is already
/// loaded the builder runs straight away, with no loading frame.
///
/// [builder] may only touch members of the deferred library — it is never
/// called before the library has loaded.
class DeferredPage extends StatefulWidget {
  const DeferredPage({
    super.key,
    required this.library,
    required this.builder,
  });

  final DeferredLibrary library;
  final WidgetBuilder builder;

  @override
  State<DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<DeferredPage> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    if (!widget.library.isLoaded) _load();
  }

  @override
  void didUpdateWidget(DeferredPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.library != widget.library && !widget.library.isLoaded) {
      _load();
    }
  }

  void _load() {
    final library = widget.library;
    library.load().then(
      (_) {
        if (mounted && library == widget.library) setState(() {});
      },
      onError: (Object error) {
        if (mounted && library == widget.library) {
          setState(() => _error = error);
        }
      },
    );
  }

  void _retry() {
    setState(() => _error = null);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.library.isLoaded) return widget.builder(context);
    return ColoredBox(
      color: DesignSystem.background,
      child: Center(
        child: _error == null
            ? const SizedBox.square(
                dimension: 32,
                child: CircularProgressIndicator(
                  key: Key('deferred-page-loading'),
                  strokeWidth: 3,
                  semanticsLabel: 'Loading',
                ),
              )
            : _LoadFailed(onRetry: _retry),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spaceLg),
      child: Column(
        key: const Key('deferred-page-error'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: DesignSystem.onSurfaceVariant,
          ),
          const SizedBox(height: DesignSystem.spaceSm),
          Text(
            "This page couldn't be loaded. Check your connection and try again.",
            textAlign: TextAlign.center,
            style: DesignSystem.bodyMd.copyWith(
              color: DesignSystem.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceMd),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
