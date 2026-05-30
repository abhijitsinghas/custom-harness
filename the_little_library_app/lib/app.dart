import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';

// Feature screen imports
import 'features/setup/setup_screen.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/book_detail/book_detail_screen.dart';
import 'features/add_book/add_book_screen.dart';
import 'features/scanner/barcode/barcode_scanner_screen.dart';
import 'features/scanner/ocr/photo_ocr_screen.dart';
import 'features/voice_input/voice_input_screen.dart';
import 'features/locations/locations_screen.dart';
import 'features/lending/checkout_screen.dart';
import 'features/lending/loan_screen.dart';
import 'features/lending/active_loans_screen.dart';
import 'features/sync_ui/conflict_resolver_screen.dart';
import 'features/activity/activity_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/management/genres_screen.dart';
import 'features/settings/management/tags_screen.dart';
import 'features/settings/management/languages_screen.dart';
import 'features/deleted/deleted_books_screen.dart';
import 'features/settings/export_screen.dart';
import 'features/settings/share_library_screen.dart';
import 'features/change_history/change_history_screen.dart';
import 'features/force_update/force_update_screen.dart';
import 'features/bulk_scan/bulk_scanner_screen.dart';

/// Builds the [GoRouter] with all 24 routes registered.
/// US-0.4.9: All routes reachable from navigation.
///
/// Memoized via [appRouter] to avoid recreating on every widget rebuild.
GoRouter _buildAppRouter() {
  return GoRouter(
    initialLocation: kRouteCatalog,
    redirect: (context, state) {
      // Redirect root path to catalog
      if (state.matchedLocation == '/') {
        return kRouteCatalog;
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('404 — Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(kRouteCatalog),
              child: const Text('Go to Catalog'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // ── Catalog ──
      GoRoute(
        path: kRouteCatalog,
        builder: (_, __) => const CatalogScreen(),
      ),

      // ── Book ──
      GoRoute(
        path: kRouteBookDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: kRouteBookAdd,
        builder: (_, __) => const AddBookScreen(),
      ),
      GoRoute(
        path: kRouteBookEdit,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return AddBookScreen(editBookId: id);
        },
      ),

      // ── Scanner ──
      GoRoute(
        path: kRouteScannerBarcode,
        builder: (_, __) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: kRouteScannerOcr,
        builder: (_, __) => const PhotoOcrScreen(),
      ),

      // ── Voice ──
      GoRoute(
        path: kRouteVoiceInput,
        builder: (_, __) => const VoiceInputScreen(),
      ),

      // ── Locations ──
      GoRoute(
        path: kRouteLocations,
        builder: (_, __) => const LocationsScreen(),
      ),

      // ── Lending ──
      GoRoute(
        path: kRouteCheckout,
        builder: (_, state) {
          final bookId = state.pathParameters['bookId'] ?? '';
          return CheckoutScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: kRouteLoan,
        builder: (_, state) {
          final bookId = state.pathParameters['bookId'] ?? '';
          return LoanScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: kRouteActiveLoans,
        builder: (_, __) => const ActiveLoansScreen(),
      ),

      // ── Sync ──
      GoRoute(
        path: kRouteConflicts,
        builder: (_, __) => const ConflictResolverScreen(),
      ),

      // ── Activity ──
      GoRoute(
        path: kRouteActivity,
        builder: (_, __) => const ActivityScreen(),
      ),

      // ── Settings ──
      GoRoute(
        path: kRouteSettings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: kRouteSettingsGenres,
        builder: (_, __) => const GenresScreen(),
      ),
      GoRoute(
        path: kRouteSettingsTags,
        builder: (_, __) => const TagsScreen(),
      ),
      GoRoute(
        path: kRouteSettingsLanguages,
        builder: (_, __) => const LanguagesScreen(),
      ),
      GoRoute(
        path: kRouteExport,
        builder: (_, __) => const ExportScreen(),
      ),
      GoRoute(
        path: kRouteShareLibrary,
        builder: (_, __) => const ShareLibraryScreen(),
      ),

      // ── Deleted ──
      GoRoute(
        path: kRouteDeleted,
        builder: (_, __) => const DeletedBooksScreen(),
      ),

      // ── Change History ──
      GoRoute(
        path: kRouteChangeHistory,
        builder: (_, state) {
          final bookId = state.pathParameters['bookId'] ?? '';
          return ChangeHistoryScreen(bookId: bookId);
        },
      ),

      // ── Setup ──
      GoRoute(
        path: kRouteSetup,
        builder: (_, __) => const SetupScreen(),
      ),

      // ── Force Update ──
      GoRoute(
        path: kRouteForceUpdate,
        builder: (_, __) => const ForceUpdateScreen(),
      ),

      // ── Bulk Scanner ──
      GoRoute(
        path: kRouteBulkScanner,
        builder: (_, __) => const BulkScannerScreen(),
      ),
    ],
  );
}

/// Memoized [GoRouter] instance to avoid recreating on every rebuild.
final GoRouter appRouter = _buildAppRouter();

/// Root widget for The Little Library app.
/// Wraps [MaterialApp.router] with localization and theme support.
class LittleLibraryApp extends ConsumerWidget {
  const LittleLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'The Little Library',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
