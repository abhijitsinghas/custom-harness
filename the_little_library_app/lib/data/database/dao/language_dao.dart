import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants.dart';
import '../database.dart';
import 'dao_exceptions.dart';

const _uuid = Uuid();

/// DAO for language CRUD operations including built-in language protection.
@DriftAccessor()
class LanguageDao {
  final AppDatabase _db;

  LanguageDao(this._db);

  /// Seeds the 3 built-in languages on first open.
  /// Idempotent across restarts.
  Future<void> seedBuiltinLanguages() async {
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
  }

  /// Creates a new custom language.
  Future<Language> createLanguage(String name, {String? id}) async {
    final langId = id ?? _uuid.v4();
    await _db.into(_db.languages).insert(
          LanguagesCompanion.insert(
            id: langId,
            name: name,
            isBuiltin: const Value(false),
          ),
        );
    return (_db.select(_db.languages)..where((l) => l.id.equals(langId)))
        .getSingle();
  }

  /// Lists all languages (built-in + custom).
  Future<List<Language>> listAll() async {
    return _db.select(_db.languages).get();
  }

  /// Deletes a language.
  ///
  /// Throws [BuiltInEntityException] if the language is built-in.
  Future<void> deleteLanguage(String id) async {
    final language = await (_db.select(_db.languages)
          ..where((l) => l.id.equals(id)))
        .getSingleOrNull();

    if (language == null) return;

    if (language.isBuiltin) {
      throw BuiltInEntityException(
        'Cannot delete built-in language "${language.name}"',
      );
    }

    await (_db.delete(_db.languages)..where((l) => l.id.equals(id))).go();
  }
}
