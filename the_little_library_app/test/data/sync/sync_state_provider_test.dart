import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thelittlelibrary/data/sync/sync_state_provider.dart';

/// Tests for SyncStateProvider (Riverpod) — covers US-1.3.8 state machine.
///
/// The provider lives in lib/data/sync/sync_state_provider.dart.

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.3.8: State machine
  // ═══════════════════════════════════════════════════════════════════════════
  group('SyncStateProvider — state machine (US-1.3.8)', () {
    test('should emit idle as initial state', () {
      final state = container.read(syncStateProvider);
      expect(state, isA<SyncIdle>());
    });

    test('should emit pulling during pull operation', () {
      final notifier = container.read(syncStateProvider.notifier);
      notifier.update(const SyncPulling(progress: 0.5, stageMessage: 'Pulling...'));

      final state = container.read(syncStateProvider);
      expect(state, isA<SyncPulling>());
      if (state case SyncPulling(progress: final p, stageMessage: final m)) {
        expect(p, 0.5);
        expect(m, 'Pulling...');
      }
    });

    test('should emit pushing during push operation', () {
      final notifier = container.read(syncStateProvider.notifier);
      notifier.update(const SyncPushing(progress: 0.3, stageMessage: 'Pushing...'));

      final state = container.read(syncStateProvider);
      expect(state, isA<SyncPushing>());
      if (state case SyncPushing(progress: final p)) {
        expect(p, 0.3);
      }
    });

    test('should emit offline when no internet available', () {
      final notifier = container.read(syncStateProvider.notifier);
      notifier.update(const SyncOffline(pendingCount: 5));

      final state = container.read(syncStateProvider);
      expect(state, isA<SyncOffline>());
      if (state case SyncOffline(pendingCount: final count)) {
        expect(count, 5);
      }
    });

    test('should emit error with message for each error type', () {
      final notifier = container.read(syncStateProvider.notifier);

      // Storage full error
      notifier.update(const SyncError(message: SyncError.storageFull));
      var state = container.read(syncStateProvider);
      expect(state, isA<SyncError>());
      if (state case SyncError(message: final msg)) {
        expect(msg, SyncError.storageFull);
      }

      // Auth expired error
      notifier.update(const SyncError(message: SyncError.authExpired));
      state = container.read(syncStateProvider);
      if (state case SyncError(message: final msg)) {
        expect(msg, SyncError.authExpired);
      }

      // Folder not found error
      notifier.update(const SyncError(message: SyncError.folderNotFound));
      state = container.read(syncStateProvider);
      if (state case SyncError(message: final msg)) {
        expect(msg, SyncError.folderNotFound);
      }
    });

    test('should transition from pulling → idle after successful pull', () {
      final notifier = container.read(syncStateProvider.notifier);

      notifier.update(const SyncPulling(progress: 0.0));
      expect(container.read(syncStateProvider), isA<SyncPulling>());

      notifier.update(const SyncIdle());
      expect(container.read(syncStateProvider), isA<SyncIdle>());
    });

    test('should transition from pushing → idle after successful push', () {
      final notifier = container.read(syncStateProvider.notifier);

      notifier.update(const SyncPushing(progress: 0.0));
      expect(container.read(syncStateProvider), isA<SyncPushing>());

      notifier.update(const SyncIdle());
      expect(container.read(syncStateProvider), isA<SyncIdle>());
    });

    test('should include pending change count in offline state', () {
      final notifier = container.read(syncStateProvider.notifier);
      notifier.update(const SyncOffline(pendingCount: 12));

      final state = container.read(syncStateProvider);
      expect(state, isA<SyncOffline>());
      if (state case SyncOffline(pendingCount: final count)) {
        expect(count, 12);
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.3.9: Progress tracking
  // ═══════════════════════════════════════════════════════════════════════════
  group('SyncStateProvider — progress tracking (US-1.3.9)', () {
    test('should emit progress fraction during large sync', () {
      final notifier = container.read(syncStateProvider.notifier);

      // Progress should be a double between 0.0 and 1.0
      notifier.update(const SyncPulling(progress: 0.0));
      var state = container.read(syncStateProvider);
      if (state case SyncPulling(progress: final p)) expect(p, 0.0);

      notifier.update(const SyncPulling(progress: 0.5));
      state = container.read(syncStateProvider);
      if (state case SyncPulling(progress: final p)) expect(p, 0.5);

      notifier.update(const SyncPulling(progress: 1.0));
      state = container.read(syncStateProvider);
      if (state case SyncPulling(progress: final p)) expect(p, 1.0);
    });

    test('should emit stage messages during merge phases', () {
      final notifier = container.read(syncStateProvider.notifier);

      notifier.update(const SyncPulling(
        progress: 0.3,
        stageMessage: 'Downloading change log...',
      ));

      final state = container.read(syncStateProvider);
      if (state case SyncPulling(stageMessage: final msg)) {
        expect(msg, 'Downloading change log...');
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.3.24: Accessibility
  // ═══════════════════════════════════════════════════════════════════════════
  group('SyncStateProvider — accessibility (US-1.3.24)', () {
    test('should expose text labels for sync states suitable for TalkBack', () {
      // Each sync state should have a non-empty semanticLabel.
      expect(const SyncIdle().semanticLabel, isNotEmpty);
      expect(const SyncPulling().semanticLabel, isNotEmpty);
      expect(const SyncPushing().semanticLabel, isNotEmpty);
      expect(const SyncOffline().semanticLabel, isNotEmpty);
      expect(const SyncError(message: 'test').semanticLabel, isNotEmpty);
    });

    test('should combine color + text for error states', () {
      // Error states must have isColorBlindAccessible = true by default
      // and include explicit text in semanticLabel.
      const error = SyncError(message: 'Drive storage full');
      expect(error.isColorBlindAccessible, true);
      expect(error.semanticLabel, contains('Drive storage full'));
    });
  });
}
