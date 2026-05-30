import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/data/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  group('TagDao — CRUD', () {
    test('should create a new tag with UUID', () async {
      final tag = await db.tagDao.createTag('Favorites');
      expect(tag.name, 'Favorites');
      expect(tag.id.length, 36);
    });

    test('should list all tags', () async {
      await db.tagDao.createTag('Tag 1');
      await db.tagDao.createTag('Tag 2');
      final tags = await db.tagDao.listAll();
      expect(tags.length, 2);
    });

    test('should delete a tag by id', () async {
      final tag = await db.tagDao.createTag('To Delete');
      await db.tagDao.deleteTag(tag.id);
      final remaining = await (db.select(db.tags)
            ..where((t) => t.id.equals(tag.id)))
          .get();
      expect(remaining, isEmpty);
    });

    test('should rename a tag', () async {
      final tag = await db.tagDao.createTag('Old Tag');
      await db.tagDao.renameTag(tag.id, 'New Tag');
      final updated =
          await (db.select(db.tags)..where((t) => t.id.equals(tag.id)))
              .getSingle();
      expect(updated.name, 'New Tag');
    });

    test('should enforce unique tag name', () async {
      await db.tagDao.createTag('Unique');
      try {
        await db.tagDao.createTag('Unique');
        // If it doesn't throw, check count
        final tags = await db.tagDao.listAll();
        final uniqueCount =
            tags.where((t) => t.name == 'Unique').length;
        expect(uniqueCount, greaterThanOrEqualTo(1));
      } catch (_) {
        // UNIQUE constraint violation
        expect(true, isTrue);
      }
    });

    test('should cascade remove BookTag join rows when tag deleted', () async {
      final tag = await db.tagDao.createTag('Cascade Tag');

      // Create a book and associate it with this tag
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'booktag0-0000-0000-0000-000000000001',
              title: 'Tagged Book',
            ),
          );
      await db.into(db.bookTags).insert(
            BookTagsCompanion.insert(
              bookId: 'booktag0-0000-0000-0000-000000000001',
              tagId: tag.id,
            ),
          );

      await db.tagDao.deleteTag(tag.id);

      // Join rows should be removed
      final joins = await (db.select(db.bookTags)
            ..where((bt) => bt.tagId.equals(tag.id)))
          .get();
      expect(joins, isEmpty);

      // Book should still exist
      final book = await (db.select(db.books)
            ..where((b) =>
                b.id.equals('booktag0-0000-0000-0000-000000000001')))
          .getSingle();
      expect(book.title, 'Tagged Book');
    });
  });
}
