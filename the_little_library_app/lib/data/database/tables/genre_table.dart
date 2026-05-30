import 'package:drift/drift.dart';

@TableIndex(name: 'idx_genre_name', columns: {#name})
class Genres extends Table {
  @override
  String get tableName => 'genre';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get name => text()
      .withLength(min: 1)
      .customConstraint('COLLATE NOCASE NOT NULL UNIQUE')();

  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
