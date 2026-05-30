/// Enums and predefined constants used throughout the app.
/// US-0.1.5, US-0.2.23
library;

/// Physical format of a book.
enum BookFormat {
  hardcover,
  paperback,
  other,
}

/// Physical condition assessment of a book.
enum BookCondition {
  newCondition,
  likeNew,
  used,
  worn,
  damaged,
}

/// Availability status of a book in the library.
enum BookStatus {
  available,
  checkedOut,
  loaned,
}

/// Type of change recorded in the change log.
enum EventType {
  create,
  update,
  delete,
}

/// Domain entity type for change log tracking.
enum EntityType {
  book,
  location,
  genre,
  tag,
  author,
  loan,
  language,
}

/// 20 predefined genres seeded on first launch (US-0.1.5).
const List<String> kPredefinedGenres = [
  'Fiction',
  'Non-Fiction',
  'Science',
  'Technology',
  'History',
  'Biography & Memoir',
  'Poetry',
  'Religion & Spirituality',
  'Philosophy',
  'Self-Help',
  'Business & Economics',
  'Art & Photography',
  'Cooking',
  'Travel',
  'Health & Wellness',
  'Comics & Graphic Novels',
  "Children's",
  'Young Adult',
  'Reference',
  'Textbooks',
];

/// 3 built-in languages seeded on first launch (US-0.1.5).
const List<Map<String, String>> kBuiltinLanguages = [
  {'name': 'English', 'isoCode': 'en'},
  {'name': 'Hindi', 'isoCode': 'hi'},
  {'name': 'Sanskrit', 'isoCode': 'sa'},
];

/// Human-readable display names for enum values (US-0.2.23).
const Map<BookFormat, String> kBookFormatDisplayNames = {
  BookFormat.hardcover: 'Hardcover',
  BookFormat.paperback: 'Paperback',
  BookFormat.other: 'Other',
};

const Map<BookCondition, String> kBookConditionDisplayNames = {
  BookCondition.newCondition: 'New',
  BookCondition.likeNew: 'Like New',
  BookCondition.used: 'Used',
  BookCondition.worn: 'Worn',
  BookCondition.damaged: 'Damaged',
};

const Map<BookStatus, String> kBookStatusDisplayNames = {
  BookStatus.available: 'Available',
  BookStatus.checkedOut: 'Checked Out',
  BookStatus.loaned: 'Loaned',
};

const Map<EventType, String> kEventTypeDisplayNames = {
  EventType.create: 'Created',
  EventType.update: 'Updated',
  EventType.delete: 'Deleted',
};

const Map<EntityType, String> kEntityTypeDisplayNames = {
  EntityType.book: 'Book',
  EntityType.location: 'Location',
  EntityType.genre: 'Genre',
  EntityType.tag: 'Tag',
  EntityType.author: 'Author',
  EntityType.loan: 'Loan',
  EntityType.language: 'Language',
};
