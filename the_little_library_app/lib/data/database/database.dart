import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:thelittlelibrary/core/constants.dart';

import 'fts.dart';
import 'tables/app_metadata_table.dart';
import 'tables/author_table.dart';
import 'tables/book_author_table.dart';
import 'tables/book_genre_table.dart';
import 'tables/book_loan_table.dart';
import 'tables/book_shelf_table.dart';
import 'tables/book_table.dart';
import 'tables/book_tag_table.dart';
import 'tables/change_log_table.dart';
import 'tables/genre_table.dart';
import 'tables/language_table.dart';
import 'tables/location_tables.dart';
import 'tables/tag_table.dart';

import 'dao/book_dao.dart';
import 'dao/location_dao.dart';
import 'dao/genre_dao.dart';
import 'dao/language_dao.dart';
import 'dao/tag_dao.dart';
import 'dao/author_dao.dart';
import 'dao/change_log_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Books,
    Authors,
    BookAuthors,
    Genres,
    BookGenres,
    Tags,
    BookTags,
    Languages,
    BookLoans,
    Rooms,
    Cupboards,
    Shelves,
    BookShelves,
    ChangeLogEvents,
    AppMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  // DAO getters
  BookDao get bookDao => BookDao(this);
  LocationDao get locationDao => LocationDao(this);
  GenreDao get genreDao => GenreDao(this);
  LanguageDao get languageDao => LanguageDao(this);
  TagDao get tagDao => TagDao(this);
  AuthorDao get authorDao => AuthorDao(this);
  ChangeLogDao get changeLogDao => ChangeLogDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (Migrator m) async {
          await m.createAll();

          // Seed default app metadata (schema version = 1)
          await into(appMetadata).insert(AppMetadataCompanion.insert());

          // Create Google Books cache table (manually, since build_runner
          // cannot run due to pre-existing compilation errors in other
          // workstream files).
          await customStatement('''
            CREATE TABLE IF NOT EXISTS google_books_cache (
              cache_key TEXT NOT NULL PRIMARY KEY,
              query_type TEXT NOT NULL,
              query_value TEXT NOT NULL,
              results_json TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          // Create FTS5 virtual table and triggers
          await customStatement(createFts5Table);
          for (final trigger in fts5Triggers) {
            await customStatement(trigger);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'little_library.db'));
    return NativeDatabase(file);
  });
}
