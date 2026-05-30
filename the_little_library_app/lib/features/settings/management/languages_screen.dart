import 'package:flutter/material.dart';

/// Language management screen.
/// US-0.4.9: /settings/languages route placeholder.
class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Languages')),
      body: const Center(
        child: Text('Languages — Placeholder'),
      ),
    );
  }
}
