import 'package:drift/drift.dart';

@TableIndex(name: 'idx_language_name', columns: {#name})
class Languages extends Table {
  @override
  String get tableName => 'language';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get name => text()
      .withLength(min: 1)
      .customConstraint('COLLATE NOCASE NOT NULL UNIQUE')();

  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
