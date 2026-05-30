import 'package:drift/drift.dart';

@TableIndex(name: 'idx_change_log_entity_timestamp', columns: {#entityType, #timestamp})
@TableIndex(name: 'idx_change_log_entity_id_timestamp', columns: {#entityType, #entityId, #timestamp})
class ChangeLogEvents extends Table {
  @override
  String get tableName => 'change_log';

  TextColumn get eventId => text().withLength(min: 36, max: 36)();

  TextColumn get entityType => text().withLength(min: 1)();

  TextColumn get entityId => text().withLength(min: 36, max: 36)();

  TextColumn get fieldName => text().withLength(min: 1)();

  TextColumn get oldValue => text().nullable()();

  TextColumn get newValue => text().nullable()();

  TextColumn get timestamp =>
      text().clientDefault(() => DateTime.now().toIso8601String())();

  TextColumn get deviceUser => text().withLength(min: 1)();

  TextColumn get eventType => text().withLength(min: 1)();

  @override
  Set<Column> get primaryKey => {eventId};
}
