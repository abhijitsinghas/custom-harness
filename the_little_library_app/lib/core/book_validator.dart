/// Validation utilities for the Add/Edit Book form.
/// US-101, US-102, US-103, US-100, US-99
library;

import 'isbn_utils.dart';

/// Validates a book title.
///
/// Returns an error message string if invalid, or null if valid.
/// - Empty or whitespace-only titles are rejected.
String? validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Title is required';
  }
  return null;
}

/// Validates an ISBN input.
///
/// Returns an error message string if invalid, or null if valid.
/// - Empty/null ISBN is allowed (ISBN is optional).
/// - Must be 10 or 13 digits (after stripping hyphens/spaces).
/// - ISBN-10 with X checksum is accepted.
String? validateIsbn(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // ISBN is optional
  }

  final normalized = normalizeIsbn(value);
  if (normalized == null) {
    return 'Enter a valid 10 or 13 digit ISBN';
  }

  if (!isIsbn10(normalized) && !isIsbn13(normalized)) {
    return 'Enter a valid 10 or 13 digit ISBN';
  }

  return null;
}

/// Validates a publication year string.
///
/// Returns an error message string if invalid, or null if valid.
/// - Empty/null is allowed (publication date is optional).
/// - Accepts year-only format (YYYY) or full date (YYYY-MM-DD).
/// - Year must be between 1000 and the current year (inclusive).
String? validatePublicationYear(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Optional field
  }

  final trimmed = value.trim();
  int year;

  // Try parsing as year-only (4 digits)
  if (RegExp(r'^\d{4}$').hasMatch(trimmed)) {
    year = int.parse(trimmed);
  } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
    // Full date format — extract the year
    year = int.parse(trimmed.substring(0, 4));
  } else {
    return 'Enter a valid year (e.g., 1988) or date (YYYY-MM-DD)';
  }

  final currentYear = DateTime.now().year;
  if (year < 1000) {
    return 'Publication year must be between 1000 and $currentYear';
  }
  if (year > currentYear) {
    return 'Publication year must be between 1000 and $currentYear';
  }

  return null;
}

/// Normalizes and converts an ISBN input to ISBN-13 format.
///
/// Returns null if input is empty/null.
/// Throws FormatException if input is an invalid ISBN.
String? convertAndNormalizeIsbn(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return toIsbn13(value);
}

/// Validates a page count input.
///
/// Returns an error message string if invalid, or null if valid.
/// - Empty/null is allowed.
/// - Must be a positive integer.
String? validatePageCount(String? value) {
  if (value == null || value.trim().isEmpty) return null;

  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < 0) {
    return 'Enter a valid number of pages';
  }
  return null;
}

/// Validates a price input.
///
/// Returns an error message string if invalid, or null if valid.
/// - Empty/null is allowed.
/// - Must be a non-negative number.
String? validatePrice(String? value) {
  if (value == null || value.trim().isEmpty) return null;

  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed < 0) {
    return 'Enter a valid price';
  }
  return null;
}
