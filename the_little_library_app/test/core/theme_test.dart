import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_little_library_app/core/theme.dart';

void main() {
  group('AppTheme', () {
    group('light theme', () {
      test('has correct brightness', () {
        expect(AppTheme.light.brightness, Brightness.light);
      });

      test('uses Material 3', () {
        expect(AppTheme.light.useMaterial3, isTrue);
      });

      test('primary colour matches mockup token (#5D4037)', () {
        expect(AppTheme.light.colorScheme.primary, const Color(0xFF5D4037));
      });

      test('onPrimary is white', () {
        expect(
          AppTheme.light.colorScheme.onPrimary,
          const Color(0xFFFFFFFF),
        );
      });

      test('primaryContainer matches mockup token (#EADDCF)', () {
        expect(
          AppTheme.light.colorScheme.primaryContainer,
          const Color(0xFFEADDCF),
        );
      });

      test('secondary colour matches mockup token (#FFA000)', () {
        expect(
          AppTheme.light.colorScheme.secondary,
          const Color(0xFFFFA000),
        );
      });

      test('surface colour matches mockup token (#FFF8F0)', () {
        expect(
          AppTheme.light.colorScheme.surface,
          const Color(0xFFFFF8F0),
        );
      });

      test('scaffold background is warm grey (#FAFAF5)', () {
        expect(
          AppTheme.light.scaffoldBackgroundColor,
          const Color(0xFFFAFAF5),
        );
      });

      test('app bar theme uses primaryContainer background', () {
        final appBar = AppTheme.light.appBarTheme;
        expect(appBar.backgroundColor, const Color(0xFFEADDCF));
        expect(appBar.foregroundColor, const Color(0xFF3E2723));
        expect(appBar.elevation, 0);
      });

      test('card theme has 12dp border radius', () {
        final shape = AppTheme.light.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));
      });

      test('FAB theme uses secondary colour', () {
        final fab = AppTheme.light.floatingActionButtonTheme;
        expect(fab.backgroundColor, const Color(0xFFFFA000));
        expect(fab.foregroundColor, const Color(0xFF000000));
      });

      test('input decoration uses filled style with 8dp radius', () {
        final input = AppTheme.light.inputDecorationTheme;
        expect(input.filled, isTrue);
        expect(input.fillColor, const Color(0xFFFFF8F0));
        final border = input.border as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(8));
      });

      test('text theme uses Roboto at 16sp / 14sp', () {
        final text = AppTheme.light.textTheme;
        expect(text.bodyLarge?.fontFamily, 'Roboto');
        expect(text.bodyLarge?.fontSize, 16);
        expect(text.bodyMedium?.fontFamily, 'Roboto');
        expect(text.bodyMedium?.fontSize, 14);
      });
    });

    group('dark theme', () {
      test('has correct brightness', () {
        expect(AppTheme.dark.brightness, Brightness.dark);
      });

      test('uses Material 3', () {
        expect(AppTheme.dark.useMaterial3, isTrue);
      });

      test('primary is a lighter brown (#BCAAA4)', () {
        expect(AppTheme.dark.colorScheme.primary, const Color(0xFFBCAAA4));
      });

      test('secondary is a lighter amber (#FFB74D)', () {
        expect(
          AppTheme.dark.colorScheme.secondary,
          const Color(0xFFFFB74D),
        );
      });

      test('scaffold background is near-black (#121212)', () {
        expect(
          AppTheme.dark.scaffoldBackgroundColor,
          const Color(0xFF121212),
        );
      });
    });

    group('light scheme (static getter)', () {
      test('returns a ColorScheme, not a ThemeData', () {
        expect(AppTheme.lightScheme, isA<ColorScheme>());
      });

      test('has light brightness', () {
        expect(AppTheme.lightScheme.brightness, Brightness.light);
      });
    });

    group('dark scheme (static getter)', () {
      test('returns a ColorScheme, not a ThemeData', () {
        expect(AppTheme.darkScheme, isA<ColorScheme>());
      });

      test('has dark brightness', () {
        expect(AppTheme.darkScheme.brightness, Brightness.dark);
      });
    });
  });
}
