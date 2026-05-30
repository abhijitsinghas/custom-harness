import 'package:drift/drift.dart';

@TableIndex(name: 'idx_book_author_book_id', columns: {#bookId})
@TableIndex(name: 'idx_book_author_author_id', columns: {#authorId})
class BookAuthors extends Table {
  @override
  String get tableName => 'book_author';

  TextColumn get bookId =>
      text().customConstraint('REFERENCES book(id)')();

  TextColumn get authorId =>
      text().customConstraint('REFERENCES author(id)')();

  @override
  Set<Column> get primaryKey => {bookId, authorId};
}
