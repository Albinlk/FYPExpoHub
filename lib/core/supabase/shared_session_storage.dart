import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'shared_session_cookies_stub.dart'
    if (dart.library.js_interop) 'shared_session_cookies_web.dart' as platform;

/// The parent domain both sites live on: the exhibition
/// (`fskmjasinfypexhibition.site`) and the FYP Workspace (`fyp.…`).
const kSharedCookieDomain = 'fskmjasinfypexhibition.site';

/// Read and write access to `document.cookie`, injectable for tests.
abstract class CookieJar {
  String read();
  void write(String cookie);
}

/// Keeps the Supabase session in cookies on `.fskmjasinfypexhibition.site`
/// instead of per-origin localStorage, so signing in on the exhibition
/// also signs you in on the FYP Workspace and vice versa (backlog W4).
///
/// Both sites must use this one store. If each kept its own copy, one
/// site refreshing the token would leave the other holding a revoked
/// refresh token, and using it signs the user out everywhere.
///
/// A session (with the user object) can exceed the 4 KB cookie limit, so
/// it is base64url-encoded and split across numbered cookies.
class SharedSessionStorage extends LocalStorage {
  SharedSessionStorage({
    required this.jar,
    this.domain = kSharedCookieDomain,
    this.readLegacy,
    this.clearLegacy,
  });

  final CookieJar jar;
  final String domain;

  /// The session the app kept in localStorage before W4, moved over once
  /// so nobody is signed out by the switch.
  final String? Function()? readLegacy;
  final void Function()? clearLegacy;

  static const _prefix = 'fyp-sb-';
  static const _countName = '${_prefix}n';
  static const _chunkSize = 3000;
  static const _maxAge = 60 * 60 * 24 * 30; // matches a long-lived refresh token

  Map<String, String> _cookies() {
    final out = <String, String>{};
    for (final part in jar.read().split(';')) {
      final i = part.indexOf('=');
      if (i <= 0) continue;
      out[part.substring(0, i).trim()] = part.substring(i + 1).trim();
    }
    return out;
  }

  void _set(String name, String value, int maxAge) => jar.write(
      '$name=$value; Domain=$domain; Path=/; Max-Age=$maxAge; Secure; SameSite=Lax');

  String? _readSession() {
    final c = _cookies();
    final n = int.tryParse(c[_countName] ?? '');
    if (n == null || n <= 0) return null;
    final buf = StringBuffer();
    for (var i = 0; i < n; i++) {
      final part = c['$_prefix$i'];
      if (part == null) return null; // half-written; treat as signed out
      buf.write(part);
    }
    try {
      return utf8.decode(base64Url.decode(buf.toString()));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    if (_readSession() != null) return;
    final legacy = readLegacy?.call();
    if (legacy != null) {
      await persistSession(legacy);
      clearLegacy?.call();
    }
  }

  @override
  Future<bool> hasAccessToken() async => _readSession() != null;

  @override
  Future<String?> accessToken() async => _readSession();

  @override
  Future<void> removePersistedSession() async {
    final c = _cookies();
    final n = int.tryParse(c[_countName] ?? '') ?? 0;
    for (var i = 0; i < n; i++) {
      _set('$_prefix$i', '', 0);
    }
    _set(_countName, '', 0);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    final encoded = base64Url.encode(utf8.encode(persistSessionString));
    final chunks = <String>[
      for (var i = 0; i < encoded.length; i += _chunkSize)
        encoded.substring(i, (i + _chunkSize).clamp(0, encoded.length)),
    ];
    final old = int.tryParse(_cookies()[_countName] ?? '') ?? 0;
    for (var i = 0; i < chunks.length; i++) {
      _set('$_prefix$i', chunks[i], _maxAge);
    }
    for (var i = chunks.length; i < old; i++) {
      _set('$_prefix$i', '', 0);
    }
    _set(_countName, '${chunks.length}', _maxAge);
  }
}

/// The shared store when the app runs on one of our hosts, else null
/// (localhost, previews), which keeps Supabase's default localStorage.
LocalStorage? sharedSessionStorageFor(String host, {required String supabaseUrl}) {
  if (host != kSharedCookieDomain && !host.endsWith('.$kSharedCookieDomain')) return null;
  final jar = platform.documentCookieJar();
  if (jar == null) return null;
  final legacyKey = 'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token';
  return SharedSessionStorage(
    jar: jar,
    readLegacy: () => platform.readLocalStorage(legacyKey),
    clearLegacy: () => platform.removeLocalStorage(legacyKey),
  );
}
