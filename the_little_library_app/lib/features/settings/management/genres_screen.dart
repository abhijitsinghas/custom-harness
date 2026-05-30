import 'package:flutter/material.dart';

/// Genre management screen.
/// US-0.4.9: /settings/genres route placeholder.
class GenresScreen extends StatelessWidget {
  const GenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Genres')),
      body: const Center(
        child: Text('Genres — Placeholder'),
      ),
    );
  }
}
