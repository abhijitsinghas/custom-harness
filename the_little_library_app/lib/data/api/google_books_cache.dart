import 'package:drift/drift.dart';

/// Cache table for Google Books API responses (US-1.2.4, US-1.2.5, US-1.2.9).
///
/// Each row stores a serialized list of [BookEnrichment] results keyed by
/// the query hash (ISBN or normalized title+author). Entries expire after
/// 7 days.
class GoogleBooksCache extends Table {
  @override
  String get tableName => 'google_books_cache';

  /// SHA-256 hash of the lookup parameters (e.g. ISBN or title+author).
  TextColumn get cacheKey => text().withLength(min: 1)();

  /// The type of query: 'isbn' or 'titleAuthor'.
  TextColumn get queryType => text().withLength(min: 1)();

  /// The raw query value (ISBN string or normalized title+author).
  TextColumn get queryValue => text().withLength(min: 1)();

  /// JSON-serialized list of [BookEnrichment] results.
  TextColumn get resultsJson => text().withLength(min: 1)();

  /// ISO 8601 timestamp of when this cache entry was created.
  TextColumn get createdAt =>
      text().clientDefault(() => DateTime.now().toIso8601String())();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

/// Simple DAO for [GoogleBooksCache] operations using raw SQL.
///
/// Uses raw queries to avoid depending on drift code generation
/// (which may not be available if other workstreams have compilation
/// errors). The table definition above registers the schema with drift;
/// at runtime drift generates the table from the definition automatically.
class GoogleBooksCacheDao {
  GoogleBooksCacheDao(this._db);

  final GeneratedDatabase _db;

  /// Returns the cached results JSON for [cacheKey] if not expired,
  /// otherwise returns null and deletes the stale row.
  Future<String?> getIfNotExpired(String cacheKey) async {
    final cutoff =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    // Query for cache entry that is not expired.
    final rows = await _db.customSelect(
      'SELECT results_json FROM google_books_cache '
      'WHERE cache_key = ? AND created_at > ?',
      variables: [Variable.withString(cacheKey), Variable.withString(cutoff)],
    ).get();

    if (rows.isEmpty) {
      // Clean up stale rows (older than 7 days, including the queried key).
      await _db.customStatement(
        'DELETE FROM google_books_cache WHERE cache_key = ?',
        [cacheKey],
      );
      await _db.customStatement(
        'DELETE FROM google_books_cache WHERE created_at <= ?',
        [cutoff],
      );
      return null;
    }

    return rows.first.read<String>('results_json');
  }

  /// Inserts or replaces a cache entry.
  Future<void> upsert({
    required String cacheKey,
    required String queryType,
    required String queryValue,
    required String resultsJson,
  }) async {
    final now = DateTime.now().toIso8601String();

    await _db.customStatement(
      'INSERT OR REPLACE INTO google_books_cache '
      '(cache_key, query_type, query_value, results_json, created_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [cacheKey, queryType, queryValue, resultsJson, now],
    );
  }

  /// Checks whether a cache entry exists and is valid (not expired).
  Future<bool> hasValidEntry(String cacheKey) async {
    final result = await getIfNotExpired(cacheKey);
    return result != null;
  }

  /// Removes all cache entries (for tests/cleanup).
  Future<void> clearAll() async {
    await _db.customStatement('DELETE FROM google_books_cache', []);
  }
}
