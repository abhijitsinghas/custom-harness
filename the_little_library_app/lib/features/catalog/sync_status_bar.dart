import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_bar.g.dart';

/// Sync state for the status bar.
enum SyncState { synced, offline, error }

/// Data model for sync status.
class SyncStatus {
  const SyncStatus({
    required this.state,
    this.pendingCount = 0,
    this.errorMessage,
  });

  final SyncState state;
  final int pendingCount;
  final String? errorMessage;
}

/// Riverpod provider for sync status state.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `syncStatusProvider`.
@riverpod
class SyncStatusNotifier extends _$SyncStatusNotifier {
  @override
  SyncStatus build() => const SyncStatus(state: SyncState.synced);

  void setSynced() {
    state = const SyncStatus(state: SyncState.synced);
  }

  void setOffline(int pendingCount) {
    state = SyncStatus(state: SyncState.offline, pendingCount: pendingCount);
  }

  void setError(String message) {
    state = SyncStatus(state: SyncState.error, errorMessage: message);
  }
}

/// Sync status bar widget shown below the app bar on the catalog screen.
/// US-0.4.6, US-0.4.7, US-0.4.8: Green, amber, and red states.
class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      color: _getBackgroundColor(syncStatus.state),
      child: Semantics(
        label: _getMessage(syncStatus),
        child: SizedBox(
          height: 48,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: syncStatus.state == SyncState.error
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Sync error: ${syncStatus.errorMessage}'),
                          action: SnackBarAction(
                            label: 'Dismiss',
                            onPressed: () => ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar(),
                          ),
                        ),
                      );
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      _getIcon(syncStatus.state),
                      size: 18,
                      color: _getTextColor(syncStatus.state),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getMessage(syncStatus),
                        style: TextStyle(
                          color: _getTextColor(syncStatus.state),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(SyncState state) {
    switch (state) {
      case SyncState.synced:
        // #2E7D32 provides ~4.6:1 contrast with white text (WCAG AA >= 4.5:1)
        return const Color(0xFF2E7D32);
      case SyncState.offline:
        return const Color(0xFFFF9800);
      case SyncState.error:
        return const Color(0xFFF44336);
    }
  }

  Color _getTextColor(SyncState state) {
    switch (state) {
      case SyncState.synced:
        return Colors.white;
      case SyncState.offline:
        return const Color(0xFF3E2B23);
      case SyncState.error:
        return Colors.white;
    }
  }

  IconData _getIcon(SyncState state) {
    switch (state) {
      case SyncState.synced:
        return Icons.sync;
      case SyncState.offline:
        return Icons.cloud_off;
      case SyncState.error:
        return Icons.error_outline;
    }
  }

  String _getMessage(SyncStatus status) {
    switch (status.state) {
      case SyncState.synced:
        return 'Synced just now';
      case SyncState.offline:
        return 'Offline — ${status.pendingCount} ${status.pendingCount == 1 ? 'change' : 'changes'} pending';
      case SyncState.error:
        return status.errorMessage ?? 'Sync error';
    }
  }
}
