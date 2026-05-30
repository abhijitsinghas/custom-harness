import 'package:drift/drift.dart';

@TableIndex(name: 'idx_book_tag_book_id', columns: {#bookId})
@TableIndex(name: 'idx_book_tag_tag_id', columns: {#tagId})
class BookTags extends Table {
  @override
  String get tableName => 'book_tag';

  TextColumn get bookId =>
      text().customConstraint('REFERENCES book(id)')();

  TextColumn get tagId =>
      text().customConstraint('REFERENCES tag(id)')();

  @override
  Set<Column> get primaryKey => {bookId, tagId};
}
