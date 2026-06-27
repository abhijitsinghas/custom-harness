#!/usr/bin/env bash
# =============================================================================
# golden_check.sh — deterministic golden-test pre-filter for the visual loop
#
# Runs a golden test in CHECK mode (no --update-goldens). This is the
# deterministic layer of visual validation: Flutter already compares the
# rendered widget against the committed baseline PNG and, on mismatch, emits a
# diff PNG (`*_isolated.png`). Only if this deterministic layer fails do we
# hand off to the vision-based visual-validator for *semantic* diff analysis
# (wrong icon, wrong component, wrong copy).
#
# Usage:
#   ./golden_check.sh <app_dir> <golden_test_file>
#
# stdout: a single JSON object:
#   {"level":"PASS"}                       — golden matches committed baseline
#   {"level":"FAIL","diff_images":[...]}   — mismatch; list of emitted diff PNGs
#   {"level":"BLOCKER","error":"..."}      — test did not run (compile/build error)
# exit: 0 PASS, 1 FAIL, 2 BLOCKER
# =============================================================================
set -uo pipefail

APP_DIR="${1:-}"
TEST_FILE="${2:-}"

if [ -z "$APP_DIR" ] || [ -z "$TEST_FILE" ] || [ ! -d "$APP_DIR" ]; then
  echo '{"level":"BLOCKER","error":"usage: golden_check.sh <app_dir> <golden_test_file>"}'
  exit 2
fi
if [ ! -f "$TEST_FILE" ]; then
  echo "{\"level\":\"BLOCKER\",\"error\":\"golden test file not found: $TEST_FILE\"}"
  exit 2
fi

# Snapshot existing *_isolated.png / failure diffs so we can detect new ones
TEST_DIR=$(dirname "$TEST_FILE")
BEFORE=$(find "$APP_DIR/test" "$TEST_DIR" -name "*_isolated.png" -o -name "*.diff.png" 2>/dev/null | sort)

OUT=$(cd "$APP_DIR" && flutter test "$TEST_FILE" 2>&1)
RC=$?

if echo "$OUT" | grep -qi "compilation failed\|Error: \|Exception: .*build\|Could not find\|Failed to load"; then
  ERR=$(printf '%s' "$OUT" | tail -5 | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')
  echo "{\"level\":\"BLOCKER\",\"error\":\"$ERR\"}"
  exit 2
fi

if [ "$RC" -eq 0 ]; then
  echo '{"level":"PASS"}'
  exit 0
fi

# Failure → collect newly emitted diff images
AFTER=$(find "$APP_DIR/test" "$TEST_DIR" -name "*_isolated.png" -o -name "*.diff.png" 2>/dev/null | sort)
DIFFS=$(comm -13 <(printf '%s\n' "$BEFORE") <(printf '%s\n' "$AFTER") | grep -v '^$' || true)
DIFF_ARR=$(printf '%s\n' "$DIFFS" | sed 's/.*/"&"/' | paste -sd, - | sed 's/^/[/;s/$/]/')
[ -z "$DIFFS" ] && DIFF_ARR="[]"
echo "{\"level\":\"FAIL\",\"diff_images\":${DIFF_ARR}}"
exit 1
