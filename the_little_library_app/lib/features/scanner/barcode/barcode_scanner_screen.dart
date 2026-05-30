/// Barcode scanner screen using ML Kit barcode scanning.
/// F3 — Scan a book's barcode/ISBN, look up details online.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../data/api/google_books_client.dart';
import '../../data/api/google_books_providers.dart';

/// Screen state for barcode scanning.
enum BarcodeScanState { scanning, detected, lookingUp, error, manualEntry }

/// Barcode scanner screen.
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  BarcodeScanState _state = BarcodeScanState.scanning;
  String? _detectedBarcode;
  String? _errorMessage;
  bool _torchOn = false;
  final TextEditingController _manualIsbnController = TextEditingController();

  @override
  void dispose() {
    _manualIsbnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          if (_state == BarcodeScanState.scanning)
            IconButton(
              icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
              onPressed: () => setState(() => _torchOn = !_torchOn),
              tooltip: _torchOn ? 'Turn torch off' : 'Turn torch on',
              semanticLabel: _torchOn ? 'Torch on' : 'Torch off',
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera viewfinder area (simulated for now — real camera in Phase 4)
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: _state == BarcodeScanState.scanning
                        ? _buildScanningOverlay(theme)
                        : _buildStateOverlay(theme),
                  ),
                  // Corner bracket overlay
                  if (_state == BarcodeScanState.scanning)
                    CustomPaint(
                      size: Size.infinite,
                      painter: _CornerBracketPainter(),
                    ),
                ],
              ),
            ),
          ),
          // Bottom controls
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.qr_code_scanner, size: 64, color: Colors.white70),
        const SizedBox(height: 16),
        Text(
          'Point camera at a barcode',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        // Simulated scan button for testing
        FilledButton.tonal(
          onPressed: _simulateScan,
          child: const Text('Simulate Scan (Test)'),
        ),
      ],
    );
  }

  Widget _buildStateOverlay(ThemeData theme) {
    switch (_state) {
      case BarcodeScanState.detected:
        return _buildDetectedOverlay(theme);
      case BarcodeScanState.lookingUp:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text('Looking up book…', style: TextStyle(color: Colors.white70)),
          ],
        );
      case BarcodeScanState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _state = BarcodeScanState.scanning),
              child: const Text('Try Again'),
            ),
          ],
        );
      case BarcodeScanState.manualEntry:
        return _buildManualEntry(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetectedOverlay(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 48, color: Colors.greenAccent),
          const SizedBox(height: 16),
          Text(
            'Barcode Detected',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ISBN: $_detectedBarcode',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _lookupBook,
                child: const Text('Lookup Book'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _dismiss,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard, size: 48, color: Colors.white70),
          const SizedBox(height: 16),
          Text(
            'Enter ISBN manually',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 250,
            child: TextField(
              controller: _manualIsbnController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'ISBN (10 or 13 digits)',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitManualIsbn,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => setState(() => _state = BarcodeScanState.manualEntry),
              child: const Text('Enter ISBN manually'),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateScan() {
    setState(() {
      _detectedBarcode = '9780062315007'; // The Alchemist
      _state = BarcodeScanState.detected;
    });
  }

  Future<void> _lookupBook() async {
    if (_detectedBarcode == null) return;
    setState(() => _state = BarcodeScanState.lookingUp);

    try {
      final client = ref.read(googleBooksClientProvider);
      final results = await client.searchByIsbn(_detectedBarcode!);
      if (!context.mounted) return;

      if (results.isNotEmpty) {
        context.go(kRouteBookAdd, extra: results.first);
      } else {
        // No results — navigate with ISBN only
        context.go('${kRouteBookAdd}?isbn=$_detectedBarcode');
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _errorMessage = 'Could not look up this ISBN. You can enter details manually.';
        _state = BarcodeScanState.error;
      });
    }
  }

  void _dismiss() {
    setState(() {
      _detectedBarcode = null;
      _state = BarcodeScanState.scanning;
    });
  }

  void _submitManualIsbn() {
    final isbn = _manualIsbnController.text.trim();
    if (isbn.isNotEmpty) {
      context.go('${kRouteBookAdd}?isbn=$isbn');
    }
  }
}

/// Paints corner brackets for the scan area overlay.
class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const bracketSize = 40.0;
    final left = (size.width - 250) / 2;
    final top = (size.height - 250) / 2;
    final right = left + 250;
    final bottom = top + 250;

    // Top-left
    canvas.drawLine(Offset(left, top + bracketSize), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + bracketSize, top), paint);
    // Top-right
    canvas.drawLine(Offset(right - bracketSize, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + bracketSize), paint);
    // Bottom-left
    canvas.drawLine(Offset(left, bottom - bracketSize), Offset(left, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + bracketSize, bottom), paint);
    // Bottom-right
    canvas.drawLine(Offset(right - bracketSize, bottom), Offset(right, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - bracketSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
