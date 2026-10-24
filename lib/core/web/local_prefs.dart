import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'local_prefs_stub.dart'
    if (dart.library.js_interop) 'local_prefs_web.dart' as platform;

/// A tiny string key/value store for per-browser UI preferences (which menu
/// groups are open, …) that should survive a page reload.
///
/// Never holds anything sensitive: on the web it is the browser's
/// localStorage, readable by any script on the origin.
abstract class LocalPrefs {
  String? read(String key);

  /// Stores [value] under [key]; null removes the key.
  void write(String key, String? value);
}

/// An in-memory [LocalPrefs]: the fallback outside the browser (so tests and
/// desktop runs keep preferences for the life of the process) and the store
/// tests inject.
class MemoryLocalPrefs implements LocalPrefs {
  MemoryLocalPrefs([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  String? read(String key) => values[key];

  @override
  void write(String key, String? value) {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

/// The store the app uses: localStorage on the web, [MemoryLocalPrefs]
/// elsewhere. Tests may replace it.
LocalPrefs localPrefs = platform.createLocalPrefs();

/// The set stored under [key], or null when nothing usable is stored (never
/// written, corrupted, or storage blocked).
Set<String>? readStringSet(String key) {
  try {
    final raw = localPrefs.read(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded.whereType<String>().toSet();
  } catch (_) {
    return null;
  }
}

/// Stores [value] under [key]. Failures (storage full or blocked) are
/// ignored: the preference just won't survive a reload.
void writeStringSet(String key, Set<String> value) {
  try {
    localPrefs.write(key, jsonEncode(value.toList()..sort()));
  } catch (_) {
    // Best effort only.
  }
}

/// A set of strings that starts from what [key] holds in [localPrefs] and
/// writes every new value back, so it survives a page reload.
class PersistedStringSet extends ValueNotifier<Set<String>> {
  PersistedStringSet(this.key) : super(readStringSet(key) ?? <String>{});

  final String key;

  @override
  set value(Set<String> newValue) {
    super.value = newValue;
    writeStringSet(key, newValue);
  }

  /// Re-reads the stored value without writing it back.
  void reload() => super.value = readStringSet(key) ?? <String>{};
}
