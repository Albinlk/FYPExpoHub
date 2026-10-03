/// Web implementation: rewrites the address bar's query string with
/// `history.replaceState`, keeping the path and replacing (not adding) the
/// history entry.
library;

import 'dart:js_interop';

@JS('history')
external JSObject get _history;

@JS('location')
external JSObject get _location;

extension _History on JSObject {
  external void replaceState(JSAny? data, String title, String url);
}

extension _Location on JSObject {
  external String get pathname;
  external String get hash;
}

/// [query] is `''` or `'?a=b&c=d'` (as built by `urlWithQuery('', ...)`).
void replaceBrowserQuery(String query) {
  try {
    _history.replaceState(null, '', '${_location.pathname}$query${_location.hash}');
  } catch (_) {
    // Sandboxed frames can refuse history changes; the URL just stays as it was.
  }
}
