/// Material Design 3 theme definition with light and dark variants.
/// US-0.1.1, US-0.1.2, US-0.1.3, US-0.1.18, US-0.4.24.
library;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme.g.dart';

// ── Color tokens ────────────────────────────────────────────────────────────

// Light mode
const _primaryLight = Color(0xFF5D4037);
const _onPrimaryLight = Color(0xFFFFFFFF);
const _primaryContainerLight = Color(0xFFEADDCF);
const _onPrimaryContainerLight = Color(0xFF3E2B23);
const _secondaryLight = Color(0xFFFFA000);
const _onSecondaryLight = Color(0xFF000000);
const _surfaceLight = Color(0xFFFFF8F0);
const _onSurfaceLight = Color(0xFF1C1B1F);
const _backgroundLight = Color(0xFFFAFAF5);
const _errorLight = Color(0xFFB3261E);
const _onErrorLight = Color(0xFFFFFFFF);

// Dark mode
const _primaryDark = Color(0xFFD4C4B5);
const _onPrimaryDark = Color(0xFF3E2B23);
const _primaryContainerDark = Color(0xFF5D4037);
const _onPrimaryContainerDark = Color(0xFFEADDCF);
const _secondaryDark = Color(0xFFFFB945);
const _onSecondaryDark = Color(0xFF000000);
const _surfaceDark = Color(0xFF2B2930);
const _onSurfaceDark = Color(0xFFE6E1E5);
const _backgroundDark = Color(0xFF1C1B1F);
const _errorDark = Color(0xFFF2B8B5);
const _onErrorDark = Color(0xFF601410);

// ── SharedPreferences key ───────────────────────────────────────────────────

const _themeModeKey = 'theme_mode';

// ── Theme builder ───────────────────────────────────────────────────────────

/// Creates the light [ThemeData] with Material Design 3 tokens.
ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _primaryLight,
    brightness: Brightness.light,
    primary: _primaryLight,
    onPrimary: _onPrimaryLight,
    primaryContainer: _primaryContainerLight,
    onPrimaryContainer: _onPrimaryContainerLight,
    secondary: _secondaryLight,
    onSecondary: _onSecondaryLight,
    surface: _surfaceLight,
    onSurface: _onSurfaceLight,
    error: _errorLight,
    onError: _onErrorLight,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _backgroundLight,
  ).copyWith(
    textTheme: ThemeData(brightness: Brightness.light).textTheme.copyWith(
          bodyLarge: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
          bodyMedium: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
  );
}

/// Creates the dark [ThemeData] with Material Design 3 tokens.
ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _primaryDark,
    brightness: Brightness.dark,
    primary: _primaryDark,
    onPrimary: _onPrimaryDark,
    primaryContainer: _primaryContainerDark,
    onPrimaryContainer: _onPrimaryContainerDark,
    secondary: _secondaryDark,
    onSecondary: _onSecondaryDark,
    surface: _surfaceDark,
    onSurface: _onSurfaceDark,
    error: _errorDark,
    onError: _onErrorDark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _backgroundDark,
  ).copyWith(
    textTheme: ThemeData(brightness: Brightness.dark).textTheme.copyWith(
          bodyLarge: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
          bodyMedium: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
  );
}

// ── Theme state management ──────────────────────────────────────────────────

/// Persisted theme mode — defaults to system.
///
/// Reads the persisted [ThemeMode] from [SharedPreferences] on build.
/// Writes back on every toggle/set to persist across app restarts.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `themeModeProvider`.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // Attempt to read persisted preference synchronously.
    // SharedPreferences requires async init; we use a synchronous fallback
    // for the initial build and update asynchronously.
    _loadPersistedMode();
    return ThemeMode.system;
  }

  Future<void> _loadPersistedMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_themeModeKey);
      if (stored != null) {
        state = ThemeMode.values.byName(stored);
      }
    } catch (_) {
      // If SharedPreferences fails (e.g., first launch), keep system default.
    }
  }

  Future<void> _persist(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (_) {
      // Silently fail persistence — theme still applied in-memory.
    }
  }

  /// Toggle between light and dark mode.
  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    _persist(next);
  }

  /// Explicitly set [ThemeMode] (light, dark, or system).
  void setMode(ThemeMode mode) {
    state = mode;
    _persist(mode);
  }
}
