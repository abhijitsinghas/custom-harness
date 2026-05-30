import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/data/database/database.dart';
import 'package:thelittlelibrary/data/database/duplicate_detector.dart';

void main() {
  late AppDatabase db;
  late DuplicateDetector detector;

  setUp(() async {
    db = AppDatabase.memory();
    detector = DuplicateDetector(db);
    // Seed test data
    await db.into(db.authors).insert(
          AuthorsCompanion.insert(
            id: 'author00-0000-0000-0000-000000000001',
            rawName: 'Paulo Coelho',
            normalizedName: 'paulo coelho',
          ),
        );
    await db.into(db.books).insert(
          BooksCompanion.insert(
            id: 'bookalc0-0000-0000-0000-000000000001',
            title: 'The Alchemist',
            isbn: const Value('9780062315007'),
          ),
        );
    await db.into(db.bookAuthors).insert(
          BookAuthorsCompanion.insert(
            bookId: 'bookalc0-0000-0000-0000-000000000001',
            authorId: 'author00-0000-0000-0000-000000000001',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.15: Duplicate detection — ISBN exact match
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.15 — ISBN exact match', () {
    test('should return DuplicateResult.exactMatch when same ISBN-13 exists',
        () async {
      final result = await detector.check(
        isbn: '9780062315007',
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho'],
      );
      expect(result, isA<ExactIsbnMatch>());
    });

    test('should normalize ISBNs before comparison', () async {
      final result = await detector.check(
        isbn: '978-0-06-231500-7', // With hyphens
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho'],
      );
      expect(result, isA<ExactIsbnMatch>());
    });

    test('should return null when ISBN does not match any existing book',
        () async {
      final result = await detector.check(
        isbn: '9781234567890',
        title: 'Unknown',
        authorNames: ['Unknown'],
      );
      expect(result, isNull);
    });

    test('should only check non-deleted books for ISBN match', () async {
      // Soft-delete the existing book
      await (db.update(db.books)
            ..where((b) => b.id.equals('bookalc0-0000-0000-0000-000000000001')))
          .write(const BooksCompanion(isDeleted: Value(true)));

      final result = await detector.check(
        isbn: '9780062315007',
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho'],
      );
      // Should not find the soft-deleted book
      expect(result, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.16: Duplicate detection — fuzzy title + author
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.16 — fuzzy title + author', () {
    test('should return DuplicateResult.fuzzyMatch when similar title+author',
        () async {
      final result = await detector.check(
        isbn: null,
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho'],
      );
      // Should fuzzy match the existing book
      expect(result, isA<FuzzyTitleAuthorMatch>());
    });

    test('should return null when similarity below 80% threshold', () async {
      final result = await detector.check(
        isbn: null,
        title: 'Completely Different Book Title',
        authorNames: ['Totally Different Author'],
      );
      expect(result, isNull);
    });

    test('should fuzzy match on at least one author of multi-author books',
        () async {
      final result = await detector.check(
        isbn: null,
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho', 'Another Author'],
      );
      expect(result, isA<FuzzyTitleAuthorMatch>());
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.18: Book with no ISBN
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.18 — no ISBN', () {
    test('should skip ISBN exact-match step when isbn is null', () async {
      final result = await detector.check(
        isbn: null,
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho'],
      );
      // Should fall through to fuzzy matching
      expect(result, isA<FuzzyTitleAuthorMatch>());
    });

    test('should still perform fuzzy title+author check when ISBN is null',
        () async {
      final result = await detector.check(
        isbn: null,
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho'],
      );
      expect(result, isNotNull);
    });

    test('should detect fuzzy duplicate even without ISBN', () async {
      final result = await detector.check(
        isbn: null,
        title: 'The Alchemist',
        authorNames: ['Paulo Coelho'],
      );
      expect(result, isA<FuzzyTitleAuthorMatch>());
    });
  });
}
