/// Duplicate detection warning dialog.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/duplicate_detector.dart';
import '../add_book_provider.dart';

/// Dialog shown when a potential duplicate is detected.
class DuplicateDialog extends StatelessWidget {
  const DuplicateDialog({
    super.key,
    required this.notifier,
    required this.ref,
  });

  final BookFormNotifier notifier;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duplicate = notifier.duplicateResult;

    if (duplicate == null) return const SizedBox.shrink();

    return AlertDialog(
      key: const Key('duplicate_dialog'),
      title: const Text('Possible Duplicate'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _buildDuplicateMessage(duplicate),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (duplicate is FuzzyTitleAuthorMatch)
            Text(
              'Similar title and author.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('cancel_button'),
          onPressed: () {
            notifier.cancelSave();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('add_anyway_button'),
          onPressed: () {
            notifier.saveAnyway();
            Navigator.of(context).pop();
          },
          child: const Text('Add Anyway'),
        ),
      ],
    );
  }

  String _buildDuplicateMessage(DuplicateResult result) {
    switch (result) {
      case ExactIsbnMatch():
        return 'This may be a duplicate of "${notifier.title}" already in your library (ISBN match).';
      case FuzzyTitleAuthorMatch(:final title, :final author):
        return 'This may be a duplicate of "$title" by $author already in your library.';
    }
  }
}
