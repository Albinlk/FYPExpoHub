import 'package:flutter/material.dart';

/// Design tokens extracted directly from the Stitch "FYP Expo Hub" project.
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

  // Typography TextStyles
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 40.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.02,
  );

  static const TextStyle h1Mobile = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  /// Page heading: desktop h1, a 28px heading on phones so titles like
  /// "Project Catalogue" stay on one line.
  static TextStyle pageTitle(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 768 ? h1 : h1Mobile.copyWith(fontSize: 28);

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h2Mobile = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h3Mobile = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
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
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
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
      cardTheme: CardThemeData(
        color: DesignSystem.surfaceContainerLowest,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: DesignSystem.radiusLg,
          side: const BorderSide(color: DesignSystem.surfaceContainer, width: 1),
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
