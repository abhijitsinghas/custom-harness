#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Flutter Dev Framework — Installer
# =============================================================================
# Installs the 8-agent TDD pipeline + all skills into any Flutter project.
# Skills are fetched from their upstream GitHub repos.
#
# Usage:
#   ./install.sh [target-directory]
#
#   target-directory: Path to the Flutter project (default: current directory)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

if [ ! -d "$TARGET" ]; then
  echo "Error: Target directory '$TARGET' does not exist."
  exit 1
fi

echo ""
echo "══════════════════════════════════════════════════════"
echo "  Flutter Dev Framework — Installer"
echo "══════════════════════════════════════════════════════"
echo ""
echo "  Source:  $SCRIPT_DIR"
echo "  Target:  $TARGET"
echo ""

# ── Step 1: Copy agent definitions ──────────────────────────────────────────

echo "── Step 1: Installing agent definitions (8 agents)..."
mkdir -p "$TARGET/.pi/agents"
COPIED=0
for agent in "$SCRIPT_DIR/agents/"*.md; do
  [ -f "$agent" ] || continue
  name=$(basename "$agent")
  if [ -f "$TARGET/.pi/agents/$name" ]; then
    echo "  • $name (exists — skipped)"
  else
    cp "$agent" "$TARGET/.pi/agents/$name"
    echo "  • $name"
    COPIED=$((COPIED + 1))
  fi
done
echo "  → $COPIED agents installed"

# ── Step 2: Copy our own skills ─────────────────────────────────────────────

echo ""
echo "── Step 2: Installing framework skills..."
mkdir -p "$TARGET/.pi/skills"
COPIED=0
for skill_dir in "$SCRIPT_DIR/skills/"*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  if [ -d "$TARGET/.pi/skills/$name" ]; then
    echo "  • $name (exists — skipped)"
  else
    cp -r "$skill_dir" "$TARGET/.pi/skills/$name"
    COPIED=$((COPIED + 1))
  fi
done
echo "  → $COPIED framework skills installed"

# ── Step 3: Fetch Dart skills from dart-lang/skills ──────────────────────────

echo ""
echo "── Step 3: Fetching Dart skills (dart-lang/skills)..."

DART_SKILLS=(
  dart-add-unit-test
  dart-collect-coverage
  dart-fix-runtime-errors
  dart-generate-test-mocks
  dart-run-static-analysis
  dart-use-pattern-matching
)

DART_TMP=$(mktemp -d)
trap "rm -rf $DART_TMP" EXIT

git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/dart-lang/skills.git "$DART_TMP" 2>&1 | tail -1

cd "$DART_TMP"
git sparse-checkout set "${DART_SKILLS[@]/#/skills/}" 2>&1 | tail -1

DART_COPIED=0
for skill in "${DART_SKILLS[@]}"; do
  if [ -d "skills/$skill" ]; then
    if [ -d "$TARGET/.pi/skills/$skill" ]; then
      echo "  • $skill (exists — skipped)"
    else
      cp -r "skills/$skill" "$TARGET/.pi/skills/$skill"
      DART_COPIED=$((DART_COPIED + 1))
    fi
  else
    echo "  ⚠️  $skill not found in upstream repo"
  fi
done
echo "  → $DART_COPIED Dart skills installed"

# ── Step 4: Fetch Flutter skills from flutter/skills ─────────────────────────

echo ""
echo "── Step 4: Fetching Flutter skills (flutter/skills)..."

FLUTTER_SKILLS=(
  flutter-add-integration-test
  flutter-add-widget-preview
  flutter-add-widget-test
  flutter-apply-architecture-best-practices
  flutter-build-responsive-layout
  flutter-fix-layout-issues
  flutter-implement-json-serialization
  flutter-use-http-package
)

FLUTTER_TMP=$(mktemp -d)
trap "rm -rf $FLUTTER_TMP $DART_TMP" EXIT

git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/flutter/skills.git "$FLUTTER_TMP" 2>&1 | tail -1

cd "$FLUTTER_TMP"
git sparse-checkout set "${FLUTTER_SKILLS[@]/#/skills/}" 2>&1 | tail -1

FLUTTER_COPIED=0
for skill in "${FLUTTER_SKILLS[@]}"; do
  if [ -d "skills/$skill" ]; then
    if [ -d "$TARGET/.pi/skills/$skill" ]; then
      echo "  • $skill (exists — skipped)"
    else
      cp -r "skills/$skill" "$TARGET/.pi/skills/$skill"
      FLUTTER_COPIED=$((FLUTTER_COPIED + 1))
    fi
  else
    echo "  ⚠️  $skill not found in upstream repo"
  fi
done
echo "  → $FLUTTER_COPIED Flutter skills installed"

# ── Step 5: Copy framework documentation ─────────────────────────────────────

echo ""
echo "── Step 5: Installing framework documentation..."
if [ -f "$TARGET/FRAMEWORK.md" ]; then
  echo "  • FRAMEWORK.md (exists — skipped)"
else
  cp "$SCRIPT_DIR/FRAMEWORK.md" "$TARGET/FRAMEWORK.md"
  echo "  • FRAMEWORK.md"
fi

# ── Step 6: Configure settings.json ──────────────────────────────────────────

echo ""
echo "── Step 6: Configuring pi settings..."
SETTINGS_FILE="$TARGET/.pi/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
  echo "  • settings.json exists — merging packages (requires python3)"
  python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    data = json.load(f)
with open('$SCRIPT_DIR/settings.template.json') as f:
    template = json.load(f)
packages = data.get('packages', [])
for pkg in template.get('packages', []):
    if pkg not in packages:
        packages.append(pkg)
        print(f'  • Added {pkg}')
data['packages'] = packages
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null || {
    echo "  ⚠️  python3 not available — copying template"
    cp "$SCRIPT_DIR/settings.template.json" "$SETTINGS_FILE"
  }
else
  cp "$SCRIPT_DIR/settings.template.json" "$SETTINGS_FILE"
  echo "  • settings.json (created)"
fi

# ── Step 7: Install npm packages ─────────────────────────────────────────────

echo ""
echo "── Step 7: Installing npm packages..."
if command -v pi &> /dev/null; then
  cd "$TARGET"
  pi install 2>&1 | tail -3
  echo "  → Packages installed"
else
  echo "  ⚠️  'pi' not found. Run 'pi install' manually."
fi

# ── Step 8: Create template AGENTS.md ────────────────────────────────────────

echo ""
echo "── Step 8: Creating AGENTS.md template..."
if [ -f "$TARGET/AGENTS.md" ]; then
  echo "  • AGENTS.md (exists — skipped)"
else
  cat > "$TARGET/AGENTS.md" << 'AGENTS_EOF'
# AGENTS.md — [Project Name]

> **App directory:** `[app_dir]/` | **Package:** `[com.example.app]`

## Pipeline Configuration

```yaml
planning:
  max_rounds: 3

review:
  max_rounds: 3

artifacts:
  dir: specs/phase-N/
  plan: plan.md
  stories: stories.md
  tests: tests-report.md
  implementation: impl-report.md
  reviews: reviews/
    code: code-review-r{N}.md
    test: test-review-r{N}.md
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| State | Riverpod |
| Database | drift (SQLite) |
| Routing | go_router |
| Testing | flutter_test, mockito |

## Architecture

```
[app_dir]/
├── lib/
│   ├── core/          # Theme, constants, extensions
│   ├── data/          # Database, APIs, repositories
│   └── features/      # Feature screens
├── test/              # Unit + widget tests
└── integration_test/  # Integration + E2E tests
```

## Design Tokens

| Token | Value |
|-------|-------|
| Primary | #000000 |
| Background | #FFFFFF |
| Font | Roboto, 16sp body |

## Shared Contracts

```dart
// Providers
final databaseProvider = Provider<AppDatabase>((ref) => ...);

// Routes
'/home', '/settings', ...
```
AGENTS_EOF
  echo "  • AGENTS.md (template created)"
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════════════════════════"
echo "  Installation Complete"
echo "══════════════════════════════════════════════════════"
echo ""
echo "  Installed:"
echo "    • 8 agents          (.pi/agents/)"
echo "    • 17 skills total:"
echo "        $COPIED framework  (.pi/skills/ — brainstorming, grill-me, writing-plans)"
echo "        $DART_COPIED Dart      (.pi/skills/ — from dart-lang/skills)"
echo "        $FLUTTER_COPIED Flutter   (.pi/skills/ — from flutter/skills)"
echo "    • Framework docs     (FRAMEWORK.md)"
echo "    • pi settings        (.pi/settings.json)"
echo "    • AGENTS.md template"
echo ""
echo "  Next:"
echo "    1. Edit AGENTS.md with your project details"
echo "    2. /name orchestrator"
echo "    3. Orchestrator, begin Phase 0."
echo ""
