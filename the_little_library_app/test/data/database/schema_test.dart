import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:the_little_library_app/data/database/database.dart';

/// Validates that every table, column, foreign key, and index from spec-v2.md
/// is present in the generated schema.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns all table names in the database.
  Future<List<String>> allTableNames(AppDatabase db) async {
    final rows = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    ).get();
    return rows.map((r) => r.read<String>('name')).toList();
  }

  /// Returns column info for [table] as a list of {name, type, notnull}.
  Future<List<Map<String, dynamic>>> tableInfo(
    AppDatabase db,
    String table,
  ) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows
        .map((r) => {
              'name': r.read<String>('name'),
              'type': r.read<String>('type'),
              'notnull': r.read<int>('notnull') == 1,
            })
        .toList();
  }

  /// Returns foreign key info for [table] as a list of {from, to, table}.
  Future<List<Map<String, dynamic>>> foreignKeys(
    AppDatabase db,
    String table,
  ) async {
    final rows =
        await db.customSelect('PRAGMA foreign_key_list($table)').get();
    return rows
        .map((r) => {
              'from': r.read<String>('from'),
              'to': r.read<String>('to'),
              'table': r.read<String>('table'),
            })
        .toList();
  }

  /// Returns index names for [table].
  Future<List<String>> indexNames(AppDatabase db, String table) async {
    final rows = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name=?",
      variables: [Variable.withString(table)],
    ).get();
    return rows.map((r) => r.read<String>('name')).toList();
  }

  // ── Table existence ──────────────────────────────────────────────────────

  test('should contain all 14 expected tables + book_fts', () async {
    final names = await allTableNames(db);

    expect(names, contains('book'));
    expect(names, contains('book_author'));
    expect(names, contains('book_genre'));
    expect(names, contains('book_tag'));
    expect(names, contains('book_shelf'));
    expect(names, contains('book_loan'));
    expect(names, contains('author'));
    expect(names, contains('genre'));
    expect(names, contains('tag'));
    expect(names, contains('language'));
    expect(names, contains('room'));
    expect(names, contains('cupboard'));
    expect(names, contains('shelf'));
    expect(names, contains('change_log'));
    expect(names, contains('book_fts'));
  });

  // ── Book table ───────────────────────────────────────────────────────────

  group('Book table', () {
    test('should have all 21 columns', () async {
      final cols = await tableInfo(db, 'book');
      final names = cols.map((c) => c['name']).toSet();

      expect(names, contains('id'));
      expect(names, contains('title'));
      expect(names, contains('isbn'));
      expect(names, contains('language_id'));
      expect(names, contains('cover_image_path'));
      expect(names, contains('cover_image_url'));
      expect(names, contains('publisher'));
      expect(names, contains('edition'));
      expect(names, contains('publication_date'));
      expect(names, contains('format'));
      expect(names, contains('page_count'));
      expect(names, contains('description'));
      expect(names, contains('condition'));
      expect(names, contains('price_paid'));
      expect(names, contains('purchase_date'));
      expect(names, contains('notes'));
      expect(names, contains('status'));
      expect(names, contains('checked_out_to'));
      expect(names, contains('is_deleted'));
      expect(names, contains('created_at'));
      expect(names, contains('updated_at'));
      expect(names.length, 21);
    });

    test('should have is_deleted defaulting to 0 (false)', () async {
      final cols = await tableInfo(db, 'book');
      final isDeleted = cols.firstWhere((c) => c['name'] == 'is_deleted');
      expect(isDeleted['notnull'], isTrue);
    });

    test('should have all expected indices', () async {
      final indices = await indexNames(db, 'book');
      expect(indices, contains('idx_book_title'));
      expect(indices, contains('idx_book_isbn'));
      expect(indices, contains('idx_book_language_id'));
      expect(indices, contains('idx_book_format'));
      expect(indices, contains('idx_book_condition'));
      expect(indices, contains('idx_book_purchase_date'));
      expect(indices, contains('idx_book_created_at'));
      expect(indices, contains('idx_book_status'));
      expect(indices, contains('idx_book_checked_out_to'));
    });
  });

  // ── Join tables ──────────────────────────────────────────────────────────

  group('BookAuthor table', () {
    test('should have book_id + author_id columns', () async {
      final cols = await tableInfo(db, 'book_author');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('book_id'));
      expect(names, contains('author_id'));
    });

    test('should have book_id index', () async {
      final indices = await indexNames(db, 'book_author');
      expect(indices, contains('idx_book_author_book_id'));
      expect(indices, contains('idx_book_author_author_id'));
    });

    test('should have FK from book_id → book.id', () async {
      final fks = await foreignKeys(db, 'book_author');
      final bookFk = fks.firstWhere((f) => f['from'] == 'book_id');
      expect(bookFk['table'], 'book');
      expect(bookFk['to'], 'id');
    });
  });

  group('BookGenre table', () {
    test('should have book_id + genre_id columns', () async {
      final cols = await tableInfo(db, 'book_genre');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('book_id'));
      expect(names, contains('genre_id'));
    });

    test('should have both indices', () async {
      final indices = await indexNames(db, 'book_genre');
      expect(indices, contains('idx_book_genre_book_id'));
      expect(indices, contains('idx_book_genre_genre_id'));
    });
  });

  group('BookTag table', () {
    test('should have book_id + tag_id columns', () async {
      final cols = await tableInfo(db, 'book_tag');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('book_id'));
      expect(names, contains('tag_id'));
    });

    test('should have both indices', () async {
      final indices = await indexNames(db, 'book_tag');
      expect(indices, contains('idx_book_tag_book_id'));
      expect(indices, contains('idx_book_tag_tag_id'));
    });
  });

  group('BookShelf table', () {
    test('should have book_id (PK) + shelf_id', () async {
      final cols = await tableInfo(db, 'book_shelf');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('book_id'));
      expect(names, contains('shelf_id'));
    });

    test('should have shelf_id index', () async {
      final indices = await indexNames(db, 'book_shelf');
      expect(indices, contains('idx_book_shelf_shelf_id'));
    });
  });

  group('BookLoan table', () {
    test('should have all 10 columns', () async {
      final cols = await tableInfo(db, 'book_loan');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('book_id'));
      expect(names, contains('borrower_name'));
      expect(names, contains('borrower_contact'));
      expect(names, contains('loaned_date'));
      expect(names, contains('due_date'));
      expect(names, contains('returned_date'));
      expect(names, contains('notes'));
      expect(names, contains('created_at'));
      expect(names, contains('created_by'));
      expect(names.length, 10);
    });

    test('should have indices on book_id+returned_date and borrower_name',
        () async {
      final indices = await indexNames(db, 'book_loan');
      expect(indices, contains('idx_book_loan_book_returned'));
      expect(indices, contains('idx_book_loan_borrower'));
    });
  });

  // ── Reference tables ─────────────────────────────────────────────────────

  group('Author table', () {
    test('should have all columns', () async {
      final cols = await tableInfo(db, 'author');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('raw_name'));
      expect(names, contains('normalized_name'));
      expect(names, contains('disambiguation'));
    });

    test('should have indices on normalized_name + raw_name', () async {
      final indices = await indexNames(db, 'author');
      expect(indices, contains('idx_author_normalized_name'));
      expect(indices, contains('idx_author_raw_name'));
    });
  });

  group('Genre table', () {
    test('should have id, name, is_custom', () async {
      final cols = await tableInfo(db, 'genre');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('name'));
      expect(names, contains('is_custom'));
    });

    test('should have index on name', () async {
      final indices = await indexNames(db, 'genre');
      expect(indices, contains('idx_genre_name'));
    });
  });

  group('Tag table', () {
    test('should have id + name', () async {
      final cols = await tableInfo(db, 'tag');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('name'));
    });

    test('should have index on name', () async {
      final indices = await indexNames(db, 'tag');
      expect(indices, contains('idx_tag_name'));
    });
  });

  group('Language table', () {
    test('should have id, name, is_builtin', () async {
      final cols = await tableInfo(db, 'language');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('name'));
      expect(names, contains('is_builtin'));
    });

    test('should have index on name', () async {
      final indices = await indexNames(db, 'language');
      expect(indices, contains('idx_language_name'));
    });
  });

  // ── Location tables ──────────────────────────────────────────────────────

  group('Room table', () {
    test('should have id + name', () async {
      final cols = await tableInfo(db, 'room');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('name'));
    });

    test('should have index on name', () async {
      final indices = await indexNames(db, 'room');
      expect(indices, contains('idx_room_name'));
    });
  });

  group('Cupboard table', () {
    test('should have id, name, room_id', () async {
      final cols = await tableInfo(db, 'cupboard');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('name'));
      expect(names, contains('room_id'));
    });

    test('should have FK from room_id → room.id', () async {
      final fks = await foreignKeys(db, 'cupboard');
      final roomFk = fks.firstWhere((f) => f['from'] == 'room_id');
      expect(roomFk['table'], 'room');
      expect(roomFk['to'], 'id');
    });

    test('should have index on room_id', () async {
      final indices = await indexNames(db, 'cupboard');
      expect(indices, contains('idx_cupboard_room_id'));
    });
  });

  group('Shelf table', () {
    test('should have id, name, cupboard_id', () async {
      final cols = await tableInfo(db, 'shelf');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('id'));
      expect(names, contains('name'));
      expect(names, contains('cupboard_id'));
    });

    test('should have FK from cupboard_id → cupboard.id', () async {
      final fks = await foreignKeys(db, 'shelf');
      final cupboardFk = fks.firstWhere((f) => f['from'] == 'cupboard_id');
      expect(cupboardFk['table'], 'cupboard');
      expect(cupboardFk['to'], 'id');
    });

    test('should have index on cupboard_id', () async {
      final indices = await indexNames(db, 'shelf');
      expect(indices, contains('idx_shelf_cupboard_id'));
    });
  });

  // ── ChangeLog table ──────────────────────────────────────────────────────

  group('ChangeLog table', () {
    test('should have all 9 columns', () async {
      final cols = await tableInfo(db, 'change_log');
      final names = cols.map((c) => c['name']).toSet();
      expect(names, contains('event_id'));
      expect(names, contains('entity_type'));
      expect(names, contains('entity_id'));
      expect(names, contains('field_name'));
      expect(names, contains('old_value'));
      expect(names, contains('new_value'));
      expect(names, contains('timestamp'));
      expect(names, contains('device_user'));
      expect(names, contains('event_type'));
      expect(names.length, 9);
    });

    test('should have indices on entity_type+timestamp and entity+entity+ts',
        () async {
      final indices = await indexNames(db, 'change_log');
      expect(indices, contains('idx_changelog_type_ts'));
      expect(indices, contains('idx_changelog_type_entity_ts'));
    });
  });

  // ── FTS5 virtual table ───────────────────────────────────────────────────

  group('book_fts virtual table', () {
    test('should exist', () async {
      final names = await allTableNames(db);
      expect(names, contains('book_fts'));
    });

    test('should be a virtual FTS5 table', () async {
      final rows = await db.customSelect(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='book_fts'",
      ).get();
      expect(rows, isNotEmpty);
      final sql = rows.first.read<String>('sql');
      expect(sql, contains('USING fts5'));
    });
  });
}
