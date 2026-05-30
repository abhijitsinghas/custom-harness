import 'package:drift/drift.dart';

class AppMetadata extends Table {
  @override
  String get tableName => 'app_metadata';

  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {schemaVersion};
}
