# Model Strategy — Model-Agnostic Capability Tiers (resolved per target machine)

> The harness is **model-agnostic**. No agent hardcodes a specific model ID. Instead each
> agent role is bound to a **capability tier**, and the orchestrator resolves each tier to a
> concrete model ID **on the target machine** at Phase 0. This keeps the harness portable
> across machines, providers, and model availability.

## How model resolution works (single source of truth)

For every agent dispatch the orchestrator resolves the model in this priority order:

1. **Target project `.pi/settings.json` → `subagents.agentOverrides[<agentName>]`**
   (the native `pi-subagents` per-agent override). If present, use its `model`, `thinking`,
   and `fallbackModels`. This is the recommended way to pin models per project.
   Keys are agent names as discovered by `subagent({ action: "list" })`
   (e.g. `planner`, `feature-agent`, `visual-validator`, `architect`, `reviewer`, or the
   package-qualified `flutter-dev.<name>` — verify with `action: "list"`).
2. **Tier default** resolved from `pi --list-models` output by capability match (see tier
   table below). The orchestrator picks the first available model whose capabilities satisfy
   the tier.
3. **`ask_user`** only if both (1) and (2) fail — never guess an ID.

Thinking level is encoded as a `:level` suffix on the model string that `pi-subagents` parses
natively (e.g. `opencode-go/deepseek-v4-pro:xhigh`, `openai-codex/gpt-5.5:high`). The
orchestrator passes `model` per dispatch (the per-task `model` parameter) so routing is
dynamic per workstream, not frozen in agent frontmatter.

If a model rejects a thinking level, retry with the highest supported level shown by
`pi --list-models`. Never assign `xhigh` to a model that only supports `low/medium/high`.

## Capability tiers

| Tier | Use for | Required capability | Thinking | Agents |
|---|---|---|---|---|
| `planner-tier` | Planning, architecture judgment, spec→plan decomposition | Strong reasoning; long context | `high` | planner |
| `ui-vision-tier` | UI-critical implementation + visual mockup comparison | **Vision-capable**; strong coding | `high` | feature-agent (UI-critical), visual-validator |
| `logic-tier` | Complex non-visual logic: data, state, sync, offline, auth, DB | Strong coding; long context | `xhigh` for complex, `high` for medium | feature-agent (logic/foundation) |
| `mechanical-tier` | Fast, cheap, deterministic work: golden tests, arch scans, simple widgets, constants, docs | Fast coding model | `high` | feature-agent (simple), architect, golden-test-generator |
| `review-tier` | Deep review and precision repair against spec/plan/tests/tokens | Strong reasoning; careful | `high` | reviewer |
| `escalation-tier` | Critical milestones, data-loss risk, final review | Strongest available reasoning (vision optional) | `high` | final review / critical escalation |

## Tier → workstream routing (set by planner, enforced by orchestrator)

| Workstream tier/type | Agent tier | Visual validation | Fixer on failure | Escalation |
|---|---|---:|---|---|
| Broad planning / plan critique | planner-tier | N/A | — | same |
| UI-critical: screens/widgets | ui-vision-tier | YES (ui-vision-tier) | mechanical-tier | escalation-tier re-review |
| Foundation scaffold | logic-tier (xhigh) | No | mechanical-tier | review-tier |
| Database/schema/migration | logic-tier (xhigh) | No | review-tier | escalation-tier (data-loss risk only) |
| Sync/offline/conflicts | logic-tier (xhigh) | No | review-tier | escalation-tier |
| Auth/routing/state | logic-tier (xhigh) | No | mechanical-tier | review-tier |
| Complex logic feature | logic-tier (xhigh) | No | mechanical-tier | review-tier |
| Medium logic feature | logic-tier (high) | No | mechanical-tier | review-tier |
| Simple widget/constants/docs | mechanical-tier (high) | No | logic-tier (high) | review-tier |
| Integration/E2E tests | logic-tier (high) | No | mechanical-tier | review-tier |
| Golden test generation | mechanical-tier (high) | No | logic-tier (high) | review-tier |
| Architecture consistency scan | mechanical-tier (high) | N/A | — | — |
| Normal review | review-tier (high) | N/A | N/A | escalation-tier |
| Final review | escalation-tier (high) | N/A | N/A | same |

## Tier capability matching (for `pi --list-models` selection)

When resolving a tier default, the orchestrator matches model capabilities (from `/models`):

| Tier | Must have | Prefer |
|---|---|---|
| `planner-tier` | reasoning supported; context ≥ 128k | highest reasoning |
| `ui-vision-tier` | **vision/image input supported**; reasoning | — |
| `logic-tier` | reasoning; context ≥ 128k | high output limit |
| `mechanical-tier` | fast/cheap; any coding model | lowest cost |
| `review-tier` | reasoning; careful | — |
| `escalation-tier` | strongest reasoning | vision optional |

If no vision-capable model is available on the machine, the orchestrator must ask the user
before any UI-critical dispatch — visual validation is impossible without vision.

## Example `.pi/settings.json` (target project — edit per machine)

Concrete IDs below are **examples only**. Verify with `pi --list-models` and replace with IDs
that resolve on your machine. This is the recommended per-project pin.

```json
{
  "subagents": {
    "agentOverrides": {
      "planner":            { "model": "openai-codex/gpt-5.5",    "thinking": "high",  "fallbackModels": ["openai-codex/gpt-5.4"] },
      "feature-agent":      { "model": "opencode-go/deepseek-v4-pro", "thinking": "xhigh", "fallbackModels": ["opencode-go/deepseek-v4-flash"] },
      "visual-validator":   { "model": "openai-codex/gpt-5.5",    "thinking": "high",  "fallbackModels": [] },
      "architect":          { "model": "opencode-go/deepseek-v4-flash", "thinking": "high", "fallbackModels": [] },
      "reviewer":           { "model": "openai-codex/gpt-5.4",    "thinking": "high",  "fallbackModels": ["openai-codex/gpt-5.5"] }
    }
  }
}
```

> Note: for UI-critical workstreams the orchestrator overrides the feature-agent's default with
> a `ui-vision-tier` model per dispatch (see routing table). So `feature-agent`'s override
> above is the *logic-tier* default; the orchestrator passes the vision model explicitly for
> UI-critical dispatches.

## Failure escalation ladders

```text
Logic failure:
  Attempt 1: logic-tier (xhigh/high)
  → mechanical-tier fix attempt
  → repeated failure: review-tier
  → critical (data-loss/auth/boot-blocker/release-gate): escalation-tier

Visual failure (discrepancies not resolved):
  Attempts 1..N (default 3): ui-vision-tier feature-agent + ui-vision-tier visual-validator loop
  → max iterations reached: present to user (autonomy mode may auto-accept minor diffs — see AGENTS.md)

Architecture check failure:
  WARN: log to state.json, continue
  FAIL: block pipeline, apply autonomy-mode recovery before asking user
```

Critical repeated failure means: data loss risk, unsafe DB migration, broken sync/conflict
resolution, auth/session security issue, routing loop or app boot blocker, duplicate-detector
correctness suspect, scan/OCR architecture unstable, or final release gate failure after
review-tier repair.

## Operational notes

- Run `pi --list-models` at Phase 0 and cache the result for the session.
- The orchestrator passes `model` (and `acceptance`, `context`, `output`, `reads`) per
  `subagent()` dispatch — do not rely on agent frontmatter to carry the model.
- If a selected model rejects a thinking level, retry with the highest supported level from
  `/models`.
- Do not assign `xhigh` to a model that does not support it.
- UI-critical work requires a vision-capable model. Do not route screens/widgets to a
  non-vision model.
- Golden test generation and architecture scans are mechanical — use the mechanical-tier for
  cost efficiency.
- Do not use models outside the resolved set unless the user explicitly overrides via
  `subagents.agentOverrides`.
