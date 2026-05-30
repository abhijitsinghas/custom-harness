import 'package:flutter/material.dart';

/// Deleted books screen showing soft-deleted entries.
/// US-0.4.9: /deleted route placeholder.
class DeletedBooksScreen extends StatelessWidget {
  const DeletedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deleted Books')),
      body: const Center(
        child: Text('Deleted Books — Placeholder'),
      ),
    );
  }
}
