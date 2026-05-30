import 'package:intl/intl.dart';

// ── String ───────────────────────────────────────────────────────────────────

/// Convenience extensions on [String].
extension StringHelpers on String {
  /// Returns `true` when the trimmed string is empty.
  bool get isBlank => trim().isEmpty;

  /// Returns `true` when the trimmed string is **not** empty.
  bool get isNotBlank => !isBlank;

  /// Capitalises the first character of this string.
  String get capitalised =>
      isBlank ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Title-cases every word in this string.
  String get titleCase =>
      split(RegExp(r'\s+')).map((w) => w.capitalised).join(' ');

  /// Strips common ISBN prefix/suffix noise (e.g. "ISBN-13:", spaces, dashes).
  String get normalisedIsbn =>
      replaceAll(RegExp(r'[^\dX]'), '').toUpperCase();
}

// ── DateTime ─────────────────────────────────────────────────────────────────

/// Human-readable formatting helpers for [DateTime].
extension DateTimeFormatting on DateTime {
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat _full = DateFormat('d MMM yyyy, h:mm a');
  static final DateFormat _relativeToday = DateFormat("'Today at' h:mm a");
  static final DateFormat _relativeYesterday =
      DateFormat("'Yesterday at' h:mm a");

  /// Formats as "12 Jan 2026".
  String get dayMonthYear => _dayMonthYear.format(this);

  /// Formats as "12 Jan 2026, 3:45 PM".
  String get full => _full.format(this);

  /// Relative formatting for recent dates, e.g. "Today at 3:45 PM".
  String get friendly {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(year, month, day);

    if (dateOnly == today) return _relativeToday.format(this);
    if (dateOnly == today.subtract(const Duration(days: 1))) {
      return _relativeYesterday.format(this);
    }
    return dayMonthYear;
  }
}

// ── ISBN ─────────────────────────────────────────────────────────────────────

/// ISBN utility extensions.
///
/// Full ISBN-10 → ISBN-13 conversion lives in `lib/core/utils/isbn_utils.dart`
/// (W03). Here we expose lightweight normalisation helpers.
abstract final class IsbnNormalizer {
  IsbnNormalizer._();

  /// Removes hyphens, spaces, and ISBN prefix labels, returning a pure digit
  /// string (or digit + 'X' for ISBN-10 checksum).
  static String normalise(String raw) => raw.normalisedIsbn;

  /// Returns `true` when [raw] normalises to exactly 10 characters (ISBN-10).
  static bool isIsbn10(String raw) => normalise(raw).length == 10;

  /// Returns `true` when [raw] normalises to exactly 13 characters (ISBN-13).
  static bool isIsbn13(String raw) => normalise(raw).length == 13;
}
