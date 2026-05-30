/// Author input field with type-ahead search and disambiguation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add_book_provider.dart';

/// Text input field for adding authors with type-ahead search.
class AuthorInputField extends StatefulWidget {
  const AuthorInputField({
    super.key,
    required this.notifier,
    required this.ref,
  });

  final BookFormNotifier notifier;
  final WidgetRef ref;

  @override
  State<AuthorInputField> createState() => _AuthorInputFieldState();
}

class _AuthorInputFieldState extends State<AuthorInputField> {
  final _controller = TextEditingController();
  bool _showingInput = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showingInput) {
      return TextButton.icon(
        key: const Key('add_author_button'),
        onPressed: () {
          setState(() => _showingInput = true);
          _controller.clear();
        },
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Author'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    return Column(
      children: [
        TextField(
          key: const Key('author_input'),
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Author name',
            hintText: 'Type author name…',
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _showingInput = false);
                _controller.clear();
              },
            ),
          ),
          onChanged: widget.notifier.searchAuthors,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              widget.notifier.addNewAuthor(value);
              _controller.clear();
            }
          },
          textInputAction: TextInputAction.done,
        ),
        if (widget.notifier.authorSearchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.notifier.authorSearchResults.length,
              itemBuilder: (context, index) {
                final author = widget.notifier.authorSearchResults[index];
                return ListTile(
                  title: Text(author.rawName),
                  onTap: () {
                    widget.notifier.addExistingAuthor(author);
                    _controller.clear();
                  },
                );
              },
            ),
          ),
        if (widget.notifier.showingAuthorDisambiguation)
          _buildDisambiguationDialog(context),
      ],
    );
  }

  Widget _buildDisambiguationDialog(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "An author named '${widget.notifier.authorSearchQuery}' already exists.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Is this the same person?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.notifier.confirmAuthorDisambiguation(true, '');
                    },
                    child: const Text('Yes, same person'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.notifier.cancelAuthorDisambiguation();
                    },
                    child: const Text('No, different person'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
