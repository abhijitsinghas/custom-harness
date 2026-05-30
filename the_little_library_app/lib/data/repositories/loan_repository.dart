import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'database_provider.dart';

/// Repository for book loan CRUD with active-loan queries.
class LoanRepository {
  LoanRepository(this._db);

  final AppDatabase _db;

  /// Create a new book loan.
  Future<BookLoan> add(BookLoan loan) async {
    await _db.into(_db.bookLoans).insert(
          BookLoansCompanion.insert(
            id: loan.id,
            bookId: loan.bookId,
            borrowerName: loan.borrowerName,
            borrowerContact: Value(loan.borrowerContact),
            loanedDate: Value(loan.loanedDate),
            dueDate: Value(loan.dueDate),
            returnedDate: Value(loan.returnedDate),
            notes: Value(loan.notes),
            createdAt: Value(loan.createdAt),
            createdBy: Value(loan.createdBy),
          ),
        );
    return loan;
  }

  /// Mark a loan as returned by setting [returnedDate].
  Future<void> returnLoan(String id, String returnedDate) async {
    await (_db.update(_db.bookLoans)..where((l) => l.id.equals(id)))
        .write(BookLoansCompanion(returnedDate: Value(returnedDate)));
  }

  /// Get active (unreturned) loans for a specific book.
  Future<List<BookLoan>> getActiveByBook(String bookId) async {
    return (_db.select(_db.bookLoans)
          ..where(
              (l) => l.bookId.equals(bookId) & l.returnedDate.isNull()))
        .get();
  }

  /// Get all active (unreturned) loans.
  Future<List<BookLoan>> getAllActive() async {
    return (_db.select(_db.bookLoans)..where((l) => l.returnedDate.isNull()))
        .get();
  }

  /// Get loan history for a specific book (including returned).
  Future<List<BookLoan>> getHistoryByBook(String bookId) async {
    return (_db.select(_db.bookLoans)..where((l) => l.bookId.equals(bookId)))
        .get();
  }
}

/// Riverpod provider for [LoanRepository].
final loanRepoProvider = Provider<LoanRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LoanRepository(db);
});
