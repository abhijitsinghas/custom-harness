import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/exceptions.dart';
import 'book_enrichment.dart';
import 'google_books_cache.dart';

/// Default Google Books API key (fallback when no custom key is configured).
const String _defaultApiKey = 'AIzaSyDEFAULT_KEY_PLACEHOLDER';

/// SharedPreferences keys for quota tracking and custom API key.
const String _kPrefQuotaCount = 'google_books_quota_count';
const String _kPrefQuotaDate = 'google_books_quota_date';
const String _kPrefCustomApiKey = 'google_books_custom_api_key';
const String _kPrefQuotaExceeded = 'google_books_quota_exceeded';

/// Google Books API base URL.
const String _kBaseUrl = 'https://www.googleapis.com/books/v1/volumes';

/// Maximum results per search (US-1.2.2).
const int _kMaxResults = 5;

/// HTTP request timeout duration (US-1.2.8).
const Duration _kTimeout = Duration(seconds: 10);

// ── Exceptions ──────────────────────────────────────────────────────────────

/// [OfflineException] is now defined in core/exceptions.dart.

/// Thrown when the daily Google Books API quota is exceeded (US-1.2.13).
class QuotaExceededException implements Exception {
  QuotaExceededException([this.message = 'Daily API quota exceeded']);
  final String message;

  @override
  String toString() => 'QuotaExceededException: $message';
}

// ── Client ──────────────────────────────────────────────────────────────────

/// Client for the Google Books API with caching, quota tracking, and
/// timeout handling.
///
/// US-1.2.1 through US-1.2.17.
class GoogleBooksClient {
  GoogleBooksClient({
    required http.Client httpClient,
    required GoogleBooksCacheDao cache,
    SharedPreferences? prefs,
    String? customApiKey,
  })  : _httpClient = httpClient,
        _cache = cache,
        _prefs = prefs {
    _customApiKey = customApiKey;
    _quotaExceeded = _prefs?.getBool(_kPrefQuotaExceeded) ?? false;
  }

  final http.Client _httpClient;
  final GoogleBooksCacheDao _cache;
  final SharedPreferences? _prefs;

  String? _customApiKey;
  bool _quotaExceeded = false;
  bool _isLoading = false;

  // ── Public state ──────────────────────────────────────────────────────────

  /// Whether the daily API quota is exceeded.
  bool get isQuotaExceeded => _quotaExceeded;

  /// Controller for quota exceeded stream.
  final StreamController<bool> _quotaExceededController =
      StreamController<bool>.broadcast();

  /// Stream that emits when quota exceeded status changes (US-1.2.7, US-1.2.13).
  Stream<bool> get isQuotaExceededStream => _quotaExceededController.stream;

  /// Whether a lookup is currently in progress (US-1.2.17 accessibility).
  bool get isLoading => _isLoading;

  // ── Custom API key ────────────────────────────────────────────────────────

  /// Sets a custom Google Books API key (US-1.2.6).
  void setCustomApiKey(String? key) {
    _customApiKey = key;
    final prefs = _prefs;
    if (prefs != null && key != null) {
      prefs.setString(_kPrefCustomApiKey, key);
    }
  }

  /// Returns the effective API key (custom or default).
  String get _effectiveApiKey {
    // If custom key is set, use it. Otherwise use default.
    final customKey = _customApiKey;
    if (customKey != null && customKey.isNotEmpty) {
      return customKey;
    }
    // Try reading from SharedPreferences.
    final prefs = _prefs;
    if (prefs != null) {
      final stored = prefs.getString(_kPrefCustomApiKey);
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }
    }
    return _defaultApiKey;
  }

  // ── Search methods ────────────────────────────────────────────────────────

  /// Searches for a book by ISBN (US-1.2.1).
  ///
  /// Queries the Google Books API with `q=isbn:<isbn>` and returns
  /// a list of [BookEnrichment] results ordered by relevance (best first).
  Future<List<BookEnrichment>> searchByIsbn(String isbn) async {
    final normalizedIsbn = _normalizeIsbn(isbn);
    final cacheKey = 'isbn:${_hashString(normalizedIsbn)}';

    // Check cache first.
    final cached = await _cache.getIfNotExpired(cacheKey);
    if (cached != null) {
      return _deserializeResults(cached);
    }

    // Check quota.
    if (_quotaExceeded) {
      throw QuotaExceededException();
    }

    _isLoading = true;
    try {
      final results = await _performGet(
        query: 'isbn:$normalizedIsbn',
        maxResults: _kMaxResults,
      );

      // Cache successful results.
      if (results.isNotEmpty) {
        await _cache.upsert(
          cacheKey: cacheKey,
          queryType: 'isbn',
          queryValue: normalizedIsbn,
          resultsJson: jsonEncode(results.map((e) => e.toJson()).toList()),
        );
      }

      return results;
    } finally {
      _isLoading = false;
    }
  }

  /// Searches for books by title (and optionally author) (US-1.2.2).
  ///
  /// Sends `intitle:<title>` and `inauthor:<author>` query parameters,
  /// returning up to 5 results ordered by relevance.
  Future<List<BookEnrichment>> searchByTitleAuthor(
    String title, {
    String? author,
  }) async {
    final normalizedTitle = _normalize(title);
    final normalizedAuthor = author != null ? _normalize(author) : '';
    final cacheKey =
        'titleAuthor:${_hashString('$normalizedTitle|$normalizedAuthor')}';

    // Check cache first.
    final cached = await _cache.getIfNotExpired(cacheKey);
    if (cached != null) {
      return _deserializeResults(cached);
    }

    // Check quota.
    if (_quotaExceeded) {
      throw QuotaExceededException();
    }

    _isLoading = true;
    try {
      final results = await _performGet(
        query: _buildTitleAuthorQuery(normalizedTitle, normalizedAuthor),
        maxResults: _kMaxResults,
      );

      // Cache successful results.
      if (results.isNotEmpty) {
        await _cache.upsert(
          cacheKey: cacheKey,
          queryType: 'titleAuthor',
          queryValue: '$normalizedTitle|$normalizedAuthor',
          resultsJson: jsonEncode(results.map((e) => e.toJson()).toList()),
        );
      }

      return results;
    } finally {
      _isLoading = false;
    }
  }

  // ── Internal HTTP ─────────────────────────────────────────────────────────

  /// Performs an HTTP GET to the Google Books API.
  Future<List<BookEnrichment>> _performGet({
    required String query,
    int maxResults = _kMaxResults,
    bool isFallback = false,
  }) async {
    final uri = Uri.parse(_kBaseUrl).replace(queryParameters: {
      'q': query,
      'maxResults': maxResults.toString(),
      'key': _effectiveApiKey,
    });

    http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: {'Accept': 'application/json'}).timeout(_kTimeout);
    } on SocketException catch (e) {
      throw OfflineException('Network error: ${e.message}');
    } on TimeoutException {
      throw TimeoutException(
          'Google Books API request timed out after ${_kTimeout.inSeconds} seconds');
    }

    return _handleResponse(response, query: query, isFallback: isFallback);
  }

  /// Handles the HTTP response, parsing results and tracking quota.
  Future<List<BookEnrichment>> _handleResponse(
    http.Response response, {
    required String query,
    bool isFallback = false,
  }) async {
    // Handle quota-related errors (US-1.2.13).
    if (response.statusCode == 429 ||
        (response.statusCode == 403 &&
            response.body.toLowerCase().contains('quota'))) {
      _setQuotaExceeded(true);
      throw QuotaExceededException();
    }

    // Handle invalid API key (US-1.2.6 fallback).
    if (response.statusCode == 403 && !isFallback) {
      // If we're using a custom key, fall back to default.
      final customKey = _customApiKey;
      if (customKey != null && customKey.isNotEmpty) {
        _customApiKey = null; // Reset custom key, use default.
        return _performGet(
            query: query, maxResults: _kMaxResults, isFallback: true);
      }
      _setQuotaExceeded(true);
      throw QuotaExceededException('API key rejected');
    }

    // Generic error.
    if (response.statusCode != 200) {
      throw Exception(
        'Google Books API error: HTTP ${response.statusCode}',
      );
    }

    // Parse JSON (US-1.2.15).
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException catch (e) {
      // Corrupted JSON — return empty list, don't crash.
      _log('GoogleBooksClient: Failed to parse JSON: $e');
      return [];
    }

    final totalItems = json['totalItems'] as int? ?? 0;
    if (totalItems == 0) {
      return []; // Empty result set (US-1.2.10).
    }

    final items = json['items'] as List<dynamic>?;
    if (items == null) return [];

    // Increment daily quota counter (US-1.2.7).
    if (!_quotaExceeded) {
      _incrementQuotaCounter();
      _quotaExceededController.add(false);
    }

    return items.map((item) {
      return BookEnrichment.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  // ── Quota tracking ────────────────────────────────────────────────────────

  /// Increments the daily quota counter in memory and SharedPreferences.
  void _incrementQuotaCounter() {
    if (_quotaExceeded) return;

    final today = _todayDateString();
    final storedDate = _prefs?.getString(_kPrefQuotaDate);

    int count;
    if (storedDate == today) {
      count = (_prefs?.getInt(_kPrefQuotaCount) ?? 0) + 1;
    } else {
      count = 1;
    }

    _prefs?.setString(_kPrefQuotaDate, today);
    _prefs?.setInt(_kPrefQuotaCount, count);
  }

  /// Sets the quota exceeded flag and persists it.
  void _setQuotaExceeded(bool exceeded) {
    _quotaExceeded = exceeded;
    _prefs?.setBool(_kPrefQuotaExceeded, exceeded);
    _quotaExceededController.add(exceeded);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Builds a title+author query string for the API.
  String _buildTitleAuthorQuery(String title, String author) {
    final parts = <String>[];
    if (title.isNotEmpty) {
      parts.add('intitle:$title');
    }
    if (author.isNotEmpty) {
      parts.add('inauthor:$author');
    }
    return parts.join(' ');
  }

  /// Normalizes an ISBN by stripping hyphens and spaces.
  String _normalizeIsbn(String isbn) {
    return isbn.replaceAll(RegExp(r'[\s-]'), '');
  }

  /// Normalizes a string for caching: lowercase, trim.
  String _normalize(String s) {
    return s.trim().toLowerCase();
  }

  /// Computes a SHA-256 hash of [input] (US-1.2.5).
  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Deserializes cached JSON results.
  List<BookEnrichment> _deserializeResults(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => BookEnrichment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns today's date as YYYY-MM-DD string.
  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Logs an error message (stub for US-1.2.15).
  void _log(String message) {
    // In production, this would use a proper logging framework.
    // For now, print to stderr (avoid_print is suppressed for logging).
    // ignore: avoid_print
    print('[GoogleBooksClient] $message');
  }

  /// Disposes the stream controller.
  void dispose() {
    _quotaExceededController.close();
  }
}
