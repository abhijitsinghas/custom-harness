import 'package:flutter/material.dart';

/// Voice input screen for adding books via speech-to-text.
/// US-0.4.9: /voice-input route placeholder.
class VoiceInputScreen extends StatelessWidget {
  const VoiceInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Input')),
      body: const Center(
        child: Text('Voice Input — Placeholder'),
      ),
    );
  }
}
