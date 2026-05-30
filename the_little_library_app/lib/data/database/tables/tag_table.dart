import 'package:drift/drift.dart';

class Tags extends Table {
  @override
  String get tableName => 'tag';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get name => text().withLength(min: 1).unique()();

  @override
  Set<Column> get primaryKey => {id};
}
