import 'package:drift/drift.dart';

import '../../core/isbn_utils.dart';
import '../../core/utils.dart';
import 'database.dart';

/// Represents a detected duplicate match.
sealed class DuplicateResult {
  String get bookId;
}

/// An exact ISBN match was found.
class ExactIsbnMatch extends DuplicateResult {
  @override
  final String bookId;
  final String isbn;

  ExactIsbnMatch({required this.bookId, required this.isbn});
}

/// A fuzzy title+author match was found with >=80% similarity.
class FuzzyTitleAuthorMatch extends DuplicateResult {
  @override
  final String bookId;
  final String title;
  final String author;
  final double similarity;

  FuzzyTitleAuthorMatch({
    required this.bookId,
    required this.title,
    required this.author,
    required this.similarity,
  });
}

/// Detects potential duplicate books before insertion.
class DuplicateDetector {
  DuplicateDetector(this._db);

  final AppDatabase _db;

  /// Checks for duplicate books. Returns null if no duplicate found.
  Future<DuplicateResult?> check({
    String? isbn,
    required String title,
    required List<String> authorNames,
  }) async {
    // Step 1: ISBN exact match (if ISBN provided)
    if (isbn != null) {
      final isbn13 = toIsbn13(isbn);
      if (isbn13 != null) {
        final match = await _checkIsbnMatch(isbn13);
        if (match != null) return match;
      }
    }

    // Step 2: Fuzzy title+author match
    return _checkFuzzyMatch(title, authorNames);
  }

  Future<DuplicateResult?> _checkIsbnMatch(String isbn13) async {
    final existing = await (_db.select(_db.books)
          ..where((b) => b.isbn.equals(isbn13) & b.isDeleted.equals(false)))
        .getSingleOrNull();

    if (existing != null) {
      return ExactIsbnMatch(bookId: existing.id, isbn: isbn13);
    }
    return null;
  }

  Future<DuplicateResult?> _checkFuzzyMatch(
    String title,
    List<String> authorNames,
  ) async {
    const threshold = 80.0;

    final rows = await (_db.select(_db.books).join([
          innerJoin(_db.bookAuthors,
              _db.bookAuthors.bookId.equalsExp(_db.books.id)),
          innerJoin(_db.authors,
              _db.authors.id.equalsExp(_db.bookAuthors.authorId)),
        ])
          ..where(_db.books.isDeleted.equals(false)))
        .get();

    final bookData = <String, Book>{};
    final bookAuthors = <String, List<String>>{};

    for (final row in rows) {
      final book = row.readTable(_db.books);
      final author = row.readTable(_db.authors);
      bookData[book.id] = book;
      bookAuthors.putIfAbsent(book.id, () => []).add(author.rawName);
    }

    final normalizedTitle = title.trim().toLowerCase();
    final normalizedInputAuthors =
        authorNames.map((a) => a.trim().toLowerCase()).toList();

    double bestScore = 0.0;
    String? bestBookId;

    for (final entry in bookData.entries) {
      final book = entry.value;
      final candidateAuthors = bookAuthors[book.id] ?? [];

      final candidateTitle = book.title.trim().toLowerCase();
      final titleScore = similarityRatio(normalizedTitle, candidateTitle);

      double maxAuthorScore = 0.0;
      for (final inputAuthor in normalizedInputAuthors) {
        for (final candidateAuthor in candidateAuthors) {
          final score = similarityRatio(
              inputAuthor, candidateAuthor.toLowerCase());
          if (score > maxAuthorScore) maxAuthorScore = score;
        }
      }

      final combinedScore = (titleScore + maxAuthorScore) / 2;
      if (combinedScore >= threshold && combinedScore > bestScore) {
        bestScore = combinedScore;
        bestBookId = book.id;
      }
    }

    if (bestBookId != null && bestScore >= threshold) {
      final book = bookData[bestBookId]!;
      return FuzzyTitleAuthorMatch(
        bookId: book.id,
        title: book.title,
        author: (bookAuthors[book.id] ?? ['']).join(', '),
        similarity: bestScore,
      );
    }

    return null;
  }
}
