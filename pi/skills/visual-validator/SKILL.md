---
name: visual-validator
description: Compares rendered Flutter widgets against Stitch mockup screenshots using vision capabilities. Iterates until visual parity is achieved. Does NOT modify production code directly.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-19
---

# Visual Validator

Use this skill to validate that a rendered Flutter widget visually matches its corresponding mockup screenshot from Stitch. This is the iterative pixel-perfect feedback loop — the critical gap that distinguishes working AI-generated UIs from broken ones.

## When to use

- After a feature-agent completes a UI-critical workstream (screen/widget implementation)
- As part of the visual validation phase of the pipeline
- When the user reports visual discrepancies and wants a comparison

## Required inputs

- **Mockup screenshot path** — the `screen.png` from the Stitch mockup directory
- **Widget code path** — the implemented Dart file
- **Design tokens path** — `design_tokens.json` for expected color/typography/spacing values
- **Golden test path** — the generated golden test (for rendering)
- **App directory** — the Flutter app directory
- **Stitch HTML path** — the `code.html` from the same mockup (for expected layout structure)

## Process

### Step 1: Gather all references

Read these in order:
1. The `design_tokens.json` — for expected values
2. The Stitch `code.html` — for expected component hierarchy and layout
3. The mockup `screen.png` — the visual benchmark
4. The widget code — what was actually implemented

### Step 2: Render the widget

Run the golden test to produce a rendered PNG of the widget:

```bash
cd [APP_DIR]
flutter test --update-goldens test_goldens/[widget_name]_golden_test.dart
```

This creates a golden PNG at `test/goldens/[widget_name]_light.png` (and dark mode variant if configured).

### Step 3: Read and compare

Read both images:
- The mockup `screen.png` (from Stitch)
- The rendered golden PNG (from Step 2)

Compare across these dimensions:

| Dimension | What to check | Tolerance |
|---|---|---|
| **Layout** | Element positions, alignment, grid columns, component hierarchy | 2dp |
| **Colors** | Background, surface, text, accent — against design_tokens.json hex values | Exact match |
| **Typography** | Font family, size, weight, line height — against design_tokens.json | Exact match |
| **Spacing** | Padding, margins, gaps between elements — against design_tokens.json | 2dp |
| **Corner radii** | Card corners, button corners, sheet corners | 2dp |
| **Shadows** | Elevation, blur, offset | Subjective match |
| **Icons** | Icon glyph, size, color | Exact for icon choice, 2dp for size |

### Step 4: Score each dimension

Score each dimension:
- **MATCH** — No visible difference, within tolerance
- **MINOR_DIFFERENCE** — Visible but doesn't break the design (e.g., 1px alignment shift)
- **MISMATCH** — Clearly wrong (e.g., wrong color, missing element, completely different layout)

### Step 5: Produce discrepancy report

If any MISMATCH or >2 MINOR_DIFFERENCE items exist, produce a report:

```markdown
## Visual Discrepancy Report — [Widget Name]

### Mockup: design-assets/.../[screen-name]/screen.png
### Rendered: test/goldens/[widget_name]_light.png

| # | Dimension | Severity | Expected (from tokens/HTML) | Actual | Fix |
|---|---:|---:|---:|---|---|
| 1 | Spacing | MINOR | Card gap: 12dp | Card gap: 8dp | Change `gridDelegate.mainAxisSpacing` from 8.0 to 12.0 |
| 2 | Colors | MISMATCH | Accent: `#0D7377` | Accent: `#00595c` | Use `colorScheme.primary` instead of hardcoded value |
| 3 | Typography | MISMATCH | Title: Lora 600 | Title: Inter 500 | Change to `Theme.of(context).textTheme.headlineLarge` |
| 4 | Layout | MINOR | Status dot: top-right | Status dot: centered | Change `Positioned(right: 8, top: 8)` |

### Fix Instructions

For each mismatch, provide exact instructions:
- File: `lib/features/catalog/widgets/book_card.dart:45`
- Change: `mainAxisSpacing: 8.0` → `mainAxisSpacing: 12.0`
- Why: Match design token spacing.md (12dp card gap from Stitch HTML)
```

### Step 6: Route back to feature-agent

Pass the discrepancy report to the feature-agent with instructions to apply the fixes. The orchestrator handles the routing.

### Step 7: Re-validate

After the feature-agent applies fixes:
1. Re-run the golden test
2. Read the new golden PNG
3. Compare again
4. Score again
5. Report

### Step 8: Termination

- **Parity confirmed:** All dimensions score MATCH or ≤2 MINOR_DIFFERENCE
  - Report: "Visual parity achieved for [Widget Name]"
  - Delete the throwaway golden (used only during iteration)
  - Instruct feature-agent to re-run golden test to establish permanent baseline
  
- **Max iterations reached** (default: 3, configurable via `AGENTS.md`):
  - Report remaining discrepancies to user
  - Offer user choices: continue iterating, reduce strictness, skip validation, abort

## Component-specific checks

For common component types, apply extra checks:

### Book Cards (grid)
- Aspect ratio is exact 3:4
- Status dot is in top-right corner (8dp from edge)
- Gradient scrim reaches 40% of card height
- Title uses white text, 14dp, Inter 500
- Author uses white at 80% opacity, 12dp, Inter 400

### Search Bar
- Border radius is exactly 24dp
- Height is 48dp (or multiples of 8)
- Camera button is circular, 48dp × 48dp, accent color

### Bottom Sheet
- Top corners have 16dp radius
- Handle bar is 40dp × 4dp, 30% opacity
- Background matches `surface` color

### Buttons
- Height is exactly 48dp
- Corner radius is 12dp
- Background is accent color in filled state

## Rules

- **Do NOT modify production code directly** — produce reports, don't edit
- **Do NOT overwrite source mockup images** — `screen.png` and `code.html` are immutable
- **Golden PNGs are transient during iteration** — delete and regenerate freely
- **Always reference design_tokens.json by token name** — never hardcode hex in reports
- **Report exact line numbers where possible** — the feature-agent needs precision
- **Dark mode comparison is optional but recommended** — if both light and dark mockup screens exist, validate both

## Edge cases

- **No golden test exists yet:** Run golden-test-generator first, then validate
- **Widget depends on runtime data:** Use test doubles/mocks for golden rendering
- **Network images in mockups:** Use placeholder containers with matching aspect ratios for goldens
- **Animation in component:** Capture first frame only; note that animation wasn't validated
- **Scrollable content:** Compare the first visible portion; note that overflow content wasn't compared
