/// DTO for a single result from the Google Books API.
///
/// Contains all the enrichment fields that may be displayed in the
/// Add Book form (US-1.2.1, US-1.2.3, US-1.2.11).
library;

/// Data transfer object representing a book's enrichment metadata
/// as returned by the Google Books API.
class BookEnrichment {
  const BookEnrichment({
    required this.title,
    this.authors = const [],
    this.isbn,
    this.publisher,
    this.description,
    this.pageCount,
    this.coverUrl,
    this.publicationDate,
    this.subtitle,
    this.categories = const [],
    this.googleBooksId,
  });

  /// The book's title. Never null.
  final String title;

  /// The list of authors. Empty list if none provided by the API.
  final List<String> authors;

  /// The ISBN-13 or ISBN-10 from the volume's industry identifiers.
  final String? isbn;

  /// The publisher name.
  final String? publisher;

  /// A synopsis or description of the book.
  final String? description;

  /// Total page count.
  final int? pageCount;

  /// URL to the cover image thumbnail (as provided by the API).
  final String? coverUrl;

  /// Publication date as returned by the API (e.g. "2020-05-15").
  final String? publicationDate;

  /// The subtitle of the book, if any.
  final String? subtitle;

  /// List of categories/genres from Google Books.
  final List<String> categories;

  /// The Google Books volume ID.
  final String? googleBooksId;

  // ── Serialization ──────────────────────────────────────────────────────────

  /// Creates a [BookEnrichment] from a JSON map (API response).
  factory BookEnrichment.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};

    // Extract authors, defaulting to empty list.
    List<String> extractAuthors() {
      final authorsRaw = volumeInfo['authors'];
      if (authorsRaw is List) {
        return List<String>.from(authorsRaw.map((e) => e.toString()));
      }
      return [];
    }

    // Extract ISBN from industry identifiers.
    String? extractIsbn() {
      final ids = volumeInfo['industryIdentifiers'];
      if (ids is List) {
        for (final id in ids) {
          if (id is Map) {
            final type = id['type'] as String? ?? '';
            final identifier = id['identifier'] as String?;
            if (type == 'ISBN_13' && identifier != null) {
              return identifier;
            }
          }
        }
        // Fallback: return first ISBN (could be ISBN_10).
        for (final id in ids) {
          if (id is Map) {
            final identifier = id['identifier'] as String?;
            if (identifier != null) {
              return identifier;
            }
          }
        }
      }
      return null;
    }

    // Extract cover URL.
    String? extractCoverUrl() {
      final imageLinks = volumeInfo['imageLinks'];
      if (imageLinks is Map) {
        return (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'])
            as String?;
      }
      return null;
    }

    // Extract categories.
    List<String> extractCategories() {
      final cats = volumeInfo['categories'];
      if (cats is List) {
        return List<String>.from(cats.map((e) => e.toString()));
      }
      return [];
    }

    return BookEnrichment(
      title: volumeInfo['title'] as String? ?? '',
      authors: extractAuthors(),
      isbn: extractIsbn(),
      publisher: volumeInfo['publisher'] as String?,
      description: volumeInfo['description'] as String?,
      pageCount: volumeInfo['pageCount'] as int?,
      coverUrl: extractCoverUrl(),
      publicationDate: volumeInfo['publishedDate'] as String?,
      subtitle: volumeInfo['subtitle'] as String?,
      categories: extractCategories(),
      googleBooksId: json['id'] as String?,
    );
  }

  /// Serializes this [BookEnrichment] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authors': authors,
      'isbn': isbn,
      'publisher': publisher,
      'description': description,
      'pageCount': pageCount,
      'coverUrl': coverUrl,
      'publicationDate': publicationDate,
      'subtitle': subtitle,
      'categories': categories,
      'googleBooksId': googleBooksId,
    };
  }

  /// Creates a copy with the given fields replaced.
  BookEnrichment copyWith({
    String? title,
    List<String>? authors,
    String? isbn,
    String? publisher,
    String? description,
    int? pageCount,
    String? coverUrl,
    String? publicationDate,
    String? subtitle,
    List<String>? categories,
    String? googleBooksId,
  }) {
    return BookEnrichment(
      title: title ?? this.title,
      authors: authors ?? this.authors,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      pageCount: pageCount ?? this.pageCount,
      coverUrl: coverUrl ?? this.coverUrl,
      publicationDate: publicationDate ?? this.publicationDate,
      subtitle: subtitle ?? this.subtitle,
      categories: categories ?? this.categories,
      googleBooksId: googleBooksId ?? this.googleBooksId,
    );
  }

  @override
  String toString() =>
      'BookEnrichment(title: $title, authors: $authors, isbn: $isbn)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookEnrichment &&
          title == other.title &&
          _listEquals(authors, other.authors) &&
          isbn == other.isbn &&
          publisher == other.publisher &&
          description == other.description &&
          pageCount == other.pageCount &&
          coverUrl == other.coverUrl &&
          publicationDate == other.publicationDate &&
          subtitle == other.subtitle &&
          _listEquals(categories, other.categories) &&
          googleBooksId == other.googleBooksId;

  @override
  int get hashCode => Object.hash(
        title,
        Object.hashAll(authors),
        isbn,
        publisher,
        description,
        pageCount,
        coverUrl,
        publicationDate,
        subtitle,
        Object.hashAll(categories),
        googleBooksId,
      );
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
