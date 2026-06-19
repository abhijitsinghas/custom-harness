---
name: golden-test-generator
description: Generates golden (visual regression) tests for Flutter screens/widgets. Creates test files, renders baselines in light and dark mode, and stores goldens separately from source mockups.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-19
---

# Golden Test Generator

Use this skill to generate golden (screenshot comparison) tests for Flutter screens. Golden tests serve as the permanent visual baseline after the visual-validator confirms pixel-parity with mockups.

## When to use

- After implementing a new screen/widget (UI-critical workstream)
- Before the visual-validator runs its comparison
- When regenerating baselines after intentional design changes
- When the pipeline asks for a golden test baseline

## First: Read runtime config

Before generating golden tests:

1. Read `AGENTS.md` for `GOLDEN_TEST_DIR`, `GOLDEN_TEST_SRC_DIR`, and `GOLDEN_TEST_FRAMEWORK`
2. Read `design_tokens.json` if available for theme expectations
3. Read the screen/widget code and its test dependencies
4. Check whether `test_goldens/` directory exists; create if needed

## Process

### Step 1: Identify the widget

From the assigned workstream or task input, identify:
- The widget class name
- The screen/widget file path
- Whether it needs light mode, dark mode, or both
- Whether any provider/theme overrides are needed

### Step 2: Create the golden test file

Create a file at `test_goldens/[widget_name]_golden_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
// Import the app theme (from runtime config)
import 'package:APP_PACKAGE/core/app_theme.dart';
// Import the widget under test
import 'package:APP_PACKAGE/features/FEATURE_PATH/widget_file.dart';

void main() {
  group('${WidgetName} golden tests', () {
    testWidgets('renders correctly in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: const ${WidgetName}(...requiredParams)),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(${WidgetName}),
        matchesGoldenFile('goldens/${widget_name}_light.png'),
      );
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: const ${WidgetName}(...requiredParams)),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(${WidgetName}),
        matchesGoldenFile('goldens/${widget_name}_dark.png'),
      );
    });

    // State variants (if applicable)
    testWidgets('renders loading state correctly', (tester) async {
      // ... loading state golden
    });

    testWidgets('renders empty state correctly', (tester) async {
      // ... empty state golden
    });
  });
}
```

### Step 3: Run to generate baselines

```bash
cd [APP_DIR]
flutter test --update-goldens test_goldens/[widget_name]_golden_test.dart
```

The goldens will be created in `test/goldens/` (or `test_goldens/goldens/` depending on project config).

### Step 4: Verify goldens exist

Check that golden PNGs were created:

```bash
ls test/goldens/[widget_name]_light.png
ls test/goldens/[widget_name]_dark.png
```

### Step 5: Report

Produce a summary:
- Golden test file path
- Golden PNG paths
- Light/dark or single mode
- Any state variants covered
- Whether goldens should be committed to version control

## Rules

- **Source mockups (Stitch screen.png) are IMMUTABLE** — never use as golden inputs
- **Golden PNGs go in `test/goldens/`** — separate from source mockup directory
- **After visual-validator confirms parity**, delete the throwaway golden (created during iteration) and re-run golden test to establish the permanent baseline
- **Goldens should be committed** to version control as they are part of CI
- **CI runs golden tests WITHOUT `--update-goldens`** flag — they detect regressions
- **Golden tests need deterministic test data** — use fixed test books, fixed test locations, no random content
- Use `tester.pumpAndSettle()` for async screens; add `Duration(seconds: 2)` timeout if needed

## Anti-patterns

- Do NOT overwrite `design-assets/` mockup files with golden outputs
- Do NOT run `--update-goldens` in CI (detection of regressions is the goal)
- Do NOT use network images in goldens (use asset stubs or local test images)
- Do NOT skip golden tests for UI-critical screens without explicit user approval

## Failure handling

If golden test generation fails:
- Check widget compiles without errors
- Check all required params are provided
- Check theme imports are correct
- If network images are needed, replace with `Container(color: ...)` stubs for golden tests
- Report failure with exact error output
