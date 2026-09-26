import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/utils/external_link.dart';

void main() {
  test('keeps http(s) links as they are', () {
    expect(safeExternalUri('https://github.com/a/b').toString(), 'https://github.com/a/b');
    expect(safeExternalUri('http://demo.example.com').toString(), 'http://demo.example.com');
  });

  test('assumes https when the scheme is missing', () {
    expect(safeExternalUri('  github.com/a/b ').toString(), 'https://github.com/a/b');
  });

  test('refuses empty and non-web links', () {
    for (final raw in [null, '', '   ', 'javascript:alert(1)', 'mailto:a@b.c', 'data:text/html,x', 'https://']) {
      expect(safeExternalUri(raw), isNull, reason: raw);
    }
  });
}
