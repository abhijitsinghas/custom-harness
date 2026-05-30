import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

/// Riverpod provider for [AppDatabase].
///
/// Returns a file-backed [AppDatabase] for production.
/// Override with [AppDatabase.memory()] in tests via [ProviderScope.overrides].
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
