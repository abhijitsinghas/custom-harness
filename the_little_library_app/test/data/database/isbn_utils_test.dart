import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/core/isbn_utils.dart';

/// Tests for ISBN normalization and conversion utilities — covers US-1.1.17.

void main() {
  group('US-1.1.17 — ISBN conversion', () {
    test('should convert known ISBN-10 0062315005 → 9780062315007', () {
      final result = convertIsbn10to13('0062315005');
      expect(result, '9780062315007');
    });

    test('should return unmodified ISBN-13 when already 13 digits', () {
      final result = toIsbn13('9780062315007');
      expect(result, '9780062315007');
    });

    test('should strip hyphens and spaces before conversion', () {
      final result = toIsbn13('0-0623-1500-5');
      expect(result, '9780062315007');
    });

    test('should validate ISBN-10 checksum before conversion', () {
      // Invalid checksum should throw
      expect(
        () => convertIsbn10to13('0062315000'),
        throwsFormatException,
      );
    });

    test('should compute correct ISBN-13 checksum digit', () {
      final digit = computeIsbn13CheckDigit('978006231500');
      expect(digit, 7);
    });

    test('should handle ISBN-10 ending in X (10 as checksum)', () {
      // 080442957X is a valid ISBN-10 with X checksum
      // Converting to ISBN-13: 978 prefix + first 9 digits + new checksum
      final result = toIsbn13('080442957X');
      expect(result, '9780804429573');
    });

    test('should normalize ISBN by stripping all non-digit characters except X',
        () {
      final result = normalizeIsbn('978-0-545-01022-1');
      expect(result, '9780545010221');
    });

    test('should return null for invalid-length input', () {
      // Invalid length (not 10 or 13 after stripping)
      final result = toIsbn13('12345');
      expect(result, isNull);
    });

    test('should detect ISBN-10 vs ISBN-13 format correctly', () {
      expect(isIsbn10('0062315005'), isTrue);
      expect(isIsbn10('9780062315007'), isFalse);
      expect(isIsbn13('9780062315007'), isTrue);
      expect(isIsbn13('0062315005'), isFalse);
    });
  });
}
