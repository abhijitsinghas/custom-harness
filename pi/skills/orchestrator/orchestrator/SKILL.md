---
name: orchestrator
description: TDD-enforced Flutter development pipeline. Use when starting development, building features, or running phases. Orchestrates planner, story-writer, test-writer, implementers, and reviewers through spec-driven, test-first delivery.
---

# Orchestrator — Development Pipeline

You orchestrate the 7-agent Flutter development pipeline. You are a procedure, not an agent. Follow the steps. Dispatch subagents. Do NOT do their work yourself.

## Before Starting

**REQUIRED: `/name orchestrator`** — agents send intercom to this name. Without it, research fails.

Read `AGENTS.md` for project configuration. Find: app directory, package name, planning.max_rounds, review.max_rounds.

## Research Dispatch

Agents communicate research needs via intercom to this session. When you receive an intercom ask from an agent:

1. Read the research question
2. Dispatch researcher on-demand: `subagent({ agent: "flutter-dev.researcher", model: "opencode-go/deepseek-v4-flash", thinking: "xhigh", task: "RESEARCH: [agent's question]. Use official docs. Verified facts with source URLs." })`
3. Reply to agent: `intercom({ action: "reply", message: "[research findings]" })`

This works because agents are dispatched **asynchronously** — this session is never blocked.

## The Pipeline

```
PLANNER (iterative, async) → specs/plan.md
    ↓
Per phase (all async):
  STORY-WRITER → TEST-WRITER → IMPLEMENTERS (∥) → REVIEWERS (∥) → FEEDBACK → GATE
```

## Phase 0: Planning

### Step 1: Dispatch Planner — Round 1

```
subagent({
  agent: "flutter-dev.planner",
  task: "Round 1: Produce initial master plan from spec + mockups. Read AGENTS.md. Output: specs/plan.md. Cover all phases with shared contracts, workstreams, dependencies, pipeline tiers. If you need research, send intercom({ action: 'ask', to: 'orchestrator', message: 'RESEARCH: ...' }). I will research and reply.",
  async: true
})
```

While planner runs, monitor for intercom asks. When received: dispatch researcher, reply.

### Step 2: Check Planner Status

```
subagent({ action: "status", id: "[planner-run-id]" })
```

### Step 3: Planner — Critique + Refine Rounds

For round 2 to planning.max_rounds (default 3):

```
subagent({
  agent: "flutter-dev.planner",
  task: "Round N: Critique plan at specs/plan.md against spec. Cite specific sections. Apply improvements. If nothing citeable to improve, respond PLAN_COMPLETE.",
  async: true
})
```

Monitor for intercom asks. Stop when planner responds PLAN_COMPLETE or round == max_rounds.

### Step 4: Review Plan with User

Present plan summary. Ask for approval.

## Per-Phase Execution

For each phase in order. All agents dispatched async:

### Step 1: Story-Writer

```
subagent({
  agent: "flutter-dev.story-writer",
  task: "Write user stories for Phase N. Plan: specs/plan.md (Phase N). Spec: [path]. Mockups: [path]. Output: specs/phase-N/stories.md. Cover happy paths, edge cases, errors, empty states, accessibility. For research, intercom({ action: 'ask', to: 'orchestrator' }).",
  async: true
})
```

### Step 2: Test-Writer

```
subagent({
  agent: "flutter-dev.test-writer",
  task: "Write tests from specs/phase-N/stories.md. Output: specs/phase-N/tests-report.md + test files. Map every story to a test. Confirm all FAIL.",
  async: true
})
```

### Step 3: Implementers (Parallel)

```
subagent({ tasks: [
  { agent: "flutter-dev.data-implementer",
    task: "Implement data layer for Phase N. Tests: specs/phase-N/tests-report.md. Plan: specs/plan.md. Minimum code. NEVER modify test files." },
  { agent: "flutter-dev.ui-implementer",
    task: "Implement UI for Phase N. Tests: specs/phase-N/tests-report.md. Plan: specs/plan.md. Mockups: [path]. NEVER modify test files." }
], concurrency: 2, async: true })
```

### Step 4: Reviewers (Parallel, Fresh Context)

```
subagent({ tasks: [
  { agent: "flutter-dev.code-reviewer",
    task: "Review Phase N implementation against specs/phase-N/stories.md. Run dart analyze and flutter test. BLOCKERS/SHOULD_FIX/NICE_TO_HAVE. Output: specs/phase-N/reviews/code-review-r1.md. For research, intercom({ action: 'ask', to: 'orchestrator' })." },
  { agent: "flutter-dev.test-reviewer",
    task: "Review Phase N test coverage against specs/phase-N/stories.md. Run coverage. Output: specs/phase-N/reviews/test-review-r1.md." }
], concurrency: 2, context: "fresh", async: true })
```

### Step 5: Feedback Loop

Read review files. Count BLOCKERS.

- **Zero BLOCKERS** → Quality Gate
- **BLOCKERS > 0, round < review.max_rounds** → dispatch fixes, re-review with incremented round (r2, r3)
- **BLOCKERS > 0, round == max_rounds** → escalate to user

### Step 6: Quality Gate

```bash
cd [APP_DIR]
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
flutter analyze && flutter test && flutter test integration_test/
dart run coverage:test_with_coverage
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n [PACKAGE_NAME]/.MainActivity
```

## Intercom Handling Loop

While agents run asynchronously, continuously check for intercom asks:

```
1. Check pending: intercom({ action: "pending" })
2. If asks waiting → process each:
   a. Read the question
   b. subagent({ agent: "flutter-dev.researcher", task: "RESEARCH: [question]" })
   c. intercom({ action: "reply", to: "[sender]", message: "[findings]" })
3. Check agent status: subagent({ action: "status", id: "[run-id]" })
4. If still running → continue monitoring
5. If completed → move to next step
```

## Hard Rules

- **NEVER do agents' work.** Dispatch. They implement.
- **All agents dispatched async** — this session must stay free for intercom.
- **NEVER analyze, implement, or review.** That's the agents' job.
- **NEVER make architecture decisions.** Escalate to user.
- Always read AGENTS.md first for project paths and config.
