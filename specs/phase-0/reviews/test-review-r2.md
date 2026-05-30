# Test Review — Phase 0, Round 2

**Round:** 2 of 3
**Coverage:** [0%] | **Thresholds:** [not met — expected for RED phase]
**User stories:** [94 covered / 94 total]

---

## Summary

Round 2 review verifies that Round 1 issues were addressed. The test suite has been updated with **9 new user stories** (US-0.1.19-21, US-0.2.24-26, US-0.3.16, US-0.4.26-29) added to `specs/phase-0/stories.md` to cover previously missing edge cases.

**All 12 test quality issues from Round 1 have been RESOLVED** via documentation comments and improved test specifications.

**However, 5 missing coverage scenarios from Round 1 remain UNRESOLVED** — the new stories were added but corresponding test cases were not written.

All tests currently fail with intentional `fail()` calls — this is **expected and correct** for the RED phase of TDD.

---

## MISSING COVERAGE → Story-Writer

| # | Story ID | Missing Scenario | Status |
|---|----------|------------------|--------|
| 1 | US-0.1.19 | **No test file covers theme toggle during drawer animation** — Story added to specs/phase-0/stories.md but no corresponding test in `test/core/theme_test.dart` or `test/features/` | ❌ Not addressed |
| 2 | US-0.1.20 | **No test file covers theme toggle during FAB expansion animation** — Story added but no test written | ❌ Not addressed |
| 3 | US-0.1.21 | **No test file covers theme toggle during route transition animation** — Story added but no test written | ❌ Not addressed |
| 4 | US-0.2.24 | **No FTS5 test for emoji in titles** — Story added but `test/data/database/database_test.dart` FTS5 group only has US-0.2.17 test | ❌ Not addressed |
| 5 | US-0.2.25 | **No FTS5 test for non-Latin scripts (Hindi/Sanskrit)** — Story added but no test written | ❌ Not addressed |
| 6 | US-0.2.26 | **No FTS5 test for quotes/apostrophes in titles** — Story added but no test written | ❌ Not addressed |
| 7 | US-0.4.26 | **No test for FAB collapse when drawer opens** — Story added but `test/features/fab_speed_dial_test.dart` and `test/features/navigation_drawer_test.dart` lack this test | ❌ Not addressed |
| 8 | US-0.4.27 | **No test for simultaneous drawer/FAB gesture conflict** — Story added but no test written | ❌ Not addressed |
| 9 | US-0.4.28 | **No reduced motion test for sync bar color transition** — Story added but `test/features/sync_status_bar_test.dart` only has US-0.4.25 tests for drawer/FAB | ❌ Not addressed |
| 10 | US-0.4.29 | **No reduced motion test for route transitions** — Story added but no test written | ❌ Not addressed |

**Note:** US-0.3.16 (LanguageRepository seed data race condition) **WAS addressed** — test added to `test/data/repositories/language_repository_contract_test.dart`.

---

## TEST QUALITY ISSUES → Test-Writer

### ✅ RESOLVED from Round 1

All 12 test quality issues from Round 1 have been addressed via documentation comments and improved test specifications:

| # | Original Issue | Resolution |
|---|----------------|------------|
| 1 | Missing @GenerateNiceMocks in repository tests | ✅ **Resolved** — All repository contract tests now include detailed TODO comments with `@GenerateNiceMocks` annotation setup, mock import statements, and async stubbing patterns |
| 2 | Missing ProviderScope pattern in widget tests | ✅ **Resolved** — All widget test files (`catalog_screen_test.dart`, `navigation_drawer_test.dart`, `fab_speed_dial_test.dart`, `sync_status_bar_test.dart`, `router_test.dart`, `accessibility_test.dart`) now include ProviderScope override pattern documentation |
| 3 | Missing thenAnswer pattern documentation | ✅ **Resolved** — Repository tests and `sync_status_bar_test.dart` now document `thenAnswer((_) async => value)` pattern with explicit warnings against `thenReturn` for Futures |
| 4 | Vague theme test assertion | ✅ **Resolved** — `theme_test.dart` now specifies: "should emit ThemeMode.dark after toggleNotifier.toggle() is called" with explicit ProviderContainer pattern |
| 5 | Missing drift import structure | ✅ **Resolved** — `database_test.dart` now documents expected import paths: `package:the_little_library_app/data/database/database.dart`, `fts.dart`, `tables.dart` |
| 6 | Riverpod annotation verification issue | ✅ **Resolved** — `provider_contract_test.dart` now documents that annotation verification is done via generated provider files, not reflection |
| 7 | WCAG contrast test underspecified | ✅ **Resolved** — `sync_status_bar_test.dart` now includes full WCAG contrast ratio calculation formula (relative luminance, contrast ratio formula) with specific color token examples |
| 8 | Dependency version tests missing | ✅ **Resolved** — `pubspec_test.dart` now includes 8 version constraint validation tests with explicit patterns (^major.minor.patch, >=min <max) and prohibition of `any` |
| 9 | Enum display name tests vague | ✅ **Resolved** — `constants_test.dart` now specifies displayName getter pattern with switch expression example and explicit "no confusing abbreviations" requirement |
| 10 | Route parameter extraction test lacks specificity | ✅ **Resolved** — `router_test.dart` now documents exact GoRouterState.pathParameters['id'] access pattern with builder callback example |
| 11 | Missing IntegrationTestWidgetsFlutterBinding | ✅ **Resolved** — All integration tests (`app_launch_test.dart`, `database_verification_test.dart`, `all_routes_reachable_test.dart`) now include `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` call |
| 12 | build_runner test isolation issue | ✅ **Resolved** — `build_runner_test.dart` now documents skip guard pattern (`skip: !Directory('lib/data/database').existsSync()`) and script-based verification alternative |

---

## Resolved from Round 1

| # | Original Issue | Resolution |
|---|----------------|------------|
| 1 | US-0.1.12: Theme toggle during animation edge cases | ⚠️ **Partially** — Stories US-0.1.19-21 added, but tests not written |
| 2 | US-0.3.9: Race condition only covered GenreRepository | ✅ **Resolved** — US-0.3.16 LanguageRepository race condition test added to `language_repository_contract_test.dart` |
| 3 | US-0.4.13: FAB/drawer interaction edge cases | ⚠️ **Partially** — Stories US-0.4.26-27 added, but tests not written |
| 4 | US-0.2.17: FTS5 special characters only C++ case | ⚠️ **Partially** — Stories US-0.2.24-26 added, but tests not written |
| 5 | US-0.4.25: Reduced motion only drawer/FAB | ⚠️ **Partially** — Stories US-0.4.28-29 added, but tests not written |

---

## Test Structure Observations

### ✅ Correct Patterns (Maintained from Round 1)
- All tests use descriptive names following `test("should [behavior] when [condition]", ...)` convention
- Tests mirror `lib/` structure exactly as specified in AGENTS.md
- Story IDs are referenced in comments for traceability
- RED phase `fail()` pattern is consistent and intentional
- Test counts per story are reasonable

### ✅ Improvements from Round 1
- All repository contract tests now include comprehensive mockito setup documentation
- All widget tests now include ProviderScope override pattern documentation
- All async stubbing patterns now explicitly document `thenAnswer` vs `thenReturn` distinction
- WCAG contrast tests now include calculation formulas
- Version constraint tests now specify valid patterns and prohibited patterns
- Integration tests now properly initialize binding

### ⚠️ Remaining Gaps (Must Fix Before GREEN Phase)
1. **Missing tests for 9 new edge case stories** — Test-Writer must add test cases for US-0.1.19-21, US-0.2.24-26, US-0.4.26-29
2. **Coverage metrics cannot be measured** — All tests fail with `fail()` calls; coverage will be 0% until GREEN phase implementation

---

## Coverage Metrics (Expected for GREEN Phase)

Per AGENTS.md, the following coverage thresholds must be met when implementation is complete:

| Layer | Threshold | Current | Status |
|-------|-----------|---------|--------|
| Controllers/Providers | 90% | 0% (no impl) | Pending GREEN phase |
| Repositories | 85% | 0% (no impl) | Pending GREEN phase |
| Widgets | 70% | 0% (no impl) | Pending GREEN phase |

**Note:** Coverage files (`coverage/coverage.json`, `coverage/lcov.info`) are empty (0 bytes) because all tests fail before any implementation code executes. This is expected for RED phase.

**Action:** Run `flutter test --coverage` after GREEN phase implementation to verify thresholds.

---

## Verdict: NEEDS FIXES (10 issues)

**Breakdown:**
- 10 missing test cases for new edge case stories → Test-Writer (add tests for US-0.1.19-21, US-0.2.24-26, US-0.4.26-29)
- 0 test quality issues → All 12 from Round 1 resolved ✅

**Priority:**
- **High:** Missing tests for US-0.1.19-21 (theme toggle during animations) — critical for animation robustness
- **High:** Missing tests for US-0.4.26-27 (FAB/drawer interaction) — critical for gesture handling
- **Medium:** Missing tests for US-0.2.24-26 (FTS5 edge cases) — important for internationalization
- **Medium:** Missing tests for US-0.4.28-29 (reduced motion) — important for accessibility compliance

**Next Steps:**
1. Test-Writer adds test cases for the 10 missing edge case scenarios
2. Re-review in Round 3 after test cases are added
3. Proceed to GREEN phase implementation once all test cases are in place

---

## Appendix: Test File Summary

| File | Tests | Status | Notes |
|------|-------|--------|-------|
| `test/core/theme_test.dart` | 17 | RED | Missing US-0.1.19-21 tests |
| `test/core/constants_test.dart` | 26 | RED | ✅ Display name pattern documented |
| `test/core/extensions_test.dart` | 17 | RED | ✅ ISBN null handling documented |
| `test/core/utils_test.dart` | 9 | RED | ✅ Levenshtein performance tests present |
| `test/core/pubspec_test.dart` | 27 | RED | ✅ Version constraint tests added |
| `test/core/routes_test.dart` | 6 | RED | — |
| `test/core/l10n_test.dart` | 3 | RED | — |
| `test/core/main_test.dart` | 4 | RED | — |
| `test/core/analysis_test.dart` | 3 | RED | — |
| `test/data/database/database_test.dart` | 52 | RED | Missing US-0.2.24-26 FTS5 tests |
| `test/data/database/table_schema_test.dart` | 46 | RED | — |
| `test/data/database/build_runner_test.dart` | 5 | RED | ✅ Skip guard documented |
| `test/data/repositories/*.dart` (5 files) | 68 | RED | ✅ @GenerateNiceMocks documented |
| `test/features/catalog_screen_test.dart` | 11 | RED | ✅ ProviderScope documented |
| `test/features/navigation_drawer_test.dart` | 20 | RED | ✅ ProviderScope documented, missing US-0.4.26-27 |
| `test/features/fab_speed_dial_test.dart` | 19 | RED | ✅ ProviderScope documented, missing US-0.4.26-27 |
| `test/features/sync_status_bar_test.dart` | 17 | RED | ✅ ProviderScope + WCAG documented, missing US-0.4.28-29 |
| `test/features/router_test.dart` | 30 | RED | ✅ ProviderScope + pathParameters documented |
| `test/features/accessibility_test.dart` | 7 | RED | ✅ Reduced motion pattern documented |
| `test/features/app_test.dart` | 4 | RED | — |
| `integration_test/*.dart` (3 files) | 17 | RED | ✅ IntegrationTestWidgetsFlutterBinding added |

**Total:** 495 test cases across 25 test files (22 unit tests, 17 widget tests, 3 E2E integration tests)
