/// Setup wizard state management.
/// Workstream 2.1 (F0): Manages the 3-step setup wizard flow.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the current step in the setup wizard.
enum SetupStep {
  welcome, // Step 1: Google Sign-In
  connect, // Step 2: Choose library connection method
  sync, // Step 3: Sync progress
}

/// Represents how the user chose to connect their library.
enum LibraryConnectionMethod {
  none,
  joinViaLink,
  createNew,
}

/// Represents the current sync stage during Step 3.
enum SyncStage {
  downloading,
  organizing,
  fetchingCovers,
  finalizing,
  complete,
  error,
  offline,
}

/// Immutable snapshot of the setup wizard state.
class SetupWizardState {
  const SetupWizardState({
    this.currentStep = SetupStep.welcome,
    this.isSignedIn = false,
    this.hasSkippedSignIn = false,
    this.selectedConnectionMethod = LibraryConnectionMethod.none,
    this.inviteLink = '',
    this.linkError,
    this.inviteEmails = '',
    this.syncStage = SyncStage.downloading,
    this.syncProgress = 0.0,
    this.syncedBooks = 0,
    this.syncedLocations = 0,
    this.syncError,
    this.isLargeLibrary = false,
    this.showSharePanel = false,
  });

  final SetupStep currentStep;
  final bool isSignedIn;
  final bool hasSkippedSignIn;
  final LibraryConnectionMethod selectedConnectionMethod;
  final String inviteLink;
  final String? linkError;
  final String inviteEmails;
  final SyncStage syncStage;
  final double syncProgress;
  final int syncedBooks;
  final int syncedLocations;
  final String? syncError;
  final bool isLargeLibrary;
  final bool showSharePanel;

  /// Human-readable stage message for the sync progress screen.
  String get syncStageMessage {
    switch (syncStage) {
      case SyncStage.downloading:
        return 'Downloading catalog…';
      case SyncStage.organizing:
        return 'Organizing shelves…';
      case SyncStage.fetchingCovers:
        return 'Fetching covers…';
      case SyncStage.finalizing:
        return 'Finalizing…';
      case SyncStage.complete:
        return 'Sync complete!';
      case SyncStage.error:
        return syncError ?? 'Sync error';
      case SyncStage.offline:
        return 'Offline — your library will sync when you\'re back online.';
    }
  }

  /// Stats string for the completion screen.
  String get syncStats =>
      'Synced $syncedBooks ${syncedBooks == 1 ? 'book' : 'books'}, '
      '$syncedLocations ${syncedLocations == 1 ? 'location' : 'locations'}';

  SetupWizardState copyWith({
    SetupStep? currentStep,
    bool? isSignedIn,
    bool? hasSkippedSignIn,
    LibraryConnectionMethod? selectedConnectionMethod,
    String? inviteLink,
    Object? linkError, // Use Object? to allow setting to null
    String? inviteEmails,
    SyncStage? syncStage,
    double? syncProgress,
    int? syncedBooks,
    int? syncedLocations,
    String? syncError,
    bool? isLargeLibrary,
    bool? showSharePanel,
  }) {
    return SetupWizardState(
      currentStep: currentStep ?? this.currentStep,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      hasSkippedSignIn: hasSkippedSignIn ?? this.hasSkippedSignIn,
      selectedConnectionMethod:
          selectedConnectionMethod ?? this.selectedConnectionMethod,
      inviteLink: inviteLink ?? this.inviteLink,
      linkError:
          linkError == null ? null : (linkError as String? ?? this.linkError),
      inviteEmails: inviteEmails ?? this.inviteEmails,
      syncStage: syncStage ?? this.syncStage,
      syncProgress: syncProgress ?? this.syncProgress,
      syncedBooks: syncedBooks ?? this.syncedBooks,
      syncedLocations: syncedLocations ?? this.syncedLocations,
      syncError: syncError ?? this.syncError,
      isLargeLibrary: isLargeLibrary ?? this.isLargeLibrary,
      showSharePanel: showSharePanel ?? this.showSharePanel,
    );
  }

  /// Explicit linkError setter that always uses the provided value.
  SetupWizardState copyWithLinkError(String? error) {
    return SetupWizardState(
      currentStep: currentStep,
      isSignedIn: isSignedIn,
      hasSkippedSignIn: hasSkippedSignIn,
      selectedConnectionMethod: selectedConnectionMethod,
      inviteLink: inviteLink,
      linkError: error,
      inviteEmails: inviteEmails,
      syncStage: syncStage,
      syncProgress: syncProgress,
      syncedBooks: syncedBooks,
      syncedLocations: syncedLocations,
      syncError: syncError,
      isLargeLibrary: isLargeLibrary,
      showSharePanel: showSharePanel,
    );
  }

  /// Accessibility label for the current step.
  String get stepAccessibilityLabel {
    const total = 3;
    final current = currentStep.index + 1;
    final title = switch (currentStep) {
      SetupStep.welcome => 'Welcome to The Little Library',
      SetupStep.connect => 'Connect to your family library',
      SetupStep.sync => syncStage == SyncStage.complete
          ? 'You\'re all set!'
          : 'Syncing your library',
    };
    return 'Step $current of $total, $title';
  }
}

/// Riverpod notifier for the setup wizard state.
///
/// Manages step transitions, sign-in state, library connection method,
/// invite link validation, and simulated sync progress.
class SetupWizardNotifier extends Notifier<SetupWizardState> {
  @override
  SetupWizardState build() {
    return const SetupWizardState();
  }

  /// Advance to the next step.
  void nextStep() {
    final nextIndex = state.currentStep.index + 1;
    if (nextIndex < SetupStep.values.length) {
      state = state.copyWith(currentStep: SetupStep.values[nextIndex]);
      if (state.currentStep == SetupStep.sync) {
        _startSync();
      }
    }
  }

  /// Go back to the previous step.
  void previousStep() {
    if (state.currentStep.index > 0) {
      final prevIndex = state.currentStep.index - 1;
      state = state.copyWith(currentStep: SetupStep.values[prevIndex]);
    }
  }

  /// Jump to a specific step.
  void goToStep(SetupStep step) {
    state = state.copyWith(currentStep: step);
    if (step == SetupStep.sync) {
      _startSync();
    }
  }

  /// Mark user as signed in and advance to Step 2.
  void onSignInSuccess() {
    state = state.copyWith(isSignedIn: true);
    nextStep();
  }

  /// Handle sign-in failure.
  void onSignInFailure(String error) {
    state = state.copyWith(syncError: error);
  }

  /// Clear sign-in error.
  void clearSignInError() {
    state = state.copyWith(syncError: null);
  }

  /// Skip sign-in and advance to Step 2.
  void skipSignIn() {
    state = state.copyWith(hasSkippedSignIn: true);
    nextStep();
  }

  /// Select the "Join via link/QR" option card.
  void selectJoinViaLink() {
    state = state.copyWith(
      selectedConnectionMethod: LibraryConnectionMethod.joinViaLink,
    );
    state = state.copyWithLinkError(null);
  }

  /// Select the "Create new library" option card.
  void selectCreateNew() {
    state = state.copyWith(
      selectedConnectionMethod: LibraryConnectionMethod.createNew,
    );
  }

  /// Update the invite link input.
  void setInviteLink(String link) {
    state = state.copyWith(inviteLink: link);
    state = state.copyWithLinkError(null);
  }

  /// Validate and join via invite link.
  void joinLibrary() {
    final link = state.inviteLink.trim();
    if (link.isEmpty) {
      state = state.copyWithLinkError(
        'Please paste a link or scan a QR code.',
      );
      return;
    }
    if (!_isValidInviteLink(link)) {
      state = state.copyWithLinkError(
        "This link doesn't work. Ask a family member for a new one.",
      );
      return;
    }
    state = state.copyWithLinkError(null);
    nextStep();
  }

  /// Handle QR code scan result.
  void onQRCodeScanned(String decodedUrl) {
    state = state.copyWith(inviteLink: decodedUrl);
    state = state.copyWithLinkError(null);
  }

  /// Create a new library (shows share panel).
  void createLibrary() {
    state = state.copyWith(showSharePanel: true);
  }

  /// Update the invite emails input.
  void setInviteEmails(String emails) {
    state = state.copyWith(inviteEmails: emails);
  }

  /// Send invites and advance to Step 3.
  void sendInvites() {
    nextStep();
  }

  /// Skip family invites and advance to Step 3.
  void skipInvites() {
    nextStep();
  }

  /// Mark sync as complete with given stats.
  void completeSync({int books = 847, int locations = 12}) {
    state = state.copyWith(
      syncStage: SyncStage.complete,
      syncProgress: 1.0,
      syncedBooks: books,
      syncedLocations: locations,
    );
  }

  /// Mark sync as offline.
  void markSyncOffline() {
    state = state.copyWith(
      syncStage: SyncStage.offline,
      syncProgress: 0.0,
    );
  }

  /// Mark sync as errored.
  void markSyncError(String message) {
    state = state.copyWith(
      syncStage: SyncStage.error,
      syncError: message,
    );
  }

  /// Simulate sync progress.
  void updateSyncProgress(double progress) {
    state = state.copyWith(syncProgress: progress);
  }

  /// Update sync stage.
  void updateSyncStage(SyncStage stage) {
    state = state.copyWith(syncStage: stage);
  }

  /// Reset to initial state.
  void reset() {
    state = const SetupWizardState();
  }

  // ─── Private helpers ───────────────────────────────────────────────────

  bool _isValidInviteLink(String link) {
    if (link.contains('littlelibrary.app')) return true;
    try {
      final uri = Uri.parse(link);
      return uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  void _startSync() {
    state = state.copyWith(
      syncStage: SyncStage.downloading,
      syncProgress: 0.0,
    );
  }
}

/// Riverpod provider for [SetupWizardState].
///
/// ### Usage
/// ```dart
/// final setupState = ref.watch(setupWizardProvider);
/// // ...
/// ref.read(setupWizardProvider.notifier).nextStep();
/// ```
final setupWizardProvider =
    NotifierProvider<SetupWizardNotifier, SetupWizardState>(
  SetupWizardNotifier.new,
);
