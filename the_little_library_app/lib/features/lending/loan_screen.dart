import 'package:flutter/material.dart';

/// Loan detail screen for a specific book loan.
/// US-0.4.9: /loan/:bookId route placeholder.
class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Loan — Book $bookId')),
      body: Center(
        child: Text('Loan — Book ID: $bookId'),
      ),
    );
  }
}
