# New Project Guide — Build a Flutter Android App with the Custom Harness

> Step-by-step procedure for using this harness to create a new Flutter-based Android app from specs and mockups.
>
> Goal: project-agnostic, reliability-first, autonomous execution with plan approval, deterministic design-token extraction, native `pi-subagents` acceptance contracts, visual validation, golden baselines, architecture checks, review, and final build gates.

---

## 0. What this harness expects

For best results, prepare these inputs before starting:

| Input | Required? | Notes |
|---|---:|---|
| Product/spec document | Yes | Functional requirements, user flows, edge cases, data model expectations |
| UI mockups | Strongly recommended | Stitch export preferred: each screen folder should contain `screen.png` + `code.html` |
| Design system notes | Optional | Human design doc; Stitch HTML remains the visual source of truth |
| Target app folder | Yes | Can be empty; harness can scaffold Flutter app after approval |
| Android package ID | For Android build/smoke | Example: `com.example.myapp` |
| Model configuration | Yes | Concrete model IDs must exist on the target machine (`pi --list-models`) |
| Git repo | Yes | Harness uses git + `docs/state.json` for recovery/resume |

---

## 1. Create or choose the target project folder

Create a fresh project folder anywhere outside this harness repo:

```bash
mkdir -p ~/Development/Projects/my_flutter_app
cd ~/Development/Projects/my_flutter_app
```

If you already have a project, use that folder instead.

Initialize git if it is not already initialized:

```bash
git init
```

The orchestrator can also initialize git during Phase 0, but doing it up front is cleaner.

---

## 2. Install the harness into the target project

From the target project directory:

```bash
bash /path/to/custom-harness/install.sh
```

Example:

```bash
cd ~/Development/Projects/my_flutter_app
bash ~/Development/Projects/pi-workspace/research/custom-harness/install.sh
```

After install, the target project should contain:

```text
.pi/
  agents/
  skills/
  tools/
    extract_design_tokens.js
    arch_check.sh
    golden_check.sh
  settings.json
AGENTS.md
FRAMEWORK.md
MODEL_STRATEGY.md
STITCH_PIPELINE.md
design-tokens-schema.md
```

Run a quick check:

```bash
ls .pi/agents .pi/skills .pi/tools
```

---

## 3. Add project inputs

Recommended target layout:

```text
my_flutter_app/
├── docs/
│   ├── SPEC.md
│   ├── user-stories.md                 # optional
│   ├── design.md                       # optional
│   └── design_tokens.json              # generated in Phase 0
├── design-assets/
│   └── Stitch-Mockup/
│       ├── 01-welcome/
│       │   ├── screen.png
│       │   └── code.html
│       ├── 02-home/
│       │   ├── screen.png
│       │   └── code.html
│       └── ...
└── app/                                # Flutter app dir, can be created by harness
```

If you do not have Stitch mockups, you can still run the harness, but visual validation and design-token extraction will be weaker.

---

## 4. Configure `AGENTS.md`

Open the installed `AGENTS.md` in the target project and fill in all required values.

Minimum required fields:

```markdown
## Project Identity
| Project name | My Flutter App |
| App type | Flutter app |
| Primary platform | Android |
| Package/application id | com.example.myapp |
| Organization for `flutter create --org` | com.example |

## Project Paths
| Product spec | docs/SPEC.md |
| Mockups/screenshots | design-assets/Stitch-Mockup/ |
| Design tokens (JSON) | docs/design_tokens.json |
| Stitch HTML mockups | design-assets/Stitch-Mockup/ |
| Flutter app directory | app/ |
| Plan output | docs/plan.md |
| Review output | docs/review.md |
| Integration test directory | app/integration_test/ |
| Golden test source | app/test_goldens/ |
| Golden test images | app/test/goldens/ |
| Architecture decision log | docs/ARCHITECTURE_LOG.md |
| Orchestrator state file | docs/state.json |
| Harness tools directory | .pi/tools/ |
```

Also confirm:

- state management choice (Riverpod / Bloc / Provider / etc.)
- routing package (for example, `go_router`)
- persistence/API packages
- test strategy
- autonomy mode (`Enabled` or `Disabled`)

---

## 5. Configure concrete model IDs

The harness is model-agnostic. It uses capability tiers, but the target project must map those tiers to real model IDs available on your machine.

List models:

```bash
pi --list-models
```

Then edit `.pi/settings.json` in the target project. Example shape:

```json
{
  "packages": [
    "npm:pi-ask-user",
    "npm:@plannotator/pi-extension",
    "npm:intercom",
    "npm:pi-intercom",
    "npm:pi-subagents"
  ],
  "subagents": {
    "agentOverrides": {
      "planner": {
        "model": "[planner-tier-model-id]",
        "thinking": "high"
      },
      "feature-agent": {
        "model": "[logic-tier-model-id]",
        "thinking": "xhigh",
        "fallbackModels": ["[mechanical-tier-model-id]"]
      },
      "visual-validator": {
        "model": "[ui-vision-tier-model-id]",
        "thinking": "high"
      },
      "architect": {
        "model": "[mechanical-tier-model-id]",
        "thinking": "high"
      },
      "reviewer": {
        "model": "[review-tier-model-id]",
        "thinking": "high"
      }
    }
  }
}
```

Important:

- `visual-validator` and UI-critical feature work need a **vision-capable** model.
- Use exact IDs from `pi --list-models`.
- If unsure, start Pi and use:

```text
subagent({ action: "list" })
```

to confirm discovered agent names.

---

## 6. Optional preflight checks

Run these before starting Pi:

```bash
flutter doctor -v
node .pi/tools/extract_design_tokens.js design-assets/Stitch-Mockup/ docs/design_tokens.json
bash .pi/tools/arch_check.sh app before_workstream PRE docs/design_tokens.json docs/ARCHITECTURE_LOG.md
```

If the Flutter app does not exist yet, the `arch_check.sh` command can wait until after scaffolding.

---

## 7. Start Pi and launch the orchestrator

From the target project root:

```bash
pi
```

In Pi:

```text
/name orchestrator
```

Then send a start prompt like:

```text
Orchestrator, begin Phase 0 for this project.

Runtime inputs:
- Priority: reliability/quality first
- App type: Flutter Android app
- Spec: docs/SPEC.md
- App directory: app/
- Mockups: design-assets/Stitch-Mockup/ (contains screen.png + code.html per screen)
- Design tokens: docs/design_tokens.json (auto-extract if missing/stale)
- Plan output: docs/plan.md
- Review output: docs/review.md
- Golden test source: app/test_goldens/
- Golden test images: app/test/goldens/
- Architecture log: docs/ARCHITECTURE_LOG.md
- State file: docs/state.json
- Harness tools: .pi/tools/
- Package id: com.example.myapp
- Visual validation: enabled
- Max visual iterations: 3
- Autonomy mode: enabled
Ask me only for missing high-risk decisions.
```

---

## 8. Phase 0 — environment, scaffold, design tokens

The orchestrator should:

1. Resolve runtime config from `AGENTS.md` and the start prompt.
2. Run `flutter doctor -v`.
3. Initialize git if needed.
4. Create or verify `docs/state.json`.
5. Scaffold the Flutter app if `app/pubspec.yaml` does not exist and you approve/default it.
6. Run deterministic design-token extraction:

```bash
node .pi/tools/extract_design_tokens.js design-assets/Stitch-Mockup/ docs/design_tokens.json
```

7. Run initial gates:

```bash
cd app
flutter pub get
flutter analyze
flutter test
```

If this phase fails, fix toolchain/config issues before continuing.

---

## 9. Phase 1 — planner creates implementation plan

The planner reads:

- `AGENTS.md`
- product spec
- mockups/design tokens
- existing code
- architecture log (if any)

It writes `docs/plan.md` with:

- workstreams in dependency order
- UI-critical annotations
- design-token references
- exact files to create/modify
- tests expected
- native `pi-subagents` acceptance contracts per workstream
- Spec → Test Traceability Matrix

Review the plan carefully. In autonomy mode, you can allow the orchestrator to proceed after plan sanity checks; otherwise explicitly approve.

---

## 10. Phase 2 — implementation workstreams

For each workstream, the orchestrator should:

1. Run deterministic architecture scan:

```bash
bash .pi/tools/arch_check.sh app before_workstream Wxx docs/design_tokens.json docs/ARCHITECTURE_LOG.md
```

2. Dispatch `feature-agent` with:
   - scoped `reads`
   - concrete model resolved from `.pi/settings.json`
   - native `acceptance` contract
   - `output: file-only` where appropriate

3. Feature-agent implements only that workstream and must satisfy the acceptance contract.

4. For UI-critical workstreams:
   - generate/update golden tests
   - run deterministic golden pre-filter:

```bash
bash .pi/tools/golden_check.sh app app/test_goldens/<screen>_golden_test.dart
```

   - if needed, visual-validator performs semantic diff against Stitch `screen.png`
   - feature-agent applies only discrepancy-report fixes
   - final accepted golden is committed as baseline

5. Run post-workstream architecture scan.
6. Update `docs/state.json`.
7. Commit successful workstream.

---

## 11. Phase 3 — reviewer gate

Reviewer checks:

- spec coverage
- plan compliance
- acceptance contract evidence
- Spec → Test Traceability Matrix
- golden coverage
- design-token compliance
- architecture log consistency
- tests and integration/E2E coverage

Expected output: `docs/review.md`.

Verdicts:

- `APPROVE` → final quality gate
- `NEEDS FIXES` → orchestrator dispatches scoped repair workstreams

---

## 12. Phase 4 — final quality gate

Run project-specific commands. Flutter Android default:

```bash
cd app
flutter pub get
# if code generation is configured:
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter test test_goldens/
flutter test integration_test/   # if tests exist / emulator configured
flutter build apk --debug
```

Optional device smoke:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.example.myapp/.MainActivity
```

Do not declare success if required gates fail or are skipped without an explicit reason recorded in `docs/review.md`.

---

## 13. Resume / recovery

The source of truth is:

- `docs/state.json`
- git commits
- native `pi-subagents` run IDs

If a session stops:

1. Restart Pi in the target project.
2. Start orchestrator.
3. Ask:

```text
Resume from docs/state.json. Check subagent status and continue from the first non-passed workstream.
```

The orchestrator should use:

```text
subagent({ action: "status" })
subagent({ action: "resume", id: "<runId>" })
```

when applicable.

---

## 14. Common pitfalls

| Problem | Fix |
|---|---|
| Model dispatch fails | Run `pi --list-models`; update `.pi/settings.json` `subagents.agentOverrides` |
| Visual validator cannot compare images | Use a vision-capable model for `visual-validator` / `ui-vision-tier` |
| Design tokens missing | Run `.pi/tools/extract_design_tokens.js` manually and inspect warnings |
| Golden tests flaky | Load fonts/icons with `FontLoader`; set fixed viewport/devicePixelRatio; stub network images |
| Integration tests cannot run | Configure Android emulator/device; mark integration verify with `allowFailure: true` only until emulator is available |
| Agent edits too much | Ensure workstream file list is exact and acceptance `stopRules` include no scope creep |
| Resume unclear | Inspect `docs/state.json`, git log, and `subagent({ action: "status" })` |

---

## 15. Minimal checklist

Before starting implementation, confirm:

- [ ] `AGENTS.md` filled in
- [ ] `.pi/settings.json` model overrides use real model IDs
- [ ] `flutter doctor -v` passes for Android
- [ ] spec is present
- [ ] mockups are present, if visual fidelity is required
- [ ] `docs/design_tokens.json` generated
- [ ] `docs/plan.md` approved
- [ ] every workstream has an acceptance contract
- [ ] Spec → Test Traceability Matrix has no gaps
- [ ] git repo is initialized

Once all are checked, let the orchestrator proceed through workstreams.
