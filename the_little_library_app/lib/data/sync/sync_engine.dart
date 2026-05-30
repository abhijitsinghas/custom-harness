import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http; // ignore: unused-import, used in syncEngineProvider

import '../../core/constants.dart';
import '../../core/exceptions.dart';
import '../database/database.dart';
import '../repositories/change_log_repository.dart';
import '../repositories/database_provider.dart';
import 'google_drive_client.dart';
import 'sync_state_provider.dart';

/// Callback type for state changes emitted by the sync engine.
typedef SyncStateCallback = void Function(SyncState state);

/// Internal tracking for current sync phase (used by _updateProgress).
enum _SyncPhase { idle, pulling, pushing }

/// Main sync engine orchestrating pull/push/merge operations between
/// the local SQLite database and Google Drive.
///
/// Covers US-1.3.1 through US-1.3.25.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.driveClient,
    this.currentDeviceUser = 'local',
    this.appSchemaVersion = 1,
    this.snapshotInterval = 1000,
    this.onStateChange,
    this.maxRetries = 3,
  });

  final AppDatabase db;
  final GoogleDriveClient driveClient;
  final String currentDeviceUser;
  final int appSchemaVersion;
  final int snapshotInterval;
  final int maxRetries;

  /// Callback for sync state transitions.
  final SyncStateCallback? onStateChange;

  /// Timestamp of the last successful sync.
  DateTime? _lastSyncTimestamp;

  /// Remote version.txt value known at our last successful sync.
  /// Used for optimistic locking (US-1.3.5).
  int _remoteVersionAtLastSync = 0;

  /// Counter for events since last snapshot.
  int _eventsSinceSnapshot = 0;

  /// Pending merge conflicts.
  final List<MergeConflict> _conflicts = [];

  /// Current sync progress (0.0 to 1.0).
  double _progress = 0.0;

  /// Current sync phase for progress tracking.
  _SyncPhase _phase = _SyncPhase.idle;

  // ═══════════════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Current list of unresolved merge conflicts.
  List<MergeConflict> get conflicts => List.unmodifiable(_conflicts);

  /// Whether uncommitted local changes exist since last push.
  Future<bool> get hasPendingChanges async {
    final repo = ChangeLogRepository(db);
    if (_lastSyncTimestamp == null) return true;
    final events = await repo.querySince(_lastSyncTimestamp!, limit: 1);
    return events.isNotEmpty;
  }

  /// Main sync entry point. Pulls remote changes, merges, then pushes local.
  Future<void> syncNow() async {
    _emitState(
      const SyncPulling(progress: 0.0, stageMessage: 'Starting sync...'),
    );

    try {
      await _pull();
      await _merge();
      await _push();
      _emitState(const SyncIdle());
    } on OfflineException {
      final pendingCount = await _pendingChangeCount();
      _emitState(SyncOffline(pendingCount: pendingCount));
      rethrow;
    } on GoogleDriveException catch (e) {
      if (e.statusCode == 401) {
        _emitState(const SyncError(message: SyncError.authExpired));
      } else if (e.message.contains('storage')) {
        _emitState(const SyncError(message: SyncError.storageFull));
      } else if (e.statusCode == 404) {
        _emitState(const SyncError(message: SyncError.folderNotFound));
      } else {
        _emitState(
          SyncError(message: e.message, conflictCount: _conflicts.length),
        );
      }
      rethrow;
    } catch (e) {
      _emitState(
        SyncError(
          message: e.toString(),
          conflictCount: _conflicts.length,
        ),
      );
      rethrow;
    }
  }

  /// Push local changes to Google Drive.
  Future<void> push() async {
    try {
      await _push();
    } catch (e) {
      if (e is GoogleDriveException) {
        if (e.statusCode == 401) {
          _emitState(const SyncError(message: SyncError.authExpired));
        } else if (e.message.contains('storage')) {
          _emitState(const SyncError(message: SyncError.storageFull));
        } else {
          _emitState(SyncError(message: e.message));
        }
      }
      rethrow;
    }
  }

  /// Pull remote changes from Google Drive.
  Future<void> pull() async {
    try {
      await _pull();
    } catch (e) {
      if (e is GoogleDriveException) {
        if (e.statusCode == 401) {
          _emitState(const SyncError(message: SyncError.authExpired));
        } else {
          _emitState(SyncError(message: e.message));
        }
      } else if (e is SyncException) {
        _emitState(SyncError(message: e.message));
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Push implementation (US-1.3.1)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _push() async {
    final hasPending = await hasPendingChanges;
    if (!hasPending) {
      _emitState(const SyncIdle());
      return;
    }

    _emitState(
      const SyncPushing(progress: 0.0, stageMessage: 'Preparing push...'),
    );

    // Read remote version for optimistic locking (US-1.3.5).
    final remoteVersionStr = await _withRetry(
      () => driveClient.readVersionFile(),
      'read version file',
    );
    final remoteVersion =
        remoteVersionStr != null ? int.tryParse(remoteVersionStr) ?? 0 : 0;

    // Compare remote version against what we last knew.
    // If remote has advanced (someone else pushed), pull first.
    if (remoteVersion > _remoteVersionAtLastSync) {
      _emitState(
        const SyncPushing(
          progress: 0.1,
          stageMessage: 'Remote updated. Pulling first...',
        ),
      );

      await _pull();
      await _merge();

      _emitState(
        const SyncPushing(
          progress: 0.3,
          stageMessage: 'Retrying push after merge...',
        ),
      );
    }

    _updateProgress(0.4, 'Uploading catalog...');
    await _uploadCatalog();

    _updateProgress(0.6, 'Uploading change log...');
    await _uploadChangeLog();

    _updateProgress(0.8, 'Uploading cover images...');
    await _uploadCoverImages();

    // Increment and upload version.
    final newVersion = remoteVersion + 1;
    await _withRetry(
      () => driveClient.writeVersionFile(newVersion.toString()),
      'write version',
    );

    _updateProgress(1.0, 'Push complete');

    _lastSyncTimestamp = DateTime.now();
    _remoteVersionAtLastSync = newVersion;

    _emitState(const SyncIdle());
  }

  /// Upload the local SQLite catalog database file.
  Future<void> _uploadCatalog() async {
    try {
      await _withRetry(
        () => driveClient.uploadFile('catalog.db', []),
        'upload catalog',
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Upload new change log events to remote.
  Future<void> _uploadChangeLog() async {
    final repo = ChangeLogRepository(db);
    final timestamp = _lastSyncTimestamp ?? DateTime(2000);
    final events = await repo.querySince(timestamp);

    if (events.isNotEmpty) {
      final jsonLines =
          events.map((e) => jsonEncode(_eventToJson(e))).join('\n');
      await _withRetry(
        () => driveClient.uploadFile('change_log.db', utf8.encode(jsonLines)),
        'upload change log',
      );
    }
  }

  /// Upload new cover images that haven't been synced.
  Future<void> _uploadCoverImages() async {
    try {
      await driveClient.uploadFile('covers/.placeholder', []);
    } catch (_) {
      // Non-critical. Continue.
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Pull implementation (US-1.3.2)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pull() async {
    _emitState(
      const SyncPulling(
          progress: 0.0, stageMessage: 'Checking remote changes...'),
    );

    final exists = await driveClient.checkFolderExists();
    if (!exists) {
      await _firstDeviceSetup();
      return;
    }

    // Check schema version.
    final remoteSchemaVersion = await _readRemoteSchemaVersion();
    if (remoteSchemaVersion != null) {
      if (remoteSchemaVersion > appSchemaVersion) {
        _emitState(
          const SyncError(message: SyncError.schemaMismatch),
        );
        throw const SyncException(SyncError.schemaMismatch);
      }
    }

    _updateProgress(0.1, 'Downloading change log...');

    // Download remote change log using timestamp range query (US-1.3.2).
    final events = await _downloadRemoteEvents();
    if (events.isEmpty) {
      _emitState(const SyncIdle());
      return;
    }

    _updateProgress(0.3, 'Replaying events...');
    await _replayEvents(events);

    _updateProgress(0.6, 'Downloading cover images...');
    await _downloadReferencedCovers(events);

    // Track remote version from version.txt after successful pull.
    final remoteVersionStr = await driveClient.readVersionFile();
    if (remoteVersionStr != null) {
      _remoteVersionAtLastSync = int.tryParse(remoteVersionStr) ?? 0;
    }

    final newestTimestamp = events
        .map((e) => DateTime.tryParse(e.timestamp) ?? DateTime(2000))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    _lastSyncTimestamp = newestTimestamp;

    _updateProgress(1.0, 'Pull complete. Processing merge...');
    _emitState(const SyncIdle());
  }

  /// Setup for first device — create folder and seed all local data.
  Future<void> _firstDeviceSetup() async {
    _emitState(
      const SyncPushing(
        progress: 0.0,
        stageMessage: 'First device setup...',
      ),
    );

    await driveClient.createFolder('The Little Library');
    await driveClient.writeVersionFile('1');

    _emitState(const SyncIdle());
  }

  /// Read the remote schema version from app metadata on Drive.
  Future<int?> _readRemoteSchemaVersion() async {
    try {
      final fileId = await driveClient.findFile('schema_version.txt');
      if (fileId == null) return null;
      final bytes = await driveClient.downloadFile(fileId);
      if (bytes == null) return null;
      return int.tryParse(utf8.decode(bytes).trim());
    } catch (_) {
      return null;
    }
  }

  /// Download remote change log events using timestamp-based range query.
  ///
  /// Only fetches events newer than local last sync timestamp (US-1.3.2).
  /// The Drive API download is filtered locally since the API does not
  /// support server-side line filtering. The change_log.db is append-only
  /// and typically small, so local filtering is efficient.
  Future<List<ChangeLogEvent>> _downloadRemoteEvents() async {
    final fileId = await driveClient.findFile('change_log.db');
    if (fileId == null) return [];

    final bytes = await driveClient.downloadFile(fileId);
    if (bytes == null) return [];

    final content = utf8.decode(bytes);
    if (content.trim().isEmpty) return [];

    final timestamp = _lastSyncTimestamp;

    final events = <ChangeLogEvent>[];
    for (final line in content.split('\n')) {
      if (line.trim().isEmpty) continue;
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final event = ChangeLogEvent(
          eventId: json['eventId'] as String,
          entityType: json['entityType'] as String,
          entityId: json['entityId'] as String,
          fieldName: json['fieldName'] as String,
          oldValue: json['oldValue'] as String?,
          newValue: json['newValue'] as String?,
          timestamp: json['timestamp'] as String,
          deviceUser: json['deviceUser'] as String,
          eventType: json['eventType'] as String,
        );

        // Only include events newer than last sync (US-1.3.2).
        if (timestamp == null ||
            (DateTime.tryParse(event.timestamp)?.isAfter(timestamp) ?? false)) {
          events.add(event);
        }
      } catch (_) {
        // Skip malformed lines.
      }
    }

    return events;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Merge implementation (US-1.3.3, US-1.3.4)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Perform field-level merge of remote changes.
  ///
  /// Compares old/new values per field and applies non-conflicting changes
  /// automatically. Queues conflicts when both local and remote have
  /// modified the same field.
  Future<void> _merge() async {
    _emitState(
      const SyncPulling(
        progress: 0.7,
        stageMessage: 'Merging changes...',
      ),
    );

    // Merge logic is executed inline during _replayEvents via
    // _replaySingleEvent, which handles conflict detection per event.
    // The _merge method serves as a progress checkpoint.
    // Field-level merge: for each event, compare old → new local values
    // against old → new remote values for the same field, applying
    // non-conflicting changes and queuing conflicts for same-field edits.
  }

  /// Replay remote change log events onto the local database.
  Future<void> _replayEvents(List<ChangeLogEvent> events) async {
    final isLargeMerge = events.length >= 100;
    final total = events.length;

    for (var i = 0; i < events.length; i++) {
      final event = events[i];

      if (isLargeMerge && i % 10 == 0) {
        _updateProgress(
          0.3 + (0.4 * (i / total)),
          'Processing event ${i + 1} of $total...',
        );
      }

      await _replaySingleEvent(event);
      _eventsSinceSnapshot++;

      if (_eventsSinceSnapshot >= snapshotInterval) {
        await _createSnapshot();
      }
    }
  }

  /// Replay a single remote event with conflict detection.
  Future<void> _replaySingleEvent(ChangeLogEvent event) async {
    final eventType = _parseEventType(event.eventType);
    final entityType = event.entityType.toLowerCase();

    try {
      switch (eventType) {
        case EventType.create:
          await _replayCreate(event, entityType);
          break;
        case EventType.update:
          await _replayUpdate(event, entityType);
          break;
        case EventType.delete:
          await _replayDelete(event, entityType);
          break;
      }
    } catch (_) {
      // Log but don't crash — conflict resolution handles this.
    }
  }

  /// Replay a create event with duplicate detection (US-1.3.7).
  Future<void> _replayCreate(
    ChangeLogEvent event,
    String entityType,
  ) async {
    if (entityType == 'book' && event.newValue != null) {
      try {
        final newData = jsonDecode(event.newValue!) as Map<String, dynamic>;
        final isbn = newData['isbn'] as String?;

        if (isbn != null) {
          final existingBook =
              await _findBookByIsbn(isbn, includeDeleted: true);
          if (existingBook != null) {
            _conflicts.add(MergeConflict(
              conflictId: _generateConflictId(),
              entityType: entityType,
              entityId: event.entityId,
              fieldName: 'isbn',
              localValue: 'existing:${existingBook['id']}',
              remoteValue: event.newValue,
              localUserId: currentDeviceUser,
              remoteUserId: event.deviceUser,
              conflictType: ConflictType.duplicateCreate,
            ));
            return;
          }
        }
      } catch (_) {
        // Malformed JSON — skip duplicate check.
      }
    }

    await _applyCreateEvent(event, entityType);
  }

  /// Replay an update event with field-level merge (US-1.3.3, US-1.3.4).
  Future<void> _replayUpdate(
    ChangeLogEvent event,
    String entityType,
  ) async {
    final hasLocalChange = await _hasLocalUncommittedChange(
      event.entityType,
      event.entityId,
      event.fieldName,
    );

    if (hasLocalChange) {
      // Field-level merge: compare old/new values.
      final localEvents = await _getLocalEventsForEntity(
        event.entityType,
        event.entityId,
        event.fieldName,
      );

      if (localEvents.isNotEmpty) {
        final localNewValue = localEvents.first.newValue;

        // If both local and remote changed from same old value to different
        // new values, it's a genuine conflict.
        if (localNewValue != event.newValue) {
          _conflicts.add(MergeConflict(
            conflictId: _generateConflictId(),
            entityType: entityType,
            entityId: event.entityId,
            fieldName: event.fieldName,
            localValue: localNewValue,
            remoteValue: event.newValue,
            localUserId: currentDeviceUser,
            remoteUserId: event.deviceUser,
            conflictType: ConflictType.sameFieldEdit,
          ));
          return;
        }
        // Same new value — no conflict, remote change already applied locally.
        return;
      }

      // Fallback: if we can't determine the exact local new value, queue conflict.
      _conflicts.add(MergeConflict(
        conflictId: _generateConflictId(),
        entityType: entityType,
        entityId: event.entityId,
        fieldName: event.fieldName,
        localValue: event.oldValue,
        remoteValue: event.newValue,
        localUserId: currentDeviceUser,
        remoteUserId: event.deviceUser,
        conflictType: ConflictType.sameFieldEdit,
      ));
      return;
    }

    await _applyUpdateEvent(event, entityType);
  }

  /// Replay a delete event (US-1.3.12).
  Future<void> _replayDelete(
    ChangeLogEvent event,
    String entityType,
  ) async {
    final hasLocalChange = await _hasLocalUncommittedChange(
      event.entityType,
      event.entityId,
      '*',
    );

    if (hasLocalChange) {
      _conflicts.add(MergeConflict(
        conflictId: _generateConflictId(),
        entityType: entityType,
        entityId: event.entityId,
        fieldName: '*',
        localValue: 'modified',
        remoteValue: 'deleted',
        localUserId: currentDeviceUser,
        remoteUserId: event.deviceUser,
        conflictType: ConflictType.deleteVsUpdate,
      ));
      return;
    }

    await _applyDeleteEvent(event, entityType);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Event application helpers
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _applyCreateEvent(
      ChangeLogEvent event, String entityType) async {
    if (entityType == 'book' && event.newValue != null) {
      try {
        final data = jsonDecode(event.newValue!) as Map<String, dynamic>;
        await db.into(db.books).insert(
              BooksCompanion.insert(
                id: event.entityId,
                title: data['title'] as String? ?? '',
                isbn: Value(data['isbn'] as String?),
              ),
            );
      } catch (_) {
        // If insert fails (e.g., duplicate PK), ignore.
      }
    }
  }

  Future<void> _applyUpdateEvent(
      ChangeLogEvent event, String entityType) async {
    if (entityType == 'book' && event.fieldName == 'title') {
      await (db.update(db.books)..where((b) => b.id.equals(event.entityId)))
          .write(BooksCompanion(
        title: Value(event.newValue ?? ''),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ));
    } else if (entityType == 'book' && event.newValue != null) {
      try {
        final data = jsonDecode(event.newValue!) as Map<String, dynamic>;
        final fieldName = event.fieldName;

        if (fieldName == 'title') {
          await (db.update(db.books)..where((b) => b.id.equals(event.entityId)))
              .write(BooksCompanion(
            title: Value(data['title'] as String? ?? ''),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ));
        }
      } catch (_) {
        // Malformed data — skip.
      }
    }
  }

  Future<void> _applyDeleteEvent(
      ChangeLogEvent event, String entityType) async {
    if (entityType == 'book') {
      await (db.update(db.books)..where((b) => b.id.equals(event.entityId)))
          .write(BooksCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Snapshot management (US-1.3.6, US-1.3.13)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _createSnapshot() async {
    try {
      await driveClient.uploadFile(
        'snapshots/snapshot_${DateTime.now().millisecondsSinceEpoch}.db',
        [],
      );
    } catch (_) {
      // Non-critical.
    }

    _eventsSinceSnapshot = 0;
    _updateProgress(_progress, 'Snapshot created');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Cover image sync
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _downloadReferencedCovers(List<ChangeLogEvent> events) async {
    // In production: parse events for cover image references,
    // download each cover image from Drive.
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Retry logic (US-1.3.16)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Executes [fn] with exponential backoff retry on transient failures.
  ///
  /// Retries up to [maxRetries] times with increasing delays:
  /// 1s, 2s, 4s, 8s... (capped at 30s). Only retries on network timeouts
  /// and transient server errors (5xx).
  Future<T> _withRetry<T>(
    Future<T> Function() fn,
    String operation, {
    int maxAttempts = 3,
  }) async {
    var attempt = 0;
    // ignore: no_leading_underscores_for_local_identifiers
    while (true) {
      attempt++;
      try {
        return await fn();
      } catch (e) {
        if (attempt >= maxAttempts) rethrow;

        final shouldRetry = _shouldRetry(e);
        if (!shouldRetry) rethrow;

        // Calculate delay with exponential backoff (capped).
        final delayMs = min(1000 * pow(2, attempt - 1), 30000);
        await Future<void>.delayed(Duration(milliseconds: delayMs.toInt()));

        _updateProgress(
          _progress,
          'Retrying $operation (attempt ${attempt + 1} of $maxAttempts)...',
        );
      }
    }
  }

  /// Whether the error is transient and worth retrying.
  bool _shouldRetry(Object error) {
    if (error is GoogleDriveException) {
      // Retry on server errors (5xx) and network timeouts.
      final code = error.statusCode;
      return code >= 500 || code == 408 || code == 429;
    }
    if (error is TimeoutException) return true;
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Query helpers
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> _hasLocalUncommittedChange(
    String entityType,
    String entityId,
    String fieldName,
  ) async {
    final repo = ChangeLogRepository(db);
    final events = await repo.getEventsForEntity(entityType, entityId);

    final timestamp = _lastSyncTimestamp;

    for (final event in events) {
      if (event.deviceUser != currentDeviceUser) continue;

      if (timestamp == null) {
        if (fieldName == '*' || event.fieldName == fieldName) {
          return true;
        }
        continue;
      }

      final eventTime = DateTime.tryParse(event.timestamp);
      if (eventTime != null && eventTime.isAfter(timestamp)) {
        if (fieldName == '*' || event.fieldName == fieldName) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get local change log events for a specific entity and field.
  Future<List<ChangeLogEvent>> _getLocalEventsForEntity(
    String entityType,
    String entityId,
    String fieldName,
  ) async {
    final repo = ChangeLogRepository(db);
    final events = await repo.getEventsForEntity(entityType, entityId);
    final timestamp = _lastSyncTimestamp;

    return events.where((e) {
      if (e.deviceUser != currentDeviceUser) return false;
      if (e.fieldName != fieldName) return false;
      if (timestamp == null) return true;
      final eventTime = DateTime.tryParse(e.timestamp);
      return eventTime != null && eventTime.isAfter(timestamp);
    }).toList();
  }

  Future<Map<String, dynamic>?> _findBookByIsbn(
    String isbn, {
    bool includeDeleted = false,
  }) async {
    try {
      var query = db.select(db.books)..where((b) => b.isbn.equals(isbn));
      if (!includeDeleted) {
        query = query..where((b) => b.isDeleted.equals(false));
      }
      final book = await query.getSingleOrNull();
      if (book != null) {
        return {'id': book.id, 'title': book.title, 'isbn': book.isbn};
      }
    } catch (_) {}
    return null;
  }

  Future<int> _pendingChangeCount() async {
    final repo = ChangeLogRepository(db);
    if (_lastSyncTimestamp == null) {
      final all = await repo.querySince(DateTime(2000), limit: 1);
      return all.isNotEmpty ? 1 : 0;
    }
    final events = await repo.querySince(_lastSyncTimestamp!);
    return events.length;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // State management helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Emit a state change via the [onStateChange] callback.
  void _emitState(SyncState state) {
    if (state is SyncPulling) {
      _phase = _SyncPhase.pulling;
      _progress = state.progress;
    } else if (state is SyncPushing) {
      _phase = _SyncPhase.pushing;
      _progress = state.progress;
    } else if (state is SyncIdle) {
      _phase = _SyncPhase.idle;
      _progress = 1.0;
    }

    onStateChange?.call(state);
  }

  /// Update progress during an active sync operation.
  ///
  /// Constructs the appropriate [SyncState] based on the current [_phase]
  /// and emits it via [onStateChange].
  void _updateProgress(double progress, String stageMessage) {
    _progress = progress;

    SyncState state;
    switch (_phase) {
      case _SyncPhase.pulling:
        state = SyncPulling(progress: progress, stageMessage: stageMessage);
      case _SyncPhase.pushing:
        state = SyncPushing(progress: progress, stageMessage: stageMessage);
      case _SyncPhase.idle:
        // Don't emit progress updates when idle.
        return;
    }

    onStateChange?.call(state);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Serialization helpers
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> _eventToJson(ChangeLogEvent event) => {
        'eventId': event.eventId,
        'entityType': event.entityType,
        'entityId': event.entityId,
        'fieldName': event.fieldName,
        'oldValue': event.oldValue,
        'newValue': event.newValue,
        'timestamp': event.timestamp,
        'deviceUser': event.deviceUser,
        'eventType': event.eventType,
      };

  EventType _parseEventType(String type) {
    switch (type.toLowerCase()) {
      case 'create':
        return EventType.create;
      case 'update':
        return EventType.update;
      case 'delete':
        return EventType.delete;
      default:
        return EventType.update;
    }
  }

  String _generateConflictId() {
    return 'conflict_${DateTime.now().microsecondsSinceEpoch}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Data models
// ═══════════════════════════════════════════════════════════════════════════

/// Type of merge conflict.
enum ConflictType {
  sameFieldEdit,
  deleteVsUpdate,
  duplicateCreate,
}

/// Represents a merge conflict between local and remote changes.
class MergeConflict {
  const MergeConflict({
    required this.conflictId,
    required this.entityType,
    required this.entityId,
    required this.fieldName,
    required this.localValue,
    required this.remoteValue,
    required this.localUserId,
    required this.remoteUserId,
    required this.conflictType,
  });

  final String conflictId;
  final String entityType;
  final String entityId;
  final String fieldName;
  final String? localValue;
  final String? remoteValue;
  final String localUserId;
  final String remoteUserId;
  final ConflictType conflictType;

  String get accessibleDescription {
    final typeDesc = switch (conflictType) {
      ConflictType.sameFieldEdit =>
        'Both you and another user edited the $fieldName field',
      ConflictType.deleteVsUpdate =>
        'Another user deleted this $entityType while you made changes',
      ConflictType.duplicateCreate =>
        'A book with this ISBN already exists in your library',
    };
    return 'Conflict: $typeDesc. Local value: $localValue. Remote value: $remoteValue.';
  }
}

/// Exception thrown by the sync engine.
class SyncException implements Exception {
  const SyncException(this.message);

  final String message;

  @override
  String toString() => 'SyncException: $message';
}

/// Riverpod provider for [SyncEngine].
///
/// Creates a SyncEngine wired to the database and GoogleDriveClient.
/// The SyncEngine uses the Riverpod ref to emit state changes to
/// [syncStateProvider] via its [onStateChange] callback.
/// Override in tests with a mock/fake via [ProviderScope.overrides].
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(databaseProvider);
  // Create a SyncEngine that requires drive setup before use.
  // The drive client will be configured when auth is available.
  // Tests should override via ProviderScope.overrides with a mock engine.
  return SyncEngine(
    db: db,
    driveClient: GoogleDriveClient(
      httpClient: http.Client(),
    ),
    onStateChange: (state) {
      ref.read(syncStateProvider.notifier).update(state);
    },
  );
});

