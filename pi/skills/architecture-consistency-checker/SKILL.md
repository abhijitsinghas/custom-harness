---
name: architecture-consistency-checker
description: Fast mechanical pattern scan before and after workstream execution. Checks for common Flutter anti-patterns: print() in production code, bare null assertions, missing dispose(), dynamic misuse, setState overreach.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-19
---

# Architecture Consistency Checker

A fast, mechanical scan that checks the codebase for common Flutter anti-patterns. Runs before and after each feature-agent workstream to catch drift early. Read-only — never modifies code.

## When to use

- Before dispatching a feature-agent workstream (establish baseline)
- After a feature-agent workstream completes (catch regressions)
- On demand when the user suspects pattern drift
- During review phases (supplements the reviewer's deep check)

## Deterministic script first

Prefer the shipped read-only script over ad-hoc grep sequences:

```bash
[HARNESS_TOOLS]/arch_check.sh [APP_DIR] [before_workstream|after_workstream] [WORKSTREAM_ID] [DESIGN_TOKENS_PATH] [ARCHITECTURE_LOG_PATH]
```

The script emits JSON on stdout and a concise markdown-style report on stderr. Exit code:
- `0`: no FAIL-level issues
- `3`: at least one FAIL-level issue
- `2`: usage/environment error

Only run the individual commands below manually when the script is unavailable or when you need
to explain a specific finding.

## Checks

Run each check. Report results as PASS / WARN / FAIL.

### Check 1: No `print()` in production code

```bash
grep -rn "print(" lib/ --include="*.dart" | grep -v "_test.dart" | grep -v "\.g\.dart"
```

- **PASS:** 0 matches
- **WARN:** 1-2 matches (may be temporary debug)
- **FAIL:** 3+ matches (logging convention violated)

### Check 2: No bare null assertion operators (`!`)

```bash
grep -rn "\.!\b" lib/ --include="*.dart" | grep -v "_test.dart" | grep -v "\.g\.dart"
```

- **PASS:** 0 matches
- **WARN:** 1-3 matches
- **FAIL:** 4+ matches

### Check 3: Minimal `setState` usage (only for ephemeral state)

```bash
grep -rn "setState" lib/ --include="*.dart" | grep -v "_test.dart" | grep -v "\.g\.dart"
```

- **PASS:** 0-2 matches (acceptable for focus/animation/hover)
- **WARN:** 3-5 matches
- **FAIL:** 6+ matches (likely state management issue)

### Check 4: `StatefulWidget` count matches `dispose()` count

```bash
SW_COUNT=$(grep -rn "extends StatefulWidget" lib/ --include="*.dart" | grep -v "_test.dart" | grep -v "\.g\.dart" | wc -l)
DISPOSE_COUNT=$(grep -rn "void dispose()" lib/ --include="*.dart" | grep -v "_test.dart" | grep -v "\.g\.dart" | wc -l)
```

- **PASS:** DISPOSE_COUNT >= SW_COUNT minus States that don't need dispose
- **WARN:** 1-2 missing dispose()
- **FAIL:** 3+ missing dispose()

### Check 5: Minimal `dynamic` usage outside JSON boundaries

```bash
grep -rn "\bdynamic\b" lib/ --include="*.dart" | grep -v "_test.dart" | grep -v "\.g\.dart" | grep -v "Map<String, dynamic>" | grep -v "jsonDecode"
```

- **PASS:** 0 matches
- **WARN:** 1-2 matches
- **FAIL:** 3+ matches

### Check 6: Generated files not manually edited

```bash
# Check if any .g.dart files were modified by anything other than build_runner
git diff --name-only HEAD | grep "\.g\.dart$"
```

- **PASS:** 0 modified generated files
- **FAIL:** Any modified generated file (manual edit detected)

### Check 7: Design token compliance (when design_tokens.json exists)

```bash
# Check for hardcoded colors where design tokens exist
grep -rn "Color(0x" lib/ --include="*.dart" | grep -v "_test.dart" | grep -v "\.g\.dart" | grep -v "static const" | grep -v "//" 
```

- **PASS:** 0 hardcoded colors outside constant declarations
- **WARN:** 1-5 hardcoded colors
- **FAIL:** 6+ hardcoded colors (design token usage not enforced)

### Check 8: Golden test coverage for UI screens

```bash
SCREEN_COUNT=$(find lib/ -name "*screen*.dart" -o -name "*page*.dart" | grep -v "_test.dart" | wc -l)
GOLDEN_COUNT=$(find test_goldens/ -name "*_golden_test.dart" 2>/dev/null | wc -l)
```

- **PASS:** GOLDEN_COUNT >= SCREEN_COUNT (all screens have golden tests) OR no golden config
- **WARN:** GOLDEN_COUNT < SCREEN_COUNT but > 0
- **FAIL:** SCREEN_COUNT > 0 but GOLDEN_COUNT == 0 (golden tests configured but missing)

### Check 9: Architecture log present and updated

```bash
if [ -f "docs/ARCHITECTURE_LOG.md" ]; then
  LAST_ENTRY=$(tail -5 docs/ARCHITECTURE_LOG.md)
  echo "Latest architecture log entries:"
  echo "$LAST_ENTRY"
fi
```

- **PASS:** ARCHITECTURE_LOG.md exists and has recent entries
- **WARN:** File exists but hasn't been updated recently
- **INFO:** No ARCHITECTURE_LOG.md configured (not required for all projects)

## Report format

```markdown
## Architecture Consistency Check

**Run:** [before/after] workstream [WORKSTREAM_ID]
**Timestamp:** [ISO timestamp]

### Results

| Check | Result | Details |
|---|---|---|
| 1. print() in production | PASS | 0 matches |
| 2. Bare `!` operators | WARN | 2 matches in user_service.dart:45, auth_provider.dart:89 |
| 3. setState count | FAIL | 8 matches across 4 files |
| 4. dispose() pairing | PASS | 3 dispose for 3 StatefulWidgets |
| 5. dynamic usage | PASS | 0 matches outside JSON |
| 6. Generated file edits | PASS | 0 modified |
| 7. Design token compliance | WARN | 3 hardcoded colors |
| 8. Golden test coverage | PASS | 4 screens, 4 golden tests |
| 9. Architecture log | INFO | Not configured |

### Summary

- PASS: 6
- WARN: 2
- FAIL: 1

### Recommendations

- FAIL on setState: Consider migrating catalog state to Riverpod provider
- WARN on bare !: Add null checks before assertions
```

## Rules

- **Read-only** — never modify code; this is an observation tool
- **Report don't fix** — findings go to the orchestrator, who decides action
- **Fast** — should complete in under 10 seconds for a medium codebase
- **Different from reviewer** — reviewer does deep analysis; this does fast pattern matching
- **Configurable thresholds** — the orchestrator can adjust WARN vs FAIL thresholds per project
