import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/app/site_hosts.dart';

/// The Help route table points at `{#id}` section ids in the handbook guides
/// (`docs/guides/<guide>.md`). Renaming or dropping a heading id there would
/// silently land Help at the top of the page, so every id must still exist.
void main() {
  final guides = {for (final r in kHandbookRoutes.values) r.guide};

  for (final guide in guides) {
    test('every Help anchor exists in docs/guides/$guide.md', () {
      final file = File('docs/guides/$guide.md');
      expect(file.existsSync(), isTrue, reason: '${file.path} (run tests from the repo root)');
      final ids = RegExp(r'\{#([A-Za-z0-9_-]+)\}').allMatches(file.readAsStringSync()).map((m) => m.group(1)).toSet();
      final missing = [
        for (final e in kHandbookRoutes.entries)
          if (e.value.guide == guide && e.value.anchor != null && !ids.contains(e.value.anchor)) '${e.key} -> #${e.value.anchor}',
      ];
      expect(missing, isEmpty, reason: 'anchors missing from $guide.md');
    });
  }

  test('route table keys are absolute paths without a trailing slash', () {
    for (final key in kHandbookRoutes.keys) {
      expect(key.startsWith('/'), isTrue, reason: key);
      if (key != '/') expect(key.endsWith('/'), isFalse, reason: key);
    }
  });
}
