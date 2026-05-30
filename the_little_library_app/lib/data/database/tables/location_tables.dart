import 'package:drift/drift.dart';

@TableIndex(name: 'idx_room_name', columns: {#name})
class Rooms extends Table {
  @override
  String get tableName => 'room';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get name => text()
      .withLength(min: 1)
      .customConstraint('COLLATE NOCASE NOT NULL UNIQUE')();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_cupboard_room_id', columns: {#roomId})
class Cupboards extends Table {
  @override
  String get tableName => 'cupboard';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get name => text().withLength(min: 1)();

  TextColumn get roomId => text().customConstraint('REFERENCES room(id)')();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_shelf_cupboard_id', columns: {#cupboardId})
class Shelves extends Table {
  @override
  String get tableName => 'shelf';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get name => text().withLength(min: 1)();

  TextColumn get cupboardId =>
      text().customConstraint('REFERENCES cupboard(id)')();

  @override
  Set<Column> get primaryKey => {id};
}
