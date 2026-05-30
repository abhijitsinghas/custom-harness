# Flutter Dev Framework

> **8 specialised agents. Typed handoff contracts. Versioned reviews. Project-agnostic.**
>
> Copy `.pi/agents/` to any Flutter project, write an `AGENTS.md`, start building.

---

## Why This Exists

AI agents write code. They also write tests that pass by construction, skip edge cases, and mark their own homework. The feedback loop collapses.

This framework enforces **information isolation**: no agent sees what the previous one wrote. The story-writer never sees the code. The implementer never sees the spec — only the tests. The reviewers see everything but never edit. Problems can't be silently reconciled — they surface as failures.

---

## The 8 Agents

| # | Agent | Model | Thinking | Tools | Does |
|---|-------|-------|----------|-------|------|
| 1 | `orchestrator` | deepseek-v4-flash | high | read, write, edit, bash, glob, subagent, intercom | Dispatch, monitor, enforce pipeline, run quality gate |
| 2 | `planner` | kimi-k2.6 | xhigh | read, write, edit, bash, glob | Scope phases, decompose workstreams, order dependencies |
| 3 | `story-writer` | kimi-k2.6 | xhigh | read, write, edit, bash, glob | User stories from spec + mockups: happy paths, edges, errors, empty states, accessibility |
| 4 | `test-writer` | deepseek-v4-pro | xhigh | read, write, edit, bash, glob | Unit, widget, integration, E2E tests from user stories |
| 5 | `data-implementer` | deepseek-v4-pro | xhigh | read, write, edit, bash, glob | Data layer: drift tables, DAOs, repositories, API clients, sync, auth |
| 6 | `ui-implementer` | qwen3.6-plus | xhigh | read, write, edit, bash, glob | UI layer: screens, widgets, navigation, state wiring from mockups |
| 7 | `code-reviewer` | kimi-k2.5 | xhigh | read, bash, glob | Read-only: check implementation against user stories, run analysis |
| 8 | `test-reviewer` | qwen3.5-plus | xhigh | read, bash, glob | Read-only: check test coverage and quality against user stories |

### Subagent Configuration

| Parameter | Workers (agents 2-8) | Orchestrator (agent 1) |
|-----------|----------------------|------------------------|
| `inheritProjectContext` | `false` | `true` |
| `inheritSkills` | `false` | `true` |
| `systemPromptMode` | `replace` | `replace` |
| `tools` | read+write (implementers), read-only (reviewers) | + subagent + intercom |

### Skills Per Agent

| Agent | Skills |
|-------|--------|
| orchestrator | pi-subagents, pi-intercom |
| planner | brainstorming, writing-plans, flutter-apply-architecture-best-practices, ask-user |
| story-writer | brainstorming, flutter-apply-architecture-best-practices |
| test-writer | dart-add-unit-test, dart-generate-test-mocks, dart-collect-coverage, flutter-add-widget-test, flutter-add-integration-test |
| data-implementer | flutter-implement-json-serialization, flutter-apply-architecture-best-practices, flutter-use-http-package, dart-use-pattern-matching |
| ui-implementer | flutter-build-responsive-layout, flutter-add-widget-preview, flutter-apply-architecture-best-practices, flutter-add-widget-test, flutter-fix-layout-issues |
| code-reviewer | dart-run-static-analysis, dart-collect-coverage, plannotator-review |
| test-reviewer | dart-run-static-analysis, dart-collect-coverage |

---

## The Pipeline (Per Phase)

```
PLAN → STORIES → TESTS → IMPLEMENT → REVIEW → FIX → GATE
  │       │         │         │           │        │      │
  │       │         │         │      ┌────┴────┐ ┌─┴──┐   │
  │       │         │         │  code-reviewer test-   │
  │       │         │         │                reviewer │
  │       │         │         │      │              │    │
  │       │         │         │  ┌───┴───┐    ┌────┴───┐│
  │       │         │         │implementer  test-writer │
  │       │         │         │           story-writer  │
  │       │         │         │                         │
  │       │         │    [feedback: max 3 rounds]       │
  │       │         │                                   │
  ▼       ▼         ▼         ▼                         ▼
plan.md stories.md tests.md impl-report.md         APK on device
```

### Step-by-Step

| Step | Agent | Reads | Writes |
|------|-------|-------|--------|
| 1 | planner | Spec, roadmap, AGENTS.md | `specs/phase-N/plan.md` |
| 2 | story-writer | `plan.md`, spec, mockups | `specs/phase-N/stories.md` |
| 3 | test-writer | `stories.md` | `specs/phase-N/tests-report.md` + test files |
| 4a | data-implementer | `tests-report.md`, plan | Production code + `specs/phase-N/impl-report.md` |
| 4b | ui-implementer | `tests-report.md`, plan, mockups | Production code + `specs/phase-N/impl-report.md` |
| 5a | code-reviewer | All artifacts + git diff | `specs/phase-N/reviews/code-review-r{N}.md` |
| 5b | test-reviewer | All artifacts + test files | `specs/phase-N/reviews/test-review-r{N}.md` |
| 6 | orchestrator | Review files | Dispatching fixes or escalating |

---

## Handoff Protocol

Every agent reads one artifact, writes one artifact. The orchestrator passes file paths only.

```
specs/phase-N/
├── plan.md                    ← planner output
├── stories.md                 ← story-writer output
├── tests-report.md            ← test-writer output (coverage map + summary)
├── impl-report.md             ← implementer output (changed files + test status)
└── reviews/
    ├── code-review-r1.md      ← code-reviewer, round 1
    ├── code-review-r2.md      ← code-reviewer, round 2
    ├── code-review-r3.md      ← code-reviewer, round 3
    ├── test-review-r1.md      ← test-reviewer, round 1
    ├── test-review-r2.md      ← test-reviewer, round 2
    └── test-review-r3.md      ← test-reviewer, round 3
```

### Artifact Formats

**plan.md**
```markdown
# Phase N Plan
## Workstreams (ordered by dependency)
## Integration/E2E Test Scenarios
```

**stories.md**
```markdown
# User Stories — Phase N
## Happy Path
### US-1: [Title]
**As a** [role] **I want to** [action] **So that** [benefit]
**Given** ... **When** ... **Then** ...
## Edge Cases | Error States | Empty States | Accessibility
```

**tests-report.md**
```markdown
# Test Report — Phase N
## Coverage Map
| Story ID | Test File | Test Name | Type |
## Uncovered Stories
## Test Execution: All FAIL (expected)
```

**impl-report.md**
```markdown
# Implementation Report — Phase N
## Changed Files | Test Status | Decisions Made | Issues Found
```

**code-review-r{N}.md**
```markdown
# Code Review — Phase N, Round {N}
**Round:** {N} of {max}
## BLOCKER — Must Fix | SHOULD FIX | NICE TO HAVE
## Resolved from Round {N-1}
## Verdict: APPROVE / NEEDS FIXES ({N} blockers)
```

**test-review-r{N}.md**
```markdown
# Test Review — Phase N, Round {N}
**Coverage:** [X%] | **Stories:** [N/M covered]
## MISSING COVERAGE → Story-Writer | TEST QUALITY → Test-Writer
## Resolved from Round {N-1}
## Verdict: APPROVE / NEEDS FIXES ({N} issues)
```

---

## Review Rounds

Configured in `AGENTS.md`:

```yaml
review:
  max_rounds: 3
```

After each round, the orchestrator evaluates:

| Condition | Action |
|-----------|--------|
| Zero BLOCKERS in both reviews | → Quality gate |
| BLOCKERS remain, round < 3 | → Dispatch fixes, increment round (`r1` → `r2` → `r3`) |
| BLOCKERS remain, round = 3 | → Escalate to user with unresolved issues |

Each review file tracks its round and resolved issues. Reviewers are read-only — they never edit code. Their findings route through the orchestrator to the right agent:
- `code-reviewer` → data-implementer or ui-implementer
- `test-reviewer` → test-writer (quality issues) or story-writer (coverage gaps)

---

## Quality Gate (Every Phase)

```bash
cd [APP_DIR]
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
flutter analyze                     # Zero warnings
flutter test                        # Unit + widget
flutter test integration_test/      # Integration + E2E
dart run coverage:test_with_coverage # 90/85/70 thresholds
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n [PACKAGE_NAME]/.MainActivity
```

---

## Project Structure

```
project/
├── AGENTS.md                           ← Architecture, conventions, review config, design tokens
├── docs/                               ← Specs, implementation plan, UI mockups
├── .pi/
│   ├── agents/                         ← 8 agent definitions (this framework)
│   ├── skills/                         ← Flutter + Dart skills
│   └── settings.json                   ← npm packages (pi-subagents, pi-intercom, etc.)
└── [app_dir]/                          ← Flutter project (created by Phase 0)
    ├── lib/                            ← All production code
    ├── test/                           ← Unit + widget tests
    └── integration_test/               ← Integration + E2E tests
```

---

## Hard Constraints

| Agent | Never |
|-------|-------|
| orchestrator | Analyze code, debug, implement, review, make architecture decisions |
| planner | Implement, test, review code |
| story-writer | Write code or tests |
| test-writer | Write production code |
| implementers | Modify test files, add features not in tests |
| reviewers | Edit code or tests — read-only, report findings only |

---

## How to Start

```
1. /models                          ← Verify opencode-go models available
2. /name orchestrator               ← Name your session
3. Orchestrator, begin Phase 0. Confirm the plan before dispatching any agents.
```

The orchestrator reads `AGENTS.md` for project paths and conventions. Pi auto-loads `AGENTS.md` into every session. The orchestrator dispatches agents. You review and approve at each gate.
