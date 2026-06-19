---
name: design-token-extractor
description: Extracts unified machine-readable design tokens from Stitch HTML mockups. Produces a canonical design_tokens.json — the single source of truth for all UI work.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-19
---

# Design Token Extractor

Extract a unified, machine-queryable `design_tokens.json` from Stitch HTML mockup directories. This file becomes the canonical design reference that ALL agents (planner, feature-agent, visual-validator, reviewer) use instead of re-interpreting prose markdown docs.

## When to use

- At Phase 0 (foundation) of the pipeline, when `STITCH_MOCKUPS_PATH` is configured
- When a design system update happens and tokens need regenerating
- Before the planner creates workstreams — tokens inform screens, components, colors

## Prerequisites

- `design_tokens.json` does not exist OR user confirms regeneration is OK
- `STITCH_MOCKUPS_PATH` points to a Stitch directory with `*/code.html` files
- The `stitch-html-parser` skill is available

## Process

### Step 1: Confirm source

```bash
ls [STITCH_MOCKUPS_PATH]/*/code.html | wc -l
```

If no HTML files found: report to user and ask if a different path should be used.

### Step 2: Run the Stitch parser

Invoke the `stitch-html-parser` skill logic to parse all HTML files and extract raw tokens. The parser:

1. Reads all `*/code.html` files
2. Extracts tailwind.config blocks
3. Merges and resolves naming conflicts
4. Produces a draft `design_tokens.json`

### Step 3: Enhance with component inference

After the parser produces raw tokens, enhance them:

1. **Component inference from HTML patterns:**
   - Scan repeated HTML structures across screens to identify components
   - A repeating `div` with `aspect-[3/4]` and `scrim-gradient` → is a BookCard
   - A repeating `div` with `rounded-full` and search icon → is a SearchBar
   - Document each identified component with its:
     - Element structure
     - Padding/margin classes → spacing values
     - Color classes → token references
     - Typography classes → token references

2. **Component state expansion:**
   - For each component, document which states appear across screens
   - e.g., BookCard might appear with: green dot (available), amber dot (checked out), red dot (loaned)

3. **Typographic scale validation:**
   - Verify that all font families specified in tailwind.config exist in `google_fonts` or are system fonts
   - Flag any that need explicit Google Fonts declarations

4. **Spacing scale normalization:**
   - Ensure all spacing values are multiples of the base grid unit (typically 4 or 8)
   - Flag non-multiples

### Step 4: Cross-reference with human design doc

If `DESIGN_SYSTEM_PATH` points to a `01-design.md` or similar:
- Cross-reference extracted tokens against the prose design spec
- Identify discrepancies (e.g., doc says `#0D7377` accent, HTML uses `#00595c`)
- Report discrepancies to user; prefer the HTML as the visual source of truth

### Step 5: Write output

Write the enhanced `design_tokens.json` to `docs/design_tokens.json` (configurable):

```bash
mkdir -p [OUTPUT_DIR]
```

Write JSON with:
- Complete color palette (light + dark)
- Typographic scale
- Spacing scale
- Border radius values
- Component library (inferred)
- Screen catalog
- Warnings and unresolved issues
- Extraction metadata (timestamp, screen count, parser version)

### Step 6: Validate

After writing, validate:

1. All screens from `STITCH_MOCKUPS_PATH` are represented in `screens[]`
2. All hex values are 6-character or 8-character format
3. All spacing values are numbers (not strings like "16px")
4. Font families are valid Google Fonts or system font names
5. No raw Tailwind class names remain in component descriptions

### Step 7: Report

Output a summary:
- Total screens processed
- Total colors extracted (light + dark)
- Typography entries
- Components inferred
- Warnings and action items
- Output file path: `docs/design_tokens.json`

## Rules

- **Extract, don't invent** — if a value isn't in the HTML, flag it as missing, don't guess
- **HTML is the visual source of truth** — if it conflicts with DESIGN.md, the HTML wins (it's what the user saw and approved)
- **Names matter** — use the most common token name across screens for the canonical output
- **All agents reference design_tokens.json** — not raw HTML files, not raw DESIGN.md
- **Regenerate on design change** — if the user updates Stitch screens, re-extract tokens

## Output conventions

Refer to `design-tokens-schema.md` for the complete output schema.

## Anti-patterns

- Do NOT use a subset of screens — process ALL `code.html` files found
- Do NOT hardcode color hex values extracted from one screen in isolation
- Do NOT skip screens because they're "similar" — every screen has its own tailwind.config variants
