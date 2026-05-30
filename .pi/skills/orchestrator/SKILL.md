---
name: orchestrator
description: 3-agent Flutter development pipeline. Planner → Feature agents (per workstream, git commits) → One review (all diffs) → Quality Gate.
---

# Orchestrator — 3-Agent Pipeline

You orchestrate the Flutter development pipeline. You are a procedure, not an agent. Follow the steps. Dispatch subagents. Do NOT do their work yourself.

## Pipeline

```
planner → specs/plan.md
  → for each workstream (dependency order): feature-agent → implement + test + commit
  → ONE reviewer (fresh context, sees ALL diffs) → specs/review.md
  → if blockers: fix affected workstreams → re-review
  → Quality Gate
```

## Before Starting

1. Name your session: `/name [your-name]`
2. Read `AGENTS.md` for project configuration (auto-injected into all agents)

## Step 1: Resolve Project Paths

AGENTS.md is auto-injected in context. Check if it has a `## Project Paths` table.

For each path below, use the AGENTS.md value if present. If missing, ask the user:

```
ask_user({
  question: "What is the {path description}?",
  allowFreeform: true,
  context: "Needed for agent dispatch. Provide a path relative to project root."
})
```

| Variable | Default (if not in AGENTS.md) | Ask user if missing |
|----------|-------------------------------|---------------------|
| `{SPEC_PATH}` | `docs/spec.md` | ✅ Yes — spec is required for planning |
| `{MOCKUPS_PATH}` | (skip if not provided) | 🟡 Optional — only if visual mockups exist |
| `{APP_DIR}` | `.` (project root) | ✅ Yes — needed for build/deploy |
| `{PLAN_PATH}` | `specs/plan.md` | ❌ No — sensible default |
| `{REVIEW_PATH}` | `specs/review.md` | ❌ No — sensible default |
| `{INTEGRATION_TEST_PATH}` | `integration_test/` | ❌ No — sensible default |
| `{PACKAGE_NAME}` | (ask user) | ✅ Yes — needed for adb launch |

Once resolved, remember these values for all subsequent dispatches.

```
subagent({
  agent: "flutter-dev.planner",
  task: "Read the spec at {SPEC_PATH} and mockups at {MOCKUPS_PATH}.
    Produce {PLAN_PATH} with dependency-ordered workstreams, each tagged with tier.
    If you need research, intercom({ action: 'ask', to: '[SESSION]', message: 'RESEARCH: ...' }).",
  async: true
})
```

While planner runs, check for intercom asks and dispatch the researcher.

Read `{PLAN_PATH}`. **Present to user with this checklist:**

- ✅ **Coverage** — Every feature from the spec has a workstream?
- ✅ **Dependencies** — Foundation before features? No circular deps?
- ✅ **Granularity** — Each workstream ≤ 8 files?
- ✅ **Tiering** — Simple→Flash, Foundation→Pro xhigh? Makes sense?
- ✅ **Miss anything?** — Auth, error handling, edge cases?

Ask for approval before proceeding.

## Step 2: Workstream Loop

For each workstream W{N} in dependency order from `specs/plan.md`:

```
Determine model/thinking override from tier:
  Foundation → deepseek-v4-pro, thinking: xhigh
  Simple     → deepseek-v4-flash, thinking: high
  otherwise  → deepseek-v4-pro, thinking: high  (default from agent frontmatter)

subagent({
  agent: "flutter-dev.feature-agent",
  model: "{determined model}",
  thinking: "{determined thinking}",
  context: "fresh",
  task: "Implement workstream W{N}: {name}.
    Plan section: {PLAN_PATH} (section W{N})
    Files: {file list}
    Tests: {test file paths}
    Dependencies: {list} — read their files for context if needed.
    Implement → test → analyze → commit with message 'W{N}: {name}'.
    If tests don't pass after 2 attempts, report failure and stop.",
  async: true
})
```

Wait for completion. Verify the commit exists (`git log -1`). Show git log to the user.

If the agent fails → ask user: retry, skip, or abort.

## Step 3: Review

After ALL workstreams complete, dispatch ONE reviewer:

```
subagent({
  agent: "flutter-dev.reviewer",
  task: "Review all workstream changes AND write integration tests.
    Read the spec at {SPEC_PATH} and plan at {PLAN_PATH}. Run git diff.
    Run dart analyze and flutter test. Check coverage.
    Write integration tests in {INTEGRATION_TEST_PATH} covering cross-workstream
    user journeys from the spec. Run: flutter test {INTEGRATION_TEST_PATH}.
    Output: {REVIEW_PATH}.",
  context: "fresh",
  async: true
})
```

Read `specs/review.md`. Count BLOCKERS.

- **Zero BLOCKERS** → Quality Gate
- **BLOCKERS > 0** → for each blocked workstream, dispatch feature-agent with fix instructions → re-review → gate or escalate

## Step 4: Quality Gate

```bash
cd {APP_DIR}
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs --force-jit
flutter analyze && flutter test && flutter test integration_test/
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n {PACKAGE_NAME}/.MainActivity
```

## Intercom Handling

Only the planner phase needs intercom monitoring. The feature-agent and reviewer phases are deterministic (implement from plan, review against plan).

```
1. intercom({ action: "pending" })
2. If waiting → read question → dispatch researcher → reply
```

## Hard Rules

- NEVER do agents' work. Dispatch. They implement.
- NEVER make architecture decisions. Escalate to user.
- All agents dispatched async — keep this session free for intercom.
