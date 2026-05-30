import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

/// The single [AppDatabase] instance used across the entire app.
///
/// This is a [keepAlive] provider so the database connection is never closed
/// while the app is running.  Tests override this with an in-memory instance
/// via `ProviderScope(overrides: [...])`.
final databaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase(),
);
