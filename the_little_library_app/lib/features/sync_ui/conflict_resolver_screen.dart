import 'package:flutter/material.dart';

/// Sync conflict resolver screen.
/// US-0.4.9: /conflicts route placeholder.
class ConflictResolverScreen extends StatelessWidget {
  const ConflictResolverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conflicts')),
      body: const Center(
        child: Text('Conflict Resolver — Placeholder'),
      ),
    );
  }
}
