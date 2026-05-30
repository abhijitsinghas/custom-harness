/// Riverpod providers for the Add/Edit Book form.
/// Manages form state, enrichment, and duplicate detection.
/// US-74 through US-117
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart';

import '../../core/book_validator.dart';
import '../../core/constants.dart';
import '../../core/exceptions.dart';
import '../../core/isbn_utils.dart';
import '../../data/api/book_enrichment.dart';
import '../../data/api/google_books_client.dart';
import '../../data/api/google_books_providers.dart';
import '../../data/database/database.dart';
import '../../data/database/duplicate_detector.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/database_provider.dart';
import '../../data/repositories/genre_repository.dart';
import '../../data/repositories/language_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/tag_repository.dart';

/// Form mode: adding a new book or editing an existing one.
enum BookFormMode { add, edit }

/// Parameters for initializing the add book form.
class BookFormParams {
  const BookFormParams._({this.mode = BookFormMode.add, this.editBookId});

  factory BookFormParams.add() => const BookFormParams._(mode: BookFormMode.add);
  factory BookFormParams.edit({required String bookId}) =>
      BookFormParams._(mode: BookFormMode.edit, editBookId: bookId);

  final BookFormMode mode;
  final String? editBookId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookFormParams &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          editBookId == other.editBookId;

  @override
  int get hashCode => Object.hash(mode, editBookId);
}

/// ChangeNotifier-based form state for the Add/Edit Book form.
/// Using ChangeNotifier instead of AsyncNotifier to avoid Riverpod family complexity.
class BookFormNotifier extends ChangeNotifier {
  BookFormNotifier({
    required this.ref,
    required this.params,
  }) {
    _initialize();
  }

  final Ref ref;
  final BookFormParams params;

  // ── State fields ──────────────────────────────────────────────────────

  BookFormMode mode = BookFormMode.add;
  String? editBookId;
  String title = '';
  String isbn = '';
  String? languageId;
  BookFormat format = BookFormat.hardcover;
  List<String> authorNames = [];
  String publisher = '';
  String edition = '';
  String publicationDate = '';
  String pageCount = '';
  String description = '';
  List<String> genreIds = [];
  List<String> tagIds = [];
  String? selectedRoomId;
  String? selectedCupboardId;
  String? selectedShelfId;
  String purchaseDate = '';
  String pricePaid = '';
  BookCondition condition = BookCondition.newCondition;
  String? coverImagePath;
  String notes = '';
  bool isSaving = false;
  String? saveError;
  String? titleError;
  String? isbnError;
  String? publicationDateError;
  bool isAutoEnrichEnabled = false;
  bool isQuotaExceeded = false;
  List<BookEnrichment> enrichmentResults = [];
  bool isEnriching = false;
  String? enrichmentError;
  int? selectedEnrichmentIndex;
  Map<String, bool> enrichedSections = {};
  DuplicateResult? duplicateResult;
  bool showingDuplicateDialog = false;
  String authorSearchQuery = '';
  List<Author> authorSearchResults = [];
  bool showingAuthorDisambiguation = false;

  // Dropdown data
  List<Room> rooms = [];
  List<Cupboard> cupboards = [];
  List<Shelve> shelves = [];
  List<Language> languages = [];
  List<Genre> genres = [];
  List<Tag> tags = [];
  List<Author> existingAuthors = [];

  // Loading state
  bool isLoading = true;
  String? loadError;

  // ── Internal helpers ──────────────────────────────────────────────────

  AppDatabase get _db => ref.read(databaseProvider);
  BookRepository get _bookRepo => ref.read(bookRepoProvider);
  GenreRepository get _genreRepo => ref.read(genreRepoProvider);
  TagRepository get _tagRepo => ref.read(tagRepoProvider);
  LocationRepository get _locationRepo => ref.read(locationRepoProvider);
  LanguageRepository get _languageRepo => ref.read(languageRepoProvider);
  GoogleBooksClient get _googleBooks => ref.read(googleBooksClientProvider);

  Timer? _autoEnrichTimer;

  Future<void> _initialize() async {
    mode = params.mode;
    editBookId = params.editBookId;

    try {
      // Load dropdown data
      languages = await _languageRepo.listAll();
      genres = await _genreRepo.listAll();
      tags = await _tagRepo.getAll();
      rooms = await _locationRepo.getAllRooms();
      existingAuthors = await _db.authorDao.listAll();

      // If editing, pre-fill from existing book
      if (params.mode == BookFormMode.edit && params.editBookId != null) {
        final details = await _db.bookDao.getBookWithDetails(params.editBookId!);
        if (details != null) {
          title = details.book.title;
          isbn = details.book.isbn ?? '';
          languageId = details.book.languageId;
          format = details.book.format ?? BookFormat.hardcover;
          authorNames = details.authors.map((a) => a.rawName).toList();
          publisher = details.book.publisher ?? '';
          edition = details.book.edition ?? '';
          publicationDate = details.book.publicationDate ?? '';
          pageCount = details.book.pageCount?.toString() ?? '';
          description = details.book.description ?? '';
          genreIds = details.genres.map((g) => g.id).toList();
          tagIds = details.tags.map((t) => t.id).toList();
          purchaseDate = details.book.purchaseDate ?? '';
          pricePaid = details.book.pricePaid?.toString() ?? '';
          condition = details.book.condition ?? BookCondition.newCondition;
          coverImagePath = details.book.coverImagePath;
          notes = details.book.notes ?? '';

          // Load location hierarchy
          if (details.room != null) {
            selectedRoomId = details.room!.id;
            cupboards = await _locationRepo.getCupboardsByRoom(details.room!.id);

            if (details.cupboard != null) {
              selectedCupboardId = details.cupboard!.id;
              shelves = await _locationRepo.getShelvesByCupboard(details.cupboard!.id);

              if (details.shelf != null) {
                selectedShelfId = details.shelf!.id;
              }
            }
          }
        }
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      loadError = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Field setters ─────────────────────────────────────────────────────

  void setTitle(String value) {
    title = value;
    titleError = validateTitle(value);
    notifyListeners();
    _scheduleAutoEnrich();
  }

  void setIsbn(String value) {
    isbn = value;
    isbnError = validateIsbn(value);
    notifyListeners();
  }

  void setLanguageId(String? value) {
    languageId = value;
    notifyListeners();
  }

  void setFormat(BookFormat value) {
    format = value;
    notifyListeners();
  }

  void setPublisher(String value) {
    publisher = value;
    notifyListeners();
  }

  void setEdition(String value) {
    edition = value;
    notifyListeners();
  }

  void setPublicationDate(String value) {
    publicationDate = value;
    publicationDateError = validatePublicationYear(value);
    notifyListeners();
  }

  void setPageCount(String value) {
    pageCount = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setPurchaseDate(String value) {
    purchaseDate = value;
    notifyListeners();
  }

  void setPricePaid(String value) {
    pricePaid = value;
    notifyListeners();
  }

  void setCondition(BookCondition value) {
    condition = value;
    notifyListeners();
  }

  void setCoverImagePath(String? value) {
    coverImagePath = value;
    notifyListeners();
  }

  void setNotes(String value) {
    notes = value;
    notifyListeners();
  }

  // ── Location ─────────────────────────────────────────────────────────

  Future<void> setSelectedRoom(String? roomId) async {
    selectedRoomId = roomId;
    selectedCupboardId = null;
    selectedShelfId = null;
    cupboards = [];
    shelves = [];
    notifyListeners();

    if (roomId != null) {
      cupboards = await _locationRepo.getCupboardsByRoom(roomId);
      notifyListeners();
    }
  }

  Future<void> setSelectedCupboard(String? cupboardId) async {
    selectedCupboardId = cupboardId;
    selectedShelfId = null;
    shelves = [];
    notifyListeners();

    if (cupboardId != null) {
      shelves = await _locationRepo.getShelvesByCupboard(cupboardId);
      notifyListeners();
    }
  }

  void setSelectedShelf(String? shelfId) {
    selectedShelfId = shelfId;
    notifyListeners();
  }

  // ── Authors ──────────────────────────────────────────────────────────

  void searchAuthors(String query) {
    authorSearchQuery = query;
    if (query.trim().isEmpty) {
      authorSearchResults = [];
    } else {
      authorSearchResults = existingAuthors
          .where((a) =>
              a.rawName.toLowerCase().contains(query.trim().toLowerCase()) ||
              a.normalizedName.contains(query.trim().toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void addExistingAuthor(Author author) {
    if (authorNames.contains(author.rawName)) return;
    authorNames = [...authorNames, author.rawName];
    authorSearchQuery = '';
    authorSearchResults = [];
    notifyListeners();
  }

  void addNewAuthor(String name) {
    if (name.trim().isEmpty) return;

    final normalizedName = name.trim().toLowerCase();
    final existingAuthor = existingAuthors
        .where((a) => a.normalizedName == normalizedName)
        .firstOrNull;

    if (existingAuthor != null) {
      showingAuthorDisambiguation = true;
      authorSearchQuery = name;
      notifyListeners();
      return;
    }

    _createAndAddAuthor(name.trim());
  }

  Future<void> _createAndAddAuthor(String name) async {
    final author = await _db.authorDao.createAuthor(name);
    authorNames = [...authorNames, author.rawName];
    authorSearchQuery = '';
    authorSearchResults = [];
    existingAuthors = [...existingAuthors, author];
    notifyListeners();
  }

  void removeAuthor(String name) {
    authorNames = authorNames.where((n) => n != name).toList();
    notifyListeners();
  }

  void confirmAuthorDisambiguation(bool isSamePerson, String disambiguationNote) {
    if (isSamePerson) {
      final existingAuthor = existingAuthors
          .where((a) =>
              a.normalizedName == authorSearchQuery.trim().toLowerCase())
          .firstOrNull;
      if (existingAuthor != null && !authorNames.contains(existingAuthor.rawName)) {
        authorNames = [...authorNames, existingAuthor.rawName];
      }
      showingAuthorDisambiguation = false;
      authorSearchQuery = '';
      notifyListeners();
    } else {
      final baseName = authorSearchQuery.trim();
      _db.authorDao.createAuthor(
        baseName,
        normalizedName: '${baseName.toLowerCase()}_${disambiguationNote.trim().toLowerCase()}',
      ).then((a) {
        authorNames = [...authorNames, a.rawName];
        showingAuthorDisambiguation = false;
        authorSearchQuery = '';
        existingAuthors = [...existingAuthors, a];
        notifyListeners();
      });
    }
  }

  void cancelAuthorDisambiguation() {
    showingAuthorDisambiguation = false;
    authorSearchQuery = '';
    notifyListeners();
  }

  // ── Genres ───────────────────────────────────────────────────────────

  void addGenre(String genreId) {
    if (genreIds.contains(genreId)) return;
    genreIds = [...genreIds, genreId];
    notifyListeners();
  }

  void removeGenre(String genreId) {
    genreIds = genreIds.where((id) => id != genreId).toList();
    notifyListeners();
  }

  Future<void> createAndAddGenre(String name) async {
    final existing = genres
        .where((g) => g.name.toLowerCase() == name.trim().toLowerCase())
        .firstOrNull;

    if (existing != null) {
      addGenre(existing.id);
      return;
    }

    final genre = await _genreRepo.createGenre(name.trim());
    genres = [...genres, genre];
    genreIds = [...genreIds, genre.id];
    notifyListeners();
  }

  // ── Tags ─────────────────────────────────────────────────────────────

  void addTag(String tagId) {
    if (tagIds.contains(tagId)) return;
    tagIds = [...tagIds, tagId];
    notifyListeners();
  }

  void removeTag(String tagId) {
    tagIds = tagIds.where((id) => id != tagId).toList();
    notifyListeners();
  }

  Future<void> createAndAddTag(String name) async {
    final existing = tags
        .where((t) => t.name.toLowerCase() == name.trim().toLowerCase())
        .firstOrNull;

    if (existing != null) {
      addTag(existing.id);
      return;
    }

    const uuid = Uuid();
    final tag = Tag(id: uuid.v4(), name: name.trim());
    await _tagRepo.add(tag);
    tags = [...tags, tag];
    tagIds = [...tagIds, tag.id];
    notifyListeners();
  }

  // ── Enrichment ───────────────────────────────────────────────────────

  void _scheduleAutoEnrich() {
    _autoEnrichTimer?.cancel();
    if (!isAutoEnrichEnabled) return;

    _autoEnrichTimer = Timer(const Duration(milliseconds: 1500), () {
      if (title.trim().isNotEmpty) {
        searchEnrichment(title);
      }
    });
  }

  void setAutoEnrichEnabled(bool enabled) {
    isAutoEnrichEnabled = enabled;
    notifyListeners();
  }

  Future<void> searchEnrichment(String query, {String? author}) async {
    isEnriching = true;
    enrichmentError = null;
    enrichmentResults = [];
    selectedEnrichmentIndex = null;
    notifyListeners();

    try {
      final results = await _googleBooks.searchByTitleAuthor(query, author: author);
      isEnriching = false;
      enrichmentResults = results;
      isQuotaExceeded = false;
      notifyListeners();
    } on QuotaExceededException {
      isEnriching = false;
      isQuotaExceeded = true;
      enrichmentError = 'Google Books daily limit reached. Try again tomorrow.';
      notifyListeners();
    } on OfflineException {
      isEnriching = false;
      enrichmentError = 'No internet connection';
      notifyListeners();
    } catch (e) {
      isEnriching = false;
      enrichmentError = e.toString();
      notifyListeners();
    }
  }

  void selectEnrichmentResult(int index) {
    selectedEnrichmentIndex = index;
    notifyListeners();
  }

  void applyEnrichment() {
    final index = selectedEnrichmentIndex;
    if (index == null || index >= enrichmentResults.length) return;

    final result = enrichmentResults[index];

    if (result.title.isNotEmpty) {
      title = result.title;
      enrichedSections['basic'] = true;
    }
    if (result.isbn != null && result.isbn!.isNotEmpty) {
      isbn = result.isbn!;
    }
    if (result.publisher != null && result.publisher!.isNotEmpty) {
      publisher = result.publisher!;
      enrichedSections['details'] = true;
    }
    if (result.description != null && result.description!.isNotEmpty) {
      description = result.description!;
    }
    if (result.pageCount != null) {
      pageCount = result.pageCount.toString();
    }
    if (result.publicationDate != null && result.publicationDate!.isNotEmpty) {
      publicationDate = result.publicationDate!.substring(0, 4);
    }
    if (result.authors.isNotEmpty) {
      authorNames = result.authors;
      enrichedSections['authors'] = true;
    }

    notifyListeners();
  }

  void closeEnrichment() {
    enrichmentResults = [];
    isEnriching = false;
    enrichmentError = null;
    selectedEnrichmentIndex = null;
    notifyListeners();
  }

  // ── Save ─────────────────────────────────────────────────────────────

  Future<void> saveBook() async {
    titleError = validateTitle(title);
    isbnError = validateIsbn(isbn);
    publicationDateError = validatePublicationYear(publicationDate);
    notifyListeners();

    if (titleError != null || isbnError != null || publicationDateError != null) {
      return;
    }

    if (mode == BookFormMode.add) {
      final isbn13 = isbn.isNotEmpty ? toIsbn13(isbn) : null;
      final detector = DuplicateDetector(_db);

      final duplicate = await detector.check(
        isbn: isbn13,
        title: title,
        authorNames: authorNames,
      );

      if (duplicate != null) {
        final existingBook = await _bookRepo.readById(duplicate.bookId);
        if (existingBook != null && existingBook.isDeleted) {
          duplicateResult = duplicate;
          showingDuplicateDialog = true;
          notifyListeners();
          return;
        }

        duplicateResult = duplicate;
        showingDuplicateDialog = true;
        notifyListeners();
        return;
      }
    }

    await _performSave();
  }

  Future<void> saveAnyway() async {
    showingDuplicateDialog = false;
    notifyListeners();
    await _performSave();
  }

  Future<void> restoreDeletedBook() async {
    final duplicate = duplicateResult;
    if (duplicate != null) {
      await _bookRepo.restore(duplicate.bookId);
    }
    showingDuplicateDialog = false;
    notifyListeners();
  }

  Future<void> _performSave() async {
    isSaving = true;
    saveError = null;
    notifyListeners();

    try {
      const uuid = Uuid();

      if (mode == BookFormMode.edit && editBookId != null) {
        await _db.bookDao.updateBookWithRelations(
          bookId: editBookId!,
          title: title.trim(),
          isbn: isbn.isNotEmpty ? isbn : null,
          languageId: languageId,
          format: format,
          condition: condition,
          authorIds: await _resolveAuthorIds(authorNames),
          genreIds: genreIds,
          tagIds: tagIds,
          shelfId: selectedShelfId,
          deviceUser: 'device_user',
        );

        await (_db.update(_db.books)..where((b) => b.id.equals(editBookId!))).write(
          BooksCompanion(
            publisher: Value(publisher.isEmpty ? null : publisher),
            edition: Value(edition.isEmpty ? null : edition),
            publicationDate: Value(publicationDate.isEmpty ? null : publicationDate),
            pageCount: Value(pageCount.isEmpty ? null : int.tryParse(pageCount)),
            description: Value(description.isEmpty ? null : description),
            pricePaid: Value(pricePaid.isEmpty ? null : double.tryParse(pricePaid)),
            purchaseDate: Value(purchaseDate.isEmpty ? null : purchaseDate),
            coverImagePath: Value(coverImagePath),
            notes: Value(notes.isEmpty ? null : notes),
          ),
        );
      } else {
        final bookId = uuid.v4();
        final authorIds = await _resolveAuthorIds(authorNames);

        await _db.bookDao.insertBookWithRelations(
          id: bookId,
          title: title.trim(),
          isbn: isbn.isNotEmpty ? isbn : null,
          languageId: languageId,
          coverImagePath: coverImagePath,
          publisher: publisher.isEmpty ? null : publisher,
          edition: edition.isEmpty ? null : edition,
          publicationDate: publicationDate.isEmpty ? null : publicationDate,
          format: format,
          pageCount: pageCount.isEmpty ? null : int.tryParse(pageCount),
          description: description.isEmpty ? null : description,
          condition: condition,
          pricePaid: pricePaid.isEmpty ? null : double.tryParse(pricePaid),
          purchaseDate: purchaseDate.isEmpty ? null : purchaseDate,
          notes: notes.isEmpty ? null : notes,
          authorIds: authorIds,
          genreIds: genreIds,
          tagIds: tagIds,
          shelfId: selectedShelfId,
          deviceUser: 'device_user',
        );
      }

      isSaving = false;
      notifyListeners();
    } catch (e) {
      isSaving = false;
      saveError = e.toString();
      notifyListeners();
    }
  }

  Future<List<String>> _resolveAuthorIds(List<String> names) async {
    final ids = <String>[];
    for (final name in names) {
      final normalized = name.trim().toLowerCase();
      final existing = existingAuthors
          .where((a) => a.normalizedName == normalized)
          .firstOrNull;
      if (existing != null) {
        ids.add(existing.id);
      } else {
        final author = await _db.authorDao.createAuthor(name.trim());
        ids.add(author.id);
      }
    }
    return ids;
  }

  void cancelSave() {
    showingDuplicateDialog = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoEnrichTimer?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for the Add/Edit Book form.
/// Creates and disposes the notifier automatically.
/// Uses ChangeNotifierProvider so that notifyListeners() triggers UI rebuilds.
final addBookFormProvider =
    ChangeNotifierProvider.family<BookFormNotifier, BookFormParams>(
  (ref, params) {
    final notifier = BookFormNotifier(ref: ref, params: params);
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);
