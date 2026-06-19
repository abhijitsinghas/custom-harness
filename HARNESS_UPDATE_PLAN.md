# Custom Harness — Comprehensive Update Plan

> **Goal:** Fix all 7 root causes of AI-generated Flutter app failure by updating the project-agnostic custom harness. Every recommendation from the analysis is addressed, tracked, and mapped to concrete file changes.

---

## Table of Contents

1. [Amendment Responses](#1-amendment-responses)
2. [Gap-to-Fix Traceability Matrix](#2-gap-to-fix-traceability-matrix)
3. [Files to Create](#3-files-to-create)
4. [Files to Modify](#4-files-to-modify)
5. [Implementation Order](#5-implementation-order)
6. [Detailed Spec for Each File](#6-detailed-spec-for-each-file)

---

## 1. Amendment Responses

### Amendment 1: Flutter/Dart skills per-project, not universally

**Already handled correctly in the current harness.** The `install.sh` uses `npx skills add dart-lang/skills -a pi` which installs skills into the **project-local** `.pi/skills/` directory, not globally. The `-a pi` flag targets the pi agent format, not `--agent universal`. This is correct — each project gets its own copy.

**No change needed** to the install mechanism itself. However, the new `VISUAL_VALIDATOR.md` and `GOLDEN_TEST.md` skills are *harness-provided custom skills* that live in `pi/skills/` and get installed per-project like the rest.

### Amendment 2: Harness must be project-agnostic

**Already designed this way.** The harness contains no product names, paths, package IDs, or features. Everything comes from `AGENTS.md` or the orchestrator start prompt at runtime.

**All new files proposed below follow this same rule.** No product-specific values in skills or agents. The new visual-validator, design-token-extractor, and golden-test-generator skills all read runtime config from `AGENTS.md` / orchestrator task input.

### Amendment 3: Stitch HTML as machine-readable UI source

**Verdict: Stitch HTML is good but insufficient alone. You need an extraction step.**

#### What Stitch HTML gives you (per screen):

In each `[screen-name]/code.html` file:
- **`<script id="tailwind-config">`** — Structured JSON-like config with colors (hex), spacing (named tokens), typography (fontFamily, fontSize with lineHeight/weight), border radius
- **HTML structure** — Component hierarchy (header > main > grid > card), layout primitives (grid, flex, aspect-ratio), exact class names
- **Real content** — Realistic book data, not placeholders

#### What Stitch HTML does NOT give you:

| Missing | Why it matters |
|---|---|
| **Unified token schema** — Each screen's tailwind config has slightly different token names (e.g. `01-welcome` uses Material 3 names like `primary-container`, `06-catalog-grid` uses simplified names like `primary`) | AI can't reference a single source of truth |
| **Dark mode values** — Only `01-welcome` and `22-catalog-dark` have dark variants; most screens don't include dark tokens | Dark mode rendering will be inconsistent |
| **Component-level spec** — No explicit states (loading, empty, error), no exact padding per component, no interaction specs | AI has to guess component behavior |
| **Explicit spacing values** — Tailwind classes like `gap-3` (12px), `p-3` (12px), `px-margin-mobile` (16px) use indirect mappings | AI must resolve Tailwind → Flutter manually |
| **Platform-specific info** — No information about status bar, safe areas, keyboard handling, back navigation | Android-specific behaviors get missed |

#### The solution: A Stitch HTML parser skill

Create a **design-token-extractor** skill that:
1. Reads all `*/code.html` files in the mockup directory
2. Extracts the tailwind config from each and **merges into one canonical `design_tokens.json`**
3. Resolves naming conflicts (e.g. `primary` in one file vs `primary-container` in another) using a priority/override convention
4. Extracts screen-specific layout summaries from the HTML into a `SCREENS.md`
5. Produces a unified, machine-queryable design token set

The `design_tokens.json` becomes a **first-class runtime input** alongside `AGENTS.md`, read by planner, feature-agent, visual-validator, and reviewer.

---

## 2. Gap-to-Fix Traceability Matrix

Each gap from the analysis is mapped to specific fixes in the harness. Every gap has at least one fix, and every fix addresses at least one gap.

| # | Gap (Root Cause) | Fixes | New/Modified Files |
|---|---|---|---|
| **G1** | **No visual feedback loop** — AI generates widgets without ever seeing what they look like | • **F1a:** Create `visual-validator` agent with vision capabilities that compares rendered output against mockups<br>• **F1b:** Add visual validation phase to orchestrator pipeline after each UI workstream<br>• **F1c:** Add visual-validator skill with iterative comparison workflow | New: `pi/agents/visual-validator.md`<br>New: `pi/skills/visual-validator/SKILL.md`<br>Modify: `pi/skills/orchestrator/SKILL.md` |
| **G2** | **Text-based design spec** — `01-design.md` is prose that must be reinterpreted by every agent context | • **F2a:** Create `design-token-extractor` skill that parses Stitch HTML → unified `design_tokens.json`<br>• **F2b:** Add `DESIGN_TOKENS_PATH` to runtime config (AGENTS.md)<br>• **F2c:** Require planner to reference design_tokens.json, not raw markdown | New: `pi/skills/design-token-extractor/SKILL.md`<br>New: `pi/skills/stitch-html-parser/SKILL.md`<br>Modify: `AGENTS.md` (add DESIGN_TOKENS_PATH)<br>Modify: `pi/skills/orchestrator/SKILL.md`<br>Modify: `pi/agents/planner.md` |
| **G3** | **Mockups are visual-only** — AI can't extract exact padding, hierarchy, colors from screenshots | • **F3a:** Stitch HTML parser extracts layout structure + tokens (covers F2a)<br>• **F3b:** Add `STITCH_MOCKUPS_PATH` to runtime config alongside `MOCKUPS_PATH`<br>• **F3c:** Visual-validator uses both rendered golden PNG AND Stitch `screen.png` for comparison | Modify: `AGENTS.md`<br>Covered by: F2a, F1a |
| **G4** | **No pixel-perfect iteration phase** — UI workstreams are one-shot generate-and-commit | • **F4a:** Split UI workstreams into "implement" → "visual-validate" → "fix" → "re-validate" sub-loop<br>• **F4b:** Add golden test generation as part of UI workstream output<br>• **F4c:** Add max-iteration counter to prevent infinite loops | New: `pi/skills/golden-test-generator/SKILL.md`<br>Modify: `pi/skills/orchestrator/SKILL.md`<br>Modify: `pi/agents/feature-agent.md` |
| **G5** | **Architecture drift across workstreams** — fresh contexts lose decision continuity | • **F5a:** Add `ARCHITECTURE_LOG_PATH` to runtime config<br>• **F5b:** Feature-agent appends decisions to architecture log after each workstream<br>• **F5c:** Pre-workstream consistency check with automated pattern scanning<br>• **F5d:** Planner reads architecture log to maintain consistency | Modify: `AGENTS.md` (add ARCHITECTURE_LOG_PATH)<br>Modify: `pi/agents/feature-agent.md`<br>Modify: `pi/agents/planner.md`<br>New: `pi/skills/architecture-consistency-checker/SKILL.md` |
| **G6** | **Wrong model for wrong task** — DeepSeek V4 Pro used for everything, including UI-critical visual work | • **F6a:** Update orchestrator model selection to split UI-critical (GPT-5.5) vs logic (DeepSeek) workstreams<br>• **F6b:** Visual-validator always uses GPT-5.5 (vision capable)<br>• **F6c:** Golden-test generator uses DeepSeek V4 Flash (mechanical work) | Modify: `MODEL_STRATEGY.md`<br>Modify: `pi/skills/orchestrator/SKILL.md` |
| **G7** | **No golden test / visual regression** — No pixel-level baseline to prevent regressions | • **F7a:** Golden-test-generator skill creates Alchemist or flutter_test golden tests per screen<br>• **F7b:** Reviewer checks golden test coverage and CI integration<br>• **F7c:** Golden tests stored separately from source mockups (immutable policy) | New: `pi/skills/golden-test-generator/SKILL.md`<br>Modify: `pi/agents/reviewer.md`<br>Modify: `pi/skills/flutter-apply-architecture-best-practices/SKILL.md` |
| **G8** | **No pre-workstream consistency guard** — Pattern violations accumulate silently | • **F8a:** Architecture-consistency-checker skill runs before each feature-agent dispatch<br>• **F8b:** Checks for: setState usage in data layer, print() statements, ! operators, missing dispose() | New: `pi/skills/architecture-consistency-checker/SKILL.md`<br>Modify: `pi/skills/orchestrator/SKILL.md` |
| **G9** | **No official Flutter Agent Skills** — AI uses deprecated patterns | • **F9a:** Install script already does `npx skills add flutter/skills` and `dart-lang/skills` — **verify this works correctly per-project**<br>• **F9b:** Add installation verification step in install.sh that checks official skills are present | Modify: `install.sh` (verification step) |

---

## 3. Files to Create

### 3.1 `pi/agents/visual-validator.md` — New Agent

**Purpose:** Compares rendered Flutter widgets against mockup screenshots using vision. Iterates until visual parity is reached.

**Model:** `openai-codex/gpt-5.5` (vision capable)
**Thinking:** `high`

**Key behavior:**
- Renders a widget via golden test to produce a PNG
- Reads both the golden PNG and the corresponding Stitch `screen.png` mockup
- Uses vision to compare: layout, colors, typography, spacing, radii, shadows
- Produces a discrepancy report
- Loops back to feature-agent with specific fix instructions (max 3 iterations)
- Only writes to the review report path, never modifies production code directly

### 3.2 `pi/agents/architect.md` — New Agent

**Purpose:** Lightweight consistency guardian that reviews code patterns before and after workstreams. Not a full review — a fast mechanical check.

**Model:** `opencode-go/deepseek-v4-flash` (cheap, fast)
**Thinking:** `high`

**Key behavior:**
- Runs pattern checks before and after feature-agent workstreams
- Checks: no `print()`, no bare `!`, minimal `setState`, no `extends StatefulWidget` where Riverpod exists, dispose() pairs with initState()
- Reports findings to orchestrator as pass/warn/fail
- Does NOT modify code (read-only)

### 3.3 `pi/skills/design-token-extractor/SKILL.md` — New Skill

**Purpose:** Parses Stitch HTML mockup directories and extracts a unified, machine-readable `design_tokens.json`.

**Trigger:** When the runtime config has `STITCH_MOCKUPS_PATH` set (or `MOCKUPS_PATH` contains `code.html` files).

**Process:**
1. Scan `STITCH_MOCKUPS_PATH` for all `*/code.html` files
2. For each file, extract the `tailwind.config` JSON from `<script id="tailwind-config">`
3. Merge all token definitions into a single canonical schema:
   - Colors (light + dark, resolved to hex)
   - Typography (fontFamily, fontSize with lineHeight/weight)
   - Spacing (named tokens → dp values)
   - Border radius
   - Component patterns (from repeating HTML structures)
4. Resolve naming conflicts using a priority convention
5. Extract screen-specific layout summaries into a SCREENS.md
6. Write `design_tokens.json` to a configured path

**Output format:**

```json
{
  "schema_version": "1.0",
  "source": "stitch-html",
  "screens_extracted": 20,
  "colors": { "light": { ... }, "dark": { ... } },
  "typography": { ... },
  "spacing": { "xs": 4, "sm": 8, "md": 12, "lg": 16, "xl": 24, "xxl": 32 },
  "components": {
    "bookCardGrid": { "aspectRatio": "3:4", ... },
    "searchBar": { "borderRadius": 24, ... },
    ...
  },
  "screens": [
    {
      "id": "06-catalog-grid",
      "name": "Catalog Grid",
      "layout": "2-column grid",
      "components_used": ["bookCardGrid", "searchBar", "bottomNav"],
      "stitch_html_path": "design-assets/TheLittleLibrary-Stitch-Mockup/06-catalog-grid/code.html"
    }
  ]
}
```

### 3.4 `pi/skills/visual-validator/SKILL.md` — New Skill

**Purpose:** The iterative visual comparison loop. Renders a Flutter widget, captures its output, compares against the mockup using vision, and drives fixes.

**Process:**
1. Read the mockup screenshot and the golden PNG
2. Compare: layout proportions, colors match design tokens, typography matches design tokens, spacing matches design tokens, corner radii match design tokens, shadows match, icons render correctly
3. Score each dimension (MATCH / MINOR_DIFFERENCE / MISMATCH)
4. If any MISMATCH or >2 MINOR_DIFFERENCE: produce discrepancy report with specific fix instructions
5. Loop back to feature-agent with the discrepancy report
6. Max 3 iterations total
7. If parity achieved: delete throwaway golden, commit the real one

### 3.5 `pi/skills/golden-test-generator/SKILL.md` — New Skill

**Purpose:** Generates golden (screenshot comparison) tests for every screen, stored separately from source mockups.

**Process:**
1. Identify the screen widget from the workstream
2. Read design tokens for light/dark theme values
3. Generate a golden test file in `test_goldens/`
4. Test renders in both light and dark mode
5. Golden PNGs stored in `test/goldens/` (version-controlled)
6. Run `flutter test --update-goldens` to create baseline
7. Report test file path and golden paths

### 3.6 `pi/skills/architecture-consistency-checker/SKILL.md` — New Skill

**Purpose:** Fast mechanical pattern checks before and after workstream execution.

**Checks:**
- `grep -r "print(" lib/ --include="*.dart"` — No print() in committed code
- `grep -r "\.!\b" lib/ --include="*.dart"` — No bare null assertion operators
- `grep -nr "extends StatefulWidget" lib/ --include="*.dart"` — Minimal StatefulWidget usage (flag count)
- `grep -nr "dispose()" --include="*.dart"` paired with `grep -nr "initState"` — Verify dispose() exists for each initState
- `grep -nr "setState" lib/ --include="*.dart"` — Minimal setState usage
- `grep -nr "dynamic" lib/ --include="*.dart"` | grep -v ".g.dart" | grep -v "jsonDecode" | grep -v "Map<String, dynamic>" — Dynamic type usage outside JSON boundaries

### 3.7 `STITCH_PIPELINE.md` — New Doc

**Purpose:** Documents the recommended Stitch → design_tokens.json → Flutter code pipeline. Explains how to set up Stitch mockups, where to place them, how to run the extractor, and how the tokens flow through the pipeline.

### 3.8 `design-tokens-schema.md` — New Doc

**Purpose:** Documents the `design_tokens.json` schema so humans and AI know what fields exist. Serves as the canonical reference for the design token format.

---

## 4. Files to Modify

### 4.1 `install.sh` — Enhanced Installer

**Changes:**

1. **Add design token tools installation** after skills installation:
   - Install `node-html-parser` or `cheerio` for HTML parsing in the Stitch extractor
   - Or provide a standalone Python script alternative

2. **Add official skills verification step** — After `npx skills add`, verify that key skills exist:
   - `flutter-build-responsive-layout/SKILL.md`
   - `flutter-apply-architecture-best-practices/SKILL.md`
   - `flutter-add-widget-test/SKILL.md`
   - `dart-use-pattern-matching/SKILL.md`

3. **Add the 6 new custom skills** to `OUR_CUSTOM_SKILLS` array:
   - `design-token-extractor`
   - `visual-validator`
   - `golden-test-generator`
   - `architecture-consistency-checker`
   - `stitch-html-parser`

4. **Add new agent installation** for `visual-validator` and `architect`

5. **Add `SKILLS_DIRECTORY` env var support** — Allow projects to customise where skills are installed if `.pi/skills/` already exists

### 4.2 `AGENTS.md` — Runtime Config Template

**Add these new fields:**

```markdown
## Design System Assets

| Path | Value | Required? |
|---|---:|---:|
| Design tokens (JSON) | `[path/to/design_tokens.json]` | Yes if using Stitch |
| Stitch HTML mockups | `[path/to/stitch-mockups/]` | Recommended (parsed for tokens) |
| Golden test directory | `[app_dir]/test/goldens/` | Yes for visual validation |
| Golden test source | `[app_dir]/test_goldens/` | Yes for golden test files |
| Architecture decision log | `docs/ARCHITECTURE_LOG.md` | Yes for consistency |

## UI/Visual Validation

| Decision | Value |
|---|---|
| Visual validation | `Enabled` / `Disabled` (default: Enabled when mockups present) |
| Max visual iterations | `3` (default, max 5) |
| Golden test framework | `flutter_test` / `alchemist` (default: flutter_test) |
| Visual comparison method | `vision` / `skip` |
```

### 4.3 `FRAMEWORK.md` — Pipeline Documentation

**Changes:**

1. **Add the updated pipeline diagram** showing the new phases:
   - Phase 0: Foundation + Design token extraction
   - Phase 1: Planning (with design token awareness)
   - Phase 2a: Feature implementation
   - Phase 2b: Visual validation loop (NEW)
   - Phase 2c: Golden test generation (NEW)
   - Phase 3: Review + architecture consistency check
   - Phase 4: Final quality gate

2. **Add the updated agent table** with visual-validator and architect:

| Agent | Role | Default model | Thinking |
|---|---|---|---|
| `planner` | Planning + design token awareness | GPT-5.5 | high |
| `feature-agent` | Implement one workstream | DeepSeek V4 Pro | xhigh/high |
| `visual-validator` | Visual comparison vs mockups (NEW) | GPT-5.5 | high |
| `architect` | Pattern consistency guard (NEW) | DeepSeek V4 Flash | high |
| `reviewer` | Full spec/plan/tests review | GPT-5.4 | high |

3. **Add golden test policy section**

4. **Add design token extraction procedure section**

5. **Update the pipeline summary** to reflect the new phases

### 4.4 `MODEL_STRATEGY.md` — Model Selection Guidance

**Changes:**

1. **Add UI-critical workstream tier** that routes to GPT-5.5:

| Workstream tier/type | First attempt | Thinking | Visual Validator | Escalation |
|---|---|---|---:|---:|
| UI-critical (screens, widgets) | GPT-5.5 | high | GPT-5.5 (vision) | GPT-5.5 (re-review) |
| Complex logic (sync, offline, DB) | DeepSeek V4 Pro | xhigh | — | GPT-5.4 |
| Medium feature | DeepSeek V4 Pro | high | — | GPT-5.4 |
| Simple/mechanical | DeepSeek V4 Flash | high | — | GPT-5.4 |
| Integration/E2E tests | DeepSeek V4 Pro | high | — | GPT-5.4 |
| Foundation/scaffold | DeepSeek V4 Pro | xhigh | — | GPT-5.4 |
| Golden tests (NEW) | DeepSeek V4 Flash | high | — | GPT-5.4 |
| Architecture check (NEW) | DeepSeek V4 Flash | high | — | GPT-5.4 |

2. **Add visual-validator to the model table:**

| Role | Default model | Thinking | Rationale |
|---|---|---|---|
| visual-validator | GPT-5.5 | high | Vision capability needed for mockup comparison |
| architect | DeepSeek V4 Flash | high | Fast mechanical checks, cheap |

3. **Update the operating principle:**

```text
GPT-5.5 plans, validates critical milestones, and validates visual fidelity.
GPT-5.4 reviews and repairs.
DeepSeek V4 Pro builds complex logic.
DeepSeek V4 Flash does mechanical checks and golden tests.
```

### 4.5 `pi/skills/orchestrator/SKILL.md` — Orchestrator Procedure

**Changes:**

1. **Add design token extraction to Phase 0:**
   - If `STITCH_MOCKUPS_PATH` or `MOCKUPS_PATH` contains `code.html` files, dispatch design-token-extractor
   - Verify `design_tokens.json` exists before proceeding to planning

2. **Add runtime config fields** for new paths:
   - `DESIGN_TOKENS_PATH`
   - `STITCH_MOCKUPS_PATH`
   - `GOLDEN_TEST_DIR`
   - `ARCHITECTURE_LOG_PATH`
   - `VISUAL_VALIDATION_ENABLED`
   - `MAX_VISUAL_ITERATIONS`

3. **Add visual validation phase** after each UI-critical workstream:
   ```
   For UI-critical workstreams (marked in plan):
     Feature-agent implements → gate → [NEW] visual-validator compares
       if discrepancies: loop back to feature-agent (max N iterations)
       if parity: generate golden tests → commit
   ```

4. **Add architecture consistency check** before each feature-agent dispatch:
   - Run architect agent on current codebase
   - Report findings to user if patterns are violated

5. **Update model selection** to differentiate UI-critical vs logic:

```text
| Workstream type | First attempt | Thinking | Visual validation |
|---|---:|---:|---:|
| UI-critical (screens) | GPT-5.5 | high | Yes |
| Complex logic | DeepSeek V4 Pro | xhigh | No |
| Medium feature | DeepSeek V4 Pro | high | Conditional |
| Simple/mechanical | DeepSeek V4 Flash | high | No |
| Foundation/scaffold | DeepSeek V4 Pro | xhigh | No |
| IT/E2E tests | DeepSeek V4 Pro | high | No |
```

6. **Update golden test rule** to be more prescriptive:

```text
## Visual validation and golden tests

If mockup screenshots or Stitch HTML are provided:

1. **Phase 0:** Run design-token-extractor to create design_tokens.json from Stitch HTML
2. **During UI workstreams:** Feature-agent generates widget + golden test simultaneously
3. **After UI workstream:** Visual-validator renders widget, compares against mockup, iterates
4. **On parity confirmed:** Golden tests become the permanent visual baseline
5. **Policy:**
   - Source mockups (Stitch screen.png + code.html) are IMMUTABLE — never overwrite
   - Golden PNGs in `test/goldens/` are generated artifacts — regenerated on purpose
   - CI runs `flutter test --update-goldens` only when goldens are intentionally updated
   - Visual validator discrepancy report is stored in review output path
```

7. **Update failure recovery** to include visual validation failures:

```text
On visual validation failure (discrepancies not resolved after max iterations):
- Report discrepancy report to user
- Offer options: manual fix, reduce strictness, skip visual validation, abort
```

### 4.6 `pi/agents/feature-agent.md` — Implementation Agent

**Changes:**

1. **Add golden test generation** as part of UI workstreams:
   - After implementing production code and unit tests, generate golden test
   - Use the golden-test-generator skill

2. **Add architecture log update** after each workstream:
   - Append decisions made to `ARCHITECTURE_LOG.md`
   - Include: new files, patterns used, state management decisions, routing decisions

3. **Add design token reference requirement:**
   - MUST read `design_tokens.json` before implementing UI work
   - MUST reference design tokens by name, not hardcode values
   - MUST verify colors match tokens exactly

4. **Add visual iteration protocol:**
   - After initial implementation, yield to visual-validator
   - When receiving discrepancy report from visual-validator, apply ONLY the specified fixes
   - Do not expand scope during visual iteration

### 4.7 `pi/agents/planner.md` — Planning Agent

**Changes:**

1. **Add design token awareness:**
   - Read `design_tokens.json` when available
   - Reference token names in workstream specs ("use accent color from design tokens")
   - Validate that specs mention exact token references, not raw values

2. **Add UI-critical annotation to workstreams:**
   - Mark workstreams as `UI-critical` when they create or modify visual screens/widgets
   - This triggers the visual validation phase in the orchestrator
   - Non-UI workstreams (data layer, repositories, tests) skip visual validation

3. **Add architecture log reading:**
   - Read `ARCHITECTURE_LOG_PATH` before creating new workstreams
   - Ensure new workstreams follow established patterns

4. **Add golden test planning:**
   - For UI-critical workstreams, plan golden test file creation
   - Specify which mockup each screen should be validated against

### 4.8 `pi/agents/reviewer.md` — Review Agent

**Changes:**

1. **Add golden test verification:**
   - Check that golden tests exist for all UI workstreams
   - Verify golden tests pass (or have valid baselines)
   - Verify goldens are NOT overwriting source mockups

2. **Add design token compliance check:**
   - Scan code for hardcoded color/spacing values where design tokens exist
   - Flag violations

3. **Add architecture log reading:**
   - Read `ARCHITECTURE_LOG.md` and verify decisions were followed
   - Flag inconsistencies with earlier decisions

### 4.9 `pi/skills/flutter-apply-architecture-best-practices/SKILL.md` — Architecture Skill

**Changes:**

1. **Add golden test section:**

```markdown
## Golden tests for visual regression

For every screen/widget workstream:

1. Create a golden test file in `test_goldens/[screen]_golden_test.dart`
2. Render the widget in both light and dark mode
3. Use `autoUpdateGoldenFiles: true` during development iteration
4. Once visually validated, commit golden PNGs as baselines
5. CI runs golden tests without `--update-goldens` to detect regressions

Golden test example:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatalogGridScreen golden test (light)', (tester) async {
    await tester.pumpWidget(
      Theme(data: AppTheme.light, child: const CatalogGridScreen()),
    );
    await expectLater(
      find.byType(CatalogGridScreen),
      matchesGoldenFile('goldens/catalog_grid_light.png'),
    );
  });

  testWidgets('CatalogGridScreen golden test (dark)', (tester) async {
    await tester.pumpWidget(
      Theme(data: AppTheme.dark, child: const CatalogGridScreen()),
    );
    await expectLater(
      find.byType(CatalogGridScreen),
      matchesGoldenFile('goldens/catalog_grid_dark.png'),
    );
  });
}
```
```

2. **Add design token reference rules:**
   - Always use `Theme.of(context).colorScheme.*` for colors
   - Always use `Theme.of(context).textTheme.*` for typography
   - Use named AppSpacing constants for padding/margins
   - Never hardcode `Color(0xFF...)` when a design token exists

3. **Add architecture decision log policy:**
   - After each workstream, append decisions to ARCHITECTURE_LOG.md
   - Include: folder structure decisions, state management patterns, routing decisions, naming conventions

---

## 5. Implementation Order

The updates are designed to be applied incrementally. Each phase is independently useful.

### Phase 1: Foundation (Do First — G7, G9)

| Step | File | Change |
|---|---|---|
| 1.1 | `pi/skills/golden-test-generator/SKILL.md` | Create golden test skill |
| 1.2 | `pi/skills/flutter-apply-architecture-best-practices/SKILL.md` | Add golden test section, token rules |
| 1.3 | `install.sh` | Add official skills verification step |
| 1.4 | `AGENTS.md` | Add golden test directory, design tokens path |

**Why first:** Golden tests are the foundation for the visual validation loop. They give the visual-validator something to compare.

### Phase 2: Design Token Pipeline (Do Second — G2, G3)

| Step | File | Change |
|---|---|---|
| 2.1 | `pi/skills/stitch-html-parser/SKILL.md` | Create Stitch HTML parser skill |
| 2.2 | `pi/skills/design-token-extractor/SKILL.md` | Create design token extractor skill |
| 2.3 | `STITCH_PIPELINE.md` | Create pipeline documentation |
| 2.4 | `design-tokens-schema.md` | Create schema documentation |
| 2.5 | `install.sh` | Add new skills to installer |
| 2.6 | `pi/agents/planner.md` | Add design token awareness |

**Why second:** Design tokens are a prerequisite for meaningful visual validation. Without machine-readable tokens, the visual-validator can't verify color/typography compliance.

### Phase 3: Visual Validation Loop (Do Third — G1, G4)

| Step | File | Change |
|---|---|---|
| 3.1 | `pi/skills/visual-validator/SKILL.md` | Create visual validator skill |
| 3.2 | `pi/agents/visual-validator.md` | Create visual validator agent |
| 3.3 | `pi/skills/orchestrator/SKILL.md` | Add visual validation phase, updated model selection, golden test rules |
| 3.4 | `pi/agents/feature-agent.md` | Add golden test generation, visual iteration protocol |
| 3.5 | `FRAMEWORK.md` | Add visual validation to pipeline |

**Why third:** This is the core fix — the feedback loop. It depends on golden tests (Phase 1) and design tokens (Phase 2).

### Phase 4: Architecture Consistency (Do Fourth — G5, G8)

| Step | File | Change |
|---|---|---|
| 4.1 | `pi/skills/architecture-consistency-checker/SKILL.md` | Create consistency checker skill |
| 4.2 | `pi/agents/architect.md` | Create architect agent |
| 4.3 | `pi/skills/orchestrator/SKILL.md` | Add pre-workstream consistency check |
| 4.4 | `pi/agents/feature-agent.md` | Add architecture log update |
| 4.5 | `pi/agents/planner.md` | Add architecture log reading |
| 4.6 | `pi/agents/reviewer.md` | Add golden test check, token compliance check, architecture log check |

### Phase 5: Model Strategy Update (Do Fifth — G6)

| Step | File | Change |
|---|---|---|
| 5.1 | `MODEL_STRATEGY.md` | Add UI-critical tier, visual-validator model, architect model |
| 5.2 | `pi/skills/orchestrator/SKILL.md` | Update model selection table |
| 5.3 | `FRAMEWORK.md` | Update agent table, operating principle |

### Phase 6: Documentation Pass (Do Last)

| Step | File | Change |
|---|---|---|
| 6.1 | `AGENTS.md` | Full pass — add all new paths, decisions, rules |
| 6.2 | `FRAMEWORK.md` | Full pass — updated pipeline, agent table, policies |
| 6.3 | `README.md` | Update with new capabilities |

---

## 6. Detailed Spec for Each File

### 6.1 `pi/agents/visual-validator.md`

```yaml
---
name: visual-validator
package: flutter-dev
description: Compares rendered Flutter widgets against Stitch mockup screenshots using vision capabilities. Iterates until visual parity is achieved.
model: openai-codex/gpt-5.5
thinking: high
tools: read, write, edit, bash, glob, fetch_content, ask_user
systemPromptMode: replace
inheritProjectContext: false
inheritSkills: false
skills: visual-validator, flutter-fix-layout-issues
---

# Visual Validator — Pixel-Perfect UI Validation

You validate that a rendered Flutter screen visually matches its corresponding Stitch mockup screenshot. You iterate with the feature-agent until visual parity is achieved.

## Required inputs

- mockup screenshot path (screen.png from Stitch)
- widget code path (the implemented screen)
- golden test path (rendered output for comparison)
- design tokens path (design_tokens.json)
- max iterations (default: 3)

## Process

1. Read the mockup screenshot
2. Read the design tokens for expected values
3. Run the golden test to render the widget:
   ```bash
   cd [APP_DIR]
   flutter test --update-goldens test_goldens/[widget]_golden_test.dart
   ```
4. Read the generated golden PNG
5. Compare the golden PNG against the mockup screenshot using vision:
   - Layout proportions and alignment
   - Colors match design tokens
   - Typography (font family, size, weight, color)
   - Spacing (padding, margins, gaps between elements)
   - Corner radii and shadows
   - Icon rendering and positioning
6. Score each dimension: MATCH / MINOR_DIFFERENCE / MISMATCH
7. Write discrepancy report

## Iteration

If discrepancies found:
- Produce specific fix instructions (file:line, what to change, what value to use)
- Route back to feature-agent
- Max 3 iterations (configurable)
- If parity not achieved after max iterations: report to user with full discrepancy report

If parity confirmed:
- Delete the throwaway golden (used for validation only)
- Run the real golden test to establish baseline
- Report success

## Hard rules

- Do not modify production code directly
- Do not overwrite source mockup images
- Golden PNGs are generated artifacts — they can be regenerated
- Always reference design tokens by name, not by raw value
