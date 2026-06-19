#!/usr/bin/env bash
# =============================================================================
# arch_check.sh — deterministic Flutter architecture consistency scanner
#
# Runs the 9 mechanical anti-pattern checks defined in the
# architecture-consistency-checker skill. Emits a JSON report on stdout and a
# human-readable markdown report on stderr. Exit code reflects the worst level:
#   0 = all PASS/WARN,  3 = at least one FAIL,  2 = usage/env error
#
# Usage:
#   ./arch_check.sh <app_dir> [run_mode] [workstream_id] [design_tokens_path] [arch_log_path]
#     run_mode: before_workstream (default) | after_workstream
#
# Read-only: never modifies files. Safe to run any time.
# =============================================================================
set -uo pipefail

APP_DIR="${1:-}"
RUN_MODE="${2:-before_workstream}"
WORKSTREAM_ID="${3:-unknown}"
DESIGN_TOKENS_PATH="${4:-}"
ARCH_LOG_PATH="${5:-docs/ARCHITECTURE_LOG.md}"

if [ -z "$APP_DIR" ] || [ ! -d "$APP_DIR" ]; then
  echo '{"error": "usage: arch_check.sh <app_dir> [run_mode] [workstream_id] [design_tokens_path] [arch_log_path]"}' >&2
  exit 2
fi

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
LIB="$APP_DIR/lib"
PASS_COUNT=0; WARN_COUNT=0; FAIL_COUNT=0
RESULTS_JSON="["

emit() {
  # emit <num> <name> <level> <count> <details>
  local num="$1" name="$2" level="$3" count="$4" details="$5"
  case "$level" in
    PASS) PASS_COUNT=$((PASS_COUNT+1)); ;;
    WARN) WARN_COUNT=$((WARN_COUNT+1)); ;;
    FAIL) FAIL_COUNT=$((FAIL_COUNT+1)); ;;
  esac
  # JSON-escape details (minimal)
  local esc_details
  esc_details=$(printf '%s' "$details" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')
  local comma=""
  [ "$num" != "1" ] && comma=","
  RESULTS_JSON="${RESULTS_JSON}${comma}{\"num\":${num},\"check\":\"${name}\",\"level\":\"${level}\",\"count\":${count},\"details\":\"${esc_details}\"}"
  printf "%s  %s  %s  (%s)  %s\n" "$num" "$name" "$level" "$count" "$details" >&2
}

count_grep() {
  # count_grep <pattern>  -> prints integer count, prints matches on stderr
  local pat="$1"
  if [ ! -d "$LIB" ]; then echo 0; return; fi
  local matches
  matches=$(grep -rnE "$pat" "$LIB" --include="*.dart" 2>/dev/null | grep -v "_test.dart" | grep -v "\.g\.dart" || true)
  local n
  n=$(printf '%s\n' "$matches" | grep -c . || true)
  [ -n "$matches" ] && printf '%s\n' "$matches" | head -5 >&2
  echo "$n"
}

# Check 1: print() in production
n=$(count_grep "print\(")
[ "$n" -eq 0 ] && emit 1 "print() in production" PASS "$n" "" \
  || { [ "$n" -le 2 ] && emit 1 "print() in production" WARN "$n" "matches above" || emit 1 "print() in production" FAIL "$n" "matches above"; }

# Check 2: bare ! null assertions  (foo!.bar)
n=$(count_grep "\.!\b")
[ "$n" -eq 0 ] && emit 2 "bare ! operators" PASS "$n" "" \
  || { [ "$n" -le 3 ] && emit 2 "bare ! operators" WARN "$n" "matches above" || emit 2 "bare ! operators" FAIL "$n" "matches above"; }

# Check 3: setState usage
n=$(count_grep "setState")
[ "$n" -le 2 ] && emit 3 "setState usage" PASS "$n" "" \
  || { [ "$n" -le 5 ] && emit 3 "setState usage" WARN "$n" "matches above" || emit 3 "setState usage" FAIL "$n" "matches above"; }

# Check 4: dispose() pairing
if [ -d "$LIB" ]; then
  SW=$(grep -rnE "extends StatefulWidget" "$LIB" --include="*.dart" 2>/dev/null | grep -v "_test.dart" | grep -v "\.g\.dart" | grep -c . || true)
  DISP=$(grep -rnE "void dispose\(\)" "$LIB" --include="*.dart" 2>/dev/null | grep -v "_test.dart" | grep -v "\.g\.dart" | grep -c . || true)
  SW=${SW:-0}; DISP=${DISP:-0}
  GAP=$(( SW - DISP ))
  [ "$GAP" -le 0 ] && emit 4 "dispose() pairing" PASS "$GAP" "stateful=$SW dispose=$DISP" \
    || { [ "$GAP" -le 2 ] && emit 4 "dispose() pairing" WARN "$GAP" "stateful=$SW dispose=$DISP" || emit 4 "dispose() pairing" FAIL "$GAP" "stateful=$SW dispose=$DISP"; }
else
  emit 4 "dispose() pairing" PASS 0 "no lib/ dir"
fi

# Check 5: dynamic outside JSON boundaries
if [ -d "$LIB" ]; then
  DYN=$(grep -rnE "\bdynamic\b" "$LIB" --include="*.dart" 2>/dev/null | grep -v "_test.dart" | grep -v "\.g\.dart" | grep -v "Map<String, dynamic>" | grep -v "jsonDecode" | grep -c . || true)
  DYN=${DYN:-0}
  [ "$DYN" -eq 0 ] && emit 5 "dynamic misuse" PASS "$DYN" "" \
    || { [ "$DYN" -le 2 ] && emit 5 "dynamic misuse" WARN "$DYN" "" || emit 5 "dynamic misuse" FAIL "$DYN" ""; }
else
  emit 5 "dynamic misuse" PASS 0 "no lib/"
fi

# Check 6: generated file manual edits (git diff)
if [ -d "$APP_DIR/.git" ] && command -v git >/dev/null 2>&1; then
  GENDIFF=$(git -C "$APP_DIR" diff --name-only HEAD 2>/dev/null | grep "\.g\.dart$" | grep -c . || true)
  GENDIFF=${GENDIFF:-0}
  [ "$GENDIFF" -eq 0 ] && emit 6 "generated file edits" PASS "$GENDIFF" "" || emit 6 "generated file edits" FAIL "$GENDIFF" "see git diff"
else
  emit 6 "generated file edits" PASS 0 "not a git repo or git unavailable"
fi

# Check 7: design token compliance (hardcoded colors)
if [ -n "$DESIGN_TOKENS_PATH" ] && [ -d "$LIB" ]; then
  HC=$(grep -rnE "Color\(0x" "$LIB" --include="*.dart" 2>/dev/null | grep -v "_test.dart" | grep -v "\.g\.dart" | grep -v "static const" | grep -v "//" | grep -c . || true)
  HC=${HC:-0}
  [ "$HC" -eq 0 ] && emit 7 "design token compliance" PASS "$HC" "" \
    || { [ "$HC" -le 5 ] && emit 7 "design token compliance" WARN "$HC" "hardcoded Color(0x..) outside constants" || emit 7 "design token compliance" FAIL "$HC" ""; }
else
  emit 7 "design token compliance" PASS 0 "no design_tokens.json configured or no lib/"
fi

# Check 8: golden test coverage vs screen count
if [ -d "$LIB" ]; then
  SCREENS=$(find "$LIB" \( -name "*screen*.dart" -o -name "*page*.dart" \) 2>/dev/null | grep -v "_test.dart" | grep -c . || true)
  GOLDENS=$(find "$APP_DIR/test_goldens" -name "*_golden_test.dart" 2>/dev/null | grep -c . || true)
  SCREENS=${SCREENS:-0}; GOLDENS=${GOLDENS:-0}
  if [ "$SCREENS" -eq 0 ]; then
    emit 8 "golden test coverage" PASS 0 "no screens yet"
  elif [ "$GOLDENS" -ge "$SCREENS" ]; then
    emit 8 "golden test coverage" PASS "$GOLDENS" "screens=$SCREENS goldens=$GOLDENS"
  elif [ "$GOLDENS" -gt 0 ]; then
    emit 8 "golden test coverage" WARN "$GOLDENS" "screens=$SCREENS goldens=$GOLDENS"
  else
    emit 8 "golden test coverage" FAIL 0 "screens=$SCREENS goldens=0"
  fi
else
  emit 8 "golden test coverage" PASS 0 "no lib/"
fi

# Check 9: architecture log freshness
if [ -f "$ARCH_LOG_PATH" ]; then
  emit 9 "architecture log" PASS 1 "present"
else
  if [ -n "${ARCH_LOG_PATH:-}" ]; then
    emit 9 "architecture log" WARN 0 "configured path missing: $ARCH_LOG_PATH"
  else
    emit 9 "architecture log" PASS 0 "not configured"
  fi
fi

RESULTS_JSON="${RESULTS_JSON}]"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat <<EOF
{"run_mode":"$RUN_MODE","workstream_id":"$WORKSTREAM_ID","timestamp":"$TIMESTAMP","app_dir":"$APP_DIR","summary":{"pass":$PASS_COUNT,"warn":$WARN_COUNT,"fail":$FAIL_COUNT},"results":$RESULTS_JSON}
EOF

printf "\n%sSummary:%s pass=%s warn=%s fail=%s\n" "$GREEN" "$NC" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT" >&2

if [ "$FAIL_COUNT" -gt 0 ]; then exit 3; fi
exit 0
