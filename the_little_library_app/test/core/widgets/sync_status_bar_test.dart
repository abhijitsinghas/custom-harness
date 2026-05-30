import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_little_library_app/core/widgets/sync_status_bar.dart';
import 'package:the_little_library_app/l10n/app_localizations.dart';

/// Wraps a widget in the minimum Material + localisation context needed by
/// [SyncStatusBar].
Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

/// Finds the first [Material] widget whose color matches [predicate].
Finder findMaterialWithColor(ColorPredicate predicate) {
  return find.byWidgetPredicate(
    (w) => w is Material && predicate(w.color),
  );
}

typedef ColorPredicate = bool Function(Color? color);

void main() {
  group('SyncStatusBar', () {
    // ── Synced state ────────────────────────────────────────────────────────
    group('when synced', () {
      testWidgets('renders synced text', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.synced),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Synced just now'), findsOneWidget);
      });

      testWidgets('renders a cloud-done icon', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.synced),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
      });

      testWidgets('uses green background', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.synced),
        ));
        await tester.pumpAndSettle();

        // Find the Material whose child is the SyncStatusBar content.
        final materials = find.byWidgetPredicate(
          (w) => w is Material && w.color == Colors.green.shade700,
        );
        expect(materials, findsOneWidget);
      });

      testWidgets('has correct semantic properties', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.synced),
        ));
        await tester.pumpAndSettle();

        // Find Semantics with the expected label.
        final semantics = find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Synced just now',
        );
        expect(semantics, findsOneWidget);
      });
    });

    // ── Pending state ───────────────────────────────────────────────────────
    group('when pending', () {
      testWidgets('renders pending text with count', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.pending, pendingCount: 5),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Offline — 5 pending'), findsOneWidget);
      });

      testWidgets('renders a cloud-sync icon', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.pending),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cloud_sync_rounded), findsOneWidget);
      });

      testWidgets('uses amber background', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.pending),
        ));
        await tester.pumpAndSettle();

        final materials = find.byWidgetPredicate(
          (w) => w is Material && w.color == Colors.amber.shade800,
        );
        expect(materials, findsOneWidget);
      });
    });

    // ── Error state ─────────────────────────────────────────────────────────
    group('when error', () {
      testWidgets('renders default error text when no message given',
          (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.error),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Sync error — tap for details'), findsOneWidget);
      });

      testWidgets('renders custom error message', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(
            state: SyncBarState.error,
            errorMessage: 'Network timeout',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Network timeout'), findsOneWidget);
      });

      testWidgets('renders a cloud-off icon', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.error),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      });

      testWidgets('uses red background', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(state: SyncBarState.error),
        ));
        await tester.pumpAndSettle();

        final materials = find.byWidgetPredicate(
          (w) => w is Material && w.color == Colors.red.shade700,
        );
        expect(materials, findsOneWidget);
      });

      testWidgets('semantic label shows custom error', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const SyncStatusBar(
            state: SyncBarState.error,
            errorMessage: 'Disk full',
          ),
        ));
        await tester.pumpAndSettle();

        final semantics = find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Disk full',
        );
        expect(semantics, findsOneWidget);
      });
    });

    // ── Tap callback ────────────────────────────────────────────────────────
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrapWithMaterial(
        SyncStatusBar(
          state: SyncBarState.synced,
          onTap: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SyncStatusBar(state: SyncBarState.synced),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      // No crash = pass.
      expect(find.byType(SyncStatusBar), findsOneWidget);
    });
  });
}
