import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The one set of layout breakpoints (logical px). Use these instead of
/// repeating `MediaQuery.of(context).size.width >= 768`.
abstract final class Breakpoints {
  /// At or above this width the desktop layout is used (side nav, tables).
  static const double desktop = 768;

  /// At or above this width card grids use three columns.
  static const double wide = 1100;

  /// Below this width space is tight (hide nav labels, collapse app bar actions).
  static const double narrow = 400;

  static double _width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isDesktop(BuildContext context) => _width(context) >= desktop;

  static bool isCompact(BuildContext context) => _width(context) < desktop;

  static bool isNarrow(BuildContext context) => _width(context) < narrow;

  static bool isWide(BuildContext context) => _width(context) >= wide;
}

/// A dialog content width that never exceeds the screen: [max] on desktop,
/// otherwise the screen width minus [gutter] (AlertDialog's own inset padding
/// is not subtracted by the framework for fixed-width children, so this is a
/// cap, not an exact fit).
double dialogWidth(BuildContext context, double max, {double gutter = 96}) {
  final available = MediaQuery.sizeOf(context).width - gutter;
  return math.max(0, math.min(max, available));
}
