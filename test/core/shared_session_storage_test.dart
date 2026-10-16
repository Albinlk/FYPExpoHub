import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/supabase/shared_session_storage.dart';

/// A cookie jar that behaves like `document.cookie`: writes set or expire
/// one cookie, reads list the live ones.
class _Jar implements CookieJar {
  final cookies = <String, String>{};
  final writes = <String>[];

  @override
  String read() => [for (final e in cookies.entries) '${e.key}=${e.value}'].join('; ');

  @override
  void write(String cookie) {
    writes.add(cookie);
    final first = cookie.split(';').first;
    final i = first.indexOf('=');
    final name = first.substring(0, i);
    if (cookie.contains('Max-Age=0')) {
      cookies.remove(name);
    } else {
      cookies[name] = first.substring(i + 1);
    }
  }
}

void main() {
  test('a large session round-trips across several cookies on the parent domain', () async {
    final jar = _Jar();
    final s = SharedSessionStorage(jar: jar);
    final session = '{"access_token":"${'a' * 5000}","user":{"email":"é@uitm.edu.my"}}';

    await s.persistSession(session);

    expect(await s.accessToken(), session);
    expect(await s.hasAccessToken(), isTrue);
    expect(jar.cookies.length, greaterThan(2));
    expect(jar.writes.every((w) => w.contains('Domain=fskmjasinfypexhibition.site') && w.contains('Secure')), isTrue);
    expect(jar.cookies.values.every((v) => v.length <= 3000), isTrue);
  });

  test('a shorter session drops the leftover chunks; sign-out clears all', () async {
    final jar = _Jar();
    final s = SharedSessionStorage(jar: jar);
    await s.persistSession('x' * 9000);
    await s.persistSession('short');
    expect(await s.accessToken(), 'short');
    expect(jar.cookies.keys, unorderedEquals(['fyp-sb-0', 'fyp-sb-n']));

    await s.removePersistedSession();
    expect(jar.cookies, isEmpty);
    expect(await s.hasAccessToken(), isFalse);
  });

  test('moves an existing per-site session over once', () async {
    final jar = _Jar();
    var cleared = false;
    final s = SharedSessionStorage(jar: jar, readLegacy: () => 'old', clearLegacy: () => cleared = true);
    await s.initialize();
    expect(await s.accessToken(), 'old');
    expect(cleared, isTrue);
  });

  test('a half-written or garbled cookie set reads as signed out', () async {
    final jar = _Jar()..cookies.addAll({'fyp-sb-n': '2', 'fyp-sb-0': 'abc'});
    expect(await SharedSessionStorage(jar: jar).accessToken(), isNull);
    jar.cookies['fyp-sb-1'] = '!!';
    expect(await SharedSessionStorage(jar: jar).accessToken(), isNull);
  });

  test('only our own hosts share the session', () {
    const url = 'https://abc.supabase.co';
    expect(sharedSessionStorageFor('localhost', supabaseUrl: url), isNull);
    expect(sharedSessionStorageFor('example.com', supabaseUrl: url), isNull);
    expect(sharedSessionStorageFor('evilfskmjasinfypexhibition.site', supabaseUrl: url), isNull);
  });
}
