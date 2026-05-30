// ── Enums ────────────────────────────────────────────────────────────────────

/// Status of a book within the library.
enum BookStatus {
  /// Book is on its assigned shelf and available.
  available,

  /// Book is checked out to a family member (internal).
  checkedOut,

  /// Book is loaned to an external person.
  loaned,
}

/// Physical or digital format of a book.
enum BookFormat {
  hardcover,
  paperback,
  ebook,
  audiobook,
}

/// Subjective condition rating for a book copy.
enum BookCondition {
  new_,
  likeNew,
  veryGood,
  good,
  fair,
  poor,
}

// ── Spacing ──────────────────────────────────────────────────────────────────

/// Semantic spacing scale used throughout the UI.
abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Minimum touch-target size (WCAG AA).
  static const double tappableMin = 48;
}

// ── Responsive breakpoints ───────────────────────────────────────────────────

abstract final class Breakpoints {
  Breakpoints._();

  /// Width at which the layout switches from compact to expanded.
  static const double largeScreenMin = 600;
}

// ── Seed data ────────────────────────────────────────────────────────────────

/// Twenty predefined genres seeded into every new library.
const List<String> predefinedGenres = [
  'Fiction',
  'Non-Fiction',
  'Mystery',
  'Science Fiction',
  'Fantasy',
  'Romance',
  'Thriller',
  'Horror',
  'Biography',
  'History',
  'Science',
  'Philosophy',
  'Poetry',
  'Drama',
  'Children',
  'Young Adult',
  'Graphic Novel',
  'Self-Help',
  'Travel',
  'Cookbook',
];

/// Three built-in languages seeded on first launch.
const List<String> predefinedLanguages = [
  'English',
  'Hindi',
  'Marathi',
];
