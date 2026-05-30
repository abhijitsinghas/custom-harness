import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:the_little_library_app/core/router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = buildRouter();
  });

  group('Router construction', () {
    test('builds a GoRouter instance', () {
      expect(router, isA<GoRouter>());
    });
  });

  group('Top-level route paths', () {
    test('all expected paths are registered', () {
      final paths = <String>{};
      for (final route in router.configuration.routes) {
        if (route is GoRoute) {
          paths.add(route.path);
        }
      }

      expect(paths.contains('/catalog'), isTrue);
      expect(paths.contains('/book/:id'), isTrue);
      expect(paths.contains('/book/add'), isTrue);
      expect(paths.contains('/book/edit/:id'), isTrue);
      expect(paths.contains('/scanner/barcode'), isTrue);
      expect(paths.contains('/scanner/ocr'), isTrue);
      expect(paths.contains('/voice-input'), isTrue);
      expect(paths.contains('/locations'), isTrue);
      expect(paths.contains('/checkout/:bookId'), isTrue);
      expect(paths.contains('/loan/:bookId'), isTrue);
      expect(paths.contains('/active-loans'), isTrue);
      expect(paths.contains('/deleted'), isTrue);
      expect(paths.contains('/activity'), isTrue);
      expect(paths.contains('/settings'), isTrue);
      expect(paths.contains('/conflicts'), isTrue);
      expect(paths.contains('/export'), isTrue);
      expect(paths.contains('/share-library'), isTrue);
      expect(paths.contains('/setup'), isTrue);
      expect(paths.contains('/force-update'), isTrue);
      expect(paths.contains('/bulk-scanner'), isTrue);
    });
  });

  group('Nested routes', () {
    test('/settings has nested /genres, /tags, /languages', () {
      final settingsRoute = router.configuration.routes
          .firstWhere((r) => r is GoRoute && r.path == '/settings') as GoRoute;

      final nestedPaths = settingsRoute.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();

      expect(nestedPaths.contains('genres'), isTrue);
      expect(nestedPaths.contains('tags'), isTrue);
      expect(nestedPaths.contains('languages'), isTrue);
    });

    test('/book/:id has nested change-history', () {
      final bookRoute = router.configuration.routes
          .firstWhere((r) => r is GoRoute && r.path == '/book/:id') as GoRoute;

      final nestedPaths = bookRoute.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();

      expect(nestedPaths.contains('change-history'), isTrue);
    });
  });

  group('Route names', () {
    test('all GoRoute entries have a non-empty name', () {
      void checkName(RouteBase route) {
        if (route is GoRoute) {
          expect(route.name, isNotNull,
              reason: 'Route ${route.path} has no name');
          expect(route.name, isNotEmpty,
              reason: 'Route ${route.path} name is empty');
        }
        for (final child in route.routes) {
          checkName(child);
        }
      }

      for (final route in router.configuration.routes) {
        checkName(route);
      }
    });
  });

  group('Parameterised routes', () {
    test('/book/:id has :id parameter', () {
      final route = router.configuration.routes
          .firstWhere((r) => r is GoRoute && r.path == '/book/:id') as GoRoute;
      expect(route.path, contains(':id'));
    });

    test('/book/edit/:id has :id parameter', () {
      final route = router.configuration.routes
          .firstWhere((r) => r is GoRoute && r.path == '/book/edit/:id')
          as GoRoute;
      expect(route.path, contains(':id'));
    });

    test('/checkout/:bookId has :bookId parameter', () {
      final route = router.configuration.routes
          .firstWhere((r) => r is GoRoute && r.path == '/checkout/:bookId')
          as GoRoute;
      expect(route.path, contains(':bookId'));
    });

    test('/loan/:bookId has :bookId parameter', () {
      final route = router.configuration.routes
          .firstWhere((r) => r is GoRoute && r.path == '/loan/:bookId')
          as GoRoute;
      expect(route.path, contains(':bookId'));
    });
  });

  group('Route name constants (AppRoutes)', () {
    test('all route names are unique', () {
      const names = <String>[
        AppRoutes.catalog,
        AppRoutes.bookDetail,
        AppRoutes.addBook,
        AppRoutes.editBook,
        AppRoutes.barcodeScanner,
        AppRoutes.ocrScanner,
        AppRoutes.voiceInput,
        AppRoutes.locations,
        AppRoutes.checkout,
        AppRoutes.loan,
        AppRoutes.conflicts,
        AppRoutes.activity,
        AppRoutes.settings,
        AppRoutes.genres,
        AppRoutes.tags,
        AppRoutes.languages,
        AppRoutes.deleted,
        AppRoutes.activeLoans,
        AppRoutes.exportData,
        AppRoutes.shareLibrary,
        AppRoutes.changeHistory,
        AppRoutes.setup,
        AppRoutes.forceUpdate,
        AppRoutes.bulkScanner,
      ];
      expect(names.toSet().length, names.length);
    });
  });

  group('Edge cases', () {
    test('total GoRoute count matches expected', () {
      int countRoutes(List<RouteBase> routes) {
        var count = 0;
        for (final r in routes) {
          if (r is GoRoute) count++;
          count += countRoutes(r.routes);
        }
        return count;
      }

      final total = countRoutes(router.configuration.routes);
      // 20 top-level + 4 nested = 24 total GoRoute entries
      expect(total, 24);
    });
  });
}
