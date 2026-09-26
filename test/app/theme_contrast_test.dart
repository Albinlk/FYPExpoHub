import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/app/theme/theme.dart';

/// WCAG 2.x contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// G-34 contrast audit: every foreground/background pair the app uses for
/// TEXT meets WCAG AA for body text (4.5 : 1). Large decorative icons in
/// outlineVariant are exempt (not text, not essential).
void main() {
  const white = Color(0xFFFFFFFF);
  final pairs = <String, (Color, Color)>{
    'body text on page': (DesignSystem.onBackground, DesignSystem.background),
    'muted text on page': (DesignSystem.onSurfaceVariant, DesignSystem.background),
    'muted text on card': (DesignSystem.onSurfaceVariant, DesignSystem.surfaceContainerLowest),
    'muted text on parchment': (DesignSystem.onSurfaceVariant, DesignSystem.surfaceContainerLow),
    'muted text on offline banner': (DesignSystem.onSurfaceVariant, DesignSystem.surfaceContainerHighest),
    'primary text on page': (DesignSystem.primary, DesignSystem.background),
    'secondary (links, labels) on page': (DesignSystem.secondary, DesignSystem.background),
    'secondary on card': (DesignSystem.secondary, white),
    'white on primary (app bars, buttons)': (DesignSystem.onPrimary, DesignSystem.primary),
    'white on secondary (buttons)': (white, DesignSystem.secondary),
    'lilac on plum': (DesignSystem.onPrimaryContainer, DesignSystem.primaryContainer),
    'umber on apricot': (DesignSystem.onSecondaryContainer, DesignSystem.secondaryContainer),
    'mint on verdigris': (DesignSystem.onTertiaryContainer, DesignSystem.tertiaryContainer),
    'tertiary text on page': (DesignSystem.tertiary, DesignSystem.background),
    'error text on card': (DesignSystem.error, white),
    'error text on page': (DesignSystem.error, DesignSystem.background),
    'error container text': (DesignSystem.onErrorContainer, DesignSystem.errorContainer),
  };

  for (final e in pairs.entries) {
    test('contrast ≥ 4.5 : 1 — ${e.key}', () {
      final ratio = contrast(e.value.$1, e.value.$2);
      expect(ratio, greaterThanOrEqualTo(4.5), reason: '${e.key}: ${ratio.toStringAsFixed(2)} : 1');
    });
  }
}
