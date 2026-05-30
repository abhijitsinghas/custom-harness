/// Multi-select chips for genres and tags with inline "+ Add" functionality.
library;

import 'package:flutter/material.dart';

/// Represents a selectable item (Genre or Tag).
class SelectableItem {
  const SelectableItem({required this.id, required this.name});

  final String id;
  final String name;
}

/// Multi-select chips widget for genres or tags.
class GenreTagChips extends StatefulWidget {
  const GenreTagChips({
    super.key,
    required this.label,
    required this.items,
    required this.selectedIds,
    required this.onAdd,
    required this.onRemove,
    required this.onCreateNew,
  });

  final String label;
  final List<dynamic> items; // List<Genre> or List<Tag>
  final List<String> selectedIds;
  final void Function(String id) onAdd;
  final void Function(String id) onRemove;
  final Future<void> Function(String name) onCreateNew;

  @override
  State<GenreTagChips> createState() => _GenreTagChipsState();
}

class _GenreTagChipsState extends State<GenreTagChips> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showingInput = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Extract the ID from a genre or tag object.
  String _getId(dynamic item) {
    if (item is Map) return item['id'] as String;
    // Use reflection-like access for drift data classes
    return item.id as String;
  }

  /// Extract the name from a genre or tag object.
  String _getName(dynamic item) {
    if (item is Map) return item['name'] as String;
    return item.name as String;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedItems = widget.items
        .where((item) => widget.selectedIds.contains(_getId(item)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Selected chips
            for (final item in selectedItems)
              _buildSelectedChip(context, item),
            // Add chip
            if (!_showingInput)
              _buildAddChip(context),
            // Inline input
            if (_showingInput) _buildInlineInput(context),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedChip(BuildContext context, dynamic item) {
    final theme = Theme.of(context);
    final id = _getId(item);
    final name = _getName(item);

    return InputChip(
      key: ValueKey('chip_$id'),
      label: Text(name),
      selected: true,
      onSelected: (_) => widget.onRemove(id),
      deleteIcon: const Icon(Icons.close, size: 16),
      avatar: Icon(
        widget.label == 'Genres' ? Icons.category : Icons.label,
        size: 16,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAddChip(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      key: const Key('add_genre_tag_chip'),
      onTap: () {
        setState(() => _showingInput = true);
        _textController.clear();
        _focusNode.requestFocus();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
            style: BorderStyle.solid,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineInput(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Name…',
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: _handleCreate,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, size: 18),
            onPressed: () => _handleCreate(_textController.text),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() => _showingInput = false);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreate(String value) async {
    if (value.trim().isEmpty) {
      setState(() => _showingInput = false);
      return;
    }

    await widget.onCreateNew(value.trim());
    setState(() {
      _showingInput = false;
      _textController.clear();
    });
  }
}
