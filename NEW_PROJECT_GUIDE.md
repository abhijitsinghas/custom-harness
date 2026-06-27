# New Project Guide — Minimal Manual Setup

> Desired flow: the user creates a target directory, copies available project inputs into it
> (specs, UI mockups, existing plans, generated artifacts, etc.), and runs the harness
> installer. After that, the AI/orchestrator discovers those files, asks questions for missing
> information, writes configuration, prepares paths, generates design tokens, plans
> workstreams, and runs the reliability pipeline.

---

## User responsibilities

The user should manually do only this:

```bash
mkdir -p ~/Development/Projects/my_flutter_app
cd ~/Development/Projects/my_flutter_app

# Copy all available project inputs into this directory now.
# Examples:
#   docs/SPEC.md
#   docs/user-stories.md
#   docs/design.md
#   design-assets/Stitch-Mockup/<screen>/screen.png
#   design-assets/Stitch-Mockup/<screen>/code.html
#   existing-plan.md or docs/plan-draft.md
#   generated/ or existing source artifacts

bash /path/to/custom-harness/install.sh
```

Recommended input layout before/after install:

```text
my_flutter_app/
├── docs/
│   ├── SPEC.md                  # required, or orchestrator will ask/pause
│   ├── user-stories.md          # optional
│   ├── design.md                # optional
│   └── plan-draft.md            # optional existing plan/reference
├── design-assets/
│   └── Stitch-Mockup/
│       ├── 01-screen/
│       │   ├── screen.png
│       │   └── code.html
│       └── ...
├── generated/                   # optional generated/reference artifacts
└── app/                         # optional existing Flutter app, or created by orchestrator
```

It is OK if some inputs are missing. The orchestrator will ask for missing required values or
create placeholders when appropriate.

Then start Pi in the target project and launch onboarding:

```bash
pi
```

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

After this point, **do not manually edit `AGENTS.md`, `.pi/settings.json`, or path tables unless
the orchestrator explicitly asks you to review a proposed change.**

---

## What the orchestrator must do during onboarding

The orchestrator owns setup after installation. It should ask focused questions, collect
answers, and write the target project's runtime configuration.

### 1. Identify the project

Ask one question at a time:

1. Project name?
2. Flutter app directory name? Default: `app/`.
3. Android package/application id? Example: `com.example.myapp`.
4. Organization for `flutter create --org`? Example: `com.example`.
5. Is this a new app or existing Flutter app?

If the user does not know a value, offer safe examples and explain the impact.

### 2. Discover and collect specs, plans, and requirements

First scan the target directory for likely inputs before asking:

```text
docs/SPEC.md
SPEC.md
docs/user-stories.md
user-stories.md
docs/design.md
design.md
docs/*plan*.md
*plan*.md
generated/
```

Then ask how to handle anything missing or ambiguous:

- use an existing discovered spec file
- choose among multiple candidate spec files
- paste spec content now and write it to `docs/SPEC.md`
- create a placeholder `docs/SPEC.md` and pause until user fills/provides it

Ask similarly for optional:

- user stories
- design system notes
- existing implementation plan / draft plan
- build instructions
- generated artifacts / existing code

Do not require the user to manually edit `AGENTS.md`; write the selected paths into it.

### 3. Discover and collect mockups/design inputs

First scan for likely mockup folders:

```text
design-assets/
mockups/
ui-mockups/
*/Stitch-Mockup/
*/stitch*/
```

Ask whether UI mockups exist only after presenting discovered candidates:

- Stitch export folder with `screen.png` + `code.html`
- screenshots only
- no mockups yet

If Stitch exists, ask the user to confirm the folder path and set:

```text
Mockups/screenshots = [that path]
Stitch HTML mockups = [that path]
Design tokens (JSON) = docs/design_tokens.json
```

If only screenshots exist, enable visual validation but skip deterministic token extraction.

If no mockups exist, disable visual validation by default and note the quality tradeoff.

### 4. Resolve model configuration

The orchestrator must run or ask the user to run:

```bash
pi --list-models
```

Then ask the user to select concrete models for capability tiers, presenting available choices:

| Tier | Needed for | Requirement |
|---|---|---|
| `planner-tier` | planning | strong reasoning |
| `ui-vision-tier` | UI implementation + visual validation | vision/image-capable |
| `logic-tier` | complex code/data/state | strong coding/reasoning |
| `mechanical-tier` | checks/simple fixes/goldens | fast/cheap |
| `review-tier` | review | careful reasoning |
| `escalation-tier` | critical fallback | strongest available |

The orchestrator writes `.pi/settings.json` `subagents.agentOverrides` for the selected models.
The user should not edit model settings manually.

### 5. Confirm architecture choices

Ask for or propose defaults:

- state management: Riverpod / Bloc / Provider / other
- routing: go_router / Navigator / other
- persistence: Drift / SQLite / Hive / Isar / none
- remote API/auth: Firebase / Supabase / REST / GraphQL / none
- code generation: build_runner / riverpod_generator / json_serializable / none
- test approach: unit + widget + golden + integration/E2E

If user is unsure, propose a sensible default and ask for approval.

### 6. Write runtime config

The orchestrator writes/updates `AGENTS.md` with all collected answers.

It also creates directories as needed:

```text
docs/
design-assets/        # if needed
app/                  # if scaffolding is approved
```

And initializes:

```text
docs/state.json
docs/ARCHITECTURE_LOG.md
```

### 7. Run Phase 0 gates

The orchestrator then performs:

```bash
flutter doctor -v
git init
```

If a Flutter app does not exist, it asks for approval/defaults and runs `flutter create`.

If Stitch mockups exist, it runs deterministic extraction:

```bash
node .pi/harness-tools/extract_design_tokens.js [STITCH_MOCKUPS_PATH] docs/design_tokens.json
```

Then initial Flutter gates:

```bash
cd [app_dir]
flutter pub get
flutter analyze
flutter test
```

### 8. Plan and approval

The planner produces `docs/plan.md` with:

- dependency-ordered workstreams
- UI-critical annotations
- design-token references
- native `pi-subagents` acceptance contracts
- Spec → Test Traceability Matrix
- expected files/tests/gates

The orchestrator summarizes the plan and asks for approval before implementation unless autonomy
mode is explicitly enabled for plan approval.

### 9. Implementation pipeline

For each workstream, orchestrator runs:

1. `.pi/harness-tools/arch_check.sh` pre-check
2. `feature-agent` with native acceptance contract
3. acceptance verify commands (`flutter analyze`, targeted tests, goldens, integration tests)
4. UI-critical visual loop when needed:
   - `.pi/harness-tools/golden_check.sh`
   - visual-validator semantic diff
   - feature-agent fixes only reported discrepancies
5. `.pi/harness-tools/arch_check.sh` post-check
6. update `docs/state.json`
7. git commit

### 10. Review and final gate

Reviewer verifies:

- spec coverage
- plan compliance
- acceptance evidence
- Spec → Test Traceability Matrix
- golden coverage
- design-token compliance
- architecture log consistency
- tests and integration/E2E coverage

Final default gate:

```bash
cd [app_dir]
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if configured
flutter analyze
flutter test
flutter test test_goldens/
flutter test integration_test/                             # if configured
flutter build apk --debug
```

---

## The only prompt the user needs to remember

```text
Orchestrator, onboard this new Flutter Android project and begin Phase 0.
I have copied the available specs, mockups, plans, and artifacts into this project directory.
Discover them, ask me one question at a time for every missing or ambiguous value,
do not assume missing project details, and write AGENTS.md, .pi/settings.json,
docs/state.json, and any needed docs/config files for me.
```

---

## What not to do manually

Do **not** manually perform these unless the orchestrator asks you to review or confirm:

- edit `AGENTS.md`
- edit `.pi/settings.json`
- create `docs/state.json`
- generate `design_tokens.json`
- decide model routing by hand
- create the implementation plan by hand
- run workstreams manually
- update golden baselines manually

The harness is designed so the orchestrator asks questions, writes configuration, and records
decisions for you.
