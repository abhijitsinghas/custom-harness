# Custom Harness — Project-Agnostic Flutter/Dart Reliability Pipeline

This repository provides a Pi-based development harness for Flutter/Dart projects.

It installs:

- project-agnostic agents: `planner`, `feature-agent`, `reviewer`, `visual-validator`, `architect`
- project-agnostic `orchestrator` skill
- official Dart and Flutter skills (per-project, not globally)
- enhanced Flutter/Dart skills for architecture, tests, golden tests, and visual validation
- custom skills: design token extraction, visual validation loop, golden test generation, architecture consistency checking
- Pi extension packages for subagents, ask-user, intercom, and Plannotator
- generic `AGENTS.md` runtime configuration template
- reliability-first framework docs
- Stitch-to-Flutter pipeline guide and design token schema reference

The harness intentionally contains no product-specific implementation assumptions. Each target project supplies its own spec, paths, tech stack, and package ids at runtime.

---

## Install into a target project

```bash
cd /path/to/target-project
bash /path/to/custom-harness/install.sh
```

Or clone alongside a project:

```bash
git clone git@github.com:abhijitsinghas/custom-harness.git .framework
cd /path/to/target-project
../.framework/install.sh
```

The installer is idempotent and skips existing agents/docs unless specifically designed to override enhanced skills.

---

## What gets installed

```text
[target-project]/
├── .pi/
│   ├── agents/
│   │   ├── planner.md
│   │   ├── feature-agent.md
│   │   ├── reviewer.md
│   │   ├── visual-validator.md              # NEW: pixel-perfect UI validation
│   │   └── architect.md                     # NEW: pattern consistency guardian
│   ├── skills/
│   │   ├── orchestrator/
│   │   ├── design-token-extractor/          # NEW: Stitch HTML → design_tokens.json
│   │   ├── stitch-html-parser/              # NEW: parse tailwind configs from code.html
│   │   ├── visual-validator/                # NEW: iterative visual comparison loop
│   │   ├── golden-test-generator/           # NEW: visual regression test generation
│   │   ├── architecture-consistency-checker/# NEW: fast anti-pattern scanning
│   │   ├── dart-add-unit-test/              # enhanced
│   │   ├── flutter-add-integration-test/    # enhanced
│   │   ├── flutter-apply-architecture-best-practices/ # enhanced
│   │   └── official Dart/Flutter skills     # installed per-project via npx
│   └── settings.json
├── AGENTS.md              # runtime config template
├── FRAMEWORK.md           # pipeline docs
├── MODEL_STRATEGY.md      # model/thinking guidance
├── STITCH_PIPELINE.md     # NEW: Stitch-to-Flutter pipeline guide
└── design-tokens-schema.md # NEW: design tokens JSON schema reference
```

Project-specific build guides, such as `THE_LITTLE_LIBRARY_BUILD_INSTRUCTIONS.md`, remain in the harness repo and can be copied manually when needed.

---

## Required project setup after install

1. Edit `AGENTS.md` in the target project.
2. Fill in at minimum:
   - project name
   - app type
   - app directory
   - spec path
   - plan output path
   - review output path
   - package/application id if mobile build/install gates are needed
   - Stitch mockups path (for visual validation)
   - Design tokens path (if using automated extraction)
3. Confirm tech stack and architecture rules.
4. Confirm quality gates.
5. Place Stitch mockups (screen.png + code.html per screen) in `design-assets/`
6. Run `design-token-extractor` to generate `design_tokens.json` from Stitch HTML

If anything is missing, the orchestrator will ask at runtime.

---

## Starting the pipeline

In Pi:

```text
/name orchestrator
```

Then:

```text
Orchestrator, begin Phase 0.
Runtime inputs:
- Priority: reliability/quality first
- Spec: [path]
- App directory: [path]
- Mockups: [optional path — Stitch directory with screen.png + code.html]
- Design system: [optional path]
- Design tokens: [path to design_tokens.json or will auto-extract]
- Generated artifacts: [optional path]
- Plan output: [path]
- Review output: [path]
- Visual validation: enabled
- Max visual iterations: 3
Ask me for missing required information.
```

---

## Pipeline summary

```text
Resolve config → scaffold + design token extraction → planner → user approval
→ [for each workstream:] architect (pre-check) → feature-agent → gates
→ [if UI-critical:] visual-validator (render→compare→iterate→fix loop)
→ golden-test-generator (establish baseline)
→ reviewer → fixes → final quality gate
```

Workstream types:

- `W{N}` — Feature workstream: production code + unit/widget tests
- `W{N} [UI-critical]` — Screen/widget workstream: includes visual validation loop
- `IT{N}` — Integration test workstream: integration tests only
- `E2E{N}` — End-to-end test workstream: complete user journey tests only

---

## Model guidance

Defaults favor reliability and visual fidelity:

| Role | Default model | Thinking | Use case |
|---|---|---|---|
| Planner | `openai-codex/gpt-5.5` | high | Planning + architecture |
| Feature-agent (UI-critical) | `openai-codex/gpt-5.5` | high | Screens, widgets, visual fidelity |
| Feature-agent (logic) | `opencode-go/deepseek-v4-pro` | xhigh | Data, state, sync, complex logic |
| Feature-agent (simple) | `opencode-go/deepseek-v4-flash` | high | Mechanical fixes, constants, docs |
| Visual-validator | `openai-codex/gpt-5.5` | high | Vision-based mockup comparison |
| Architect | `opencode-go/deepseek-v4-flash` | high | Fast pattern scans |
| Reviewer | `openai-codex/gpt-5.4` | high | Deep spec/plan/tests review |

The orchestrator should upgrade complex/failing workstreams using the four-model strategy. For `openai-codex/gpt-5.5`, use `high` rather than `xhigh`. For `opencode-go/deepseek-v4-pro` and `opencode-go/deepseek-v4-flash`, use `high` or `xhigh`.

Use Pi `/models` as the source of truth for exact model names and supported thinking levels.

**Removed models (not available / not used):** GPT-5.3-Codex, GPT-5.4-Mini, Kimi K2.6, Qwen3.7 Plus, GLM-5.1.

See `MODEL_STRATEGY.md`.

---

## Project-specific guides

This repo may include separate project runbooks, for example:

```text
THE_LITTLE_LIBRARY_BUILD_INSTRUCTIONS.md
```

Use those as manual runbooks for their named projects. They are intentionally separate from agents/skills so the harness remains project-agnostic.

---

## Key reliability rules

- Agents ask for missing runtime values instead of guessing.
- The orchestrator does not implement or debug.
- The planner does not write code.
- The feature-agent implements one workstream only.
- The visual-validator compares rendered UIs against mockups but never modifies code.
- The architect scans for anti-patterns but never modifies code.
- The reviewer does not fix code.
- **Stitch mockup screenshots** (screen.png) and HTML (code.html) are **immutable** visual references.
- **Golden test PNGs** are generated artifacts stored in `test/goldens/` — separate from source mockups.
- **design_tokens.json** is the single machine-readable source of truth for all design values.
- Golden tests establish visual baselines; `--update-goldens` only during intentional rebaselining.
- Git commits mark completed workstreams and support resume/recovery.
