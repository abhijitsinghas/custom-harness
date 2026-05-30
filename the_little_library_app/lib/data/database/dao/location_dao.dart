import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

const _uuid = Uuid();

/// A room with its cupboards and shelves.
class LocationNode {
  final Room room;
  final List<CupboardNode> cupboards;

  LocationNode({required this.room, required this.cupboards});
}

/// A cupboard with its shelves.
class CupboardNode {
  final Cupboard cupboard;
  final List<Shelve> shelves;

  CupboardNode({required this.cupboard, required this.shelves});
}

/// DAO for hierarchical location CRUD (Room → Cupboard → Shelf).
@DriftAccessor()
class LocationDao {
  final AppDatabase _db;

  LocationDao(this._db);

  // ─── Create ────────────────────────────────────────────────────────────

  /// Creates a new room.
  Future<Room> createRoom(String name, {String? id}) async {
    final roomId = id ?? _uuid.v4();
    await _db
        .into(_db.rooms)
        .insert(RoomsCompanion.insert(id: roomId, name: name));
    return (_db.select(_db.rooms)..where((r) => r.id.equals(roomId)))
        .getSingle();
  }

  /// Creates a cupboard linked to a room.
  Future<Cupboard> createCupboard(String name, String roomId,
      {String? id}) async {
    final cupboardId = id ?? _uuid.v4();
    await _db.into(_db.cupboards).insert(
          CupboardsCompanion.insert(id: cupboardId, name: name, roomId: roomId),
        );
    return (_db.select(_db.cupboards)..where((c) => c.id.equals(cupboardId)))
        .getSingle();
  }

  /// Creates a shelf linked to a cupboard.
  Future<Shelve> createShelf(String name, String cupboardId,
      {String? id}) async {
    final shelfId = id ?? _uuid.v4();
    await _db.into(_db.shelves).insert(
          ShelvesCompanion.insert(
              id: shelfId, name: name, cupboardId: cupboardId),
        );
    return (_db.select(_db.shelves)..where((s) => s.id.equals(shelfId)))
        .getSingle();
  }

  // ─── Rename ────────────────────────────────────────────────────────────

  /// Renames a room.
  Future<void> renameRoom(String id, String newName) async {
    await (_db.update(_db.rooms)..where((r) => r.id.equals(id)))
        .write(RoomsCompanion(name: Value(newName)));
  }

  /// Renames a cupboard.
  Future<void> renameCupboard(String id, String newName) async {
    await (_db.update(_db.cupboards)..where((c) => c.id.equals(id)))
        .write(CupboardsCompanion(name: Value(newName)));
  }

  /// Renames a shelf.
  Future<void> renameShelf(String id, String newName) async {
    await (_db.update(_db.shelves)..where((s) => s.id.equals(id)))
        .write(ShelvesCompanion(name: Value(newName)));
  }

  // ─── Delete with cascade ───────────────────────────────────────────────

  /// Deletes a room and cascades: cupboards → shelves, nullifies book locations.
  ///
  /// Writes change log events for every affected book (US-1.1.12).
  Future<void> deleteRoom(String id, {String deviceUser = 'local'}) async {
    await _db.transaction(() async {
      // Only fetch cupboards belonging to this specific room (hierarchy scoped).
      final cupboards = await (_db.select(_db.cupboards)
            ..where((c) => c.roomId.equals(id)))
          .get();
      final cupboardIds = cupboards.map((c) => c.id).toList();

      if (cupboardIds.isNotEmpty) {
        // Only fetch shelves for these specific cupboards.
        final shelves = await (_db.select(_db.shelves)
              ..where((s) => s.cupboardId.isIn(cupboardIds)))
            .get();

        if (shelves.isNotEmpty) {
          final shelfIds = shelves.map((s) => s.id).toList();
          await _nullifyBooksOnShelves(shelfIds, deviceUser: deviceUser);
        }

        // Delete shelves scoped to these cupboards only.
        await (_db.delete(_db.shelves)
              ..where((s) => s.cupboardId.isIn(cupboardIds)))
            .go();
        // Delete cupboards scoped to this room only.
        await (_db.delete(_db.cupboards)..where((c) => c.roomId.equals(id)))
            .go();
      }

      await (_db.delete(_db.rooms)..where((r) => r.id.equals(id))).go();
    });
  }

  /// Deletes a cupboard and cascades: shelves removed, books nullified.
  ///
  /// Writes change log events for every affected book (US-1.1.12).
  Future<void> deleteCupboard(String id, {String deviceUser = 'local'}) async {
    await _db.transaction(() async {
      // Only shelves under this specific cupboard.
      final shelves = await (_db.select(_db.shelves)
            ..where((s) => s.cupboardId.equals(id)))
          .get();

      if (shelves.isNotEmpty) {
        final shelfIds = shelves.map((s) => s.id).toList();
        await _nullifyBooksOnShelves(shelfIds, deviceUser: deviceUser);
      }

      // Delete shelves under this cupboard.
      await (_db.delete(_db.shelves)..where((s) => s.cupboardId.equals(id)))
          .go();
      await (_db.delete(_db.cupboards)..where((c) => c.id.equals(id))).go();
    });
  }

  /// Deletes a shelf and nullifies any books assigned to it.
  ///
  /// Writes change log events for every affected book (US-1.1.12).
  Future<void> deleteShelf(String id, {String deviceUser = 'local'}) async {
    await _nullifyBooksOnShelves([id], deviceUser: deviceUser);
    await (_db.delete(_db.shelves)..where((s) => s.id.equals(id))).go();
  }

  // ─── Query ─────────────────────────────────────────────────────────────

  /// Returns the full location hierarchy as a tree.
  Future<List<LocationNode>> listAllLocations() async {
    final rooms = await _db.select(_db.rooms).get();
    final result = <LocationNode>[];

    for (final room in rooms) {
      final cupboards = await (_db.select(_db.cupboards)
            ..where((c) => c.roomId.equals(room.id)))
          .get();
      final cupboardNodes = <CupboardNode>[];

      for (final cupboard in cupboards) {
        final shelves = await (_db.select(_db.shelves)
              ..where((s) => s.cupboardId.equals(cupboard.id)))
            .get();
        cupboardNodes.add(CupboardNode(cupboard: cupboard, shelves: shelves));
      }

      result.add(LocationNode(room: room, cupboards: cupboardNodes));
    }

    return result;
  }

  // ─── Private ───────────────────────────────────────────────────────────

  /// Sets shelfId to null for all books on the given shelves and records
  /// change log events for every affected book (US-1.1.12).
  Future<void> _nullifyBooksOnShelves(List<String> shelfIds,
      {String deviceUser = 'local'}) async {
    if (shelfIds.isEmpty) return;

    final now = DateTime.now().toIso8601String();

    // Fetch only book_shelf rows matching these specific shelf IDs.
    final bookShelves = await (_db.select(_db.bookShelves)
          ..where((bs) => bs.shelfId.isIn(shelfIds)))
        .get();

    // Nullify shelf assignments for these books.
    await (_db.update(_db.bookShelves)
          ..where((bs) => bs.shelfId.isIn(shelfIds)))
        .write(const BookShelvesCompanion(shelfId: Value(null)));

    final bookIds = bookShelves.map((bs) => bs.bookId).toList();
    if (bookIds.isNotEmpty) {
      // Update updatedAt timestamp for all affected books.
      await (_db.update(_db.books)..where((b) => b.id.isIn(bookIds)))
          .write(BooksCompanion(updatedAt: Value(now)));

      // Write change log events for every affected book (US-1.1.12).
      for (final bookId in bookIds) {
        await _db.into(_db.changeLogEvents).insert(
              ChangeLogEventsCompanion.insert(
                eventId: _uuid.v4(),
                entityType: 'book',
                entityId: bookId,
                eventType: 'update',
                fieldName: 'shelf_id',
                oldValue: const Value(null),
                newValue: const Value(null),
                deviceUser: deviceUser,
                timestamp: Value(now),
              ),
            );
      }
    }
  }
}
