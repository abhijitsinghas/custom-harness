import 'package:flutter/material.dart';

/// Export screen for backing up library data.
/// US-0.4.9: /export route placeholder.
class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: const Center(
        child: Text('Export — Placeholder'),
      ),
    );
  }
}
