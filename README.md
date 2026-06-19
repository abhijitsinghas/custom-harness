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
│   ├── tools/
│   │   ├── extract_design_tokens.js        # deterministic Stitch HTML → design_tokens.json
│   │   ├── arch_check.sh                   # deterministic architecture consistency scanner
│   │   └── golden_check.sh                 # deterministic golden regression pre-filter
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

Do **not** manually edit `AGENTS.md` or `.pi/settings.json` for a new project. The intended
manual flow is:

1. Create the target directory.
2. Copy all available project inputs into it — specs, UI mockups, existing plans, generated
   artifacts, reference code, etc.
3. Run the install script.
4. Start the orchestrator onboarding flow.

The AI will discover those files, ask one question at a time for anything missing or
ambiguous, write `AGENTS.md`, write `.pi/settings.json` model overrides, create
`docs/state.json`, and run Phase 0.

```bash
mkdir -p /path/to/target-project
cd /path/to/target-project
# Copy specs/mockups/plans/artifacts here now.
bash /path/to/custom-harness/install.sh
pi
```

Then use `/name orchestrator` and the onboarding prompt below.

---

## Starting the pipeline

In Pi:

```text
/name orchestrator
```

Then:

```text
Orchestrator, onboard this new Flutter Android project and begin Phase 0.
I have copied the available specs, mockups, plans, and artifacts into this project directory.
Discover them, ask me one question at a time for every missing or ambiguous value,
do not assume missing project details, and write AGENTS.md, .pi/settings.json,
docs/state.json, and any needed docs/config files for me.
```

---

## Pipeline summary

```text
Resolve config → scaffold + design token extraction → planner → user approval
→ [for each workstream:] arch_check.sh (pre) → feature-agent with native acceptance contract
→ acceptance verify gates (analyze/tests/goldens/integration)
→ [if UI-critical:] golden_check.sh deterministic pre-filter → visual-validator semantic diff → fix loop
→ golden-test-generator (establish baseline)
→ arch_check.sh (post) → reviewer → fixes → final quality gate
```

Workstream types:

- `W{N}` — Feature workstream: production code + unit/widget tests
- `W{N} [UI-critical]` — Screen/widget workstream: includes visual validation loop
- `IT{N}` — Integration test workstream: integration tests only
- `E2E{N}` — End-to-end test workstream: complete user journey tests only

---

## Model guidance

The harness is model-agnostic. It uses capability tiers and resolves concrete model IDs on the target machine via `pi --list-models` and/or `.pi/settings.json` `subagents.agentOverrides`.

| Role | Capability tier | Thinking | Use case |
|---|---|---|---|
| Planner | `planner-tier` | high | Planning + architecture |
| Feature-agent (UI-critical) | `ui-vision-tier` | high | Screens, widgets, visual fidelity |
| Feature-agent (logic) | `logic-tier` | xhigh/high | Data, state, sync, complex logic |
| Feature-agent (simple) | `mechanical-tier` | high | Mechanical fixes, constants, docs |
| Visual-validator | `ui-vision-tier` | high | Vision-based semantic mockup comparison |
| Architect | `mechanical-tier` | high | Fast deterministic pattern scans |
| Reviewer | `review-tier` | high | Deep spec/plan/tests review |
| Critical escalation | `escalation-tier` | high | Final review / high-risk failures |

Concrete IDs are examples only; verify on the target machine. See `MODEL_STRATEGY.md`.

For a full end-to-end setup procedure for a new target project, see `NEW_PROJECT_GUIDE.md`.

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
