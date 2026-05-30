/// Photo OCR screen for scanning book covers/spines.
/// F4 — Take a photo of a book cover, extract title/author via OCR.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../data/api/google_books_client.dart';
import '../../data/api/google_books_providers.dart';

/// State for the OCR processing pipeline.
enum OcrState { selectingSource, processing, showingResults, lookingUp, error }

/// Assignment of a text block to a field.
enum TextAssignment { unassigned, title, author }

/// A detected text block with its assignment.
class _TextBlock {
  final String text;
  TextAssignment assignment;
  _TextBlock(this.text, {this.assignment = TextAssignment.unassigned});
}

/// Photo OCR screen.
class PhotoOcrScreen extends ConsumerStatefulWidget {
  const PhotoOcrScreen({super.key});

  @override
  ConsumerState<PhotoOcrScreen> createState() => _PhotoOcrScreenState();
}

class _PhotoOcrScreenState extends ConsumerState<PhotoOcrScreen> {
  OcrState _state = OcrState.selectingSource;
  List<_TextBlock> _textBlocks = [];
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Book Cover'),
        actions: [
          if (_state == OcrState.showingResults)
            IconButton(
              icon: const Icon(Icons.crop),
              onPressed: _cropImage,
              tooltip: 'Crop image',
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_state) {
      case OcrState.selectingSource:
        return _buildSourceSelection(theme);
      case OcrState.processing:
        return _buildProcessing(theme);
      case OcrState.showingResults:
        return _buildResults(theme);
      case OcrState.lookingUp:
        return _buildLookingUp(theme);
      case OcrState.error:
        return _buildError(theme);
    }
  }

  Widget _buildSourceSelection(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Take a photo of a book cover or spine',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _simulateCapture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _simulateCapture,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Or enter the details manually',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(kRouteBookAdd),
              child: const Text('Manual Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessing(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Scanning text…',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final titleText = _textBlocks
        .where((t) => t.assignment == TextAssignment.title)
        .map((t) => t.text)
        .join(' ');
    final authorText = _textBlocks
        .where((t) => t.assignment == TextAssignment.author)
        .map((t) => t.text)
        .join(' ');

    return Column(
      children: [
        // Photo preview area with bounding boxes
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[900],
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image, size: 48, color: Colors.white38),
                      const SizedBox(height: 8),
                      Text(
                        'Cover Image Preview',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                // Simulated bounding boxes
                ..._textBlocks.asMap().entries.map((entry) {
                  final i = entry.key;
                  final block = entry.value;
                  final top = 40.0 + (i * 40.0);
                  final left = 40.0;
                  final color = switch (block.assignment) {
                    TextAssignment.title => Colors.blue.withOpacity(0.4),
                    TextAssignment.author => Colors.green.withOpacity(0.4),
                    TextAssignment.unassigned => Colors.orange.withOpacity(0.4),
                  };
                  return Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: 280,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: color, width: 2),
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        block.text,
                        style: TextStyle(color: color, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        // Text blocks as tappable chips
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detected Text',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap a block to assign it as Title or Author',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _textBlocks.asMap().entries.map((entry) {
                        final i = entry.key;
                        final block = entry.value;
                        final chipColor = switch (block.assignment) {
                          TextAssignment.title => Colors.blue,
                          TextAssignment.author => Colors.green,
                          TextAssignment.unassigned => null,
                        };
                        return ActionChip(
                          label: Text(
                            block.text,
                            style: TextStyle(
                              color: chipColor != null ? Colors.white : null,
                            ),
                          ),
                          backgroundColor: chipColor?.withOpacity(0.2),
                          onPressed: () => _showAssignmentMenu(i),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Action bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _retake,
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: (titleText.isNotEmpty || authorText.isNotEmpty)
                        ? _searchOnline
                        : null,
                    child: Text(
                      _hasAssignedText() ? 'Search Online' : 'Assign text first',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLookingUp(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text('Searching Google Books…'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _skipLookup,
            child: const Text('Skip — enter manually'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => setState(() => _state = OcrState.selectingSource),
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => context.go(kRouteBookAdd),
                  child: const Text('Manual Entry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _simulateCapture() {
    setState(() => _state = OcrState.processing);

    // Simulate OCR processing delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _textBlocks = [
          _TextBlock('The Alchemist'),
          _TextBlock('Paulo Coelho'),
          _TextBlock('HarperCollins'),
          _TextBlock('1988'),
        ];
        _state = OcrState.showingResults;
      });
    });
  }

  void _showAssignmentMenu(int index) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Assign as Title'),
              selected: _textBlocks[index].assignment == TextAssignment.title,
              onTap: () {
                setState(() => _textBlocks[index].assignment = TextAssignment.title);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Assign as Author'),
              selected: _textBlocks[index].assignment == TextAssignment.author,
              onTap: () {
                setState(() => _textBlocks[index].assignment = TextAssignment.author);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Unassign'),
              selected: _textBlocks[index].assignment == TextAssignment.unassigned,
              onTap: () {
                setState(
                  () => _textBlocks[index].assignment = TextAssignment.unassigned,
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _hasAssignedText() {
    return _textBlocks.any((t) => t.assignment != TextAssignment.unassigned);
  }

  Future<void> _searchOnline() async {
    setState(() => _state = OcrState.lookingUp);

    final titleText = _textBlocks
        .where((t) => t.assignment == TextAssignment.title)
        .map((t) => t.text)
        .join(' ');
    final authorText = _textBlocks
        .where((t) => t.assignment == TextAssignment.author)
        .map((t) => t.text)
        .join(' ');

    try {
      final client = ref.read(googleBooksClientProvider);
      final results = await client.searchByTitleAuthor(titleText, authorText);
      if (!context.mounted) return;

      if (results.isNotEmpty) {
        context.go(kRouteBookAdd, extra: results.first);
      } else {
        context.go('${kRouteBookAdd}?title=$titleText&author=$authorText');
      }
    } catch (e) {
      if (!context.mounted) return;
      // Fallback: navigate with extracted text
      context.go('${kRouteBookAdd}?title=$titleText&author=$authorText');
    }
  }

  void _skipLookup() {
    final titleText = _textBlocks
        .where((t) => t.assignment == TextAssignment.title)
        .map((t) => t.text)
        .join(' ');
    context.go('${kRouteBookAdd}?title=$titleText');
  }

  void _cropImage() {
    // Placeholder — would open crop editor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crop tool — coming soon')),
    );
  }

  void _retake() {
    setState(() {
      _textBlocks = [];
      _state = OcrState.selectingSource;
    });
  }
}
