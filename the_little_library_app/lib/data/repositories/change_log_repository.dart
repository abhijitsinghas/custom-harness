import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'database_provider.dart';

/// Repository for the append-only change log.
/// US-0.3.8: Change Log Repository Interface
class ChangeLogRepository {
  ChangeLogRepository(this._db);

  final AppDatabase _db;

  /// Append a change log event.
  Future<void> appendEvent(ChangeLogEvent event) async {
    await _db.into(_db.changeLogEvents).insert(
          ChangeLogEventsCompanion.insert(
            eventId: event.eventId,
            entityType: event.entityType,
            entityId: event.entityId,
            fieldName: event.fieldName,
            oldValue: Value(event.oldValue),
            newValue: Value(event.newValue),
            timestamp: Value(event.timestamp),
            deviceUser: event.deviceUser,
            eventType: event.eventType,
          ),
        );
  }

  /// Alias for [appendEvent].
  Future<void> append(ChangeLogEvent event) => appendEvent(event);

  /// Query change log events since a given [timestamp], sorted descending.
  ///
  /// The [timestamp] is converted to an ISO 8601 string for comparison
  /// against the text-based timestamp column.
  Future<List<ChangeLogEvent>> querySince(
    DateTime timestamp, {
    int? limit,
    int? offset,
  }) async {
    final timestampStr = timestamp.toIso8601String();
    var query = (_db.select(_db.changeLogEvents)
      ..where((c) => c.timestamp.isBiggerOrEqualValue(timestampStr))
      ..orderBy([(c) => OrderingTerm.desc(c.timestamp)]));
    if (limit != null) {
      query = query..limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  /// Get change log events for a specific entity.
  Future<List<ChangeLogEvent>> getEventsForEntity(
    String entityType,
    String entityId,
  ) async {
    return (_db.select(_db.changeLogEvents)
          ..where((c) =>
              c.entityType.equals(entityType) & c.entityId.equals(entityId))
          ..orderBy([(c) => OrderingTerm.desc(c.timestamp)]))
        .get();
  }

  /// Alias for [getEventsForEntity].
  Future<List<ChangeLogEvent>> getByEntity(
    String entityType,
    String entityId,
  ) =>
      getEventsForEntity(entityType, entityId);

  /// Query change log since a timestamp, accepting [DateTime] timestamp,
  /// limit, and offset.
  Future<List<ChangeLogEvent>> getSince(
    DateTime timestamp, {
    int? limit,
    int? offset,
  }) =>
      querySince(timestamp, limit: limit, offset: offset);
}

/// Riverpod provider for [ChangeLogRepository].
final changeLogRepoProvider = Provider<ChangeLogRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ChangeLogRepository(db);
});
