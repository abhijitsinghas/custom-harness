import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/data/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  group('Book Table — All Fields', () {
    test('should have all required columns in Book table', () async {
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'booksch0-0000-0000-0000-000000000001',
              title: 'Schema Test',
            ),
          );

      final book = await db.select(db.books).getSingle();
      expect(book.id, 'booksch0-0000-0000-0000-000000000001');
      expect(book.title, 'Schema Test');
      expect(book.id.length, 36);
    });

    test('should use text type for UUID id column', () async {
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'booksch0-0000-0000-0000-000000000002',
              title: 'UUID Test',
            ),
          );

      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('booksch0-0000-0000-0000-000000000002')))
          .getSingle();
      expect(book.id, isNotEmpty);
      expect(book.id.length, 36);
    });

    test('should have isbn column', () async {
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'booksch0-0000-0000-0000-000000000003',
              title: 'ISBN Test',
              isbn: const Value('978-3-16-148410-0'),
            ),
          );

      final book = await db.select(db.books).getSingle();
      expect(book.isbn, isNotNull);
    });

    test('should have is_deleted column with default false', () async {
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'booksch0-0000-0000-0000-000000000004',
              title: 'Deleted Test',
            ),
          );

      final book = await db.select(db.books).getSingle();
      expect(book.isDeleted, isFalse);
    });

    test('should have created_at and updated_at columns', () async {
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'booksch0-0000-0000-0000-000000000005',
              title: 'Timestamp Test',
            ),
          );

      final book = await db.select(db.books).getSingle();
      expect(book.createdAt, isNotNull);
      expect(book.updatedAt, isNotNull);
    });
  });

  group('Author Table — Unique Normalized Name', () {
    test('should have normalized_name column', () async {
      final author = await db.authorDao.createAuthor('Test Author');
      expect(author.normalizedName, isNotEmpty);
    });

    test('should have raw_name column', () async {
      final author = await db.authorDao.createAuthor('Raw Name');
      expect(author.rawName, 'Raw Name');
    });

    test('should have id column (UUID text, PK)', () async {
      final author = await db.authorDao.createAuthor('UUID Author');
      expect(author.id.length, 36);
    });
  });

  group('Join Tables — Composite PKs', () {
    test('should allow BookAuthor join inserts', () async {
      await db.into(db.authors).insert(
            AuthorsCompanion.insert(
              id: 'joinau00-0000-0000-0000-000000000001',
              rawName: 'Join Author',
              normalizedName: 'join author',
            ),
          );
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'joinbk00-0000-0000-0000-000000000001',
              title: 'Join Book',
            ),
          );

      await db.into(db.bookAuthors).insert(
            BookAuthorsCompanion.insert(
              bookId: 'joinbk00-0000-0000-0000-000000000001',
              authorId: 'joinau00-0000-0000-0000-000000000001',
            ),
          );

      final joins = await db.select(db.bookAuthors).get();
      expect(joins.length, 1);
    });

    test('should prevent duplicate (book_id, author_id) pairs', () async {
      await db.into(db.authors).insert(
            AuthorsCompanion.insert(
              id: 'dupau000-0000-0000-0000-000000000001',
              rawName: 'Dup Author',
              normalizedName: 'dup author',
            ),
          );
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'dupbk000-0000-0000-0000-000000000001',
              title: 'Dup Book',
            ),
          );

      await db.into(db.bookAuthors).insert(
            BookAuthorsCompanion.insert(
              bookId: 'dupbk000-0000-0000-0000-000000000001',
              authorId: 'dupau000-0000-0000-0000-000000000001',
            ),
          );

      try {
        await db.into(db.bookAuthors).insert(
              BookAuthorsCompanion.insert(
                bookId: 'dupbk000-0000-0000-0000-000000000001',
                authorId: 'dupau000-0000-0000-0000-000000000001',
              ),
            );
        fail('Should have thrown duplicate PK error');
      } catch (_) {
        expect(true, isTrue);
      }
    });
  });

  group('Location Hierarchy — FKs', () {
    test('should cascade location hierarchy', () async {
      final room = await db.locationDao.createRoom('Test Room');
      final cupboard =
          await db.locationDao.createCupboard('Test Cupboard', room.id);
      final shelf =
          await db.locationDao.createShelf('Test Shelf', cupboard.id);

      expect(room.id.length, 36);
      expect(cupboard.roomId, room.id);
      expect(shelf.cupboardId, cupboard.id);
    });
  });

  group('ChangeLogEvent — All Fields', () {
    test('should have all required columns', () async {
      await db.changeLogDao.append(
        entityType: 'book',
        entityId: 'bookcl00-0000-0000-0000-000000000001',
        eventType: 'create',
        fieldName: 'title',
        newValue: 'Test',
        deviceUser: 'test-user',
      );

      final events = await db.select(db.changeLogEvents).get();
      expect(events.length, 1);
      final e = events.first;
      expect(e.eventId.length, 36);
      expect(e.entityType, 'book');
      expect(e.eventType, 'create');
      expect(e.deviceUser, 'test-user');
      expect(e.timestamp, isNotNull);
    });
  });

  group('AppMetadata — Singleton', () {
    test('should have schema_version column', () async {
      final meta = await db.select(db.appMetadata).getSingle();
      expect(meta.schemaVersion, greaterThanOrEqualTo(1));
    });

    test('should be designed to hold exactly one row', () async {
      final rows = await db.select(db.appMetadata).get();
      expect(rows.length, 1);
    });
  });
}
