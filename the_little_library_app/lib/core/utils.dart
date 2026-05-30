/// Utility functions including Levenshtein distance for fuzzy
/// duplicate detection. US-0.1.7, US-0.1.14.
library;

/// Computes the Levenshtein distance between two strings.
/// Uses an optimized single-row algorithm with O(n) space.
int levenshteinDistance(String a, String b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  // Use runes for proper Unicode support.
  final aRunes = a.runes.toList();
  final bRunes = b.runes.toList();

  // Ensure a is the shorter string for space efficiency.
  if (aRunes.length > bRunes.length) {
    return _levenshtein(bRunes, aRunes);
  }
  return _levenshtein(aRunes, bRunes);
}

int _levenshtein(List<int> shorter, List<int> longer) {
  final n = shorter.length;
  final m = longer.length;

  // Previous row.
  var prev = List<int>.generate(n + 1, (i) => i);
  // Current row.
  var curr = List<int>.filled(n + 1, 0);

  for (var j = 1; j <= m; j++) {
    curr[0] = j;
    for (var i = 1; i <= n; i++) {
      final cost = shorter[i - 1] == longer[j - 1] ? 0 : 1;
      curr[i] = _min3(
        prev[i] + 1, // deletion
        curr[i - 1] + 1, // insertion
        prev[i - 1] + cost, // substitution
      );
    }
    // Swap rows.
    final temp = prev;
    prev = curr;
    curr = temp;
  }

  return prev[n];
}

int _min3(int a, int b, int c) {
  if (a <= b && a <= c) return a;
  if (b <= a && b <= c) return b;
  return c;
}

/// Returns the similarity ratio between two strings as a percentage (0–100).
/// Calculated as `(1 - distance / maxLength) * 100`.
double similarityRatio(String a, String b) {
  final distance = levenshteinDistance(a, b);
  final maxLen = a.length > b.length ? a.length : b.length;
  if (maxLen == 0) return 100.0;
  return (1 - distance / maxLen) * 100;
}
