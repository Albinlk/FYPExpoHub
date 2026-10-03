import 'package:flutter/widgets.dart';

import 'url_state_io.dart' if (dart.library.js_interop) 'url_state_web.dart';

/// `/booths` + `{day: 'Day 2', venue: ''}` → `/booths?day=Day+2`. Empty and
/// null values are dropped so the default view keeps a clean URL.
String urlWithQuery(String path, Map<String, String?> params) {
  final kept = <String, String>{
    for (final e in params.entries)
      if (e.value != null && e.value!.trim().isNotEmpty) e.key: e.value!.trim(),
  };
  if (kept.isEmpty) return path;
  return Uri(path: path, queryParameters: kept).toString();
}

/// Mirrors a page's filters into the address bar, so a refresh, a bookmark or a
/// shared link opens the same view.
///
/// Call [syncUrl] from `build` with the current filter values (default values
/// as `null` or empty). It writes only when something changed, after the frame,
/// and replaces the current history entry rather than adding one per keystroke.
/// It changes only the browser's address bar, not the router's state, so it is a
/// no-op outside the web and never rebuilds the page.
mixin UrlStateSync<T extends StatefulWidget> on State<T> {
  String? _lastQuery;

  void syncUrl(Map<String, String?> params) {
    final query = urlWithQuery('', params);
    if (query == _lastQuery) return;
    _lastQuery = query;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) replaceBrowserQuery(query);
    });
  }
}
