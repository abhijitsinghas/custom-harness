import 'package:drift/drift.dart';
import 'package:thelittlelibrary/core/constants.dart';

class BookFormatConverter extends TypeConverter<BookFormat, String> {
  const BookFormatConverter();

  @override
  BookFormat fromSql(String fromDb) => BookFormat.values.byName(fromDb);

  @override
  String toSql(BookFormat value) => value.name;
}

class BookConditionConverter extends TypeConverter<BookCondition, String> {
  const BookConditionConverter();

  @override
  BookCondition fromSql(String fromDb) => BookCondition.values.byName(fromDb);

  @override
  String toSql(BookCondition value) => value.name;
}

class BookStatusConverter extends TypeConverter<BookStatus, String> {
  const BookStatusConverter();

  @override
  BookStatus fromSql(String fromDb) => BookStatus.values.byName(fromDb);

  @override
  String toSql(BookStatus value) => value.name;
}

@TableIndex(name: 'idx_book_title', columns: {#title})
@TableIndex(name: 'idx_book_isbn', columns: {#isbn})
@TableIndex(name: 'idx_book_language_id', columns: {#languageId})
@TableIndex(name: 'idx_book_format', columns: {#format})
@TableIndex(name: 'idx_book_condition', columns: {#condition})
@TableIndex(name: 'idx_book_purchase_date', columns: {#purchaseDate})
@TableIndex(name: 'idx_book_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_book_status', columns: {#status})
@TableIndex(name: 'idx_book_checked_out_to', columns: {#checkedOutTo})
class Books extends Table {
  @override
  String get tableName => 'book';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get title =>
      text().withLength(min: 1).customConstraint('COLLATE NOCASE NOT NULL')();

  TextColumn get isbn => text().nullable()();

  TextColumn get languageId =>
      text().nullable().customConstraint('REFERENCES language(id)')();

  TextColumn get coverImagePath => text().nullable()();

  TextColumn get coverImageUrl => text().nullable()();

  TextColumn get publisher => text().nullable()();

  TextColumn get edition => text().nullable()();

  TextColumn get publicationDate => text().nullable()();

  TextColumn get format => text().map(const BookFormatConverter()).nullable()();

  IntColumn get pageCount => integer().nullable()();

  TextColumn get description => text().nullable()();

  TextColumn get condition =>
      text().map(const BookConditionConverter()).nullable()();

  RealColumn get pricePaid => real().nullable()();

  TextColumn get purchaseDate => text().nullable()();

  TextColumn get notes => text().nullable()();

  TextColumn get status => text().map(const BookStatusConverter()).withDefault(
        const Constant('available'),
      )();

  TextColumn get checkedOutTo => text().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  TextColumn get createdAt =>
      text().clientDefault(() => DateTime.now().toIso8601String())();

  TextColumn get updatedAt =>
      text().clientDefault(() => DateTime.now().toIso8601String())();

  @override
  Set<Column> get primaryKey => {id};
}
