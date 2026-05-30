import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'database_provider.dart';

/// Repository for tag CRUD.
class TagRepository {
  TagRepository(this._db);

  final AppDatabase _db;

  /// List all tags.
  Future<List<Tag>> getAll() async {
    return _db.select(_db.tags).get();
  }

  /// Create a new tag.
  Future<Tag> add(Tag tag) async {
    await _db.into(_db.tags).insert(
          TagsCompanion.insert(id: tag.id, name: tag.name),
        );
    return tag;
  }

  /// Update an existing tag.
  Future<Tag> update(Tag tag) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id)))
        .write(TagsCompanion(name: Value(tag.name)));
    return tag;
  }

  /// Delete a tag by id.
  Future<void> delete(String id) async {
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }
}

/// Riverpod provider for [TagRepository].
final tagRepoProvider = Provider<TagRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TagRepository(db);
});
