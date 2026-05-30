/// ISBN normalization, validation, and conversion utilities.
///
/// Supports ISBN-10 and ISBN-13 formats, stripping hyphens/spaces,
/// validating checksums, and converting ISBN-10 to ISBN-13.
library;

/// Normalizes an ISBN string by stripping all non-digit characters,
/// except uppercase 'X' which may appear as the checksum digit in ISBN-10.
///
/// Returns the raw digit string (or null if input is null/empty).
String? normalizeIsbn(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  // Keep only digits and uppercase X (for ISBN-10 checksum)
  final normalized =
      raw.toUpperCase().replaceAll(RegExp(r'[^0-9X]'), '');
  if (normalized.isEmpty) return null;
  return normalized;
}

/// Returns true if [normalized] is 10 characters and contains only digits
/// (allowing 'X' as the final character for checksum).
bool isIsbn10(String normalized) {
  if (normalized.length != 10) return false;
  // First 9 must be digits; last can be digit or X
  if (!RegExp(r'^\d{9}[\dX]$').hasMatch(normalized)) return false;
  return true;
}

/// Returns true if [normalized] is exactly 13 digits.
bool isIsbn13(String normalized) {
  if (normalized.length != 13) return false;
  return RegExp(r'^\d{13}$').hasMatch(normalized);
}

/// Validates the checksum of an ISBN-10 string.
///
/// Returns true if the weighted sum modulo 11 matches the check digit.
bool validateIsbn10Checksum(String isbn10) {
  assert(isbn10.length == 10, 'ISBN-10 must be 10 characters');
  var sum = 0;
  for (var i = 0; i < 10; i++) {
    final ch = isbn10[i];
    final digit = ch == 'X' ? 10 : int.parse(ch);
    sum += digit * (10 - i);
  }
  return sum % 11 == 0;
}

/// Validates the checksum of an ISBN-13 string.
///
/// Returns true if the weighted alternating sum modulo 10 is correct.
bool validateIsbn13Checksum(String isbn13) {
  assert(isbn13.length == 13, 'ISBN-13 must be 13 characters');
  var sum = 0;
  for (var i = 0; i < 13; i++) {
    final digit = int.parse(isbn13[i]);
    sum += digit * (i % 2 == 0 ? 1 : 3);
  }
  return sum % 10 == 0;
}

/// Computes the ISBN-13 check digit for a 12-digit prefix.
///
/// The check digit is `(10 - (sum % 10)) % 10`.
int computeIsbn13CheckDigit(String prefix12) {
  assert(prefix12.length == 12, 'Prefix must be 12 digits');
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    final digit = int.parse(prefix12[i]);
    sum += digit * (i % 2 == 0 ? 1 : 3);
  }
  return (10 - (sum % 10)) % 10;
}

/// Converts a normalized ISBN-10 to ISBN-13.
///
/// The algorithm:
/// 1. Takes the first 9 digits of the ISBN-10
/// 2. Prepends "978" (the Bookland EAN prefix)
/// 3. Computes the new ISBN-13 checksum digit
///
/// Returns null if the input is not a valid ISBN-10.
/// Throws [FormatException] if the ISBN-10 checksum is invalid.
String? convertIsbn10to13(String isbn10) {
  if (!isIsbn10(isbn10)) return null;

  if (!validateIsbn10Checksum(isbn10)) {
    throw const FormatException('Invalid ISBN-10 checksum');
  }

  final prefix9 = isbn10.substring(0, 9);
  final prefix12 = '978$prefix9';
  final checkDigit = computeIsbn13CheckDigit(prefix12);
  return '$prefix12$checkDigit';
}

/// Converts any ISBN to its ISBN-13 form.
///
/// - If the input is already a 13-digit ISBN, returns it as-is.
/// - If it's a 10-digit ISBN, converts it to ISBN-13.
/// - Non-digit characters are stripped before processing.
/// - Returns null for invalid/unrecognizable input.
String? toIsbn13(String? raw) {
  final normalized = normalizeIsbn(raw);
  if (normalized == null) return null;

  if (isIsbn13(normalized)) return normalized;
  if (isIsbn10(normalized)) {
    try {
      return convertIsbn10to13(normalized);
    } catch (_) {
      return null;
    }
  }
  return null; // Invalid length
}

/// Detects whether a normalized string is ISBN-10 (true), ISBN-13 (false),
/// or unrecognized (null).
bool? detectIsbnFormat(String normalized) {
  if (isIsbn10(normalized)) return true; // ISBN-10
  if (isIsbn13(normalized)) return false; // ISBN-13
  return null; // Unknown
}
