import 'package:flutter/material.dart';

/// Material Design 3 color schemes for The Little Library.
///
/// Light scheme derived from mockup tokens:
///   Primary: #5D4037 (warm brown)
///   Primary Container: #EADDCF (cream)
///   Secondary: #FFA000 (amber)
///   Surface: #FFF8F0 (off-white)
///   Background: #FAFAF5 (warm grey)

abstract final class AppTheme {
  AppTheme._();

  // ── Design tokens ──────────────────────────────────────────────────────────

  static const Color _primaryLight = Color(0xFF5D4037);
  static const Color _primaryContainerLight = Color(0xFFEADDCF);
  static const Color _secondaryLight = Color(0xFFFFA000);
  static const Color _surfaceLight = Color(0xFFFFF8F0);
  static const Color _backgroundLight = Color(0xFFFAFAF5);

  static const Color _primaryDark = Color(0xFFBCAAA4);
  static const Color _primaryContainerDark = Color(0xFF4E342E);
  static const Color _secondaryDark = Color(0xFFFFB74D);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _backgroundDark = Color(0xFF121212);

  static const Color _onPrimaryLight = Color(0xFFFFFFFF);
  static const Color _onPrimaryContainerLight = Color(0xFF3E2723);
  static const Color _onSecondaryLight = Color(0xFF000000);
  static const Color _onSurfaceLight = Color(0xFF1C1B1F);

  static const Color _onPrimaryDark = Color(0xFF3E2723);
  static const Color _onPrimaryContainerDark = Color(0xFFEADDCF);
  static const Color _onSecondaryDark = Color(0xFF3E2723);
  static const Color _onSurfaceDark = Color(0xFFE6E1E5);

  // ── Color schemes ──────────────────────────────────────────────────────────

  static ColorScheme get lightScheme => ColorScheme(
        brightness: Brightness.light,
        primary: _primaryLight,
        onPrimary: _onPrimaryLight,
        primaryContainer: _primaryContainerLight,
        onPrimaryContainer: _onPrimaryContainerLight,
        secondary: _secondaryLight,
        onSecondary: _onSecondaryLight,
        surface: _surfaceLight,
        onSurface: _onSurfaceLight,
        error: Colors.red.shade700,
        onError: Colors.white,
      );

  static ColorScheme get darkScheme => ColorScheme(
        brightness: Brightness.dark,
        primary: _primaryDark,
        onPrimary: _onPrimaryDark,
        primaryContainer: _primaryContainerDark,
        onPrimaryContainer: _onPrimaryContainerDark,
        secondary: _secondaryDark,
        onSecondary: _onSecondaryDark,
        surface: _surfaceDark,
        onSurface: _onSurfaceDark,
        error: Colors.redAccent.shade200,
        onError: Colors.black,
      );

  // ── Themes ─────────────────────────────────────────────────────────────────

  /// Light [ThemeData] wired to the warm-brown colour scheme.
  static ThemeData get light {
    final scheme = lightScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
      ),
    );
  }

  /// Dark [ThemeData] wired to the warm-brown colour scheme.
  static ThemeData get dark {
    final scheme = darkScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
      ),
    );
  }
}
