import 'package:flutter_test/flutter_test.dart';

// ─── ProviderScope Pattern for Widget Tests ──────────────────────────────
// TODO(implementer): Wrap widget under test with ProviderScope for Riverpod.
// All widget tests must use this pattern for isolated testing:
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:the_little_library_app/features/catalog/catalog_screen.dart';
// import 'package:the_little_library_app/data/database/database.dart';
//
// await tester.pumpWidget(
//   ProviderScope(
//     overrides: [
//       databaseProvider.overrideWithValue(AppDatabase.memory()),
//     ],
//     child: MaterialApp(home: CatalogScreen()),
//   ),
// );
// ─────────────────────────────────────────────────────────────────────────

void main() {
  group('Catalog Screen — App Launch (US-0.4.1)', () {
    testWidgets('should display app bar with title "The Little Library"', (tester) async {
      // US-0.4.1: App Launches to Catalog Screen
      // Given the app is installed
      // When I launch it
      // Then it navigates to /catalog and displays catalog placeholder screen
      //   with app bar title "The Little Library" and hamburger menu icon
      fail('Implementation not yet created — lib/features/catalog/ missing');
    });

    testWidgets('should display hamburger menu icon in the app bar', (tester) async {
      // US-0.4.1: Matching catalog.html mockup
      fail('Implementation not yet created');
    });

    testWidgets('should navigate to /catalog route on app launch', (tester) async {
      // US-0.4.1: Initial route is /catalog
      fail('Implementation not yet created');
    });

    testWidgets('should use themed Material 3 Scaffold', (tester) async {
      // US-0.4.1: Uses theme from lib/core/theme.dart
      fail('Implementation not yet created');
    });
  });

  group('Catalog Screen — Empty State (US-0.4.18)', () {
    testWidgets('should show empty state illustration when zero books exist', (tester) async {
      // US-0.4.18: Catalog Placeholder Shows Empty Catalog State
      // Given catalog screen is displayed with zero books
      // When I look at content area
      // Then empty state: book outline icon, "Your library is empty" title,
      //   "Add your first book to get started." subtitle, three quick-action buttons
      fail('Implementation not yet created');
    });

    testWidgets('should display "Your library is empty" as title in empty state', (tester) async {
      // US-0.4.18
      fail('Implementation not yet created');
    });

    testWidgets('should display "Add your first book to get started." as subtitle', (tester) async {
      // US-0.4.18
      fail('Implementation not yet created');
    });

    testWidgets('should show "Add Manually" quick-action button in empty state', (tester) async {
      // US-0.4.18
      fail('Implementation not yet created');
    });

    testWidgets('should show "Scan Barcode" quick-action button in empty state', (tester) async {
      // US-0.4.18
      fail('Implementation not yet created');
    });

    testWidgets('should show "Scan Cover" quick-action button in empty state', (tester) async {
      // US-0.4.18
      fail('Implementation not yet created');
    });

    testWidgets('should display book outline icon in empty state', (tester) async {
      // US-0.4.18: Icon should be a book outline, matching mockup
      fail('Implementation not yet created');
    });
  });
}
