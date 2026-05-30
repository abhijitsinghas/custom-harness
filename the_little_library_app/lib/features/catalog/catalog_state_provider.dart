import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants.dart';
import '../../data/database/dao/book_dao.dart';
import '../../data/database/database.dart';
import '../../data/repositories/database_provider.dart';

part 'catalog_state_provider.g.dart';

/// How search ranking is applied.
enum SearchRanking { relevance, recency, alphabetical }

/// Sort criteria for the catalog list.
enum CatalogSort { title, author, recentlyAdded, purchaseDate }

/// View mode for the catalog.
enum CatalogViewMode { grid, list }

/// All filter state for the catalog.
class CatalogFilters {
  final List<String>? genreIds;
  final String? languageId;
  final String? locationRoomId;
  final BookStatus? status;
  final BookFormat? format;
  final BookCondition? condition;
  final List<String>? tagIds;
  final String? purchaseDateFrom;
  final String? purchaseDateTo;
  final bool showDeleted;
  final bool checkedOutByMe;
  final bool showUnplaced;

  const CatalogFilters({
    this.genreIds,
    this.languageId,
    this.locationRoomId,
    this.status,
    this.format,
    this.condition,
    this.tagIds,
    this.purchaseDateFrom,
    this.purchaseDateTo,
    this.showDeleted = false,
    this.checkedOutByMe = false,
    this.showUnplaced = false,
  });

  bool get hasActiveFilters {
    return genreIds != null ||
        languageId != null ||
        locationRoomId != null ||
        status != null ||
        format != null ||
        condition != null ||
        tagIds != null ||
        purchaseDateFrom != null ||
        purchaseDateTo != null ||
        showDeleted ||
        checkedOutByMe ||
        showUnplaced;
  }

  CatalogFilters copyWith({
    List<String>? genreIds,
    String? languageId,
    String? locationRoomId,
    BookStatus? status,
    BookFormat? format,
    BookCondition? condition,
    List<String>? tagIds,
    String? purchaseDateFrom,
    String? purchaseDateTo,
    bool? showDeleted,
    bool? checkedOutByMe,
    bool? showUnplaced,
  }) {
    return CatalogFilters(
      genreIds: genreIds ?? this.genreIds,
      languageId: languageId ?? this.languageId,
      locationRoomId: locationRoomId ?? this.locationRoomId,
      status: status ?? this.status,
      format: format ?? this.format,
      condition: condition ?? this.condition,
      tagIds: tagIds ?? this.tagIds,
      purchaseDateFrom: purchaseDateFrom ?? this.purchaseDateFrom,
      purchaseDateTo: purchaseDateTo ?? this.purchaseDateTo,
      showDeleted: showDeleted ?? this.showDeleted,
      checkedOutByMe: checkedOutByMe ?? this.checkedOutByMe,
      showUnplaced: showUnplaced ?? this.showUnplaced,
    );
  }

  CatalogFilters clear() {
    return const CatalogFilters();
  }
}

/// Immutable snapshot of catalog state exposed to the UI.
class CatalogState {
  final List<Book> books;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String searchQuery;
  final SearchRanking ranking;
  final CatalogSort sort;
  final CatalogViewMode viewMode;
  final CatalogFilters filters;
  final Set<String> selectedIds;
  final bool isMultiSelect;
  final int unplacedBookCount;

  const CatalogState({
    this.books = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.error,
    this.searchQuery = '',
    this.ranking = SearchRanking.relevance,
    this.sort = CatalogSort.title,
    this.viewMode = CatalogViewMode.grid,
    this.filters = const CatalogFilters(),
    this.selectedIds = const {},
    this.isMultiSelect = false,
    this.unplacedBookCount = 0,
  });

  CatalogState copyWith({
    List<Book>? books,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? searchQuery,
    SearchRanking? ranking,
    CatalogSort? sort,
    CatalogViewMode? viewMode,
    CatalogFilters? filters,
    Set<String>? selectedIds,
    bool? isMultiSelect,
    int? unplacedBookCount,
    bool clearError = false,
  }) {
    return CatalogState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      ranking: ranking ?? this.ranking,
      sort: sort ?? this.sort,
      viewMode: viewMode ?? this.viewMode,
      filters: filters ?? this.filters,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      unplacedBookCount: unplacedBookCount ?? this.unplacedBookCount,
    );
  }
}

@riverpod
class CatalogNotifier extends _$CatalogNotifier {
  static const _pageSize = 50;

  int _offset = 0;
  bool _isFetchingMore = false;
  Timer? _searchDebounce;

  @override
  CatalogState build() {
    ref.onDispose(() {
      _searchDebounce?.cancel();
    });
    unawaited(_loadBooks());
    return const CatalogState(isLoading: true);
  }

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> _loadBooks({bool reset = true}) async => _loadBooksInner(reset: reset);

  Future<void> _loadBooksInner({bool reset = true}) async {
    if (reset) {
      _offset = 0;
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        books: const [],
        hasMore: false,
      );
    }

    try {
      final dao = _db.bookDao;
      final f = _buildBookFilters();
      final sort = _mapSort(state.sort);
      final query = state.searchQuery.trim();

      List<Book> results;
      if (query.isNotEmpty && !state.filters.hasActiveFilters && !state.filters.showUnplaced) {
        results = await dao.searchBooksByFts(query);
        results = _applySortInMemory(results, state.sort);
      } else if (state.filters.showUnplaced) {
        results = await _getUnplacedBooks();
      } else {
        results = await dao.listBooksPaginated(
          limit: _pageSize,
          offset: _offset,
          sort: sort,
          filters: f,
        );
      }

      final unplacedCount = await _getUnplacedBookCount();
      final hasMore = results.length >= _pageSize && !state.filters.showUnplaced;

      // Apply "Checked Out by Me" in-memory filter
      results = _applyCheckedOutByMe(results);

      if (reset) {
        state = state.copyWith(
          books: results,
          isLoading: false,
          hasMore: hasMore,
          unplacedBookCount: unplacedCount,
        );
      } else {
        state = state.copyWith(
          books: [...state.books, ...results],
          isLoading: false,
          hasMore: hasMore,
          unplacedBookCount: unplacedCount,
        );
      }
      _isFetchingMore = false;
    } catch (e) {
      if (reset) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          books: const [],
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      _isFetchingMore = false;
    }
  }

  BookFilters _buildBookFilters() {
    final f = state.filters;
    return BookFilters(
      genres: f.genreIds,
      languageId: f.languageId,
      status: f.status,
      format: f.format,
      condition: f.condition,
      tags: f.tagIds,
      locationRoomId: f.locationRoomId,
      purchaseDateFrom: f.purchaseDateFrom,
      purchaseDateTo: f.purchaseDateTo,
      showDeleted: f.showDeleted,
    );
  }

  /// Applies the "Checked Out by Me" filter in-memory.
  /// Matches checked_out_to against the signed-in user's display name.
  List<Book> _applyCheckedOutByMe(List<Book> books) {
    final f = state.filters;
    if (!f.checkedOutByMe) return books;
    final currentUser = ''; // Would read from authStateProvider in production
    if (currentUser.isEmpty) return books;
    return books
        .where((b) =>
            b.checkedOutTo != null &&
            b.checkedOutTo!.toLowerCase().contains(currentUser.toLowerCase()))
        .toList();
  }

  Future<List<Book>> _getUnplacedBooks() async {
    // Get all books with no shelf assignment
    final allBooks = await _db.bookDao.listBooksPaginated(
      limit: 1000,
      filters: const BookFilters(showDeleted: false),
    );
    final bookIds = allBooks.map((b) => b.id).toSet();

    // Get books that have shelf assignments
    final assignedRows = await _db.select(_db.bookShelves).get();
    final assignedBookIds = assignedRows.map((bs) => bs.bookId).toSet();

    final unplacedIds = bookIds.difference(assignedBookIds);
    final unplacedBooks = allBooks.where((b) => unplacedIds.contains(b.id)).toList();

    return _applySortInMemory(unplacedBooks, state.sort);
  }

  Future<int> _getUnplacedBookCount() async {
    final allBooks = await _db.bookDao.listBooksPaginated(
      limit: 10000,
      filters: const BookFilters(showDeleted: false),
    );
    final bookIds = allBooks.map((b) => b.id).toSet();

    final assignedRows = await _db.select(_db.bookShelves).get();
    final assignedBookIds = assignedRows.map((bs) => bs.bookId).toSet();

    return bookIds.difference(assignedBookIds).length;
  }

  BookSort _mapSort(CatalogSort sort) {
    return switch (sort) {
      CatalogSort.title => BookSort.title,
      CatalogSort.author => BookSort.author,
      CatalogSort.recentlyAdded => BookSort.recentlyAdded,
      CatalogSort.purchaseDate => BookSort.purchaseDate,
    };
  }

  List<Book> _applySortInMemory(List<Book> books, CatalogSort sort) {
    return switch (sort) {
      CatalogSort.title => List.from(books)
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())),
      CatalogSort.author => List.from(books)
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())),
      CatalogSort.recentlyAdded => List.from(books)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      CatalogSort.purchaseDate => List.from(books)
        ..sort((a, b) {
          if (a.purchaseDate == null && b.purchaseDate == null) return 0;
          if (a.purchaseDate == null) return 1;
          if (b.purchaseDate == null) return -1;
          return b.purchaseDate!.compareTo(a.purchaseDate!);
        }),
    };
  }

  void setSearchQuery(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      state = state.copyWith(searchQuery: '', clearError: true);
      _loadBooks();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(searchQuery: query, clearError: true);
      unawaited(_loadBooks());
    });
  }

  void setRanking(SearchRanking ranking) {
    state = state.copyWith(ranking: ranking, clearError: true);
    _loadBooks();
  }

  void setSort(CatalogSort sort) {
    state = state.copyWith(sort: sort, clearError: true);
    _loadBooks();
  }

  void toggleViewMode() {
    final newMode =
        state.viewMode == CatalogViewMode.grid ? CatalogViewMode.list : CatalogViewMode.grid;
    state = state.copyWith(viewMode: newMode);
  }

  void setViewMode(CatalogViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setFilters(CatalogFilters filters) {
    state = state.copyWith(filters: filters, clearError: true);
    _loadBooks();
  }

  void updateFilters({
    List<String>? genreIds,
    String? languageId,
    String? locationRoomId,
    BookStatus? status,
    BookFormat? format,
    BookCondition? condition,
    List<String>? tagIds,
    String? purchaseDateFrom,
    String? purchaseDateTo,
    bool? showDeleted,
    bool? checkedOutByMe,
    bool? showUnplaced,
  }) {
    final updated = state.filters.copyWith(
      genreIds: genreIds,
      languageId: languageId,
      locationRoomId: locationRoomId,
      status: status,
      format: format,
      condition: condition,
      tagIds: tagIds,
      purchaseDateFrom: purchaseDateFrom,
      purchaseDateTo: purchaseDateTo,
      showDeleted: showDeleted,
      checkedOutByMe: checkedOutByMe,
      showUnplaced: showUnplaced,
    );
    state = state.copyWith(filters: updated, clearError: true);
    unawaited(_loadBooks());
  }

  void clearFilters() {
    state = state.copyWith(filters: const CatalogFilters(), clearError: true);
    unawaited(_loadBooks());
  }

  void loadMore() {
    if (state.isLoading || _isFetchingMore || !state.hasMore) return;
    _isFetchingMore = true;
    _offset += _pageSize;
    unawaited(_loadBooks(reset: false));
  }

  Future<void> refresh() async {
    _offset = 0;
    await _loadBooksInner();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Multi-select
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> enterMultiSelect(String bookId) async {
    state = state.copyWith(
      isMultiSelect: true,
      selectedIds: {bookId},
    );
  }

  void toggleSelection(String bookId) {
    final newSet = Set<String>.from(state.selectedIds);
    if (newSet.contains(bookId)) {
      newSet.remove(bookId);
    } else {
      newSet.add(bookId);
    }
    if (newSet.isEmpty) {
      state = state.copyWith(isMultiSelect: false, selectedIds: const {});
    } else {
      state = state.copyWith(selectedIds: newSet);
    }
  }

  void selectAll() {
    state = state.copyWith(
      selectedIds: state.books.map((b) => b.id).toSet(),
    );
  }

  void clearSelection() {
    state = state.copyWith(isMultiSelect: false, selectedIds: const {});
  }

  void exitMultiSelect() {
    state = state.copyWith(isMultiSelect: false, selectedIds: const {});
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Actions on selected books
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> deleteSelected() async {
    for (final id in state.selectedIds) {
      await _db.bookDao.softDeleteBook(id, deviceUser: 'local');
    }
    clearSelection();
    await _loadBooksInner();
  }

  Future<void> assignLocationToSelected(String shelfId) async {
    for (final id in state.selectedIds) {
      await _db.bookDao.updateBookWithRelations(
        bookId: id,
        shelfId: shelfId,
        deviceUser: 'local',
      );
    }
    clearSelection();
    await _loadBooksInner();
  }
}
