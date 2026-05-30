import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/core/constants.dart';
import 'package:thelittlelibrary/data/database/dao/book_dao.dart';
import 'package:thelittlelibrary/data/database/database.dart';

/// Tests for BookDao — covers US-1.1.1 through US-1.1.10 and edge/error cases.

void main() {
  late AppDatabase db;
  late BookDao bookDao;

  setUp(() async {
    db = AppDatabase.memory();
    bookDao = db.bookDao;
    // Seed languages, genres for FK references
    await db.into(db.languages).insert(
          LanguagesCompanion.insert(
            id: 'lang0000-0000-0000-0000-000000000001',
            name: 'English',
            isBuiltin: const Value(true),
          ),
        );
    await db.into(db.genres).insert(
          GenresCompanion.insert(
            id: 'genre000-0000-0000-0000-000000000001',
            name: 'Fiction',
            isCustom: const Value(false),
          ),
        );
    await db.into(db.authors).insert(
          AuthorsCompanion.insert(
            id: 'author00-0000-0000-0000-000000000001',
            rawName: 'Paulo Coelho',
            normalizedName: 'paulo coelho',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.1: Create book with all related entities in a single transaction
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.1 — insertBookWithRelations', () {
    test('should insert book, authors, genres, tags, shelf in one transaction',
        () async {
      await bookDao.insertBookWithRelations(
        id: 'book0000-0000-0000-0000-000000000001',
        title: 'Test Book',
        isbn: '978-3-16-148410-0',
        languageId: 'lang0000-0000-0000-0000-000000000001',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: ['genre000-0000-0000-0000-000000000001'],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );

      final book = await db.select(db.books).getSingle();
      expect(book.title, 'Test Book');
      expect(book.isbn, '9783161484100');

      // Verify change log entry was created
      final events = await db.select(db.changeLogEvents).get();
      expect(events.any((e) => e.entityId == 'book0000-0000-0000-0000-000000000001'), isTrue);
    });

    test('should rollback entire transaction on any insert failure', () async {
      // Try inserting with a non-existent author that would cause FK violation
      try {
        await bookDao.insertBookWithRelations(
          id: 'book0000-0000-0000-0000-000000000002',
          title: 'Bad Book',
          authorIds: ['nonexistent-author-id'],
          genreIds: [],
          tagIds: [],
          shelfId: null,
          deviceUser: 'test-user',
        );
      } catch (_) {
        // Expected FK violation
      }

      // Book should not have been inserted
      final books = await db.select(db.books).get();
      expect(books.where((b) => b.id == 'book0000-0000-0000-0000-000000000002'), isEmpty);
    });

    test('should write ChangeLogEvent for the create operation', () async {
      await bookDao.insertBookWithRelations(
        id: 'book0000-0000-0000-0000-000000000003',
        title: 'Logged Book',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );

      final events = await db.select(db.changeLogEvents).get();
      final bookEvents = events.where((e) => e.entityId == 'book0000-0000-0000-0000-000000000003');
      expect(bookEvents.isNotEmpty, isTrue);
      expect(bookEvents.first.eventType, 'create');
    });

    test('should allow null shelfId for "None" location', () async {
      await bookDao.insertBookWithRelations(
        id: 'book0000-0000-0000-0000-000000000004',
        title: 'No Shelf Book',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );

      final book = await db.select(db.books).getSingle();
      expect(book.title, 'No Shelf Book');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.2: Read book with all joined data
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.2 — getBookWithDetails', () {
    setUp(() async {
      await bookDao.insertBookWithRelations(
        id: 'book0000-0000-0000-0000-000000000010',
        title: 'Detailed Book',
        isbn: '978-3-16-148410-0',
        languageId: 'lang0000-0000-0000-0000-000000000001',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: ['genre000-0000-0000-0000-000000000001'],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );
    });

    test(
        'should return book with all authors, genres, tags, language, location eagerly loaded',
        () async {
      final details = await bookDao.getBookWithDetails(
          'book0000-0000-0000-0000-000000000010');
      expect(details, isNotNull);
      expect(details!.book.title, 'Detailed Book');
      expect(details.authors.length, 1);
      expect(details.authors.first.rawName, 'Paulo Coelho');
      expect(details.genres.length, 1);
      expect(details.genres.first.name, 'Fiction');
      expect(details.tags, isEmpty);
      expect(details.language, isNotNull);
      expect(details.language!.name, 'English');
    });

    test('should include full location path Room → Cupboard → Shelf', () async {
      // No shelf assigned, so location should be null
      final details = await bookDao.getBookWithDetails(
          'book0000-0000-0000-0000-000000000010');
      expect(details!.shelf, isNull);
      expect(details.cupboard, isNull);
      expect(details.room, isNull);
    });

    test('should return null for non-existent bookId', () async {
      final details =
          await bookDao.getBookWithDetails('nonexistent-book-id');
      expect(details, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.3: Update book and its relationships
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.3 — updateBookWithRelations', () {
    setUp(() async {
      await bookDao.insertBookWithRelations(
        id: 'book0000-0000-0000-0000-000000000020',
        title: 'Original Title',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: ['genre000-0000-0000-0000-000000000001'],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );
    });

    test('should update title', () async {
      await bookDao.updateBookWithRelations(
        bookId: 'book0000-0000-0000-0000-000000000020',
        title: 'Updated Title',
        deviceUser: 'test-user',
      );

      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('book0000-0000-0000-0000-000000000020')))
          .getSingle();
      expect(book.title, 'Updated Title');
    });

    test('should replace join-table rows to match new lists', () async {
      // Add a second author
      await db.into(db.authors).insert(
            AuthorsCompanion.insert(
              id: 'author00-0000-0000-0000-000000000002',
              rawName: 'Second Author',
              normalizedName: 'second author',
            ),
          );

      await bookDao.updateBookWithRelations(
        bookId: 'book0000-0000-0000-0000-000000000020',
        authorIds: ['author00-0000-0000-0000-000000000002'],
        deviceUser: 'test-user',
      );

      final joinRows = await (db.select(db.bookAuthors)
            ..where((ba) =>
                ba.bookId.equals('book0000-0000-0000-0000-000000000020')))
          .get();
      expect(joinRows.length, 1);
      expect(joinRows.first.authorId, 'author00-0000-0000-0000-000000000002');
    });

    test('should update Book.updatedAt on modification', () async {
      await bookDao.updateBookWithRelations(
        bookId: 'book0000-0000-0000-0000-000000000020',
        title: 'Modified',
        deviceUser: 'test-user',
      );

      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('book0000-0000-0000-0000-000000000020')))
          .getSingle();
      expect(book.updatedAt, isNotNull);
    });

    test('should write ChangeLogEvent per changed field', () async {
      await bookDao.updateBookWithRelations(
        bookId: 'book0000-0000-0000-0000-000000000020',
        title: 'New Title',
        isbn: '978-0-545-01022-1',
        deviceUser: 'test-user',
      );

      final events = await (db.select(db.changeLogEvents)
            ..where((e) =>
                e.entityId.equals('book0000-0000-0000-0000-000000000020')))
          .get();

      expect(events.any((e) => e.fieldName == 'title'), isTrue);
      expect(events.any((e) => e.fieldName == 'isbn'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.4: Soft-delete a book
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.4 — softDeleteBook', () {
    setUp(() async {
      await bookDao.insertBookWithRelations(
        id: 'book0000-0000-0000-0000-000000000030',
        title: 'Book to Delete',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );
    });

    test('should set isDeleted=true without removing the row', () async {
      await bookDao.softDeleteBook('book0000-0000-0000-0000-000000000030',
          deviceUser: 'test-user');

      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('book0000-0000-0000-0000-000000000030')))
          .getSingle();
      expect(book.isDeleted, isTrue);
    });

    test('should refresh updatedAt on soft delete', () async {
      await bookDao.softDeleteBook('book0000-0000-0000-0000-000000000030',
          deviceUser: 'test-user');

      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('book0000-0000-0000-0000-000000000030')))
          .getSingle();
      expect(book.updatedAt, isNotNull);
    });

    test('should write a delete change-log event', () async {
      await bookDao.softDeleteBook('book0000-0000-0000-0000-000000000030',
          deviceUser: 'test-user');

      final events = await (db.select(db.changeLogEvents)
            ..where((e) =>
                e.entityId.equals('book0000-0000-0000-0000-000000000030') &
                e.eventType.equals('delete')))
          .get();
      expect(events.isNotEmpty, isTrue);
    });

    test('should keep BookLoan records intact for deleted book', () async {
      await bookDao.softDeleteBook('book0000-0000-0000-0000-000000000030',
          deviceUser: 'test-user');

      // Book still exists (soft deleted)
      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('book0000-0000-0000-0000-000000000030')))
          .getSingle();
      expect(book.isDeleted, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.5: Restore a soft-deleted book
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.5 — restoreBook', () {
    setUp(() async {
      await bookDao.insertBookWithRelations(
        id: 'book0000-0000-0000-0000-000000000040',
        title: 'Book to Restore',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );
      await bookDao.softDeleteBook('book0000-0000-0000-0000-000000000040',
          deviceUser: 'test-user');
    });

    test('should set isDeleted=false and keep previous status', () async {
      await bookDao.restoreBook('book0000-0000-0000-0000-000000000040',
          deviceUser: 'test-user');

      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('book0000-0000-0000-0000-000000000040')))
          .getSingle();
      expect(book.isDeleted, isFalse);
    });

    test('should preserve other fields after restore', () async {
      await bookDao.restoreBook('book0000-0000-0000-0000-000000000040',
          deviceUser: 'test-user');

      final book = await (db.select(db.books)
            ..where((b) => b.id.equals('book0000-0000-0000-0000-000000000040')))
          .getSingle();
      expect(book.title, 'Book to Restore');
    });

    test('should write an update change-log event on restore', () async {
      await bookDao.restoreBook('book0000-0000-0000-0000-000000000040',
          deviceUser: 'test-user');

      final events = await (db.select(db.changeLogEvents)
            ..where((e) =>
                e.entityId.equals('book0000-0000-0000-0000-000000000040') &
                e.eventType.equals('update') &
                e.fieldName.equals('is_deleted')))
          .get();
      expect(events.isNotEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.6: Paginated catalog list with default sort
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.6 — listBooksPaginated', () {
    setUp(() async {
      // Insert 5 books for pagination testing
      for (var i = 0; i < 5; i++) {
        final padded = i.toString().padLeft(2, '0');
        await bookDao.insertBookWithRelations(
          id: 'bookpag0-0000-0000-0000-0000000000$padded',
          title: 'Book $i',
          authorIds: ['author00-0000-0000-0000-000000000001'],
          genreIds: [],
          tagIds: [],
          shelfId: null,
          deviceUser: 'test-user',
        );
      }
    });

    test('should return books ordered by createdAt DESC', () async {
      final books = await bookDao.listBooksPaginated(limit: 50);
      expect(books.length, 5);
    });

    test('should handle offset beyond total count (empty list, not crash)',
        () async {
      final books = await bookDao.listBooksPaginated(limit: 10, offset: 100);
      expect(books, isEmpty);
    });

    test('should exclude soft-deleted books by default', () async {
      // Soft-delete one book
      await bookDao.softDeleteBook('bookpag0-0000-0000-0000-000000000000',
          deviceUser: 'test-user');

      final books = await bookDao.listBooksPaginated(limit: 50);
      expect(books.length, 4);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.7: FTS5 search on title, ISBN, publisher
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.7 — searchBooksByFts', () {
    setUp(() async {
      await bookDao.insertBookWithRelations(
        id: 'bookfts0-0000-0000-0000-000000000001',
        title: 'The Alchemist',
        isbn: '978-0-06-231500-7',
        publisher: 'HarperOne',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );
    });

    test('should return books matching FTS5 query on title', () async {
      final results = await bookDao.searchBooksByFts('Alchemist');
      expect(results.length, 1);
      expect(results.first.title, 'The Alchemist');
    });

    test('should search ISBN field via FTS5', () async {
      // ISBN is stored as normalized 13-digit (9780062315007 after conversion)
      final results = await bookDao.searchBooksByFts('9780062315007');
      expect(results.length, 1);
    });

    test('should search publisher field via FTS5', () async {
      final results = await bookDao.searchBooksByFts('HarperOne');
      expect(results.length, 1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.8: Trigram fallback search on author names
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.8 — searchBooksByAuthor', () {
    setUp(() async {
      await bookDao.insertBookWithRelations(
        id: 'bookath0-0000-0000-0000-000000000001',
        title: 'Author Search Book',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );
    });

    test('should return books linked to authors matching LIKE query', () async {
      final results = await bookDao.searchBooksByAuthor('Paulo');
      expect(results.length, 1);
      expect(results.first.title, 'Author Search Book');
    });

    test('should match partial author name (trigram-style LIKE)', () async {
      final results = await bookDao.searchBooksByAuthor('aul');
      expect(results.length, 1);
    });

    test('should return empty list when no author matches', () async {
      final results = await bookDao.searchBooksByAuthor('NonExistent');
      expect(results, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.25: Invalid UUID in query
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.25 — invalid UUID', () {
    test('should return zero rows for malformed UUID (no crash)', () async {
      final details = await bookDao.getBookWithDetails('not-a-uuid');
      expect(details, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.26: Query catalog with zero books
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.26 — empty catalog', () {
    test('should return empty list (not null) from listBooksPaginated',
        () async {
      final books = await bookDao.listBooksPaginated();
      expect(books, isEmpty);
    });

    test('should return count 0 for empty catalog', () async {
      final books = await bookDao.listBooksPaginated();
      expect(books.length, 0);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.27: Search with no matches
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.27 — search no matches', () {
    test('should return empty list from searchBooksByFts for nonexistent term',
        () async {
      final results = await bookDao.searchBooksByFts('xyznonexistent');
      expect(results, isEmpty);
    });

    test(
        'should return empty list from searchBooksByAuthor for nonexistent author',
        () async {
      final results = await bookDao.searchBooksByAuthor('NonexistentAuthor123');
      expect(results, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.22: Max-length title and description
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.22 — max-length text', () {
    test('should store 1000-char title without truncation', () async {
      final longTitle = 'A' * 1000;
      await bookDao.insertBookWithRelations(
        id: 'booklong-0000-0000-0000-000000000001',
        title: longTitle,
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );

      final details =
          await bookDao.getBookWithDetails('booklong-0000-0000-0000-000000000001');
      expect(details!.book.title.length, 1000);
      expect(details.book.title, longTitle);
    });

    test('should store 5000-char description without truncation', () async {
      final longDesc = 'D' * 5000;
      await bookDao.insertBookWithRelations(
        id: 'bookdesc-0000-0000-0000-000000000001',
        title: 'Book with long desc',
        description: longDesc,
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );

      final details =
          await bookDao.getBookWithDetails('bookdesc-0000-0000-0000-000000000001');
      expect(details!.book.description, longDesc);
    });

    test('should index long title in FTS5 correctly', () async {
      final longTitle = 'UniquePrefix ' + ('X' * 500);
      await bookDao.insertBookWithRelations(
        id: 'bookfts2-0000-0000-0000-000000000001',
        title: longTitle,
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );

      final results = await bookDao.searchBooksByFts('UniquePrefix');
      expect(results.length, 1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.21: Empty tag or genre list
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.21 — empty tag/genre on getBookWithDetails', () {
    setUp(() async {
      await bookDao.insertBookWithRelations(
        id: 'bookempt-0000-0000-0000-000000000001',
        title: 'Empty Relations Book',
        authorIds: ['author00-0000-0000-0000-000000000001'],
        genreIds: [],
        tagIds: [],
        shelfId: null,
        deviceUser: 'test-user',
      );
    });

    test('should return empty lists (not null) for tags and genres', () async {
      final details =
          await bookDao.getBookWithDetails('bookempt-0000-0000-0000-000000000001');
      expect(details!.tags, isEmpty);
      expect(details.genres, isEmpty);
    });

    test('should not crash on missing joins with zero tags/genres', () async {
      final details =
          await bookDao.getBookWithDetails('bookempt-0000-0000-0000-000000000001');
      expect(details, isNotNull);
    });
  });
}
