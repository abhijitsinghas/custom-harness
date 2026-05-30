import 'package:drift/drift.dart';

@TableIndex(name: 'idx_book_genre_book_id', columns: {#bookId})
@TableIndex(name: 'idx_book_genre_genre_id', columns: {#genreId})
class BookGenres extends Table {
  @override
  String get tableName => 'book_genre';

  TextColumn get bookId =>
      text().customConstraint('REFERENCES book(id)')();

  TextColumn get genreId =>
      text().customConstraint('REFERENCES genre(id)')();

  @override
  Set<Column> get primaryKey => {bookId, genreId};
}
