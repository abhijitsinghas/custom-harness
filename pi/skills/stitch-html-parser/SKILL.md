---
name: stitch-html-parser
description: Parses Stitch-generated HTML mockup directories to extract design tokens (colors, typography, spacing, layout) from tailwind.config blocks into structured JSON.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-19
---

# Stitch HTML Parser

Parse all `code.html` files in a Stitch mockup directory and extract structured design token data. This is the first step of the design token pipeline.

## When to use

- When the project runtime config has `STITCH_MOCKUPS_PATH` pointing to a directory with `*/code.html` files
- Before planning workstreams — tokens must be available for the planner

## Process

### Step 1: Scan the directory

```bash
find [STITCH_MOCKUPS_PATH] -name "code.html" -type f
```

Count the files found. If zero, report that this doesn't look like a Stitch mockup directory and ask the user.

### Step 2: Extract tailwind.config from each file

For each `code.html` file:

1. Read the file
2. Locate the `<script id="tailwind-config">` block
3. Extract the `tailwind.config = { ... }` JavaScript object
4. Parse the following from it:
   - `theme.extend.colors` — All color definitions with hex values
   - `theme.extend.fontFamily` — Font family groupings
   - `theme.extend.fontSize` — Font sizes with lineHeight and fontWeight
   - `theme.extend.spacing` — Named spacing tokens with values
   - `theme.extend.borderRadius` — Border radius values

### Step 3: Resolve naming inconsistencies

Stitch screens can have inconsistent token names. Apply this resolution strategy:

1. **Priority list** for color token resolution:
   - If a screen defines `primary`, map it to `brandPrimary`
   - If a screen defines `accent`, `primary`, or `primary-container`, prefer the most commonly used name across all screens
   - Resolve duplicates by value matching: if two tokens have the same hex, they're the same color
   - Track all variants in the output so conflicts are visible

2. **For typography**, prefer the file with the most complete set:
   - If a screen defines `h1`, another `headline-lg`, another `headline-lg`, prefer the most common name
   - Include font file names (e.g. `Lora`, `Inter`, `JetBrainsMono`)

3. **For spacing**, normalize:
   - Convert Tailwind-style values like `"16px"` to numbers: `16`
   - Group into a standard scale: xs=4, sm=8, md=12, lg=16, xl=24, xxl=32
   - Flag any non-standard values that don't fit the scale

4. **For dark mode**, special handling:
   - Screen directories with `-dark` suffix (e.g. `22-catalog-dark`) are dark mode references
   - Extract their colors as the dark palette
   - If no dark mode screens exist, note that dark tokens are missing

### Step 4: Extract screen-level layout summaries

For each screen, extract from the HTML structure:

- Layout pattern: single column, grid (n × m), list, form, etc.
- Key components: buttons, cards, bottom sheets, search bars, etc.
- Special elements: navigation, status bars, FABs, etc.
- Note any platform-specific hints

Store in the `screens` array of the output.

### Step 5: Write the unified output

Write to `design_tokens.json` in the configured output path (default: `docs/design_tokens.json`).

## Output schema

See `design-tokens-schema.md` for the complete JSON schema. Summary:

```json
{
  "schema_version": "1.0",
  "source": "stitch-html",
  "source_directory": "design-assets/TheLittleLibrary-Stitch-Mockup/",
  "screens_extracted": 20,
  "warnings": ["No dark mode tokens found for screens 05-19", "Color name mismatch: primary vs primary-container"],
  "colors": {
    "light": {
      "background": "#F8F7F4",
      "surface": "#FFFFFF",
      "textPrimary": "#1C1B1F",
      "textSecondary": "#6B7280",
      "accent": "#0D7377",
      "accentAlt": "#B84A2C",
      "success": "#2B9348",
      "warning": "#E09F3E",
      "error": "#D62828"
    },
    "dark": { "..." : "..." }
  },
  "typography": {
    "h1": { "family": "Lora", "size": 24, "lineHeight": 32, "weight": "w600" },
    "h2": { "family": "Lora", "size": 18, "lineHeight": 24, "weight": "w600" },
    "body": { "family": "Inter", "size": 16, "lineHeight": 24, "weight": "w400" },
    "bookTitle": { "family": "Inter", "size": 14, "lineHeight": 20, "weight": "w500" },
    "label": { "family": "Inter", "size": 14, "lineHeight": 20, "weight": "w600" },
    "caption": { "family": "Inter", "size": 12, "lineHeight": 16, "weight": "w400" },
    "mono": { "family": "JetBrainsMono", "size": 12, "lineHeight": 16, "weight": "w400" }
  },
  "spacing": { "xs": 4, "sm": 8, "md": 12, "lg": 16, "xl": 24, "xxl": 32 },
  "borderRadius": { "default": 4, "lg": 8, "xl": 12, "full": 9999 },
  "components": {
    "bookCardGrid": {
      "layout": "grid-2-columns",
      "aspectRatio": "3:4",
      "source_screens": ["06-catalog-grid", "22-catalog-dark"]
    }
  },
  "screens": [
    {
      "id": "06-catalog-grid",
      "name": "Catalog Grid",
      "html_path": "design-assets/.../06-catalog-grid/code.html",
      "screen_path": "design-assets/.../06-catalog-grid/screen.png",
      "layout": "2-column grid with sticky header + floating bottom bar",
      "key_components": ["topAppBar", "bookCardGrid", "searchBar", "cameraButton"],
      "dark_variant": "22-catalog-dark"
    }
  ]
}
```

## Rules

- **Never overwrite source `code.html` files** — this parser is read-only
- **Always note warnings** — if tokens don't resolve cleanly, the user needs to know
- **Prefer value-matching over name-matching** — two tokens with the same hex value are the same design token
- **Flag missing dark tokens** — most Stitch output omits dark mode for bulk screens
