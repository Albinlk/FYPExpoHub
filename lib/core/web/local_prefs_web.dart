import 'package:web/web.dart' as web;

import 'local_prefs.dart';

/// The browser's localStorage. Access can throw (storage disabled, a private
/// window, a sandboxed frame), so every call is guarded and fails quietly.
class _BrowserLocalPrefs implements LocalPrefs {
  @override
  String? read(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  @override
  void write(String key, String? value) {
    try {
      if (value == null) {
        web.window.localStorage.removeItem(key);
      } else {
        web.window.localStorage.setItem(key, value);
      }
    } catch (_) {
      // Storage blocked or full: the preference just won't persist.
    }
  }
}

LocalPrefs createLocalPrefs() => _BrowserLocalPrefs();
