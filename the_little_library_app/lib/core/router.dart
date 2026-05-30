import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralised route definitions for The Little Library.
///
/// All routes listed in the [shared contracts][1] are registered here.
/// Feature screens are wired in as they become available; until then every
/// route renders a lightweight placeholder.
///
/// [1]: AGENTS.md § Shared Contracts

// ── Route name constants ─────────────────────────────────────────────────────

abstract final class AppRoutes {
  AppRoutes._();

  static const catalog = 'catalog';
  static const bookDetail = 'bookDetail';
  static const addBook = 'addBook';
  static const editBook = 'editBook';
  static const barcodeScanner = 'barcodeScanner';
  static const ocrScanner = 'ocrScanner';
  static const voiceInput = 'voiceInput';
  static const locations = 'locations';
  static const checkout = 'checkout';
  static const loan = 'loan';
  static const conflicts = 'conflicts';
  static const activity = 'activity';
  static const settings = 'settings';
  static const genres = 'genres';
  static const tags = 'tags';
  static const languages = 'languages';
  static const deleted = 'deleted';
  static const activeLoans = 'activeLoans';
  static const exportData = 'exportData';
  static const shareLibrary = 'shareLibrary';
  static const changeHistory = 'changeHistory';
  static const setup = 'setup';
  static const forceUpdate = 'forceUpdate';
  static const bulkScanner = 'bulkScanner';
}

// ── Placeholder screen ───────────────────────────────────────────────────────

/// Lightweight placeholder used by routes that have not yet been wired to a
/// real feature screen.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title — coming soon',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

// ── Router ───────────────────────────────────────────────────────────────────

/// Returns a configured [GoRouter] with all application routes.
///
/// Call once during app bootstrap.  The same router instance is reused across
/// the lifetime of the app.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/catalog',
    routes: [
      // ── Catalog ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/catalog',
        name: AppRoutes.catalog,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Catalog'),
      ),

      // ── Book ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/book/add',
        name: AppRoutes.addBook,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Add Book'),
      ),
      GoRoute(
        path: '/book/edit/:id',
        name: AppRoutes.editBook,
        builder: (_, state) => _PlaceholderScreen(
          title: 'Edit Book #${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/book/:id',
        name: AppRoutes.bookDetail,
        builder: (_, state) => _PlaceholderScreen(
          title: 'Book #${state.pathParameters['id']}',
        ),
        routes: [
          GoRoute(
            path: 'change-history',
            name: AppRoutes.changeHistory,
            builder: (_, state) => _PlaceholderScreen(
              title: 'Change History #${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // ── Scanner ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/scanner/barcode',
        name: AppRoutes.barcodeScanner,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Barcode Scanner'),
      ),
      GoRoute(
        path: '/scanner/ocr',
        name: AppRoutes.ocrScanner,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'OCR Scanner'),
      ),

      // ── Voice Input ──────────────────────────────────────────────────────
      GoRoute(
        path: '/voice-input',
        name: AppRoutes.voiceInput,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Voice Input'),
      ),

      // ── Locations ────────────────────────────────────────────────────────
      GoRoute(
        path: '/locations',
        name: AppRoutes.locations,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Locations'),
      ),

      // ── Lending ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/checkout/:bookId',
        name: AppRoutes.checkout,
        builder: (_, state) => _PlaceholderScreen(
          title: 'Checkout #${state.pathParameters['bookId']}',
        ),
      ),
      GoRoute(
        path: '/loan/:bookId',
        name: AppRoutes.loan,
        builder: (_, state) => _PlaceholderScreen(
          title: 'Loan #${state.pathParameters['bookId']}',
        ),
      ),

      // ── Active Loans ─────────────────────────────────────────────────────
      GoRoute(
        path: '/active-loans',
        name: AppRoutes.activeLoans,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Active Loans'),
      ),

      // ── Deleted Books ────────────────────────────────────────────────────
      GoRoute(
        path: '/deleted',
        name: AppRoutes.deleted,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Deleted Books'),
      ),

      // ── Activity ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/activity',
        name: AppRoutes.activity,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Activity'),
      ),

      // ── Settings ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Settings'),
        routes: [
          GoRoute(
            path: 'genres',
            name: AppRoutes.genres,
            builder: (_, _) =>
                const _PlaceholderScreen(title: 'Genres'),
          ),
          GoRoute(
            path: 'tags',
            name: AppRoutes.tags,
            builder: (_, _) =>
                const _PlaceholderScreen(title: 'Tags'),
          ),
          GoRoute(
            path: 'languages',
            name: AppRoutes.languages,
            builder: (_, _) =>
                const _PlaceholderScreen(title: 'Languages'),
          ),
        ],
      ),

      // ── Sync ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/conflicts',
        name: AppRoutes.conflicts,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Conflicts'),
      ),

      // ── Export ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/export',
        name: AppRoutes.exportData,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Export'),
      ),

      // ── Share Library ────────────────────────────────────────────────────
      GoRoute(
        path: '/share-library',
        name: AppRoutes.shareLibrary,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Share Library'),
      ),

      // ── Setup ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/setup',
        name: AppRoutes.setup,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Setup'),
      ),

      // ── Force Update ─────────────────────────────────────────────────────
      GoRoute(
        path: '/force-update',
        name: AppRoutes.forceUpdate,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Force Update'),
      ),

      // ── Bulk Scanner ─────────────────────────────────────────────────────
      GoRoute(
        path: '/bulk-scanner',
        name: AppRoutes.bulkScanner,
        builder: (_, _) =>
            const _PlaceholderScreen(title: 'Bulk Scanner'),
      ),
    ],
  );
}
