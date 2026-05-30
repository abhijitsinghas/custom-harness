import 'package:drift/drift.dart';

/// An author that can be linked to many books.
///
/// [normalizedName] is the canonical, lowercase, stripped form used for dedup.
/// [disambiguation] resolves same-name collisions (e.g. "historian, b.1965").
@TableIndex(name: 'idx_author_normalized_name', columns: {#normalizedName})
@TableIndex(name: 'idx_author_raw_name', columns: {#rawName})
class Author extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Display name as entered (e.g. "J.K. Rowling").
  TextColumn get rawName => text()();

  /// Normalised for dedup — lowercase, no spaces/punctuation. Unique.
  TextColumn get normalizedName => text()();

  /// Optional note to distinguish authors with the same name.
  TextColumn get disambiguation => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A genre (category) linked to books.
///
/// [isCustom] distinguishes predefined (shipped) from user-created genres.
@TableIndex(name: 'idx_genre_name', columns: {#name})
class Genre extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Genre name (e.g. "Fiction", "Science"). Unique.
  TextColumn get name => text()();

  /// `false` = predefined seed; `true` = user-created.
  BoolColumn get isCustom =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A user-defined tag (e.g. "unread", "lent to mom").
@TableIndex(name: 'idx_tag_name', columns: {#name})
class Tag extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Tag name. Unique.
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A language available for books.
///
/// [isBuiltin] distinguishes the three shipped languages (English, Hindi,
/// Marathi) from user-added ones.
@TableIndex(name: 'idx_language_name', columns: {#name})
class Language extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Language name (e.g. "English", "Hindi"). Unique.
  TextColumn get name => text()();

  /// `true` = built-in seed; `false` = user-added.
  BoolColumn get isBuiltin =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
