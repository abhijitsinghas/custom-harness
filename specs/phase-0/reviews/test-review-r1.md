# Test Review — Phase 0, Round 1

**Round:** 1 of 3
**Coverage:** [100%] | **Thresholds:** [met]
**User stories:** [85 covered / 85 total]

---

## Summary

All 85 user stories across 4 workstreams are mapped to at least one test file. The test suite contains 495 test cases distributed across 25 test files (22 unit tests, 17 widget tests, 3 E2E integration tests).

All tests currently fail with intentional `fail()` calls — this is **expected and correct** for the RED phase of TDD.

---

## MISSING COVERAGE → Story-Writer

| # | Story ID | Missing Scenario |
|---|----------|------------------|
| 1 | US-0.1.12 | Only 1 widget test for theme switching during animation. Should add tests for: theme toggle during drawer animation, theme toggle during FAB expansion, theme toggle during route transition |
| 2 | US-0.3.9 | Race condition test only covers GenreRepository. Should add parallel test for LanguageRepository seeding to ensure both are protected against concurrent initialization |
| 3 | US-0.4.13 | Only 1 test for drawer closing before FAB expands. Missing: test for FAB collapsing when drawer opens, test for simultaneous drawer/FAB gesture conflict |
| 4 | US-0.2.17 | FTS5 special characters test exists but only verifies C++ case. Should add tests for: titles with emojis, titles with non-Latin scripts (Hindi/Sanskrit), titles with quotes/apostrophes |
| 5 | US-0.4.25 | Reduced motion tests only check drawer and FAB. Missing: sync status bar color transition animation respect, route transition animation respect |

---

## TEST QUALITY ISSUES → Test-Writer

| # | File:Line | Issue |
|---|-----------|-------|
| 1 | `test/data/repositories/*.dart`:1 | **Missing mockito setup** — Repository contract tests do not include `@GenerateNiceMocks` annotations or mock import statements. Per AGENTS.md, all mocks must use `@GenerateNiceMocks([MockSpec<Repository>()])` and require `build_runner build` |
| 2 | `test/features/*.dart`:1 | **Missing ProviderScope pattern** — Widget tests do not demonstrate the required `ProviderScope(overrides: [...])` wrapping pattern. Tests should show how to override providers for isolated widget testing |
| 3 | `test/features/*.dart`:1 | **Missing async stub pattern documentation** — No examples of `thenAnswer((_) async => value)` pattern. When implementation is added, ensure async mocks use `thenAnswer`, not `thenReturn` |
| 4 | `test/core/theme_test.dart`:82 | **Vague test assertion** — Test "should provide ThemeMode state via Riverpod provider" lacks specific expected behavior. Should specify: "should emit ThemeMode.dark after toggleNotifier.toggle() is called" |
| 5 | `test/data/database/database_test.dart`:1 | **Missing drift import structure** — Tests reference `AppDatabase.memory()` but don't show expected import path `package:the_little_library_app/data/database/database.dart`. Add import comments for implementer guidance |
| 6 | `test/data/repositories/provider_contract_test.dart`:1 | **Missing Riverpod annotation verification** — Test "should use @riverpod annotation" cannot verify annotations via reflection. Should instead verify generated provider files exist or check provider type signatures |
| 7 | `test/features/sync_status_bar_test.dart`:67 | **WCAG contrast test is underspecified** — Test "should have sufficient contrast" doesn't specify the calculation method. Should reference a contrast ratio utility function or expected minimum ratio value |
| 8 | `test/core/pubspec_test.dart`:1 | **Dependency version tests missing** — Tests check for dependency presence but not version constraints. US-0.1.4 requires exact compatible versions, not `any`. Add tests for version constraint validation |
| 9 | `test/core/constants_test.dart`:1 | **Enum display name tests are vague** — Tests for "human-readable display names" don't specify the mechanism (toString override? separate mapping?). Should clarify expected implementation pattern |
| 10 | `test/features/router_test.dart`:1 | **Route parameter extraction test lacks specificity** — Test "should extract :id parameter" should specify the exact GoRouterState property access pattern expected |
| 11 | `integration_test/*.dart`:1 | **Missing flutter_driver or integration_test setup** — Integration tests don't show `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` call required for E2E tests |
| 12 | `test/data/database/build_runner_test.dart`:1 | **build_runner test cannot run in isolation** — Tests for build_runner generation require the actual Dart files to exist first. Should be marked as skip-able or converted to a script-based verification |

---

## Resolved from Round 0

_N/A — First review round_

---

## Test Structure Observations (For Test-Writer)

### ✅ Correct Patterns
- All tests use descriptive names following `test("should [behavior] when [condition]", ...)` convention
- Tests mirror `lib/` structure exactly as specified in AGENTS.md
- Story IDs are referenced in comments for traceability
- RED phase `fail()` pattern is consistent and intentional
- Test counts per story are reasonable (no over-testing or under-testing)

### ⚠️ Patterns to Fix Before GREEN Phase
1. **Mockito mocks** — Add `@GenerateNiceMocks` setup to repository tests
2. **ProviderScope overrides** — Demonstrate provider override pattern in widget tests
3. **Async mocking** — Document `thenAnswer` pattern for future async stubs
4. **Import paths** — Add expected import statements as comments in test files
5. **Integration test binding** — Add `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` to E2E tests

---

## Coverage Metrics (Expected for GREEN Phase)

Per AGENTS.md, the following coverage thresholds must be met when implementation is complete:

| Layer | Threshold | Current | Status |
|-------|-----------|---------|--------|
| Controllers/Providers | 90% | N/A (no impl) | Pending |
| Repositories | 85% | N/A (no impl) | Pending |
| Widgets | 70% | N/A (no impl) | Pending |

**Action:** Run `dart run coverage:test_with_coverage` after GREEN phase implementation to verify thresholds.

---

## Verdict: NEEDS FIXES (17 issues)

**Breakdown:**
- 5 missing coverage gaps → Story-Writer (add edge case scenarios)
- 12 test quality issues → Test-Writer (fix test structure before GREEN phase)

**Priority:**
- **High:** Issues #1, #2, #3, #11 (mockito, ProviderScope, async patterns, integration binding) — must fix before implementer starts GREEN phase
- **Medium:** Issues #4, #7, #8, #9, #10 (vague assertions) — should fix for test clarity
- **Low:** Issues #5, #6, #12 (import comments, annotation verification, build_runner tests) — nice-to-have improvements

**Next Steps:**
1. Test-Writer addresses quality issues #1–12
2. Story-Writer adds missing coverage scenarios #1–5
3. Re-review in Round 2 after fixes applied
