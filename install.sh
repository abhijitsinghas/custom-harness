#!/usr/bin/env bash
# =============================================================================
# Flutter Dev Framework — Bootstrap Installer
# =============================================================================
# One-command setup from any git URL. Installs:
#
#   - pi extension packages (project-local, if no global pi)
#   - Agent definitions (planner, feature-agent, reviewer)
#   - Official Dart skills  via `npx skills add dart-lang/skills -a pi`
#   - Official Flutter skills via `npx skills add flutter/skills -a pi`
#   - Our enhanced skill versions (override same-named official ones)
#   - Our custom-only skills (orchestrator, brainstorming, writing-plans, grill-me)
#   - Framework docs (FRAMEWORK.md, AGENTS.md template, MODEL_STRATEGY.md, STITCH_PIPELINE.md, design-tokens-schema.md)
#   - Deterministic helper tools (.pi/harness-tools/extract_design_tokens.js, arch_check.sh, golden_check.sh)
#   - Settings for pi npm packages
#
# Generic — works with ANY project. Not tied to Flutter specifically.
#
# Usage modes:
#
#   Mode 1 — In-place (clone IS the project):
#       git clone <repo-url> my-project
#       cd my-project && ./install.sh
#
#   Mode 2 — Into current directory (repo cloned alongside):
#       git clone <repo-url> .framework
#       cd my-project && .framework/install.sh
#
#   Mode 3 — Into a specific directory (creates if needed):
#       ./install.sh /path/to/project
#
#   Mode 4 — One-liner from raw URL:
#       bash <(curl -sL https://raw.githubusercontent.com/user/repo/main/install.sh) \
#         /path/to/project
# =============================================================================

set -euo pipefail

# ── Color helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { printf "${CYAN}  •${NC} %s\n" "$1"; }
ok()    { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}  ⚠${NC} %s\n" "$1"; }
fail()  { printf "${RED}  ✗${NC} %s\n" "$1"; }
header(){ printf "\n${BOLD}── %s ──${NC}\n" "$1"; }

# ── Configuration ────────────────────────────────────────────────────────────
PI_PACKAGE="${PI_PACKAGE:-@earendil-works/pi-coding-agent}"
PI_VERSION="${PI_VERSION:-latest}"

# Our enhanced skills that override same-named official ones
OUR_ENHANCED_SKILLS=(
  dart-add-unit-test
  flutter-add-integration-test
  flutter-apply-architecture-best-practices
)

# Our custom-only skills (no official counterpart)
OUR_CUSTOM_SKILLS=(
  orchestrator
  brainstorming
  writing-plans
  grill-me
  design-token-extractor
  visual-validator
  golden-test-generator
  architecture-consistency-checker
  stitch-html-parser
)

# ── Self-locate ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Help ─────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [TARGET_DIR]

Install the Flutter Dev Framework (agents, skills, settings) into any project.

Options:
  -y, --yes        Skip confirmation prompts
  -h, --help       Show this help

Arguments:
  TARGET_DIR    Path to the project directory (default: current directory)

Examples:
  $(basename "$0")                             # Install into ./
  $(basename "$0") my-new-project              # Create + install
  $(basename "$0") /path/to/existing-project   # Install into existing project
  bash <(curl -sL <raw-url>) my-project        # One-liner
EOF
  exit 0
}

# ── Parse arguments ──────────────────────────────────────────────────────────
SKIP_CONFIRM=false
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes)    SKIP_CONFIRM=true; shift ;;
    -h|--help)   usage ;;
    -*)
      echo "Unknown option: $1"
      usage
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  TARGET="."
fi

# Resolve to absolute path
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

# ── Pre-flight checks ────────────────────────────────────────────────────────
preflight() {
  echo ""
  echo "══════════════════════════════════════════════════════════════"
  echo "  Flutter Dev Framework — Bootstrap Installer"
  echo "══════════════════════════════════════════════════════════════"
  echo ""
  echo "  Source:  $SCRIPT_DIR"
  echo "  Target:  $TARGET"
  echo ""

  # Check essential tools
  local missing=()
  for cmd in git node npm; do
    if ! command -v "$cmd" &>/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo ""
    fail "Missing required tools: ${missing[*]}"
    echo "  Install them first, then re-run this script."
    echo "  - git:   https://git-scm.com/downloads"
    echo "  - node:  https://nodejs.org/"
    echo ""
    exit 1
  fi

  # Check if pi CLI is available
  if command -v pi &>/dev/null 2>&1; then
    PI_GLOBAL=true
    ok "pi CLI found globally ($(pi --version 2>/dev/null || echo 'version unknown'))"
  else
    PI_GLOBAL=false
    warn "pi CLI not found globally — will install project-local"
  fi

  # Check if skills CLI is available (part of vercel-labs/skills ecosystem)
  if command -v skills &>/dev/null 2>&1; then
    SKILLS_GLOBAL=true
  else
    SKILLS_GLOBAL=false
  fi

  # Confirm
  if [ "$SKIP_CONFIRM" = false ]; then
    echo ""
    echo "  This will install into: ${BOLD}$TARGET${NC}"
    if [ ! -d "$TARGET" ]; then
      echo "  ℹ️  Directory doesn't exist — will be created."
    fi
    read -rp "  Continue? [Y/n] " REPLY
    if [[ ! "$REPLY" =~ ^[Yy]?$ ]]; then
      echo "  Aborted."
      exit 0
    fi
  fi
}

# ── Install pi CLI project-local ─────────────────────────────────────────────
install_pi_local() {
  local target="$1"

  header "Installing pi CLI (project-local)"

  if [ ! -f "$target/package.json" ]; then
    cd "$target"
    npm init -y >/dev/null 2>&1
    cd "$OLDPWD"
  fi

  cd "$target"
  npm install --save-dev "$PI_PACKAGE@$PI_VERSION" 2>&1 | tail -2
  cd "$OLDPWD"

  if [ -f "$target/node_modules/.bin/pi" ]; then
    ok "pi CLI installed locally at node_modules/.bin/pi"
    # Create convenience alias in .envrc (for direnv users)
    if ! grep -q 'alias pi=' "$target/.envrc" 2>/dev/null; then
      echo "alias pi='npx pi'" >> "$target/.envrc" 2>/dev/null || true
    fi
  else
    warn "pi CLI installation may have failed"
  fi
}

# ── Install pi extension packages ───────────────────────────────────────────
install_pi_packages() {
  local target="$1"

  header "Installing pi extension packages"

  local pi_cmd=""
  if [ "$PI_GLOBAL" = true ] && command -v pi &>/dev/null; then
    pi_cmd="pi"
  elif [ -x "$target/node_modules/.bin/pi" ]; then
    pi_cmd="npx pi"
  fi

  if [ -z "$pi_cmd" ]; then
    warn "pi CLI not available — skipping package installation"
    warn "Install pi globally and re-run, or run manually:"
    warn "  npm install -g $PI_PACKAGE"
    return
  fi

  # The packages to install (mirrors pi/settings.json)
  local packages=(
    "npm:pi-ask-user"
    "npm:@plannotator/pi-extension"
    "npm:intercom"
    "npm:pi-intercom"
    "npm:pi-subagents"
  )

  cd "$target"
  for pkg in "${packages[@]}"; do
    info "Installing $pkg"
    $pi_cmd install -l "$pkg" 2>&1 | tail -1
  done
  cd "$OLDPWD"

  ok "Extension packages installed"
}

# ── Copy agent definitions ───────────────────────────────────────────────────
install_agents() {
  local target="$1"
  local source="$2"

  header "Installing agent definitions"

  mkdir -p "$target/.pi/agents"
  local copied=0
  local skipped=0

  for agent in "$source/pi/agents/"*.md; do
    [ -f "$agent" ] || continue
    local name
    name=$(basename "$agent")
    if [ -f "$target/.pi/agents/$name" ]; then
      skipped=$((skipped + 1))
    else
      cp "$agent" "$target/.pi/agents/$name"
      info "$name"
      copied=$((copied + 1))
    fi
  done

  echo "  → $copied installed, $skipped skipped"
}

# ── Install official skills via `npx skills add` ─────────────────────────────
install_official_skills() {
  local target="$1"

  header "Installing official skills via 'npx skills add'"

  # Ensure skills CLI is available
  local skills_cmd=""
  if [ "$SKILLS_GLOBAL" = true ]; then
    skills_cmd="skills"
  elif [ -x "$target/node_modules/.bin/skills" ]; then
    skills_cmd="npx skills"
  else
    # Install skills CLI locally if not available
    info "Installing skills CLI..."
    cd "$target"
    npm install --save-dev skills 2>&1 | tail -1
    cd "$OLDPWD"
    skills_cmd="npx skills"
  fi

  # Install Dart skills from dart-lang/skills
  info "Installing Dart skills (dart-lang/skills)..."
  cd "$target"
  $skills_cmd add dart-lang/skills -a pi -y 2>&1 | grep -E "(Installed|✓|✗|⚠|→|Error)" || true
  cd "$OLDPWD"
  echo ""

  # Install Flutter skills from flutter/skills
  info "Installing Flutter skills (flutter/skills)..."
  cd "$target"
  $skills_cmd add flutter/skills -a pi -y 2>&1 | grep -E "(Installed|✓|✗|⚠|→|Error)" || true
  cd "$OLDPWD"
}

# ── Override specific skills with our enhanced versions ──────────────────────
apply_enhanced_skills() {
  local target="$1"
  local source="$2"

  header "Applying enhanced skill versions"

  local overridden=0

  for skill in "${OUR_ENHANCED_SKILLS[@]}"; do
    local src="$source/pi/skills/$skill"
    if [ ! -d "$src" ]; then
      warn "Enhanced skill '$skill' not found in source — skipping"
      continue
    fi

    local dest="$target/.pi/skills/$skill"
    if [ -d "$dest" ]; then
      rm -rf "$dest"
    fi
    cp -r "$src" "$dest"
    info "$skill (overridden)"
    overridden=$((overridden + 1))
  done

  echo "  → $overridden enhanced skills applied"
}

# ── Install our custom-only skills ───────────────────────────────────────────
install_custom_skills() {
  local target="$1"
  local source="$2"

  header "Installing custom-only skills"

  mkdir -p "$target/.pi/skills"
  local copied=0

  for skill in "${OUR_CUSTOM_SKILLS[@]}"; do
    local src="$source/pi/skills/$skill"
    if [ ! -d "$src" ]; then
      warn "Skill '$skill' not found in source — skipping"
      continue
    fi

    local dest="$target/.pi/skills/$skill"
    if [ -d "$dest" ]; then
      rm -rf "$dest"
    fi
    cp -r "$src" "$dest"
    info "$skill"
    copied=$((copied + 1))
  done

  echo "  → $copied installed"
}

# ── Copy framework docs ──────────────────────────────────────────────────────
install_docs() {
  local target="$1"
  local source="$2"

  header "Installing framework documentation"

  for doc in FRAMEWORK.md MODEL_STRATEGY.md STITCH_PIPELINE.md design-tokens-schema.md; do
    if [ -f "$target/$doc" ]; then
      info "$doc (exists — skipped)"
    elif [ -f "$source/$doc" ]; then
      cp "$source/$doc" "$target/$doc"
      info "$doc"
    else
      warn "$doc missing in source — skipped"
    fi
  done

  if [ -f "$target/AGENTS.md" ]; then
    info "AGENTS.md (exists — skipped)"
  elif [ -f "$source/AGENTS.md" ]; then
    cp "$source/AGENTS.md" "$target/AGENTS.md"
    info "AGENTS.md (copied as runtime config template — edit for your project)"
  else
    # Create minimal runtime config template
    cat > "$target/AGENTS.md" << 'AGENTS_EOF'
# AGENTS.md — Runtime Configuration Template

## Project Identity

| Field | Value |
|---|---|
| Project name | `[REQUIRED]` |
| App type | `[Flutter app / Dart package / other]` |
| Package/application id | `[REQUIRED for mobile build/install]` |

## Project Paths

| Path | Value |
|---|---|
| Spec | `[REQUIRED: path/to/spec.md]` |
| App directory | `[REQUIRED for Flutter]` |
| Plan output | `specs/plan.md` |
| Review output | `specs/review.md` |
| Mockups/screenshots | `[optional]` |
| Generated artifacts | `[optional]` |

## Quality Gates

Use project-specific commands. Flutter default:

```bash
cd [app_dir]
flutter pub get
flutter analyze
flutter test
```
AGENTS_EOF
    info "AGENTS.md (template created)"
  fi
}

# ── Install deterministic helper tools ───────────────────────────────────────
install_tools() {
  local target="$1"
  local source="$2"

  header "Installing deterministic helper tools"

  mkdir -p "$target/.pi/harness-tools"
  local copied=0
  if [ -d "$source/harness-tools" ]; then
    for tool in "$source/harness-tools"/*; do
      [ -f "$tool" ] || continue
      cp "$tool" "$target/.pi/harness-tools/$(basename "$tool")"
      chmod +x "$target/.pi/harness-tools/$(basename "$tool")" 2>/dev/null || true
      info "$(basename "$tool")"
      copied=$((copied + 1))
    done
  else
    warn "No harness-tools/ directory found in source — deterministic scripts unavailable"
  fi
  echo "  → $copied tools installed"
}

# ── Configure settings.json ──────────────────────────────────────────────────
install_settings() {
  local target="$1"
  local source="$2"

  header "Configuring pi settings"

  mkdir -p "$target/.pi"
  local settings_file="$target/.pi/settings.json"
  local template_file="$source/pi/settings.json"

  if [ ! -f "$template_file" ]; then
    warn "No settings template found — creating minimal settings"
    cat > "$template_file" << 'JSONEOF'
{
  "packages": [
    "npm:pi-ask-user",
    "npm:@plannotator/pi-extension",
    "npm:intercom",
    "npm:pi-intercom",
    "npm:pi-subagents"
  ]
}
JSONEOF
  fi

  if [ -f "$settings_file" ]; then
    info "settings.json exists — merging packages"
    if command -v python3 &>/dev/null; then
      python3 -c "
import json, sys
with open('$settings_file') as f:
    data = json.load(f)
with open('$template_file') as f:
    template = json.load(f)
packages = data.get('packages', [])
changed = False
for pkg in template.get('packages', []):
    if pkg not in packages:
        packages.append(pkg)
        print(f'  • Added {pkg}')
        changed = True
if not changed:
    print('  • All packages already present')
data['packages'] = packages
with open('$settings_file', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"
    else
      warn "python3 not available — overwriting with template"
      cp "$template_file" "$settings_file"
    fi
  else
    cp "$template_file" "$settings_file"
    info "settings.json (created)"
  fi
}

# ── Print summary ────────────────────────────────────────────────────────────
print_summary() {
  local target="$1"

  echo ""
  echo "══════════════════════════════════════════════════════════════"
  echo "  ${GREEN}Installation Complete${NC}"
  echo "══════════════════════════════════════════════════════════════"
  echo ""

  local agent_count=0
  for f in "$target/.pi/agents/"*.md; do
    [ -f "$f" ] && agent_count=$((agent_count + 1))
  done

  local skill_count=0
  for d in "$target/.pi/skills/"*/; do
    [ -d "$d" ] && skill_count=$((skill_count + 1))
  done

  echo "  ${BOLD}Framework root:${NC} $target"
  echo "  ${BOLD}Agents:${NC}         $agent_count  (.pi/agents/)"
  echo "  ${BOLD}Skills:${NC}         $skill_count  (.pi/skills/)"
  echo "  ${BOLD}Docs:${NC}           FRAMEWORK.md, AGENTS.md, MODEL_STRATEGY.md"
  echo "  ${BOLD}Tools:${NC}          .pi/harness-tools/ (extract_design_tokens.js, arch_check.sh, golden_check.sh)"
  echo "  ${BOLD}Settings:${NC}       .pi/settings.json"
  echo ""

  if [ "$PI_GLOBAL" = false ] && [ ! -x "$target/node_modules/.bin/pi" ]; then
    echo "  ${YELLOW}⚠️  pi CLI was not installed. To install:${NC}"
    echo "     npm install --save-dev $PI_PACKAGE"
    echo "     or globally: npm install -g $PI_PACKAGE"
    echo ""
  fi

  echo "  ${BOLD}Next steps:${NC}"
  echo "    1. If you have not already done so, copy specs/mockups/plans/artifacts into this project directory."
  echo "    2. Start Pi in this project: ${CYAN}pi${NC}"
  echo "    3. Run: ${CYAN}/name orchestrator${NC}"
  echo "    4. Say: ${CYAN}Orchestrator, onboard this new Flutter Android project and begin Phase 0. I have copied the available specs, mockups, plans, and artifacts into this project directory. Discover them, ask me one question at a time, and write AGENTS.md, .pi/settings.json, and docs/state.json for me.${NC}"
  echo "    5. Do not manually edit AGENTS.md or .pi/settings.json unless the orchestrator asks you to review a proposed change."
  echo ""
}

# ══════════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════════

preflight

# Create target directory if it doesn't exist
if [ ! -d "$TARGET" ]; then
  mkdir -p "$TARGET"
  ok "Created target directory: $TARGET"
fi

# Install pi CLI if not globally available
if [ "$PI_GLOBAL" = false ]; then
  install_pi_local "$TARGET"
fi

# ── Core installation ────────────────────────────────────────────────────────

# Step 1: Agent definitions
install_agents "$TARGET" "$SCRIPT_DIR"

# Step 2: Official skills via npx skills add
install_official_skills "$TARGET"

# Step 3: Override specific official skills with our enhanced versions
apply_enhanced_skills "$TARGET" "$SCRIPT_DIR"

# Step 4: Install our custom-only skills
install_custom_skills "$TARGET" "$SCRIPT_DIR"

# Step 5: Framework documentation
install_docs "$TARGET" "$SCRIPT_DIR"

# Step 6: Deterministic helper tools
install_tools "$TARGET" "$SCRIPT_DIR"

# Step 7: Settings
install_settings "$TARGET" "$SCRIPT_DIR"

# Step 8: pi extension packages
install_pi_packages "$TARGET"

# ── Verification ─────────────────────────────────────────────────────────────
echo ""
header "Verifying installation"

verify_ok=true

# Agents
agent_count=$(find "$TARGET/.pi/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$agent_count" -ge 5 ]; then
  ok "Agents: $agent_count files in .pi/agents/"
else
  warn "Agents: only $agent_count files (expected ≥5 — planner, feature-agent, reviewer, visual-validator, architect)"
  verify_ok=false
fi

# Skills
skill_count=$(find "$TARGET/.pi/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$skill_count" -ge 15 ]; then
  ok "Skills: $skill_count in .pi/skills/"
else
  warn "Skills: only $skill_count (expected ≥15 — official + custom)"
  verify_ok=false
fi

# Custom skills (including new ones)
for skill in "${OUR_CUSTOM_SKILLS[@]}"; do
  if [ -f "$TARGET/.pi/skills/$skill/SKILL.md" ]; then
    ok "Custom skill: $skill"
  else
    warn "Missing custom skill: $skill"
    verify_ok=false
  fi
done

# Official skills verification (key ones must exist)
OFFICIAL_REQUIRED=(
  flutter-build-responsive-layout
  flutter-apply-architecture-best-practices
  flutter-add-widget-test
  dart-use-pattern-matching
  dart-add-unit-test
)
missing_official=0
for skill in "${OFFICIAL_REQUIRED[@]}"; do
  if [ -f "$TARGET/.pi/skills/$skill/SKILL.md" ]; then
    ok "Official skill: $skill"
  else
    warn "Missing official skill: $skill"
    missing_official=$((missing_official + 1))
  fi
done
if [ "$missing_official" -gt 0 ]; then
  warn "$missing_official official skills missing. Re-run: npx skills add"
fi

# New agents verification
for agent in visual-validator architect; do
  if [ -f "$TARGET/.pi/agents/$agent.md" ]; then
    ok "Agent: $agent"
  else
    warn "Missing agent: $agent"
    verify_ok=false
  fi
done

# Enhanced skills — verify our version (with marker) won
for skill in "${OUR_ENHANCED_SKILLS[@]}"; do
  if [ -f "$TARGET/.pi/skills/$skill/SKILL.md" ]; then
    if grep -q "last_modified" "$TARGET/.pi/skills/$skill/SKILL.md" 2>/dev/null; then
      ok "Enhanced skill: $skill"
    else
      info "Skill: $skill (official version)"
    fi
  else
    warn "Missing skill: $skill"
    verify_ok=false
  fi
done

# Docs
for doc in FRAMEWORK.md AGENTS.md MODEL_STRATEGY.md STITCH_PIPELINE.md design-tokens-schema.md; do
  if [ -f "$TARGET/$doc" ]; then
    ok "Doc: $doc"
  else
    warn "Missing doc: $doc"
    verify_ok=false
  fi
done

# Tools
for tool in extract_design_tokens.js arch_check.sh golden_check.sh; do
  if [ -f "$TARGET/.pi/harness-tools/$tool" ]; then
    ok "Tool: $tool"
  else
    warn "Missing tool: $tool"
    verify_ok=false
  fi
done

# Settings
if [ -f "$TARGET/.pi/settings.json" ]; then
  ok "Settings: .pi/settings.json"
else
  warn "Missing: .pi/settings.json"
  verify_ok=false
fi

print_summary "$TARGET"

if [ "$verify_ok" = false ]; then
  echo ""
  warn "Some items need attention (see above). You may re-run the installer."
  echo ""
else
  echo ""
  ok "All checks passed."
  echo ""
fi
