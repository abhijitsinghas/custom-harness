import 'package:drift/drift.dart';

@TableIndex(name: 'idx_book_loan_book_returned', columns: {#bookId, #returnedDate})
@TableIndex(name: 'idx_book_loan_borrower_name', columns: {#borrowerName})
class BookLoans extends Table {
  @override
  String get tableName => 'book_loan';

  TextColumn get id => text().withLength(min: 36, max: 36)();

  TextColumn get bookId =>
      text().customConstraint('REFERENCES book(id)')();

  TextColumn get borrowerName => text().withLength(min: 1)();

  TextColumn get borrowerContact => text().nullable()();

  TextColumn get loanedDate =>
      text().clientDefault(() => DateTime.now().toIso8601String())();

  TextColumn get dueDate => text().nullable()();

  TextColumn get returnedDate => text().nullable()();

  TextColumn get notes => text().nullable()();

  TextColumn get createdAt =>
      text().clientDefault(() => DateTime.now().toIso8601String())();

  TextColumn get createdBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
