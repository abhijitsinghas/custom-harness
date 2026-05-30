import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import 'database_provider.dart';

/// Repository for hierarchical location CRUD (Room → Cupboard → Shelf).
/// US-0.3.3: Location Repository Interface Defines Hierarchy CRUD
class LocationRepository {
  LocationRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Create a new room.
  Future<Room> createRoom(String name) async {
    final id = _uuid.v4();
    await _db.into(_db.rooms).insert(
          RoomsCompanion.insert(id: id, name: name),
        );
    final result =
        await (_db.select(_db.rooms)..where((r) => r.id.equals(id)))
            .getSingle();
    return result;
  }

  /// Create a cupboard under a room.
  Future<Cupboard> createCupboard(String roomId, String name) async {
    final id = _uuid.v4();
    await _db.into(_db.cupboards).insert(
          CupboardsCompanion.insert(id: id, name: name, roomId: roomId),
        );
    final result =
        await (_db.select(_db.cupboards)..where((c) => c.id.equals(id)))
            .getSingle();
    return result;
  }

  /// Create a shelf under a cupboard.
  Future<Shelve> createShelf(String cupboardId, String name) async {
    final id = _uuid.v4();
    await _db.into(_db.shelves).insert(
          ShelvesCompanion.insert(id: id, name: name, cupboardId: cupboardId),
        );
    final result =
        await (_db.select(_db.shelves)..where((s) => s.id.equals(id)))
            .getSingle();
    return result;
  }

  /// Rename a room by its UUID.
  Future<void> renameRoom(String id, String newName) async {
    await (_db.update(_db.rooms)..where((r) => r.id.equals(id)))
        .write(RoomsCompanion(name: Value(newName)));
  }

  /// Rename a cupboard by its UUID.
  Future<void> renameCupboard(String id, String newName) async {
    await (_db.update(_db.cupboards)..where((c) => c.id.equals(id)))
        .write(CupboardsCompanion(name: Value(newName)));
  }

  /// Rename a shelf by its UUID.
  Future<void> renameShelf(String id, String newName) async {
    await (_db.update(_db.shelves)..where((s) => s.id.equals(id)))
        .write(ShelvesCompanion(name: Value(newName)));
  }

  /// Delete a room and cascade: affected books have their shelf set to null.
  Future<void> deleteRoom(String id) async {
    await _db.transaction(() async {
      // Find all cupboards in this room (1 query)
      final cupboards = await (_db.select(_db.cupboards)
            ..where((c) => c.roomId.equals(id)))
          .get();

      final cupboardIds = cupboards.map((c) => c.id).toList();

      if (cupboardIds.isNotEmpty) {
        // Find all shelves under these cupboards (1 query, not N)
        final shelves = await (_db.select(_db.shelves)
              ..where((s) => s.cupboardId.isIn(cupboardIds)))
            .get();

        if (shelves.isNotEmpty) {
          // Nullify book_shelf references in a single batch update
          final shelfIds = shelves.map((s) => s.id).toList();
          await (_db.update(_db.bookShelves)
                ..where((bs) => bs.shelfId.isIn(shelfIds)))
              .write(const BookShelvesCompanion(shelfId: Value(null)));
        }

        // Delete all shelves under these cupboards (single batch delete)
        await (_db.delete(_db.shelves)
              ..where((s) => s.cupboardId.isIn(cupboardIds)))
            .go();

        // Delete all cupboards under this room (single batch delete)
        await (_db.delete(_db.cupboards)
              ..where((c) => c.roomId.equals(id)))
            .go();
      }

      // Delete the room itself
      await (_db.delete(_db.rooms)..where((r) => r.id.equals(id))).go();
    });
  }

  /// Delete a cupboard and cascade: affected books have their shelf set to null.
  Future<void> deleteCupboard(String id) async {
    await _db.transaction(() async {
      final shelves = await (_db.select(_db.shelves)
            ..where((s) => s.cupboardId.equals(id)))
          .get();

      if (shelves.isNotEmpty) {
        // Nullify book_shelf references in a single batch update
        final shelfIds = shelves.map((s) => s.id).toList();
        await (_db.update(_db.bookShelves)
              ..where((bs) => bs.shelfId.isIn(shelfIds)))
            .write(const BookShelvesCompanion(shelfId: Value(null)));
      }

      await (_db.delete(_db.shelves)..where((s) => s.cupboardId.equals(id)))
          .go();
      await (_db.delete(_db.cupboards)..where((c) => c.id.equals(id))).go();
    });
  }

  /// Delete a shelf and cascade: affected books have their shelf set to null.
  Future<void> deleteShelf(String id) async {
    await (_db.update(_db.bookShelves)
          ..where((bs) => bs.shelfId.equals(id)))
        .write(const BookShelvesCompanion(shelfId: Value(null)));
    await (_db.delete(_db.shelves)..where((s) => s.id.equals(id))).go();
  }

  /// Return the full location hierarchy: all rooms.
  Future<List<Room>> queryFullHierarchy() async {
    return _db.select(_db.rooms).get();
  }

  /// Query all rooms.
  Future<List<Room>> getAllRooms() async {
    return _db.select(_db.rooms).get();
  }

  /// Query cupboards within a room.
  Future<List<Cupboard>> getCupboardsByRoom(String roomId) async {
    return (_db.select(_db.cupboards)..where((c) => c.roomId.equals(roomId)))
        .get();
  }

  /// Query shelves within a cupboard.
  Future<List<Shelve>> getShelvesByCupboard(String cupboardId) async {
    return (_db.select(_db.shelves)
          ..where((s) => s.cupboardId.equals(cupboardId)))
        .get();
  }

  /// Alias for [createRoom].
  Future<Room> addRoom(String name) => createRoom(name);
}

/// Riverpod provider for [LocationRepository].
final locationRepoProvider = Provider<LocationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocationRepository(db);
});
