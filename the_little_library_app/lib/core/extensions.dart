/// Extension utilities for ISBN conversion, date formatting, and
/// string normalization. US-0.1.6, US-0.1.13, US-0.1.15.
library;

import 'package:intl/intl.dart';

/// ISBN-10 ↔ ISBN-13 conversion and validation.
extension IsbnExtension on String {
  /// Converts an ISBN-10 to ISBN-13, or returns the input unchanged if
  /// it is already a valid ISBN-13. Returns `null` for invalid input.
  String? toIsbn13() {
    final cleaned = _cleanIsbn(this);
    if (cleaned == null) return null;

    if (cleaned.length == 13) {
      return _formatIsbn13(cleaned);
    }
    if (cleaned.length == 10) {
      return _convertIsbn10to13(cleaned);
    }
    return null;
  }

  /// Strips hyphens, spaces, and whitespace; returns null if the result
  /// is not numeric or has wrong length.
  static String? _cleanIsbn(String raw) {
    final digits = raw.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return null;
    if (!RegExp(r'^\d{9}[\dXx]$').hasMatch(digits) &&
        !RegExp(r'^\d{13}$').hasMatch(digits)) {
      return null;
    }
    return digits.toUpperCase();
  }

  /// Converts a 10-digit cleaned ISBN to the 13-digit format.
  static String? _convertIsbn10to13(String isbn10) {
    final prefix = '978$isbn10'; // 13 digits without check
    final withoutCheck = prefix.substring(0, 12);
    final checkDigit = _calculateIsbn13CheckDigit(withoutCheck);
    return _formatIsbn13('$withoutCheck$checkDigit');
  }

  /// Computes the ISBN-13 check digit.
  static int _calculateIsbn13CheckDigit(String digits12) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(digits12[i]);
      sum += digit * (i.isEven ? 1 : 3);
    }
    final mod = sum % 10;
    return mod == 0 ? 0 : 10 - mod;
  }

  /// Formats a 13-digit string with hyphens.
  static String _formatIsbn13(String digits) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 4)}-${digits.substring(4, 7)}-${digits.substring(7, 12)}-${digits.substring(12)}';
  }
}

/// String normalization for author deduplication.
/// Lowercases and strips spaces and punctuation.
extension StringNormalization on String {
  /// Returns a normalized version: lowercased with spaces and punctuation removed.
  String normalize() {
    return toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

/// Date formatting helpers (US-0.1.6, US-0.1.15).
extension DateFormatting on DateTime? {
  /// Formats to a localized date string. Returns '—' for null.
  String formatDate({String locale = 'en_US', String pattern = 'MMM d, yyyy'}) {
    final date = this;
    if (date == null) return '—';
    try {
      return DateFormat(pattern, locale).format(date);
    } on Exception {
      return '—';
    }
  }
}
