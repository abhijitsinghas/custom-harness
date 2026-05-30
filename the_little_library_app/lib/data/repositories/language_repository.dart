import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../database/database.dart';
import 'database_provider.dart';

/// Repository for language CRUD with 3 built-in languages seeded on first open.
/// US-0.3.5: Language Repository Seeds 3 Built-in Languages
/// US-0.3.6: Seeded Data Is Idempotent
/// US-0.3.11: Built-in languages must not be deletable
class LanguageRepository {
  LanguageRepository(this._db) {
    _seedBuiltinLanguages();
  }

  final AppDatabase _db;
  static const _uuid = Uuid();
  bool _seeded = false;

  /// Seed the 3 built-in languages if not already present. Idempotent.
  Future<void> _seedBuiltinLanguages() async {
    if (_seeded) return;

    await _db.transaction(() async {
      for (final lang in kBuiltinLanguages) {
        await _db.into(_db.languages).insert(
          LanguagesCompanion.insert(
            id: _uuid.v4(),
            name: lang['name']!,
            isBuiltin: const Value(true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });

    _seeded = true;
  }

  /// List all languages.
  Future<List<Language>> listAll() async {
    return _db.select(_db.languages).get();
  }

  /// Alias for [listAll].
  Future<List<Language>> listLanguages() => listAll();

  /// Create a new custom language.
  Future<Language> createLanguage(String name) async {
    final id = _uuid.v4();
    await _db.into(_db.languages).insert(
          LanguagesCompanion.insert(id: id, name: name, isBuiltin: const Value(false)),
        );
    final result =
        await (_db.select(_db.languages)..where((l) => l.id.equals(id)))
            .getSingle();
    return result;
  }

  /// Delete a language. Built-in languages (isBuiltin = true) must not be
  /// deletable. US-0.3.11: Throws [UnsupportedError] for built-in languages.
  Future<void> deleteLanguage(String id) async {
    final language =
        await (_db.select(_db.languages)..where((l) => l.id.equals(id)))
            .getSingleOrNull();
    if (language == null) return;
    if (language.isBuiltin) {
      throw UnsupportedError(
          "Built-in language '${language.name}' cannot be deleted.");
    }
    await (_db.delete(_db.languages)..where((l) => l.id.equals(id))).go();
  }

  /// Alias for [createLanguage].
  Future<Language> add(Language language) async {
    await _db.into(_db.languages).insert(
          LanguagesCompanion.insert(
            id: language.id,
            name: language.name,
            isBuiltin: Value(language.isBuiltin),
          ),
        );
    return language;
  }

  /// Update an existing language.
  Future<Language> update(Language language) async {
    await (_db.update(_db.languages)..where((l) => l.id.equals(language.id)))
        .write(LanguagesCompanion(
          name: Value(language.name),
          isBuiltin: Value(language.isBuiltin),
        ));
    return language;
  }

  /// Delete by id — convenience wrapper with built-in protection.
  Future<void> delete(String id) => deleteLanguage(id);
}

/// Riverpod provider for [LanguageRepository].
final languageRepoProvider = Provider<LanguageRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LanguageRepository(db);
});
