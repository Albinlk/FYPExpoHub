import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;

/// Lazy-loaded offline fallback dataset (assets/data/offline_fallback.json).
///
/// Previously this data was embedded in the app bundle
/// (excel_data.dart, 14.8k lines) and parsed on every startup. It is now an
/// asset fetched only when needed, keeping it out of the initial JS payload.
///
/// "Only when needed" means: the public projects/booths/schedule notifiers
/// call [load] only when the live Supabase request fails, answers empty, or
/// is still pending after [slowLiveTimeout]. On the web an asset read is an
/// HTTP fetch of the ~640 KB file, so a normal visit (live data back in
/// time) never downloads it.
///
/// Shape mirrors live Supabase rows: snake_case keys + ISO-8601 date strings,
/// so consumers run the same normalizeKeys/fromJson pipeline for fallback
/// and remote data (one code path).
class OfflineFallback {
  static const _assetPath = 'assets/data/offline_fallback.json';

  /// How long a public list waits for the live request before showing the
  /// bundled copy meanwhile (live rows still replace it when they arrive).
  ///
  /// 4 s is the app's existing network budget at boot (main.dart caps the
  /// current-event lookup at 4 s): a healthy Supabase answer, even from a
  /// cold free-tier project, is well inside it, while a hung connection
  /// still gets content on screen without a long spinner. A paused or
  /// unreachable project normally errors sooner and takes the error path.
  static const defaultSlowLiveTimeout = Duration(seconds: 4);

  /// The effective timeout; tests shorten it. Reset by [resetForTests].
  static Duration slowLiveTimeout = defaultSlowLiveTimeout;

  /// Reads the raw asset text. Tests swap it to count or stub downloads;
  /// reset by [resetForTests].
  @visibleForTesting
  static Future<String> Function(String path) readAsset = _defaultReadAsset;

  static Future<String> _defaultReadAsset(String path) =>
      rootBundle.loadString(path);

  static Map<String, List<Map<String, dynamic>>>? _cache;

  /// Returns the three fallback collections; reads and parses the asset
  /// once per session. Concurrent callers share the same in-flight future
  /// (projects/schedule/booths notifiers can all need it at once).
  static Future<Map<String, List<Map<String, dynamic>>>>? _inFlight;

  static Future<Map<String, List<Map<String, dynamic>>>> load() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);
    return _inFlight ??= _readAsset().catchError(
      (Object e, StackTrace st) {
        // Don't memoize a failure: a transient asset-fetch error used to
        // poison every later load() for the rest of the session.
        _inFlight = null;
        return Future<Map<String, List<Map<String, dynamic>>>>.error(e, st);
      },
    );
  }

  static Future<Map<String, List<Map<String, dynamic>>>> _readAsset() async {
    final raw = await readAsset(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final parsed = {
      'projects': (decoded['projects'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      'booths': (decoded['booths'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      'scheduleItems': (decoded['scheduleItems'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    };
    _cache = parsed;
    return parsed;
  }

  /// Test hook: clears the memoized cache and restores the asset reader
  /// and the slow-request timeout between tests.
  static void resetForTests() {
    _cache = null;
    _inFlight = null;
    readAsset = _defaultReadAsset;
    slowLiveTimeout = defaultSlowLiveTimeout;
  }
}
