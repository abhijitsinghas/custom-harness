import 'package:flutter/material.dart';

/// Force update screen for manual sync trigger.
/// US-0.4.9: /force-update route placeholder.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Force Update')),
      body: const Center(
        child: Text('Force Update — Placeholder'),
      ),
    );
  }
}
