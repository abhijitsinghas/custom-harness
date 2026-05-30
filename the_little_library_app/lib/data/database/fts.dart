/// FTS5 virtual table creation and management for full-text search on Books.
///
/// Provides the SQL statements to create and maintain FTS5 virtual tables
/// over the [book] table, indexing [title], [isbn], and [publisher].
library;

/// SQL to create the FTS5 virtual table over book title, isbn, publisher.
const String createFts5Table = '''
  CREATE VIRTUAL TABLE IF NOT EXISTS book_fts USING fts5(
    title,
    isbn,
    publisher,
    content='book',
    content_rowid='rowid',
    tokenize='unicode61 remove_diacritics 2'
  );
''';

/// SQL to create initial FTS5 triggers (insert, delete, update)
/// that keep the FTS5 index in sync with the book table.
const List<String> fts5Triggers = [
  '''
  CREATE TRIGGER IF NOT EXISTS book_fts_insert AFTER INSERT ON book BEGIN
    INSERT INTO book_fts(rowid, title, isbn, publisher)
    VALUES (new.rowid, new.title, new.isbn, new.publisher);
  END;
  ''',
  '''
  CREATE TRIGGER IF NOT EXISTS book_fts_delete AFTER DELETE ON book BEGIN
    INSERT INTO book_fts(book_fts, rowid, title, isbn, publisher)
    VALUES ('delete', old.rowid, old.title, old.isbn, old.publisher);
  END;
  ''',
  '''
  CREATE TRIGGER IF NOT EXISTS book_fts_update AFTER UPDATE ON book BEGIN
    INSERT INTO book_fts(book_fts, rowid, title, isbn, publisher)
    VALUES ('delete', old.rowid, old.title, old.isbn, old.publisher);
    INSERT INTO book_fts(rowid, title, isbn, publisher)
    VALUES (new.rowid, new.title, new.isbn, new.publisher);
  END;
  ''',
];
