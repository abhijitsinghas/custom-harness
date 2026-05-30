import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import 'dao_exceptions.dart';

const _uuid = Uuid();

/// DAO for author CRUD operations.
@DriftAccessor()
class AuthorDao {
  final AppDatabase _db;

  AuthorDao(this._db);

  /// Creates an author with a normalized name for deduplication.
  Future<Author> createAuthor(
    String rawName, {
    String? id,
    String? normalizedName,
  }) async {
    final authorId = id ?? _uuid.v4();
    final normalized = normalizedName ?? rawName.trim().toLowerCase();

    await _db.into(_db.authors).insert(
          AuthorsCompanion.insert(
            id: authorId,
            rawName: rawName,
            normalizedName: normalized,
          ),
        );
    return (_db.select(_db.authors)..where((a) => a.id.equals(authorId)))
        .getSingle();
  }

  /// Lists all authors.
  Future<List<Author>> listAll() async {
    return _db.select(_db.authors).get();
  }

  /// Deletes an author. Throws [Exception] if still linked to books.
  Future<void> deleteAuthor(String id) async {
    final linkedBooks = await (_db.select(_db.bookAuthors)
          ..where((ba) => ba.authorId.equals(id)))
        .get();

    if (linkedBooks.isNotEmpty) {
      throw ReferencedEntityException(
        'Cannot delete author: still referenced by ${linkedBooks.length} book(s)',
      );
    }

    await (_db.delete(_db.authors)..where((a) => a.id.equals(id))).go();
  }

  /// Normalizes an author name: trims and lowercases.
  static String normalizeAuthorName(String rawName) {
    return rawName.trim().toLowerCase();
  }
}
