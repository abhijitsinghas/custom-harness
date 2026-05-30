# AGENTS.md — The Little Library v2

> **Flutter Android app** for cataloging a home library (~10–12 cupboards/bookshelves).
> Spec: `docs/spec-v2.md` | Plan: `docs/implementation-plan.md` | Mockups: `docs/The-Little-Library---Proto-2/`
> **App code lives in:** `the_little_library_app/` — Flutter project subdirectory of this workspace
> **Package:** `com.abhijits.thelittlelibrary`

## Pipeline Configuration

```yaml
orchestrator:
  pipeline: 3-agent      # planner → feature-agent × N → reviewer

planning:
  max_rounds: 2          # Self-critique rounds for planner (optional, 1-2 max)

review:
  max_rounds: 2          # Max feedback rounds per reviewer
```

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Flutter (Android primary, iOS-compatible) | 3.x |
| State Management | Riverpod (`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`) | 2.x |
| Local Database | drift (SQLite) + FTS5 | 2.x |
| OCR | google_mlkit_text_recognition | latest |
| Barcode | google_mlkit_barcode_scanning | latest |
| HTTP | `http` package | latest |
| Google APIs | googleapis + google_sign_in | latest |
| Image Capture | image_picker | latest |
| STT | speech_to_text | latest |
| Routing | go_router | latest |
| Auth | google_sign_in | latest |
| Testing | `flutter_test`, `package:test`, mockito, build_runner | — |
| Linting | flutter_lints (recommended) | — |
| Coverage | `coverage` package | latest |

---

## Architecture (Enforced)

### Layered Architecture — MVVM + Repository Pattern

```
v2/                              ← orchestrator workspace (current directory)
├── AGENTS.md                    ← architecture, conventions, shared contracts
├── docs/                        ← specs, implementation plan, mockups
├── specs/                       ← task specs and roadmap
├── .pi/                         ← agent definitions, chains, skills
└── the_little_library_app/      ← Flutter project — ALL app code lives here
    ├── pubspec.yaml
    ├── lib/
    │   ├── core/               # Theme, constants, extensions, i18n (l10n/)
    │   ├── data/               # Database, API, sync, repositories
    │   └── features/           # All feature screens
    ├── test/                   # Unit + widget tests
    └── integration_test/       # Integration + E2E tests

### Separation of Concerns (NEVER violate)

- **UI Layer:** Widgets only. No business logic. No direct database access. Use `ref.watch(provider)` and `ref.read(provider.notifier)`.
- **Logic Layer:** Riverpod providers (AsyncNotifier, Notifier). Expose immutable state. Call repositories. Never import Flutter `material.dart` in providers.
- **Data Layer:** Repositories consume Services/DAOs. Return Domain Models. Handle caching, offline, retry.

### Riverpod Conventions

- Use `@riverpod` annotation + code generation (`riverpod_generator`). Never manually create providers.
- Override providers in tests with `ProviderContainer(overrides: [...])` or `ProviderScope(overrides: [...])`.
- Async state renders with `AsyncValue.when(data:, loading:, error:)`.
- No `setState` outside of truly local ephemeral widget state (e.g., text field focus, animation controller).

### Drift Conventions

- All tables extend `Table`. Columns defined as getters.
- DAOs use `@DriftAccessor` annotation.
- Run `dart run build_runner build` after every schema change.
- In tests, use in-memory SQLite: `AppDatabase.memory()`.
- Generated files (`*.g.dart`) are never edited manually.

### Model Conventions

- Generated drift data classes are the canonical models. No separate domain model layer.
- For API responses, create DTO classes with `fromJson`/`toJson` in `data/api/`.
- Repositories transform API DTOs → drift data classes.

### Testing Conventions

- **Unit tests:** `ProviderContainer()` with overrides. Use in-memory drift DB: `AppDatabase.memory()`. Mock API clients with mockito.
- **Widget tests:** `ProviderScope(overrides: [...])` wrapping `MaterialApp`.
- **Test naming:** `test("should [behavior] when [condition]", ...)`. Include story ID.

### Code Quality

- Run `dart analyze` before committing. Zero warnings, zero errors.
- Coverage targets: 90% controllers, 85% repositories, 70% widgets.

### Build & Deploy (Per Phase)

After every phase completes, build and deploy to the connected Android device:
```bash
cd the_little_library_app
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs --force-jit
flutter analyze
flutter test                    # Unit tests
flutter test integration_test/  # Integration + E2E tests
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.abhijits.thelittlelibrary/.MainActivity
```
Then run smoke tests on device to verify the app launches and key flows work.

### Test Layers (All Phases Must Cover)

| Layer | Location | Runs With | Purpose |
|-------|----------|-----------|---------|
| **Unit** | `test/` | `flutter test` | Individual functions, DAOs, providers, validators |
| **Widget** | `test/` | `flutter test` | Screen rendering, interactions, state changes |
| **Integration** | `integration_test/` | `flutter test integration_test/` | Multi-screen flows, data layer ↔ UI |
| **E2E** | `integration_test/` | `flutter test integration_test/` | Full user journeys on device |

---

## Shared Contracts (All Agents Reference These)

### Riverpod Providers

```dart
// Database
final databaseProvider = Provider<AppDatabase>((ref) => ...);

// Repositories
final bookRepoProvider = Provider<BookRepository>((ref) => ...);
final locationRepoProvider = Provider<LocationRepository>((ref) => ...);
final genreRepoProvider = Provider<GenreRepository>((ref) => ...);
final tagRepoProvider = Provider<TagRepository>((ref) => ...);
final languageRepoProvider = Provider<LanguageRepository>((ref) => ...);
final loanRepoProvider = Provider<LoanRepository>((ref) => ...);
final changeLogRepoProvider = Provider<ChangeLogRepository>((ref) => ...);

// Auth
final authStateProvider = StateProvider<AuthState>((ref) => ...);

// Sync
final syncStateProvider = StateProvider<SyncState>((ref) => ...);
```

### Route Names

```dart
'/catalog', '/book/:id', '/book/add', '/book/edit/:id',
'/scanner/barcode', '/scanner/ocr', '/voice-input',
'/locations', '/checkout/:bookId', '/loan/:bookId',
'/conflicts', '/activity', '/settings',
'/settings/genres', '/settings/tags', '/settings/languages',
'/deleted', '/active-loans', '/export',
'/share-library', '/change-history/:bookId',
'/setup', '/force-update', '/bulk-scanner'
```

### Design Tokens (from mockups)

| Token | Value |
|-------|-------|
| Primary | `#5D4037` (warm brown) |
| On Primary | `#FFFFFF` |
| Primary Container | `#EADDCF` (cream) |
| Secondary | `#FFA000` (amber) |
| Surface | `#FFF8F0` (off-white) |
| Background | `#FAFAF5` (warm grey) |
| Font | Roboto, 16sp body, 14sp secondary |
| Device target | 412×900dp frame, responsive |


---

## Key Constraints

- Never use `setState` outside local ephemeral widget state.
- Never manually create `StateNotifierProvider` or `ChangeNotifierProvider`.
- Never edit generated files (`*.g.dart`).
- Never write tests that validate implementation details — test behavior.
- Never add features not in the acceptance criteria (no gold-plating).
- Never make architecture decisions without approval.
- Always use UUID v4 for all primary keys.
- Always record change log events on every write operation.
- Always soft-delete — never physically purge records.
- Always use Material Design 3 widgets only.
- Always use the theme from `lib/core/theme.dart` — never hardcode colors.

---

## Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Offline-first | All core features work without internet |
| Performance | Book list renders smoothly with 2000+ books; search < 300ms |
| Storage | Cover images max 800px wide, JPEG quality 80% |
| Sync bandwidth | Incremental: only changed DB + new covers |
| Accessibility | Tappable targets ≥ 48px, semantic labels, sufficient contrast |
| Error handling | Graceful degradation, never crash on bad input/network/permissions |
| Data integrity | FK constraints, transactions for multi-table writes, soft deletes |
