import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/web/local_prefs.dart';
import 'package:fyp_expo_hub/core/web/local_prefs_stub.dart' as stub;

/// Storage that refuses every call, like a browser with site data blocked.
class _BlockedPrefs implements LocalPrefs {
  @override
  String? read(String key) => throw StateError('blocked');

  @override
  void write(String key, String? value) => throw StateError('blocked');
}

void main() {
  setUp(() => localPrefs = MemoryLocalPrefs());

  test('outside the browser the store is in memory', () {
    expect(stub.createLocalPrefs(), isA<MemoryLocalPrefs>());
  });

  test('a string set round-trips', () {
    writeStringSet('k', {'b', 'a'});
    expect((localPrefs as MemoryLocalPrefs).values['k'], '["a","b"]');
    expect(readStringSet('k'), {'a', 'b'});
  });

  test('nothing stored, or junk stored, reads as null', () {
    expect(readStringSet('missing'), isNull);
    localPrefs = MemoryLocalPrefs({'a': 'not json', 'b': '{"x":1}', 'c': '[1,"ok"]'});
    expect(readStringSet('a'), isNull);
    expect(readStringSet('b'), isNull);
    expect(readStringSet('c'), {'ok'});
  });

  test('blocked storage never throws', () {
    localPrefs = _BlockedPrefs();
    expect(readStringSet('k'), isNull);
    expect(() => writeStringSet('k', {'a'}), returnsNormally);
    final set = PersistedStringSet('k');
    expect(set.value, isEmpty);
    expect(() => set.value = {'a'}, returnsNormally);
    expect(set.value, {'a'});
  });

  test('PersistedStringSet starts from storage, saves changes, and reloads', () {
    localPrefs = MemoryLocalPrefs({'k': '["x"]'});
    final set = PersistedStringSet('k');
    expect(set.value, {'x'});

    set.value = {'x', 'y'};
    expect(readStringSet('k'), {'x', 'y'});

    localPrefs.write('k', '["z"]');
    set.reload();
    expect(set.value, {'z'});
    expect(localPrefs.read('k'), '["z"]');
  });
}
