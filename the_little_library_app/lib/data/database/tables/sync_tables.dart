import 'package:drift/drift.dart';

/// Immutable event journal for every write operation in the app.
///
/// Used by the sync engine for incremental pushes and conflict-resolving
/// merges.  A snapshot is created every 1000 events so merges only replay
/// events since the last snapshot.
///
/// The FTS5 virtual table `book_fts` (on Book.title, Book.isbn, Book.publisher)
/// is **not** modelled as a drift table class; it is created via custom SQL
/// in [AppDatabase]'s migration strategy. See `database.dart`.
@TableIndex(name: 'idx_changelog_type_ts', columns: {#entityType, #timestamp})
@TableIndex(
  name: 'idx_changelog_type_entity_ts',
  columns: {#entityType, #entityId, #timestamp},
)
class ChangeLog extends Table {
  /// UUID v4 primary key — unique event identifier.
  TextColumn get eventId => text()();

  /// Type of entity: `book`, `location`, `genre`, `tag`, `author`, `loan`,
  /// `language`.
  TextColumn get entityType => text()();

  /// UUID of the changed entity.
  TextColumn get entityId => text()();

  /// Which field changed. `*` for creates (whole entity).
  TextColumn get fieldName => text()();

  /// Previous value. Null for creates.
  TextColumn get oldValue => text().nullable()();

  /// New value. Full entity JSON for creates.
  TextColumn get newValue => text().nullable()();

  /// ISO 8601 timestamp.
  TextColumn get timestamp => text()();

  /// Google account email of the user who made the change.
  TextColumn get deviceUser => text()();

  /// `create`, `update`, or `delete`.
  TextColumn get eventType => text()();

  @override
  Set<Column> get primaryKey => {eventId};

  @override
  String get tableName => 'change_log';
}
