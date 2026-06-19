# Model Strategy — Four-Model Strategy with Visual Fidelity Tier

This harness uses exactly four models. No other models should be used for default routing. Visual fidelity tasks are routed to the most capable model.

## Target Model Set

1. `openai-codex/gpt-5.5` — Scarce, high-leverage decisions AND visual fidelity. Planner, UI-critical implementation, visual validation, final review, critical escalation.
2. `openai-codex/gpt-5.4` — Review and precision repair. Default reviewer, non-visual escalation.
3. `opencode-go/deepseek-v4-pro` — Complex logic implementation. Data, state, sync, offline, auth.
4. `opencode-go/deepseek-v4-flash` — Mechanical and fast. Simple fixes, golden tests, architecture checks.

## Operating Principle

```text
GPT-5.5 plans, validates visual fidelity, and handles critical milestones.
GPT-5.4 reviews and repairs.
DeepSeek V4 Pro builds complex logic.
DeepSeek V4 Flash cleans up, runs golden tests, and scans patterns.
```

## Thinking-Level Compatibility

Use Pi `/models` or `pi --list-models` as the final source of truth. Current constraints:

| Model | Allowed thinking levels | Default | Notes |
|---|---|---:|---|
| `openai-codex/gpt-5.5` | `low`, `medium`, `high` | `high` | Never use `xhigh`. Used for UI-critical and visual tasks. |
| `openai-codex/gpt-5.4` | `low`, `medium`, `high` if shown by `/models` | `high` | Reviewer and precision repair |
| `opencode-go/deepseek-v4-pro` | `high`, `xhigh` | `xhigh` for complex, `high` for normal | Complex logic implementer |
| `opencode-go/deepseek-v4-flash` | `high`, `xhigh` | `high` | Cheap mechanical: golden tests, architect scans, simple widgets |

If a model rejects a thinking level, retry with the highest supported level shown by `/models`.

## Agent Defaults

| Agent | Default model | Thinking | Rationale |
|---|---|---:|---|
| orchestrator skill | no fixed model | high | Procedure; dispatches, asks, gates |
| planner | `openai-codex/gpt-5.5` | high | Strongest planning/architecture judgment; no xhigh |
| feature-agent (UI-critical) | `openai-codex/gpt-5.5` | high | UI requires visual reasoning capability |
| feature-agent (logic) | `opencode-go/deepseek-v4-pro` | xhigh | High-volume complex logic implementation |
| feature-agent (simple) | `opencode-go/deepseek-v4-flash` | high | Fast, cheap for mechanical work |
| visual-validator | `openai-codex/gpt-5.5` | high | Vision capability needed for mockup comparison |
| architect | `opencode-go/deepseek-v4-flash` | high | Fast mechanical pattern scans |
| reviewer | `openai-codex/gpt-5.4` | high | Preserves GPT-5.5 quota; runs frequently |

## Updated Workstream Tier Mapping

| Workstream tier/type | First attempt | Thinking | Visual Validator | Fixer | Escalation |
|---|---|---|---:|---:|---:|
| Broad planning / plan critique | `openai-codex/gpt-5.5` | high | N/A | N/A | same |
| Huge codebase consistency scan | `opencode-go/deepseek-v4-pro` | xhigh | N/A | N/A | `openai-codex/gpt-5.5:high` for critique |
| UI-critical: screens/widgets | `openai-codex/gpt-5.5` | high | `openai-codex/gpt-5.5:high` (vision) | — | `openai-codex/gpt-5.5:high` re-review |
| Foundation scaffold | `opencode-go/deepseek-v4-pro` | xhigh | — | `opencode-go/deepseek-v4-flash:high` | `openai-codex/gpt-5.4:high` |
| Database/schema/migration | `opencode-go/deepseek-v4-pro` | xhigh | — | `openai-codex/gpt-5.4:high` | `openai-codex/gpt-5.5:high` only for data-loss risk |
| Sync/offline/conflicts | `opencode-go/deepseek-v4-pro` | xhigh | — | `openai-codex/gpt-5.4:high` | `openai-codex/gpt-5.5:high` |
| Auth/routing/state | `opencode-go/deepseek-v4-pro` | xhigh | — | `opencode-go/deepseek-v4-flash:high` | `openai-codex/gpt-5.4:high` |
| Complex logic feature | `opencode-go/deepseek-v4-pro` | xhigh | — | `opencode-go/deepseek-v4-flash:high` | `openai-codex/gpt-5.4:high` |
| Medium feature (logic) | `opencode-go/deepseek-v4-pro` | high | — | `opencode-go/deepseek-v4-flash:high` | `openai-codex/gpt-5.4:high` |
| Simple widget/constants/docs | `opencode-go/deepseek-v4-flash` | high | — | `opencode-go/deepseek-v4-pro:high` | `openai-codex/gpt-5.4:high` |
| Integration/E2E tests | `opencode-go/deepseek-v4-pro` | high | — | `opencode-go/deepseek-v4-flash:high` | `openai-codex/gpt-5.4:high` |
| Golden test generation | `opencode-go/deepseek-v4-flash` | high | — | `opencode-go/deepseek-v4-pro:high` | `openai-codex/gpt-5.4:high` |
| Architecture consistency scan | `opencode-go/deepseek-v4-flash` | high | — | — | — |
| Normal review | `openai-codex/gpt-5.4` | high | N/A | N/A | `openai-codex/gpt-5.5:high` |
| Final review | `openai-codex/gpt-5.5` | high | N/A | N/A | same |

## UI-Critical Workstream Identification

A workstream is UI-critical if the planner marks it as such. Criteria:
- Creates or significantly modifies a screen widget (`*_screen.dart`, `*_page.dart`)
- Creates or modifies a shared UI component (`widgets/` directory)
- Implements a visual layout from a Stitch mockup

The orchestrator routes UI-critical workstreams to GPT-5.5 and triggers the visual validation phase after implementation.

## Failure Escalation Ladder

```text
Logic failure:
  Attempt 1: DeepSeek V4 Pro xhigh/high
  → Mechanical fix: DeepSeek V4 Flash high
  → Repeated failure: GPT-5.4 high
  → Critical: GPT-5.5 high

Visual failure (discrepancies not resolved):
  Attempts 1-3: GPT-5.5 (feature-agent) + GPT-5.5 (visual-validator) loop
  → Max iterations reached: present to user

Architecture check failure:
  WARN: report to user, continue
  FAIL: block pipeline, ask user
```

Critical repeated failure means: data loss risk, unsafe database migration, broken sync/conflict resolution, auth/session security issue, routing loop or app boot blocker, duplicate detector correctness remains suspect, scan/OCR architecture is unstable, final release gate failure after GPT-5.4 repair.

## Operational Notes

- Run `/models` in Pi before a major project to confirm exact model names and supported thinking.
- If a selected model rejects a thinking level, retry with the highest supported level from the compatibility table above.
- Do not assign `xhigh` to GPT-5.5.
- UI-critical work requires GPT-5.5 for visual reasoning capability. Do not route screens/widgets to DeepSeek.
- The visual-validator MUST use GPT-5.5 — it needs vision to compare goldens against mockups.
- Golden test generation and architecture scans are mechanical — use DeepSeek V4 Flash for cost efficiency.
- Do not use GPT-5.3-Codex, GPT-5.4-Mini, Kimi K2.6, Qwen3.7 Plus, GLM-5.1, MiniMax, or MiMo unless the user explicitly overrides this four-model policy.
