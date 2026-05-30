import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants.dart';
import '../../../core/isbn_utils.dart';
import '../database.dart';

const _uuid = Uuid();

/// Sort options for book list queries.
enum BookSort { title, author, recentlyAdded, purchaseDate }

/// Filter criteria for book list queries.
class BookFilters {
  final List<String>? genres;
  final String? languageId;
  final BookStatus? status;
  final BookFormat? format;
  final BookCondition? condition;
  final List<String>? tags;
  final String? locationRoomId;
  final String? purchaseDateFrom;
  final String? purchaseDateTo;
  final bool showDeleted;

  const BookFilters({
    this.genres,
    this.languageId,
    this.status,
    this.format,
    this.condition,
    this.tags,
    this.locationRoomId,
    this.purchaseDateFrom,
    this.purchaseDateTo,
    this.showDeleted = false,
  });
}

/// Result for getBookWithDetails.
class BookWithDetails {
  final Book book;
  final List<Author> authors;
  final List<Genre> genres;
  final List<Tag> tags;
  final Language? language;
  final Room? room;
  final Cupboard? cupboard;
  final Shelve? shelf;

  const BookWithDetails({
    required this.book,
    required this.authors,
    required this.genres,
    required this.tags,
    this.language,
    this.room,
    this.cupboard,
    this.shelf,
  });
}

/// DAO for book CRUD, search, filtering, and sorting.
@DriftAccessor()
class BookDao {
  final AppDatabase _db;

  BookDao(this._db);

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.1: Insert with relations
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> insertBookWithRelations({
    required String id,
    required String title,
    String? isbn,
    String? languageId,
    String? coverImagePath,
    String? coverImageUrl,
    String? publisher,
    String? edition,
    String? publicationDate,
    BookFormat? format,
    int? pageCount,
    String? description,
    BookCondition? condition,
    double? pricePaid,
    String? purchaseDate,
    String? notes,
    BookStatus status = BookStatus.available,
    required List<String> authorIds,
    required List<String> genreIds,
    required List<String> tagIds,
    String? shelfId,
    required String deviceUser,
  }) async {
    final convertedIsbn = isbn != null ? toIsbn13(isbn) : null;

    await _db.transaction(() async {
      await _db.into(_db.books).insert(
            BooksCompanion.insert(
              id: id,
              title: title,
              isbn: Value(convertedIsbn),
              languageId: Value(languageId),
              coverImagePath: Value(coverImagePath),
              coverImageUrl: Value(coverImageUrl),
              publisher: Value(publisher),
              edition: Value(edition),
              publicationDate: Value(publicationDate),
              format: Value(format),
              pageCount: Value(pageCount),
              description: Value(description),
              condition: Value(condition),
              pricePaid: Value(pricePaid),
              purchaseDate: Value(purchaseDate),
              notes: Value(notes),
              status: Value(status),
            ),
          );

      for (final aid in authorIds) {
        await _db.into(_db.bookAuthors).insert(
              BookAuthorsCompanion.insert(bookId: id, authorId: aid),
            );
      }
      for (final gid in genreIds) {
        await _db.into(_db.bookGenres).insert(
              BookGenresCompanion.insert(bookId: id, genreId: gid),
            );
      }
      for (final tid in tagIds) {
        await _db.into(_db.bookTags).insert(
              BookTagsCompanion.insert(bookId: id, tagId: tid),
            );
      }

      await _db.into(_db.bookShelves).insert(
            BookShelvesCompanion.insert(
              bookId: id,
              shelfId: Value(shelfId),
            ),
          );

      await _writeChangeLog(
        entityId: id,
        eventType: EventType.create.name,
        fieldName: '*',
        newValue: title,
        deviceUser: deviceUser,
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.2: Read with details
  // ═══════════════════════════════════════════════════════════════════════════

  Future<BookWithDetails?> getBookWithDetails(String bookId) async {
    final book = await (_db.select(_db.books)
          ..where((b) => b.id.equals(bookId)))
        .getSingleOrNull();
    if (book == null) return null;

    // Authors
    final authorRows = await (_db.select(_db.authors).join([
      innerJoin(
          _db.bookAuthors, _db.bookAuthors.authorId.equalsExp(_db.authors.id)),
    ])
          ..where(_db.bookAuthors.bookId.equals(bookId)))
        .get();
    final authors = authorRows.map((r) => r.readTable(_db.authors)).toList();

    // Genres
    final genreRows = await (_db.select(_db.genres).join([
      innerJoin(
          _db.bookGenres, _db.bookGenres.genreId.equalsExp(_db.genres.id)),
    ])
          ..where(_db.bookGenres.bookId.equals(bookId)))
        .get();
    final genres = genreRows.map((r) => r.readTable(_db.genres)).toList();

    // Tags
    final tagRows = await (_db.select(_db.tags).join([
      innerJoin(_db.bookTags, _db.bookTags.tagId.equalsExp(_db.tags.id)),
    ])
          ..where(_db.bookTags.bookId.equals(bookId)))
        .get();
    final tags = tagRows.map((r) => r.readTable(_db.tags)).toList();

    // Language
    Language? language;
    if (book.languageId != null) {
      final lid = book.languageId!;
      language = await (_db.select(_db.languages)
            ..where((l) => l.id.equals(lid)))
          .getSingleOrNull();
    }

    // Location path
    Room? room;
    Cupboard? cupboard;
    Shelve? shelf;

    final bs = await (_db.select(_db.bookShelves)
          ..where((b) => b.bookId.equals(bookId)))
        .getSingleOrNull();

    if (bs != null && bs.shelfId != null) {
      final sid = bs.shelfId!;
      final s = await (_db.select(_db.shelves)
            ..where((sh) => sh.id.equals(sid)))
          .getSingleOrNull();
      shelf = s;
      if (s != null) {
        final c = await (_db.select(_db.cupboards)
              ..where((cu) => cu.id.equals(s.cupboardId)))
            .getSingleOrNull();
        cupboard = c;
        if (c != null) {
          final r = await (_db.select(_db.rooms)
                ..where((ro) => ro.id.equals(c.roomId)))
              .getSingleOrNull();
          room = r;
        }
      }
    }

    return BookWithDetails(
      book: book,
      authors: authors,
      genres: genres,
      tags: tags,
      language: language,
      room: room,
      cupboard: cupboard,
      shelf: shelf,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.3: Update with relations
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateBookWithRelations({
    required String bookId,
    String? title,
    String? isbn,
    String? languageId,
    BookFormat? format,
    BookCondition? condition,
    BookStatus? status,
    List<String>? authorIds,
    List<String>? genreIds,
    List<String>? tagIds,
    String? shelfId,
    required String deviceUser,
  }) async {
    final convertedIsbn = isbn != null ? toIsbn13(isbn) : null;
    final now = DateTime.now().toIso8601String();

    await _db.transaction(() async {
      await (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
        BooksCompanion(
          title: title != null ? Value(title) : const Value.absent(),
          isbn: isbn != null ? Value(convertedIsbn) : const Value.absent(),
          languageId:
              languageId != null ? Value(languageId) : const Value.absent(),
          format: format != null ? Value(format) : const Value.absent(),
          condition:
              condition != null ? Value(condition) : const Value.absent(),
          status: status != null ? Value(status) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );

      if (authorIds != null) {
        await (_db.delete(_db.bookAuthors)
              ..where((ba) => ba.bookId.equals(bookId)))
            .go();
        for (final aid in authorIds) {
          await _db.into(_db.bookAuthors).insert(
                BookAuthorsCompanion.insert(bookId: bookId, authorId: aid),
              );
        }
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'authors',
          newValue: authorIds.join(','),
          deviceUser: deviceUser,
        );
      }

      if (genreIds != null) {
        await (_db.delete(_db.bookGenres)
              ..where((bg) => bg.bookId.equals(bookId)))
            .go();
        for (final gid in genreIds) {
          await _db.into(_db.bookGenres).insert(
                BookGenresCompanion.insert(bookId: bookId, genreId: gid),
              );
        }
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'genres',
          newValue: genreIds.join(','),
          deviceUser: deviceUser,
        );
      }

      if (tagIds != null) {
        await (_db.delete(_db.bookTags)
              ..where((bt) => bt.bookId.equals(bookId)))
            .go();
        for (final tid in tagIds) {
          await _db.into(_db.bookTags).insert(
                BookTagsCompanion.insert(bookId: bookId, tagId: tid),
              );
        }
      }

      // Handle shelf assignment — supports both setting and clearing (null).
      // US-1.1.3: Allow moving a book to "None" (shelfId = null).
      if (true) {
        final existing = await (_db.select(_db.bookShelves)
              ..where((bs) => bs.bookId.equals(bookId)))
            .getSingleOrNull();
        if (existing != null) {
          await (_db.update(_db.bookShelves)
                ..where((bs) => bs.bookId.equals(bookId)))
              .write(BookShelvesCompanion(shelfId: Value(shelfId)));
        } else if (shelfId != null) {
          await _db.into(_db.bookShelves).insert(
                BookShelvesCompanion.insert(
                    bookId: bookId, shelfId: Value(shelfId)),
              );
        }
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'shelf_id',
          newValue: shelfId,
          deviceUser: deviceUser,
        );
      }

      if (title != null) {
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'title',
          newValue: title,
          deviceUser: deviceUser,
        );
      }

      // Write change log for every changed field (US-1.1.3).
      if (isbn != null) {
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'isbn',
          newValue: convertedIsbn,
          deviceUser: deviceUser,
        );
      }
      if (languageId != null) {
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'language_id',
          newValue: languageId,
          deviceUser: deviceUser,
        );
      }
      if (format != null) {
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'format',
          newValue: format.name,
          deviceUser: deviceUser,
        );
      }
      if (condition != null) {
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'condition',
          newValue: condition.name,
          deviceUser: deviceUser,
        );
      }
      if (status != null) {
        await _writeChangeLog(
          entityId: bookId,
          eventType: EventType.update.name,
          fieldName: 'status',
          newValue: status.name,
          deviceUser: deviceUser,
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.4: Soft-delete
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> softDeleteBook(String bookId,
      {required String deviceUser}) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
    await _writeChangeLog(
      entityId: bookId,
      eventType: EventType.delete.name,
      fieldName: 'is_deleted',
      newValue: 'true',
      deviceUser: deviceUser,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.5: Restore
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> restoreBook(String bookId, {required String deviceUser}) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(isDeleted: const Value(false), updatedAt: Value(now)),
    );
    await _writeChangeLog(
      entityId: bookId,
      eventType: EventType.update.name,
      fieldName: 'is_deleted',
      newValue: 'false',
      deviceUser: deviceUser,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.6 / 1.1.9 / 1.1.10: Paginated list with filters & sort
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Book>> listBooksPaginated({
    int limit = 50,
    int offset = 0,
    BookSort sort = BookSort.recentlyAdded,
    BookFilters? filters,
  }) async {
    final f = filters ?? const BookFilters();

    if (sort == BookSort.author) {
      return _listBooksWithAuthorSort(limit: limit, offset: offset, filters: f);
    }

    // Build SQL dynamically for non-author sort.
    // Use subquery to avoid DISTINCT + ORDER BY bug in SQLite.
    final innerSql = StringBuffer('SELECT DISTINCT book.* FROM book');
    final innerWhere = <String>[];
    final orderClauses = <String>[];

    if (!f.showDeleted) {
      innerWhere.add('book.is_deleted = 0');
    }
    if (f.languageId != null) {
      innerWhere.add('book.language_id = ?');
    }
    if (f.status != null) {
      innerWhere.add('book.status = ?');
    }
    if (f.format != null) {
      innerWhere.add('book.format = ?');
    }
    if (f.condition != null) {
      innerWhere.add('book.condition = ?');
    }
    if (f.genres != null && f.genres!.isNotEmpty) {
      innerSql.write(' INNER JOIN book_genre ON book.id = book_genre.book_id');
      final placeholders = f.genres!.map((_) => '?').join(',');
      innerWhere.add('book_genre.genre_id IN ($placeholders)');
    }
    if (f.tags != null && f.tags!.isNotEmpty) {
      innerSql.write(' INNER JOIN book_tag ON book.id = book_tag.book_id');
      final placeholders = f.tags!.map((_) => '?').join(',');
      innerWhere.add('book_tag.tag_id IN ($placeholders)');
    }
    if (f.purchaseDateFrom != null) {
      innerWhere.add('book.purchase_date >= ?');
    }
    if (f.purchaseDateTo != null) {
      innerWhere.add('book.purchase_date <= ?');
    }
    if (f.locationRoomId != null) {
      innerSql.write(
        ' INNER JOIN book_shelf ON book.id = book_shelf.book_id'
        ' INNER JOIN shelf ON book_shelf.shelf_id = shelf.id'
        ' INNER JOIN cupboard ON shelf.cupboard_id = cupboard.id',
      );
      innerWhere.add('cupboard.room_id = ?');
    }

    if (innerWhere.isNotEmpty) {
      innerSql.write(' WHERE ${innerWhere.join(' AND ')}');
    }

    // Wrap in subquery to allow ORDER BY after DISTINCT (SQLite-compatible).
    final sql = StringBuffer('SELECT * FROM ($innerSql)');

    switch (sort) {
      case BookSort.title:
        orderClauses.add('title COLLATE NOCASE ASC');
      case BookSort.recentlyAdded:
        orderClauses.add('created_at DESC');
      case BookSort.purchaseDate:
        orderClauses.add('purchase_date DESC NULLS LAST');
      case BookSort.author:
        break;
    }

    if (orderClauses.isNotEmpty) {
      sql.write(' ORDER BY ${orderClauses.join(', ')}');
    }
    sql.write(' LIMIT ? OFFSET ?');

    // Build variable list
    final variables = <Variable>[];
    if (f.languageId != null) {
      variables.add(Variable.withString(f.languageId!));
    }
    if (f.status != null) {
      variables.add(Variable.withString(f.status!.name));
    }
    if (f.format != null) {
      variables.add(Variable.withString(f.format!.name));
    }
    if (f.condition != null) {
      variables.add(Variable.withString(f.condition!.name));
    }
    if (f.genres != null) {
      for (final g in f.genres!) {
        variables.add(Variable.withString(g));
      }
    }
    if (f.tags != null) {
      for (final t in f.tags!) {
        variables.add(Variable.withString(t));
      }
    }
    if (f.purchaseDateFrom != null) {
      variables.add(Variable.withString(f.purchaseDateFrom!));
    }
    if (f.purchaseDateTo != null) {
      variables.add(Variable.withString(f.purchaseDateTo!));
    }
    if (f.locationRoomId != null) {
      variables.add(Variable.withString(f.locationRoomId!));
    }
    variables.add(Variable.withInt(limit));
    variables.add(Variable.withInt(offset));

    final rows = await _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: {_db.books},
    ).get();

    final books = <Book>[];
    for (final row in rows) {
      books.add(await _db.books.mapFromRow(row));
    }
    return books;
  }

  Future<List<Book>> _listBooksWithAuthorSort({
    int limit = 50,
    int offset = 0,
    required BookFilters filters,
  }) async {
    // Use subquery pattern to avoid SQLite DISTINCT + ORDER BY conflict.
    final innerSql = StringBuffer(
      'SELECT DISTINCT book.* FROM book '
      'INNER JOIN book_author ON book.id = book_author.book_id '
      'INNER JOIN author ON book_author.author_id = author.id',
    );
    final whereClauses = <String>[];

    if (!filters.showDeleted) {
      whereClauses.add('book.is_deleted = 0');
    }
    if (filters.languageId != null) {
      whereClauses.add('book.language_id = ?');
    }
    if (filters.status != null) {
      whereClauses.add('book.status = ?');
    }
    if (filters.format != null) {
      whereClauses.add('book.format = ?');
    }
    if (filters.condition != null) {
      whereClauses.add('book.condition = ?');
    }
    if (filters.genres != null && filters.genres!.isNotEmpty) {
      innerSql.write(' INNER JOIN book_genre ON book.id = book_genre.book_id');
      final placeholders = filters.genres!.map((_) => '?').join(',');
      whereClauses.add('book_genre.genre_id IN ($placeholders)');
    }
    if (filters.tags != null && filters.tags!.isNotEmpty) {
      innerSql.write(' INNER JOIN book_tag ON book.id = book_tag.book_id');
      final placeholders = filters.tags!.map((_) => '?').join(',');
      whereClauses.add('book_tag.tag_id IN ($placeholders)');
    }
    if (filters.purchaseDateFrom != null) {
      whereClauses.add('book.purchase_date >= ?');
    }
    if (filters.purchaseDateTo != null) {
      whereClauses.add('book.purchase_date <= ?');
    }
    if (filters.locationRoomId != null) {
      innerSql.write(
        ' INNER JOIN book_shelf ON book.id = book_shelf.book_id'
        ' INNER JOIN shelf ON book_shelf.shelf_id = shelf.id'
        ' INNER JOIN cupboard ON shelf.cupboard_id = cupboard.id',
      );
      whereClauses.add('cupboard.room_id = ?');
    }

    if (whereClauses.isNotEmpty) {
      innerSql.write(' WHERE ${whereClauses.join(' AND ')}');
    }

    // Wrap in subquery to allow ORDER BY after DISTINCT.
    final sql = StringBuffer('SELECT * FROM ($innerSql)');
    sql.write(
        ' ORDER BY raw_name COLLATE NOCASE ASC, title COLLATE NOCASE ASC');
    sql.write(' LIMIT ? OFFSET ?');

    final variables = <Variable>[];
    if (filters.languageId != null) {
      variables.add(Variable.withString(filters.languageId!));
    }
    if (filters.status != null) {
      variables.add(Variable.withString(filters.status!.name));
    }
    if (filters.format != null) {
      variables.add(Variable.withString(filters.format!.name));
    }
    if (filters.condition != null) {
      variables.add(Variable.withString(filters.condition!.name));
    }
    if (filters.genres != null) {
      for (final g in filters.genres!) {
        variables.add(Variable.withString(g));
      }
    }
    if (filters.tags != null) {
      for (final t in filters.tags!) {
        variables.add(Variable.withString(t));
      }
    }
    if (filters.purchaseDateFrom != null) {
      variables.add(Variable.withString(filters.purchaseDateFrom!));
    }
    if (filters.purchaseDateTo != null) {
      variables.add(Variable.withString(filters.purchaseDateTo!));
    }
    if (filters.locationRoomId != null) {
      variables.add(Variable.withString(filters.locationRoomId!));
    }
    variables.add(Variable.withInt(limit));
    variables.add(Variable.withInt(offset));

    final rows = await _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: {_db.books},
    ).get();

    final books = <Book>[];
    for (final row in rows) {
      books.add(await _db.books.mapFromRow(row));
    }
    return books;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.7: FTS5 search
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Book>> searchBooksByFts(String query) async {
    final escaped = query.replaceAll('"', '""');
    final ftsQuery = '"$escaped"';

    final rows = await _db.customSelect(
      'SELECT book.* FROM book '
      'JOIN book_fts ON book.rowid = book_fts.rowid '
      'WHERE book_fts MATCH ? AND book.is_deleted = 0 '
      'ORDER BY rank',
      variables: [Variable.withString(ftsQuery)],
      readsFrom: {_db.books},
    ).get();

    final books = <Book>[];
    for (final row in rows) {
      books.add(await _db.books.mapFromRow(row));
    }
    return books;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // US-1.1.8: Author search
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Book>> searchBooksByAuthor(String query) async {
    final likePattern = '%$query%';

    final rows = await (_db.select(_db.books).join([
      innerJoin(
          _db.bookAuthors, _db.bookAuthors.bookId.equalsExp(_db.books.id)),
      innerJoin(
          _db.authors, _db.authors.id.equalsExp(_db.bookAuthors.authorId)),
    ])
          ..where(_db.books.isDeleted.equals(false) &
              (_db.authors.rawName.like(likePattern) |
                  _db.authors.normalizedName.like(likePattern))))
        .get();

    return rows.map((r) => r.readTable(_db.books)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _writeChangeLog({
    required String entityId,
    required String eventType,
    required String fieldName,
    String? oldValue,
    String? newValue,
    required String deviceUser,
  }) async {
    await _db.into(_db.changeLogEvents).insert(
          ChangeLogEventsCompanion.insert(
            eventId: _uuid.v4(),
            entityType: EntityType.book.name,
            entityId: entityId,
            eventType: eventType,
            fieldName: fieldName,
            oldValue: Value(oldValue),
            newValue: Value(newValue),
            deviceUser: deviceUser,
          ),
        );
  }
}
