import 'package:drift/drift.dart';

/// A single book in the catalog.
///
/// Mirrors the spec-v2.md Book entity (21 fields). All primary keys are UUID v4
/// text. Books are soft-deleted via the [isDeleted] flag — they are never
/// physically removed from the database.
@TableIndex(name: 'idx_book_title', columns: {#title})
@TableIndex(name: 'idx_book_isbn', columns: {#isbn})
@TableIndex(name: 'idx_book_language_id', columns: {#languageId})
@TableIndex(name: 'idx_book_format', columns: {#format})
@TableIndex(name: 'idx_book_condition', columns: {#condition})
@TableIndex(name: 'idx_book_purchase_date', columns: {#purchaseDate})
@TableIndex(name: 'idx_book_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_book_status', columns: {#status})
@TableIndex(name: 'idx_book_checked_out_to', columns: {#checkedOutTo})
class Book extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Full title including subtitle. Required.
  TextColumn get title => text()();

  /// ISBN-13 (normalised from ISBN-10 on save). Nullable.
  TextColumn get isbn => text().nullable()();

  /// FK → Language. Required.
  TextColumn get languageId => text()();

  /// Local file path to cover image. Nullable.
  TextColumn get coverImagePath => text().nullable()();

  /// Remote URL if fetched online. Nullable.
  TextColumn get coverImageUrl => text().nullable()();

  /// Publisher name. Nullable.
  TextColumn get publisher => text().nullable()();

  /// Edition description (e.g. "1st", "Revised"). Nullable.
  TextColumn get edition => text().nullable()();

  /// Publication date — "YYYY-MM-DD" or "YYYY". Nullable.
  TextColumn get publicationDate => text().nullable()();

  /// Enum: Hardcover, Paperback, Ebook, Audiobook. Nullable.
  TextColumn get format => text().nullable()();

  /// Number of pages. Nullable.
  IntColumn get pageCount => integer().nullable()();

  /// Synopsis / blurb. Nullable.
  TextColumn get description => text().nullable()();

  /// Enum: New, LikeNew, VeryGood, Good, Fair, Poor. Nullable.
  TextColumn get condition => text().nullable()();

  /// Purchase price in local currency. Nullable.
  RealColumn get pricePaid => real().nullable()();

  /// ISO date string (YYYY-MM-DD). Nullable.
  TextColumn get purchaseDate => text().nullable()();

  /// Free-form notes. Nullable.
  TextColumn get notes => text().nullable()();

  /// Enum: Available, CheckedOut, Loaned. Required.
  TextColumn get status => text()();

  /// Family member name when status = CheckedOut. Nullable.
  TextColumn get checkedOutTo => text().nullable()();

  /// Soft-delete flag. Defaults to false.
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  /// ISO timestamp, auto-set on creation.
  TextColumn get createdAt => text()();

  /// ISO timestamp, auto-updated on every change.
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Join table — many-to-many between [Book] and [Author].
@TableIndex(name: 'idx_book_author_book_id', columns: {#bookId})
@TableIndex(name: 'idx_book_author_author_id', columns: {#authorId})
class BookAuthor extends Table {
  /// FK → Book.id
  TextColumn get bookId => text().references(Book, #id)();

  /// FK → Author.id
  TextColumn get authorId => text()();

  @override
  Set<Column> get primaryKey => {bookId, authorId};
}

/// Join table — many-to-many between [Book] and [Genre].
@TableIndex(name: 'idx_book_genre_book_id', columns: {#bookId})
@TableIndex(name: 'idx_book_genre_genre_id', columns: {#genreId})
class BookGenre extends Table {
  /// FK → Book.id
  TextColumn get bookId => text().references(Book, #id)();

  /// FK → Genre.id
  TextColumn get genreId => text()();

  @override
  Set<Column> get primaryKey => {bookId, genreId};
}

/// Join table — many-to-many between [Book] and [Tag].
@TableIndex(name: 'idx_book_tag_book_id', columns: {#bookId})
@TableIndex(name: 'idx_book_tag_tag_id', columns: {#tagId})
class BookTag extends Table {
  /// FK → Book.id
  TextColumn get bookId => text().references(Book, #id)();

  /// FK → Tag.id
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {bookId, tagId};
}

/// Every book has one location; defaults to "None" when [shelfId] is null.
@TableIndex(name: 'idx_book_shelf_shelf_id', columns: {#shelfId})
class BookShelf extends Table {
  /// FK → Book.id (unique — one location per book).
  TextColumn get bookId => text().references(Book, #id)();

  /// FK → Shelf.id. Nullable when the book has no location ("None").
  TextColumn get shelfId => text().nullable()();

  @override
  Set<Column> get primaryKey => {bookId};
}

/// External loan — when a book is loaned outside the household.
@TableIndex(name: 'idx_book_loan_book_returned', columns: {#bookId, #returnedDate})
@TableIndex(name: 'idx_book_loan_borrower', columns: {#borrowerName})
class BookLoan extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// FK → Book.id
  TextColumn get bookId => text().references(Book, #id)();

  /// Name of the person who borrowed the book.
  TextColumn get borrowerName => text()();

  /// Optional phone number or email.
  TextColumn get borrowerContact => text().nullable()();

  /// ISO date (YYYY-MM-DD). Required.
  TextColumn get loanedDate => text()();

  /// Expected return date (YYYY-MM-DD). Nullable.
  TextColumn get dueDate => text().nullable()();

  /// Actual return date; null if still out.
  TextColumn get returnedDate => text().nullable()();

  /// Free-form notes about the loan.
  TextColumn get notes => text().nullable()();

  /// ISO timestamp when the loan was recorded.
  TextColumn get createdAt => text()();

  /// Google account email of who recorded the loan.
  TextColumn get createdBy => text()();

  @override
  Set<Column> get primaryKey => {id};
}
