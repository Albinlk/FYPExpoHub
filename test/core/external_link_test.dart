import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/utils/external_link.dart';

void main() {
  group('safeExternalUri', () {
    test('keeps full links and adds https to a bare host', () {
      expect(safeExternalUri('https://example.com/a.png').toString(), 'https://example.com/a.png');
      expect(safeExternalUri('example.com/poster.pdf').toString(), 'https://example.com/poster.pdf');
      expect(safeExternalUri('http://example.com').toString(), 'http://example.com');
    });

    test('refuses a site-relative path instead of turning it into https://assets/…', () {
      expect(safeExternalUri('assets/images/banner.jpg'), isNull);
      expect(safeExternalUri('assets/images/poster.jpg'), isNull);
      expect(safeExternalUri('images/pic.png'), isNull);
    });

    test('refuses empty, odd schemes and scripts', () {
      expect(safeExternalUri(null), isNull);
      expect(safeExternalUri('  '), isNull);
      expect(safeExternalUri('javascript:alert(1)'), isNull);
      expect(safeExternalUri('ftp://example.com/x'), isNull);
    });
  });
}
