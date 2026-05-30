import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sync engine state machine.
///
/// Covers US-1.3.8, US-1.3.9, US-1.3.24.
sealed class SyncState {
  const SyncState();

  /// Human-readable label for accessibility (TalkBack).
  String get semanticLabel;

  /// Progress fraction (0.0 to 1.0) during an active sync operation.
  double get progress;

  /// Descriptive stage message shown during merge phases.
  String? get stageMessage;

  /// Whether the state is an active sync (pulling or pushing).
  bool get isActive => this is SyncPulling || this is SyncPushing;
}

/// No sync activity in progress.
class SyncIdle extends SyncState {
  const SyncIdle();

  @override
  String get semanticLabel => 'Sync idle';

  @override
  double get progress => 1.0;

  @override
  String? get stageMessage => null;
}

/// Downloading changes from remote.
class SyncPulling extends SyncState {
  const SyncPulling({this.progress = 0.0, this.stageMessage});

  @override
  final double progress;

  @override
  final String? stageMessage;

  @override
  String get semanticLabel => 'Syncing: downloading changes';
}

/// Uploading local changes to remote.
class SyncPushing extends SyncState {
  const SyncPushing({this.progress = 0.0, this.stageMessage});

  @override
  final double progress;

  @override
  final String? stageMessage;

  @override
  String get semanticLabel => 'Syncing: uploading changes';
}

/// No internet connection available.
class SyncOffline extends SyncState {
  const SyncOffline({this.pendingCount = 0});

  /// Number of local changes waiting to be pushed.
  final int pendingCount;

  @override
  String get semanticLabel =>
      'Offline. $pendingCount changes pending sync.';

  @override
  double get progress => 0.0;

  @override
  String? get stageMessage => null;
}

/// An error occurred during sync.
class SyncError extends SyncState {
  const SyncError({
    required this.message,
    this.pendingCount = 0,
    this.conflictCount = 0,
    this.isColorBlindAccessible = true,
  });

  /// Human-readable error description.
  final String message;

  /// Number of local changes queued but not pushed.
  final int pendingCount;

  /// Number of merge conflicts awaiting resolution.
  final int conflictCount;

  /// When true, the error message includes explicit text (not just color).
  final bool isColorBlindAccessible;

  @override
  String get semanticLabel {
    final parts = <String>['Sync error: $message'];
    if (conflictCount > 0) parts.add('$conflictCount conflicts');
    if (pendingCount > 0) parts.add('$pendingCount pending');
    return parts.join('. ');
  }

  @override
  double get progress => 0.0;

  @override
  String? get stageMessage => null;

  /// Predefined error types for common sync failures.
  static const storageFull = 'Drive storage full';
  static const syncTimedOut = 'Sync timed out';
  static const authExpired = 'Authentication expired. Please sign in again.';
  static const folderNotFound = 'Library folder not found';
  static const schemaMismatch = 'Schema version mismatch. Update required.';
  static const corruptedFile = 'Remote file corrupted. Restore from local backup.';
}

/// Riverpod notifier for sync engine state transitions.
class SyncStateNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => const SyncIdle();

  /// Update the sync state.
  void update(SyncState newState) {
    state = newState;
  }
}

/// Riverpod provider for the sync engine state.
///
/// Emits [SyncState] transitions: idle, pulling, pushing, offline, error.
final syncStateProvider =
    NotifierProvider<SyncStateNotifier, SyncState>(SyncStateNotifier.new);
