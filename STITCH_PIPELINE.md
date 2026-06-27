# Stitch → Flutter Design Token Pipeline

> How to go from Stitch mockups to design_tokens.json to pixel-perfect Flutter UIs.

## Overview

```
┌──────────────────────────┐
│  Stitch Mockup Directory │
│  ├── 01-welcome/         │
│  │   ├── screen.png      │  ← visual reference (immutable)
│  │   └── code.html       │  ← tailwind.config + HTML structure
│  ├── 02-join/            │
│  └── ...                 │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│ extract_design_tokens.js │  ← deterministic harness tool
│ + design-token-extractor │  ← semantic enhancement skill
│  1. Parse all code.html   │
│  2. Extract tailwind.config│
│  3. Merge + resolve conflicts│
│  4. Infer component patterns│
│  5. Write design_tokens.json│
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│  design_tokens.json      │  ← machine-readable source of truth
│  - colors (light + dark) │
│  - typography            │
│  - spacing               │
│  - components            │
│  - screens               │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────────────────────────────┐
│  All harness agents reference this single file:   │
│                                                    │
│  planner → plans workstreams with token refs       │
│  feature-agent → uses tokens, not hardcoded values │
│  visual-validator → compares against token values  │
│  reviewer → checks token compliance                │
│  architect → scans for hardcoded violations        │
└──────────────────────────────────────────────────┘
            │
            ▼
┌──────────────────────────┐
│  Flutter ThemeData        │
│  ColorScheme.from(        │
│    seed: Color(0xFF0D7377)│
│  )                        │
│  TextTheme applied        │
│  AppSpacing constants     │
└──────────────────────────┘
```

## Setup

### 1. Place Stitch mockups in your project

Recommended layout:

```
[project-root]/
├── design-assets/
│   └── Stitch-Mockup/          ← STITCH_MOCKUPS_PATH
│       ├── 01-welcome/
│       │   ├── screen.png
│       │   └── code.html
│       ├── 02-dashboard/
│       │   ├── screen.png
│       │   └── code.html
│       └── design.md           ← optional, Stitch-generated design doc
├── docs/
│   ├── SPEC.md
│   ├── 01-design.md            ← human-written design system
│   └── design_tokens.json      ← OUTPUT: machine-readable tokens
└── [app_dir]/
    ├── lib/
    │   └── core/
    │       └── app_theme.dart  ← generated from design_tokens.json
    ├── test/
    │   └── goldens/            ← golden PNG baselines
    └── test_goldens/           ← golden test dart files
```

### 2. Configure AGENTS.md

```markdown
## Design System Assets

| Path | Value |
|---|---|
| Design tokens (JSON) | `docs/design_tokens.json` |
| Stitch HTML mockups | `design-assets/Stitch-Mockup/` |
| Golden test directory | `[app_dir]/test/goldens/` |
| Golden test source | `[app_dir]/test_goldens/` |
```

### 3. Run deterministic extraction

During Phase 0, the orchestrator runs the shipped deterministic script first:

```bash
node .pi/harness-tools/extract_design_tokens.js design-assets/Stitch-Mockup/ docs/design_tokens.json
```

The `design-token-extractor` skill may then semantically enhance the generated JSON (component naming, warnings, design-doc cross-reference), but it should not improvise the base parsing if the script is available.

## How Agents Use design_tokens.json

### Planner
Reads the token file to understand what colors, typography, and components exist. References token names in workstream plans instead of raw values.

### Feature-Agent
Reads the token file before implementing any UI. Uses `Theme.of(context).colorScheme.XXX` instead of `Color(0xFFXXXXXX)`. Uses `AppSpacing.XX` instead of raw numbers.

### Visual-Validator
Uses token values as the expected benchmark when comparing rendered goldens against Stitch screenshots. Reports "expected accent color `#0D7377` from design_tokens.json, got `#00595c`".

### Reviewer
Scans code for hardcoded values that contradict design_tokens.json. Flags violations as BLOCKER.

### Architect
Runs check #7 (Design token compliance) using design_tokens.json as the reference.

## Stitch HTML vs DESIGN.md — Which is the source of truth?

| Source | Priority | When to use |
|---|---|---|
| **Stitch HTML (code.html)** | **Primary** — what the user visually approved | Extract colors, spacing, typography, layout |
| **Human DESIGN.md** | Secondary — prose complement | Cross-reference, fill gaps (dark mode, interaction states) |
| **Stitch screen.png** | Visual benchmark only | Compare goldens against |

**Rule:** If Stitch HTML says one thing and DESIGN.md says another, the HTML wins. The user visually approved the HTML output, not the prose spec.

## Re-extraction

When the user updates Stitch mockups (new screens, changed designs):

1. The orchestrator detects that `STITCH_MOCKUPS_PATH` files modified date > `design_tokens.json` modified date
2. Orchestrator asks user: "Stitch mockups changed. Re-extract design tokens?"
3. If approved, re-runs the design-token-extractor
4. New `design_tokens.json` is written
5. Golden tests may need re-baselining (user approval required)

## Troubleshooting

### "No dark mode tokens found"
Most Stitch output provides dark tokens only for screens specifically requested with dark mode. The extractor will note this warning. The feature-agent should still implement dark mode using Material 3's default dark theme + token overrides.

### "Color name mismatch between screens"
Stitch sometimes uses different token names for the same color. The extractor resolves by value-matching (same hex = same token). The resolution is noted in the warnings field.

### "Component patterns detected but no component specs"
Stitch HTML reveals repeated patterns (e.g., card structures) but doesn't have explicit component documentation. The extractor infers components from repeated HTML patterns. The planner should verify inferred components against the design spec.
