import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// A thin status bar showing the current sync state.
///
/// Three visual modes:
/// - **Synced** — green bar with a checkmark and "Synced just now".
/// - **Pending** — amber bar with a clock and "Offline — N pending".
/// - **Error** — red bar with a warning and the error message.
class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({
    super.key,
    required this.state,
    this.pendingCount = 0,
    this.errorMessage,
    this.onTap,
  });

  /// The current sync state driving the visual appearance.
  final SyncBarState state;

  /// Number of pending changes (only used when [state] is [SyncBarState.pending]).
  final int pendingCount;

  /// Human-readable error (only used when [state] is [SyncBarState.error]).
  final String? errorMessage;

  /// Optional callback when the bar is tapped (e.g. navigate to sync details).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (Color background, IconData icon, String label) = switch (state) {
      SyncBarState.synced => (
          Colors.green.shade700,
          Icons.cloud_done_rounded,
          l10n.syncStatusSynced,
        ),
      SyncBarState.pending => (
          Colors.amber.shade800,
          Icons.cloud_sync_rounded,
          l10n.syncStatusPending(pendingCount),
        ),
      SyncBarState.error => (
          Colors.red.shade700,
          Icons.cloud_off_rounded,
          errorMessage ?? l10n.syncStatusError,
        ),
    };

    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          label: label,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The three visual states of the [SyncStatusBar].
enum SyncBarState {
  /// Everything is in sync — green.
  synced,

  /// Changes are queued offline — amber.
  pending,

  /// Sync has failed — red.
  error,
}
