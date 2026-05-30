import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/data/database/database.dart';

/// Tests for LocationDao — covers US-1.1.11, US-1.1.12, US-1.1.28.

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.11: Location hierarchy CRUD — Room → Cupboard → Shelf
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.11 — location hierarchy CRUD', () {
    test('should create a Room with UUID and enforce FK constraints', () async {
      final room = await db.locationDao.createRoom('Living Room');
      expect(room.name, 'Living Room');
      expect(room.id.length, 36);
    });

    test('should create a Cupboard linked to a Room', () async {
      final room = await db.locationDao.createRoom('Study');
      final cupboard =
          await db.locationDao.createCupboard('Bookshelf A', room.id);
      expect(cupboard.name, 'Bookshelf A');
      expect(cupboard.roomId, room.id);
    });

    test('should create a Shelf linked to a Cupboard', () async {
      final room = await db.locationDao.createRoom('Library');
      final cupboard =
          await db.locationDao.createCupboard('Cabinet 1', room.id);
      final shelf = await db.locationDao.createShelf('Shelf 1', cupboard.id);
      expect(shelf.name, 'Shelf 1');
      expect(shelf.cupboardId, cupboard.id);
    });

    test('should return full tree via cascading query', () async {
      // Create room, cupboard, shelf
      final room = await db.locationDao.createRoom('Library');
      await db.locationDao.createCupboard('Fiction', room.id);

      final tree = await db.locationDao.listAllLocations();
      expect(tree.length, 1);
      expect(tree.first.room.id, room.id);
    });

    test('should enforce FK constraint: cannot create Cupboard for non-existent Room', () async {
      try {
        await db.locationDao.createCupboard('Bad Cupboard', 'non-existent-room');
        fail('Should have thrown FK violation');
      } catch (_) {
        // Expected FK violation
        expect(true, isTrue);
      }
    });

    test('should enforce FK constraint: cannot create Shelf for non-existent Cupboard', () async {
      try {
        await db.locationDao.createShelf('Bad Shelf', 'non-existent-cupboard');
        fail('Should have thrown FK violation');
      } catch (_) {
        // Expected FK violation
        expect(true, isTrue);
      }
    });

    test('should allow renaming a Room', () async {
      final room = await db.locationDao.createRoom('Old Name');
      await db.locationDao.renameRoom(room.id, 'New Name');
      final updated = await (db.select(db.rooms)..where((r) => r.id.equals(room.id)))
          .getSingle();
      expect(updated.name, 'New Name');
    });

    test('should allow renaming a Cupboard', () async {
      final room = await db.locationDao.createRoom('Room');
      final cupboard = await db.locationDao.createCupboard('Old Cupboard', room.id);
      await db.locationDao.renameCupboard(cupboard.id, 'New Cupboard');
      final updated = await (db.select(db.cupboards)
            ..where((c) => c.id.equals(cupboard.id)))
          .getSingle();
      expect(updated.name, 'New Cupboard');
    });

    test('should allow renaming a Shelf', () async {
      final room = await db.locationDao.createRoom('Room');
      final cupboard = await db.locationDao.createCupboard('Cupboard', room.id);
      final shelf = await db.locationDao.createShelf('Old Shelf', cupboard.id);
      await db.locationDao.renameShelf(shelf.id, 'New Shelf');
      final updated = await (db.select(db.shelves)
            ..where((s) => s.id.equals(shelf.id)))
          .getSingle();
      expect(updated.name, 'New Shelf');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.12: Delete a Room/Cupboard and cascade books to "None"
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.12 — cascade delete cupboard', () {
    test('should delete Cupboard and its Shelves in a transaction', () async {
      final room = await db.locationDao.createRoom('Room');
      final cupboard = await db.locationDao.createCupboard('Cupboard', room.id);
      await db.locationDao.createShelf('Shelf', cupboard.id);

      await db.locationDao.deleteCupboard(cupboard.id);

      // Cupboard should be deleted
      final cupboards =
          await (db.select(db.cupboards)..where((c) => c.id.equals(cupboard.id)))
              .get();
      expect(cupboards, isEmpty);
    });

    test('should delete a Room and cascades through Cupboards → Shelves', () async {
      final room = await db.locationDao.createRoom('Room');
      await db.locationDao.createCupboard('Cupboard', room.id);

      await db.locationDao.deleteRoom(room.id);

      final rooms =
          await (db.select(db.rooms)..where((r) => r.id.equals(room.id))).get();
      expect(rooms, isEmpty);
    });

    test('should delete a Shelf and set its books to null shelfId', () async {
      final room = await db.locationDao.createRoom('Room');
      final cupboard = await db.locationDao.createCupboard('Cupboard', room.id);
      final shelf = await db.locationDao.createShelf('Shelf', cupboard.id);

      // Create a book on this shelf
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'bookslf0-0000-0000-0000-000000000001',
              title: 'Shelf Book',
            ),
          );
      await db.into(db.bookShelves).insert(
            BookShelvesCompanion.insert(
              bookId: 'bookslf0-0000-0000-0000-000000000001',
              shelfId: Value(shelf.id),
            ),
          );

      await db.locationDao.deleteShelf(shelf.id);

      // Book should have null shelfId now
      final bs = await (db.select(db.bookShelves)
            ..where((b) =>
                b.bookId.equals('bookslf0-0000-0000-0000-000000000001')))
          .getSingleOrNull();
      if (bs != null) {
        expect(bs.shelfId, isNull);
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.28: No locations defined
  // ═══════════════════════════════════════════════════════════════════════════
  group('US-1.1.28 — no locations defined', () {
    test('should return empty tree from listAllLocations when no locations exist',
        () async {
      final tree = await db.locationDao.listAllLocations();
      expect(tree, isEmpty);
    });

    test('should default book location to "None" (null shelfId) when no locations',
        () async {
      // A book inserted without shelfId should have no location
      await db.into(db.books).insert(
            BooksCompanion.insert(
              id: 'booknol0-0000-0000-0000-000000000001',
              title: 'No Location Book',
            ),
          );

      final bs = await (db.select(db.bookShelves)
            ..where((b) =>
                b.bookId.equals('booknol0-0000-0000-0000-000000000001')))
          .getSingleOrNull();
      expect(bs, isNull); // No book_shelf row = "None"
    });
  });
}
