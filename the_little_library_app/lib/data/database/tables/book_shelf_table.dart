import 'package:drift/drift.dart';

class BookShelves extends Table {
  @override
  String get tableName => 'book_shelf';

  TextColumn get bookId =>
      text().customConstraint('REFERENCES book(id)').unique()();

  TextColumn get shelfId =>
      text().nullable().customConstraint('REFERENCES shelf(id)')();

  @override
  Set<Column> get primaryKey => {bookId};
}
