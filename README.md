# Custom Harness — Project-Agnostic Flutter/Dart Reliability Pipeline

This repository provides a Pi-based development harness for Flutter/Dart projects.

It installs:

- project-agnostic agents: `planner`, `feature-agent`, `reviewer`
- project-agnostic `orchestrator` skill
- official Dart and Flutter skills
- enhanced Flutter/Dart skills for architecture and tests
- Pi extension packages for subagents, ask-user, intercom, and Plannotator
- generic `AGENTS.md` runtime configuration template
- reliability-first framework docs

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
│   │   └── reviewer.md
│   ├── skills/
│   │   ├── orchestrator/
│   │   ├── dart-add-unit-test/                  # enhanced
│   │   ├── flutter-add-integration-test/        # enhanced
│   │   ├── flutter-apply-architecture-best-practices/ # enhanced
│   │   └── official Dart/Flutter skills
│   └── settings.json
├── AGENTS.md           # runtime config template
├── FRAMEWORK.md        # pipeline docs
└── MODEL_STRATEGY.md   # model/thinking guidance
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
3. Confirm tech stack and architecture rules.
4. Confirm quality gates.

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
- Mockups: [optional path]
- Design system: [optional path]
- Generated artifacts: [optional path]
- Plan output: [path]
- Review output: [path]
Ask me for missing required information.
```

---

## Pipeline summary

```text
Resolve config → scaffold/check environment → planner → user approval
→ feature-agent per workstream → gates → reviewer → fixes → final quality gate
```

Workstream types:

- `W{N}` — Feature workstream: production code + unit/widget tests
- `IT{N}` — Integration test workstream: integration tests only
- `E2E{N}` — End-to-end test workstream: complete user journey tests only

---

## Model guidance

Defaults favor reliability:

| Role | Default model | Thinking |
|---|---|---:|
| Planner | `openai-codex/gpt-5.5` | high |
| Feature-agent | `openai-codex/gpt-5.3-codex` | high |
| Reviewer | `openai-codex/gpt-5.5` | high |

The orchestrator should upgrade complex/failing workstreams to the strongest available model with that model's highest supported thinking level. For `openai-codex/gpt-5.5`, use `high` rather than `xhigh`. For `opencode-go/deepseek-v4-pro` and `opencode-go/deepseek-v4-flash`, use `high` or `xhigh`.

Use Pi `/models` as the source of truth for exact model names and supported thinking levels. ChatGPT/Codex models can be used only if exposed in your Pi/provider configuration; otherwise use opencode-go fallbacks.

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
- The reviewer does not fix code.
- Mockup screenshots are immutable visual references; do not overwrite them with `--update-goldens`.
- Git commits mark completed workstreams and support resume/recovery.
