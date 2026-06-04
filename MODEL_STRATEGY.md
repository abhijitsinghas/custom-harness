# Model Strategy — Mixed OpenAI Codex + OpenCode Go

This harness is project-agnostic, but model selection should match workstream risk and each model's supported thinking levels.

## Thinking-level compatibility

Use Pi's `/models` or `pi --list-models` as the final source of truth. Current constraints for this setup:

| Model family | Supported thinking levels to use |
|---|---|
| `openai-codex/gpt-5.5` | `low`, `medium`, `high` only — **do not use `xhigh`** |
| `opencode-go/deepseek-v4-pro` | `high`, `xhigh` |
| `opencode-go/deepseek-v4-flash` | `high`, `xhigh` |
| `openai-codex/gpt-5.3-codex` | use `high` by default; use `xhigh` only if `/models` confirms it is supported locally |
| `openai-codex/gpt-5.4-mini` | use `medium` or `high`; do not assume `xhigh` |

When in doubt, choose the highest supported level shown by `/models`, not the highest level Pi accepts globally.

## Principles

1. **Mix subscriptions intentionally.** Use OpenCode Go for huge-context planning/scans and OpenAI Codex for precision implementation/review.
2. **Do not hardcode product decisions into model prompts.** Product context comes from runtime config.
3. **Use stronger models where mistakes are expensive:** planning, database/schema, routing, sync, auth, review, and failure recovery.
4. **Use faster/cheaper models for low-risk mechanical work:** small widgets, constants, docs, and minor refactors.
5. **Escalate on failure to the strongest available model with its highest supported thinking level.** For `gpt-5.5`, that means `high`, not `xhigh`.

## Recommended agent frontmatter defaults

| Agent | Default model | Thinking | Rationale |
|---|---|---:|---|
| orchestrator skill | no fixed model | high | The orchestrator is a procedure. It dispatches, asks, and gates. |
| planner | `openai-codex/gpt-5.5` | high | Strongest planning/architecture judgment; GPT-5.5 does not support xhigh. |
| feature-agent | `openai-codex/gpt-5.3-codex` | high | Strong default for agentic implementation work. |
| reviewer | `openai-codex/gpt-5.5` | high | GPT-5.5 is strongest for complex coding/review, but does not support xhigh. |

## Workstream tier mapping

| Workstream tier/type | First attempt | Thinking | Retry/escalation |
|---|---|---:|---|
| Broad planning / huge artifact scan | `opencode-go/deepseek-v4-pro` | xhigh | same or `openai-codex/gpt-5.5:high` for critique |
| Plan critique / architecture sanity check | `openai-codex/gpt-5.5` | high | same |
| Foundation scaffold | `openai-codex/gpt-5.5` | high | same |
| Database/schema/sync/auth/routing | `openai-codex/gpt-5.5` | high | same |
| Complex feature | `openai-codex/gpt-5.5` or `openai-codex/gpt-5.3-codex` | high | `openai-codex/gpt-5.5:high` |
| Medium feature | `openai-codex/gpt-5.3-codex` | high | `openai-codex/gpt-5.5:high` |
| Simple widget/constants/docs | `opencode-go/deepseek-v4-flash` or `openai-codex/gpt-5.4-mini` | high | `openai-codex/gpt-5.3-codex:high` |
| Integration/E2E tests | `openai-codex/gpt-5.3-codex` | high | `openai-codex/gpt-5.5:high` |
| Visual/mockup review | `openai-codex/gpt-5.5` | high | same |
| Final review | `openai-codex/gpt-5.5` | high | optional second opinion with `opencode-go/deepseek-v4-pro:xhigh` for huge context |
| Huge codebase consistency scan | `opencode-go/deepseek-v4-pro` | xhigh | same |

## Concrete usage examples

```text
Planner broad scan:       opencode-go/deepseek-v4-pro:xhigh
Feature default:          openai-codex/gpt-5.3-codex:high
Foundation feature:       openai-codex/gpt-5.5:high
Reviewer:                 openai-codex/gpt-5.5:high
Simple task:              opencode-go/deepseek-v4-flash:high
Huge-context review pass: opencode-go/deepseek-v4-pro:xhigh
```

## Why not always use GPT-5.5?

Use `gpt-5.5` for correctness-critical implementation and review. But OpenCode Go remains valuable because:

- `deepseek-v4-pro` has very large context in Pi and supports `xhigh`.
- `deepseek-v4-flash` is excellent for high-volume simple tasks.
- Broad planning over specs, generated artifacts, and many files can exceed Codex's practical context budget. In those cases, the orchestrator can override the planner to `opencode-go/deepseek-v4-pro:xhigh` for a huge-context scan or second pass.

## Operational notes

- Run `/models` in Pi before a major project to confirm exact model names and supported thinking.
- If a selected model rejects a thinking level, retry with the highest supported level from the compatibility table above.
- Prefer explicit model strings in orchestrator dispatch for high-risk workstreams.
