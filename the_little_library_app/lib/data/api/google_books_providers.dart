/// Riverpod providers for the Google Books API client.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'google_books_cache.dart';
import 'google_books_client.dart';
import '../repositories/database_provider.dart';

/// Provides a [GoogleBooksCacheDao] for caching API responses.
final googleBooksCacheDaoProvider = Provider<GoogleBooksCacheDao>((ref) {
  final db = ref.watch(databaseProvider);
  return GoogleBooksCacheDao(db);
});

/// Provides a [GoogleBooksClient] for Google Books API calls.
///
/// In tests, override this with a mock client:
/// ```dart
/// googleBooksClientProvider.overrideWithValue(mockClient)
/// ```
final googleBooksClientProvider = Provider<GoogleBooksClient>((ref) {
  final cache = ref.watch(googleBooksCacheDaoProvider);
  final httpClient = http.Client();

  // Attempt to get SharedPreferences synchronously; if not available, pass null.
  // In production, SharedPreferences.getInstance() is async, but we create the
  // client without it for the initial provider. Quota tracking will be limited.
  SharedPreferences? prefs;
  try {
    // Synchronous access attempt — may return null on first launch.
    // SharedPreferences.getInstance() requires async init.
    // We use a workaround: create the client without prefs initially.
  } catch (_) {
    prefs = null;
  }

  final client = GoogleBooksClient(
    httpClient: httpClient,
    cache: cache,
    prefs: prefs,
  );

  // Dispose the client (and its HTTP client) when the provider is destroyed.
  ref.onDispose(() {
    client.dispose();
    httpClient.close();
  });

  return client;
});
