import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../database/database.dart';
import 'database_provider.dart';

/// Repository for genre CRUD with 20 predefined genres seeded on first open.
/// US-0.3.4: Genre Repository Seeds 20 Predefined Genres on First Open
/// US-0.3.6: Seeded Data Is Idempotent
/// US-0.3.9: Seed Data Race Condition handled via INSERT OR IGNORE
/// US-0.3.11: Built-in genres must not be deletable
class GenreRepository {
  GenreRepository(this._db) {
    _seedPredefinedGenres();
  }

  final AppDatabase _db;
  static const _uuid = Uuid();
  bool _seeded = false;

  /// Seed the 20 predefined genres if not already present. Idempotent.
  Future<void> _seedPredefinedGenres() async {
    if (_seeded) return;

    // Use a transaction with INSERT OR IGNORE for idempotency and
    // race-condition safety (US-0.3.6, US-0.3.9).
    await _db.transaction(() async {
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
    });

    _seeded = true;
  }

  /// List all genres.
  Future<List<Genre>> listAll() async {
    return _db.select(_db.genres).get();
  }

  /// Alias for [listAll].
  Future<List<Genre>> listGenres() => listAll();

  /// Create a new custom genre.
  Future<Genre> createGenre(String name) async {
    final id = _uuid.v4();
    await _db.into(_db.genres).insert(
          GenresCompanion.insert(id: id, name: name, isCustom: const Value(true)),
        );
    final result =
        await (_db.select(_db.genres)..where((g) => g.id.equals(id)))
            .getSingle();
    return result;
  }

  /// Delete a genre. Built-in genres (isCustom = false) must not be deletable.
  /// US-0.3.11: Throws [UnsupportedError] for built-in genres.
  Future<void> deleteGenre(String id) async {
    final genre = await (_db.select(_db.genres)..where((g) => g.id.equals(id)))
        .getSingleOrNull();
    if (genre == null) return;
    if (!genre.isCustom) {
      throw UnsupportedError(
          "Built-in genre '${genre.name}' cannot be deleted.");
    }
    await (_db.delete(_db.genres)..where((g) => g.id.equals(id))).go();
  }

  /// Rename an existing genre.
  Future<void> renameGenre(String id, String newName) async {
    await (_db.update(_db.genres)..where((g) => g.id.equals(id)))
        .write(GenresCompanion(name: Value(newName)));
  }

  /// Alias for [createGenre].
  Future<Genre> add(Genre genre) async {
    await _db.into(_db.genres).insert(
          GenresCompanion.insert(
            id: genre.id,
            name: genre.name,
            isCustom: Value(genre.isCustom),
          ),
        );
    return genre;
  }

  /// Update an existing genre.
  Future<Genre> update(Genre genre) async {
    await (_db.update(_db.genres)..where((g) => g.id.equals(genre.id)))
        .write(GenresCompanion(
          name: Value(genre.name),
          isCustom: Value(genre.isCustom),
        ));
    return genre;
  }

  /// Delete by id — convenience wrapper with built-in protection.
  Future<void> delete(String id) => deleteGenre(id);
}

/// Riverpod provider for [GenreRepository].
final genreRepoProvider = Provider<GenreRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GenreRepository(db);
});
