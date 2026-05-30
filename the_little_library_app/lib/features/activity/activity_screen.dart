import 'package:flutter/material.dart';

/// Recent activity screen showing change log entries.
/// US-0.4.9: /activity route placeholder.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Activity')),
      body: const Center(
        child: Text('Recent Activity — Placeholder'),
      ),
    );
  }
}
