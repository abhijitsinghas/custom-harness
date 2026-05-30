/// Book detail provider — fetches full book details, loan history, and
/// handles soft-delete/restore actions.
/// US-50 through US-58: Book Detail Screen state management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/dao/book_dao.dart';
import '../../data/database/database.dart';
import '../../data/repositories/database_provider.dart';
import '../../data/repositories/loan_repository.dart';

/// Consolidated view-model data for the book detail screen.
class BookDetailState {
  final Book book;
  final List<Author> authors;
  final List<Genre> genres;
  final List<Tag> tags;
  final Language? language;
  final Room? room;
  final Cupboard? cupboard;
  final Shelve? shelf;
  final List<BookLoan> loanHistory;

  const BookDetailState({
    required this.book,
    required this.authors,
    required this.genres,
    required this.tags,
    this.language,
    this.room,
    this.cupboard,
    this.shelf,
    this.loanHistory = const [],
  });

  /// Whether the book is soft-deleted.
  bool get isDeleted => book.isDeleted;

  /// Human-readable status text combining status and location.
  String get statusText {
    final parts = <String>[];
    switch (book.status) {
      case BookStatus.available:
        parts.add('Available');
      case BookStatus.checkedOut:
        parts.add('Checked Out');
      case BookStatus.loaned:
        parts.add('Loaned');
    }
    if (isDeleted) {
      parts.add('[Deleted]');
    }
    final locationParts = <String>[];
    if (room != null) locationParts.add(room!.name);
    if (shelf != null) locationParts.add(shelf!.name);
    if (locationParts.isNotEmpty) {
      parts.add('— ${locationParts.join(' / ')}');
    }
    return parts.join(' ');
  }
}

/// Provider for fetching book detail with all relations.
final bookDetailProvider =
    FutureProvider.family<BookDetailState, String>((ref, bookId) async {
  final db = ref.watch(databaseProvider);
  final bookDao = BookDao(db);

  final details = await bookDao.getBookWithDetails(bookId);
  if (details == null) {
    throw Exception('Book not found: $bookId');
  }

  final loanRepo = ref.watch(loanRepoProvider);
  final loans = await loanRepo.getHistoryByBook(bookId);

  return BookDetailState(
    book: details.book,
    authors: details.authors,
    genres: details.genres,
    tags: details.tags,
    language: details.language,
    room: details.room,
    cupboard: details.cupboard,
    shelf: details.shelf,
    loanHistory: loans,
  );
});
