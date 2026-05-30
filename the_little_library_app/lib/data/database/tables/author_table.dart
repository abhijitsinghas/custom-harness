import 'package:drift/drift.dart';

@TableIndex(name: 'idx_author_normalized_name', columns: {#normalizedName})
@TableIndex(name: 'idx_author_raw_name', columns: {#rawName})
class Authors extends Table {
  @override
  String get tableName => 'author';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get rawName =>
      text().withLength(min: 1).customConstraint('COLLATE NOCASE NOT NULL')();

  TextColumn get normalizedName => text()
      .withLength(min: 1)
      .customConstraint('COLLATE NOCASE NOT NULL UNIQUE')();

  TextColumn get disambiguation => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
