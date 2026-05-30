import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

const _uuid = Uuid();

/// DAO for tag CRUD operations.
@DriftAccessor()
class TagDao {
  final AppDatabase _db;

  TagDao(this._db);

  /// Creates a new tag.
  Future<Tag> createTag(String name, {String? id}) async {
    final tagId = id ?? _uuid.v4();
    await _db
        .into(_db.tags)
        .insert(TagsCompanion.insert(id: tagId, name: name));
    return (_db.select(_db.tags)..where((t) => t.id.equals(tagId))).getSingle();
  }

  /// Lists all tags.
  Future<List<Tag>> listAll() async {
    return _db.select(_db.tags).get();
  }

  /// Deletes a tag and cascades: removes associated BookTag join rows.
  Future<void> deleteTag(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.bookTags)..where((bt) => bt.tagId.equals(id))).go();
      await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Renames a tag.
  Future<void> renameTag(String id, String newName) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(id)))
        .write(TagsCompanion(name: Value(newName)));
  }
}
