import 'package:flutter/material.dart';

/// Checkout screen for lending a book.
/// US-0.4.9: /checkout/:bookId route placeholder.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout — Book $bookId')),
      body: Center(
        child: Text('Checkout — Book ID: $bookId'),
      ),
    );
  }
}
