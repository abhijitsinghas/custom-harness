import 'package:flutter/material.dart';

/// Active loans screen showing all currently loaned books.
/// US-0.4.9: /active-loans route placeholder.
class ActiveLoansScreen extends StatelessWidget {
  const ActiveLoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Loans')),
      body: const Center(
        child: Text('Active Loans — Placeholder'),
      ),
    );
  }
}
