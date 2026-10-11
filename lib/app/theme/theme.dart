import 'package:flutter/material.dart';

/// Design tokens ("Scholar + Lab", see DESIGN.md). Colours are the Ink &
/// Terracotta palette checked by test/app/theme_contrast_test.dart.
class DesignSystem {
  DesignSystem._();

  // Colors
  static const Color primary = Color(0xFF2A1838); // Aubergine Ink
  static const Color primaryContainer = Color(0xFF3D2A52); // Plum
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFC2AEDD); // Lilac

  static const Color secondary = Color(0xFF9A3A12); // Terracotta
  static const Color secondaryContainer = Color(0xFFF6B48A); // Apricot
  static const Color onSecondaryContainer = Color(0xFF6E2609); // Burnt Umber

  static const Color tertiary = Color(0xFF0B2A26); // Deep Verdigris
  static const Color tertiaryContainer = Color(0xFF12423B); // Verdigris
  static const Color onTertiaryContainer = Color(0xFF84CDB8); // Sage Mint

  static const Color background = Color(0xFFFAF7F2); // Warm Paper
  static const Color onBackground = Color(0xFF1E1A20); // Ink Black
  
  static const Color surface = Color(0xFFFAF7F2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // White (cards, modals)
  static const Color surfaceContainerLow = Color(0xFFF3EEE7); // Parchment
  static const Color surfaceContainer = Color(0xFFECE5DB); // Dividers, borders
  static const Color surfaceContainerHighest = Color(0xFFE0D7CA); // Outline

  static const Color onSurfaceVariant = Color(0xFF4E4652); // Muted body text
  static const Color outlineVariant = Color(0xFFCFC5BA); // Input borders
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Border Radii
  static final BorderRadius radiusSm = BorderRadius.circular(4);      // Tags, check-boxes
  static final BorderRadius radiusLg = BorderRadius.circular(8);      // Buttons, inputs, standard cards
  static final BorderRadius radiusXl = BorderRadius.circular(12);     // Large sections, hero, dialogs
  static final BorderRadius radiusFull = BorderRadius.circular(9999); // Pills, rounded action buttons

  // Spacing & Padding
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double gutter = 24.0;
  static const double marginMobile = 16.0;
  static const double marginDesktop = 48.0;

  /// Graph-paper lines behind heroes (Ink at 6%). Decorative only.
  static const Color gridLine = Color(0x0F2A1838);

  /// Hairline rules and card borders.
  static const Color rule = outlineVariant;

  // Typography ("Scholar + Lab"): Fraunces for display and page headlines,
  // Inter for body and UI, JetBrains Mono for codes and numbers.
  // Flutter letterSpacing is in logical pixels, so em values are multiplied
  // by the font size.
  static const String serif = 'Fraunces';
  static const String mono = 'JetBrains Mono';

  /// Hero headline only.
  static const TextStyle display = TextStyle(
    fontFamily: serif,
    fontSize: 56.0,
    fontWeight: FontWeight.bold,
    height: 1.05,
    letterSpacing: -0.02 * 56.0,
  );

  static const TextStyle displayMobile = TextStyle(
    fontFamily: serif,
    fontSize: 40.0,
    fontWeight: FontWeight.bold,
    height: 1.08,
    letterSpacing: -0.02 * 40.0,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: serif,
    fontSize: 40.0,
    fontWeight: FontWeight.bold,
    height: 1.15,
    letterSpacing: -0.02 * 40.0,
  );

  static const TextStyle h1Mobile = TextStyle(
    fontFamily: serif,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    height: 1.15,
    letterSpacing: -0.02 * 32.0,
  );

  /// Page heading: desktop h1, a 28px heading on phones so titles like
  /// "Project Catalogue" stay on one line.
  static TextStyle pageTitle(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 768 ? h1 : h1Mobile.copyWith(fontSize: 28);

  static const TextStyle h2 = TextStyle(
    fontFamily: serif,
    fontSize: 30.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.01 * 30.0,
  );

  static const TextStyle h2Mobile = TextStyle(
    fontFamily: serif,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.01 * 24.0,
  );

  /// Card titles and panel headings (UI, so Inter).
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h3Mobile = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Eyebrow above a headline: "FSKM · UiTM JASIN". Pass upper-case text.
  static const TextStyle kicker = TextStyle(
    fontFamily: mono,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.08 * 12.0,
  );

  /// Codes: booth BK1-07, programme CS266, form F6b, matric numbers.
  static const TextStyle code = TextStyle(
    fontFamily: mono,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Big numbers in stat blocks.
  static const TextStyle stat = TextStyle(
    fontFamily: mono,
    fontSize: 32.0,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.01 * 32.0,
  );

  static const TextStyle statMobile = TextStyle(
    fontFamily: mono,
    fontSize: 26.0,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.01 * 26.0,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18.0,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static const TextStyle bodyLgMobile = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.05 * 12.0, // converting em to logical pixels
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: DesignSystem.primary,
        onPrimary: DesignSystem.onPrimary,
        primaryContainer: DesignSystem.primaryContainer,
        onPrimaryContainer: DesignSystem.onPrimaryContainer,
        secondary: DesignSystem.secondary,
        secondaryContainer: DesignSystem.secondaryContainer,
        onSecondaryContainer: DesignSystem.onSecondaryContainer,
        // background/onBackground/surfaceVariant are deprecated in M3;
        // the page background is set via scaffoldBackgroundColor below and
        // surfaceContainerHighest keeps surfaceVariant's old colour.
        surface: DesignSystem.surface,
        onSurface: DesignSystem.onBackground,
        surfaceContainerHighest: DesignSystem.surfaceContainerLow,
        onSurfaceVariant: DesignSystem.onSurfaceVariant,
        outline: DesignSystem.surfaceContainerHighest,
        outlineVariant: DesignSystem.outlineVariant,
        error: DesignSystem.error,
        errorContainer: DesignSystem.errorContainer,
        onErrorContainer: DesignSystem.onErrorContainer,
      ),
      scaffoldBackgroundColor: DesignSystem.background,
      // Desktop browsers default to a compact density that shrinks touch
      // targets below 48dp; keep the standard size everywhere.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      // One accent: primary actions are terracotta; secondary actions are
      // ink outlines.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: DesignSystem.secondary,
          foregroundColor: DesignSystem.onPrimary,
          textStyle: DesignSystem.button,
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48))),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: DesignSystem.primary,
          textStyle: DesignSystem.button,
          side: const BorderSide(color: DesignSystem.primary),
          shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: DesignSystem.h1,
        displayMedium: DesignSystem.h2,
        displaySmall: DesignSystem.h3,
        bodyLarge: DesignSystem.bodyLg,
        bodyMedium: DesignSystem.bodyMd,
        bodySmall: DesignSystem.bodySm,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignSystem.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: DesignSystem.primary),
      ),
      // Flat and editorial: hierarchy from rules and paper tones, not shadows.
      cardTheme: CardThemeData(
        color: DesignSystem.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignSystem.radiusLg,
          side: const BorderSide(color: DesignSystem.rule, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DesignSystem.surfaceContainer,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignSystem.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spaceMd,
          vertical: DesignSystem.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: DesignSystem.radiusLg,
          borderSide: const BorderSide(color: DesignSystem.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignSystem.radiusLg,
          borderSide: const BorderSide(color: DesignSystem.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignSystem.radiusLg,
          borderSide: const BorderSide(color: DesignSystem.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignSystem.radiusLg,
          borderSide: const BorderSide(color: DesignSystem.error, width: 1),
        ),
        labelStyle: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
        floatingLabelStyle: DesignSystem.bodySm.copyWith(color: DesignSystem.primary, fontWeight: FontWeight.w500),
      ),
    );
  }
}
