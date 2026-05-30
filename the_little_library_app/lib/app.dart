import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'core/router.dart';
import 'core/widgets/sync_status_bar.dart';

/// Root widget of The Little Library.
///
/// Wraps the entire app in a [ProviderScope] and wires together the Material
/// theme, router, and localisation delegates.  A thin [SyncStatusBar] is
/// rendered above the navigation shell so the user always sees sync state.
class TheLittleLibraryApp extends ConsumerWidget {
  const TheLittleLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = buildRouter();

    return MaterialApp.router(
      title: 'The Little Library',
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Localisation ─────────────────────────────────────────────────────
      localizationsDelegates:
          AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // ── Router ───────────────────────────────────────────────────────────
      routerConfig: router,

      // ── Builder for shared chrome (sync bar) ─────────────────────────────
      builder: (context, child) {
        // Placeholder sync bar — always shows synced during W01.
        // Later workstreams will drive this from a Riverpod provider.
        return Column(
          children: [
            const SyncStatusBar(state: SyncBarState.synced),
            Expanded(child: child!),
          ],
        );
      },
    );
  }
}
