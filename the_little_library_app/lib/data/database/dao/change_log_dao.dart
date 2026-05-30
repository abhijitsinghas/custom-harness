import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

const _uuid = Uuid();

/// DAO for change log event operations.
@DriftAccessor()
class ChangeLogDao {
  final AppDatabase _db;

  ChangeLogDao(this._db);

  /// Appends a change log event with all required fields.
  Future<void> append({
    String? eventId,
    required String entityType,
    required String entityId,
    required String eventType,
    required String fieldName,
    String? oldValue,
    String? newValue,
    required String deviceUser,
  }) async {
    final id = eventId ?? _uuid.v4();
    final timestamp = DateTime.now().toIso8601String();

    await _db.into(_db.changeLogEvents).insert(
          ChangeLogEventsCompanion.insert(
            eventId: id,
            entityType: entityType,
            entityId: entityId,
            eventType: eventType,
            fieldName: fieldName,
            oldValue: Value(oldValue),
            newValue: Value(newValue),
            deviceUser: deviceUser,
            timestamp: Value(timestamp),
          ),
        );
  }

  /// Queries events since a given timestamp, sorted descending.
  Future<List<ChangeLogEvent>> querySince(
    String timestamp, {
    int? limit,
    int? offset,
  }) async {
    var query = _db.select(_db.changeLogEvents)
      ..where((e) => e.timestamp.isBiggerThanValue(timestamp))
      ..orderBy([(e) => OrderingTerm.desc(e.timestamp)]);

    if (limit != null) {
      query = query..limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  /// Queries all events for a specific entity type and id.
  Future<List<ChangeLogEvent>> getEventsForEntity(
    String entityType,
    String entityId,
  ) async {
    return (_db.select(_db.changeLogEvents)
          ..where((e) =>
              e.entityType.equals(entityType) & e.entityId.equals(entityId))
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)]))
        .get();
  }
}
