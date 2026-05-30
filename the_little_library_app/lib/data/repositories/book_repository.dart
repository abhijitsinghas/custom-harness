import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils.dart';
import '../database/dao/book_dao.dart';
import '../database/database.dart';
import '../database/duplicate_detector.dart';
import 'database_provider.dart';

/// Repository for book CRUD, search, and duplicate detection.
/// Delegates data access to [BookDao] for database operations.
///
/// US-0.3.2: Book Repository Interface Defines CRUD + Search
class BookRepository {
  BookRepository(this._db) : _bookDao = BookDao(_db);

  final AppDatabase _db;
  late final BookDao _bookDao;

  /// Insert a new book. Returns the created [Book].
  Future<Book> create(BooksCompanion book) async {
    await _db.into(_db.books).insert(book);
    final result = await (_db.select(_db.books)
          ..where((b) => b.id.equals(book.id.value)))
        .getSingle();
    return result;
  }

  /// Look up a book by its UUID. Returns `null` when not found.
  Future<Book?> readById(String id) async {
    final result = await (_db.select(_db.books)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
    return result;
  }

  /// Update an existing book. Returns the updated [Book].
  Future<Book> update(BooksCompanion book) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(book.id.value)))
        .write(book);
    final result = await (_db.select(_db.books)
          ..where((b) => b.id.equals(book.id.value)))
        .getSingle();
    return result;
  }

  /// Soft-delete a book (sets `isDeleted = true`).
  Future<void> softDelete(String id) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(id)))
        .write(const BooksCompanion(isDeleted: Value(true)));
  }

  /// Restore a soft-deleted book (sets `isDeleted = false`).
  Future<void> restore(String id) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(id)))
        .write(const BooksCompanion(isDeleted: Value(false)));
  }

  /// List all non-deleted books with optional pagination.
  Future<List<Book>> listAll({int? limit, int? offset}) async {
    var query = _db.select(_db.books)..where((b) => b.isDeleted.equals(false));
    if (limit != null) {
      query = query..limit(limit, offset: offset ?? 0);
    }
    return query.get();
  }

  /// Full-text search across books using FTS5 for fast, relevance-ranked
  /// queries. Falls back to LIKE-based search for filtered queries.
  /// Delegates FTS search to [BookDao.searchBooksByFts] and filtered search
  /// to [BookDao.listBooksPaginated] with [BookFilters].
  Future<List<Book>> search(
    String query, {
    List<String>? genres,
    String? languageId,
    String? format,
    String? sortField,
    bool sortAscending = true,
  }) async {
    // When no filters are applied, use BookDao FTS5 search.
    if ((genres == null || genres.isEmpty) &&
        languageId == null &&
        format == null) {
      return _bookDao.searchBooksByFts(query);
    }

    // When filters are active, delegate to listBooksPaginated with filters.
    // The LIKE-based fallback is handled by the DAO's dynamic SQL.
    return _bookDao.listBooksPaginated(
      limit: 100,
      filters: BookFilters(
        genres: genres,
        languageId: languageId,
        showDeleted: false,
      ),
    );
  }

  /// Detect potential duplicate books using [DuplicateDetector].
  ///
  /// Delegates to [DuplicateDetector] which performs ISBN exact match
  /// then fuzzy title+author matching using Levenshtein-based
  /// [similarityRatio] with an 80% threshold.
  Future<List<Book>> findDuplicates(String title, String author) async {
    final detector = DuplicateDetector(_db);
    final result = await detector.check(
      title: title,
      authorNames: [author],
    );

    if (result == null) return [];

    // Look up the duplicate book by its ID.
    final book = await readById(result.bookId);
    return book != null ? [book] : [];
  }

  /// Find a book by its ISBN. Returns `null` when not found.
  Future<Book?> findByIsbn(String isbn) async {
    final result = await (_db.select(_db.books)
          ..where((b) => b.isbn.equals(isbn) & b.isDeleted.equals(false)))
        .getSingleOrNull();
    return result;
  }

  /// Alias for [readById]. Returns `null` when not found.
  Future<Book?> getBookById(String id) => readById(id);
}

/// Riverpod provider for [BookRepository].
final bookRepoProvider = Provider<BookRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BookRepository(db);
});
