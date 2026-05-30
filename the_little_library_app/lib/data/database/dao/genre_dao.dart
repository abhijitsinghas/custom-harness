import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants.dart';
import '../database.dart';
import 'dao_exceptions.dart';

const _uuid = Uuid();

/// [BuiltInEntityException] is defined in dao_exceptions.dart.

/// DAO for genre CRUD operations including built-in genre protection.
@DriftAccessor()
class GenreDao {
  final AppDatabase _db;

  GenreDao(this._db);

  /// Seeds the 20 predefined genres on first open.
  /// Idempotent across restarts (uses insertOrIgnore).
  Future<void> seedBuiltinGenres() async {
    for (final name in kPredefinedGenres) {
      await _db.into(_db.genres).insert(
            GenresCompanion.insert(
              id: _uuid.v4(),
              name: name,
              isCustom: const Value(false),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// Creates a new custom genre.
  Future<Genre> createGenre(String name, {String? id}) async {
    final genreId = id ?? _uuid.v4();
    await _db.into(_db.genres).insert(
          GenresCompanion.insert(
            id: genreId,
            name: name,
            isCustom: const Value(true),
          ),
        );
    return (_db.select(_db.genres)..where((g) => g.id.equals(genreId)))
        .getSingle();
  }

  /// Lists all genres (built-in + custom).
  Future<List<Genre>> listAll() async {
    return _db.select(_db.genres).get();
  }

  /// Renames a genre.
  Future<void> renameGenre(String id, String newName) async {
    await (_db.update(_db.genres)..where((g) => g.id.equals(id)))
        .write(GenresCompanion(name: Value(newName)));
  }

  /// Deletes a genre.
  ///
  /// Throws [BuiltInEntityException] if the genre is built-in (isCustom=false).
  Future<void> deleteGenre(String id) async {
    final genre = await (_db.select(_db.genres)..where((g) => g.id.equals(id)))
        .getSingleOrNull();

    if (genre == null) return;

    if (!genre.isCustom) {
      throw BuiltInEntityException(
        'Cannot delete built-in genre "${genre.name}"',
      );
    }

    await _db.transaction(() async {
      await (_db.delete(_db.bookGenres)..where((bg) => bg.genreId.equals(id)))
          .go();
      await (_db.delete(_db.genres)..where((g) => g.id.equals(id))).go();
    });
  }
}
