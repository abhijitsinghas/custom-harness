import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(W02): Initialise drift AppDatabase and override databaseProvider.

  runApp(
    const ProviderScope(
      child: TheLittleLibraryApp(),
    ),
  );
}
