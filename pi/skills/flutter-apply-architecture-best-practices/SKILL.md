---
name: flutter-apply-architecture-best-practices
description: Apply project-agnostic Flutter architecture best practices. Defaults to layered UI/logic/data separation and can adapt to the runtime-configured state management, routing, persistence, and code generation stack.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: 2026-06-04
---

# Flutter Architecture Best Practices

Use this skill when structuring a Flutter project, adding a feature, reviewing architecture, or refactoring for scalability.

## First: read runtime config

Before recommending or changing architecture, read:

- `AGENTS.md` if present
- the assigned plan/workstream
- `pubspec.yaml`
- existing `lib/` structure
- project-specific architecture rules in the runtime prompt

Do not force Riverpod, Drift, GoRouter, or any package unless the project config/spec already selected them or the user approves the decision.

## Default architecture model

For medium/large Flutter apps, prefer layered separation:

```text
UI / Presentation
  ↓ watches/calls
Logic / State / ViewModel layer
  ↓ calls
Data / Repository / Service layer
  ↓ owns
Persistence, API clients, platform plugins
```

### UI layer

- Widgets render state and collect user input.
- No direct database/network calls from widgets.
- No business rules in build methods.
- Local `setState` only for ephemeral UI state such as focus, animation, or temporary text editing.
- Render loading, empty, error, and data states for async screens.
- Use `Theme.of(context)` and configured design tokens.
- Add semantic labels and stable keys where tests need them.

### Logic/state layer

Adapt to configured state management:

- Riverpod: providers/notifiers own feature state; widgets use `ref.watch` and `ref.read`.
- Bloc/Cubit: blocs own state transitions; widgets dispatch events and render states.
- Provider/ChangeNotifier: keep notifiers focused and testable.
- Other: follow project conventions.

Rules:

- Keep state classes immutable where practical.
- Keep state layer free of `material.dart` unless project explicitly allows UI dependencies.
- Expose behavior-oriented methods, not raw persistence details.
- Inject dependencies for testability.

### Data layer

- Repositories expose use-case-oriented APIs.
- Services/DAOs/API clients own raw persistence and network details.
- Keep external services behind interfaces/adapters when they affect determinism or future swaps.
- Handle offline, retry, caching, and error translation in data/repository layers, not widgets.

## Suggested folder layouts

Use the layout already present in the project unless it is clearly broken. Safe default:

```text
lib/
  main.dart
  app.dart
  core/ or app/          # theme, router, constants
  data/                  # database, api, repositories, sync
  domain/                # pure business rules/use cases if useful
  features/              # feature UI + state
  shared/                # reusable widgets/utilities
```

If generated artifacts already exist in a root layout, preserve them initially to avoid import churn unless the user approves a migration.

## Adding a feature: reliability-first workflow

1. Read the feature workstream and allowed files.
2. Identify dependencies and existing patterns.
3. Add/adjust data model or API DTO only if in scope.
4. Implement repository/service methods.
5. Implement state/controller/view-model.
6. Implement UI with all states.
7. Add stable test keys for planned integration/E2E journeys.
8. Write unit/widget tests.
9. Run generators if configured.
10. Run targeted tests, static analysis, then broader tests.

## Code generation rules

- Never manually edit generated files (`*.g.dart`, `*.freezed.dart`, generated mocks, etc.).
- Run the configured generator, typically:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- If generator output changes unexpectedly outside the workstream, stop and report.

## Error handling

- Convert low-level errors into user-actionable states/messages.
- UI should gracefully handle permission denial, network failure, empty data, invalid input, and unavailable platform services.
- Avoid crashes from null data, disposed controllers, or async race conditions.

## Testing obligations

- Pure business logic: unit tests.
- Repositories/services: unit tests with fakes/in-memory persistence.
- Screens/widgets: widget tests covering loading/empty/error/data and key interactions.
- Multi-screen flows: integration/E2E tests using project-approved APIs.

## Architecture decision gate

Ask the user before:

- introducing a new state-management package
- changing folder architecture
- changing persistence strategy
- altering code-generation strategy
- adding external services/auth/sync providers
- performing large migrations
