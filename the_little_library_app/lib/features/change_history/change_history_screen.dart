import 'package:flutter/material.dart';

/// Change history screen for a specific book.
/// US-0.4.9: /change-history/:bookId route placeholder.
class ChangeHistoryScreen extends StatelessWidget {
  const ChangeHistoryScreen({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change History')),
      body: Center(
        child: Text('Change History — Book ID: $bookId'),
      ),
    );
  }
}
