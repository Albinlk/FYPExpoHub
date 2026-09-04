import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Lazy-loaded offline fallback dataset (assets/data/offline_fallback.json).
///
/// Previously this data was embedded in the app bundle
/// (excel_data.dart, 14.8k lines) and parsed on every startup. It is now an
/// asset fetched only when needed, keeping it out of the initial JS payload.
///
/// Shape mirrors live Supabase rows: snake_case keys + ISO-8601 date strings,
/// so consumers run the same normalizeKeys/fromJson pipeline for fallback
/// and remote data (one code path).
class OfflineFallback {
  static const _assetPath = 'assets/data/offline_fallback.json';

  static Map<String, List<Map<String, dynamic>>>? _cache;

  /// Returns the three fallback collections; reads and parses the asset
  /// once per session. Concurrent callers share the same in-flight future
  /// (projects/schedule/booths notifiers all start loading at boot).
  static Future<Map<String, List<Map<String, dynamic>>>> _inFlight =
      Future.value({});

  static Future<Map<String, List<Map<String, dynamic>>>> load() async {
    if (_cache != null) return _cache!;
    if (!_inFlightCompletionPending) {
      _inFlightCompletionPending = true;
      _inFlight = _readAsset();
    }
    return _inFlight;
  }

  static bool _inFlightCompletionPending = false;

  static Future<Map<String, List<Map<String, dynamic>>>> _readAsset() async {
    final raw = await rootBundle.loadString(_assetPath);
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

  /// Test hook: clears the memoized cache between tests.
  static void resetForTests() {
    _cache = null;
    _inFlightCompletionPending = false;
    _inFlight = Future.value({});
  }
}
