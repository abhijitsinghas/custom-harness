/// Enrichment bottom sheet for Google Books search results.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/api/book_enrichment.dart';
import '../add_book_provider.dart';

/// Bottom sheet showing Google Books enrichment results.
class EnrichmentSheet extends StatelessWidget {
  const EnrichmentSheet({
    super.key,
    required this.notifier,
    required this.ref,
  });

  final BookFormNotifier notifier;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      notifier.isEnriching
                          ? 'Searching Google Books…'
                          : 'Select a match',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    key: const Key('enrich_close'),
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      notifier.closeEnrichment();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  if (notifier.isEnriching) ..._buildSkeletonLoaders(),
                  if (notifier.enrichmentError != null && !notifier.isEnriching)
                    _buildErrorState(context),
                  if (!notifier.isEnriching &&
                      notifier.enrichmentResults.isEmpty &&
                      notifier.enrichmentError == null)
                    _buildEmptyState(context),
                  if (!notifier.isEnriching &&
                      notifier.enrichmentResults.isNotEmpty)
                    ...notifier.enrichmentResults.asMap().entries.map(
                          (entry) => _buildResultCard(
                            context,
                            entry.value,
                            entry.key,
                          ),
                        ),
                ],
              ),
            ),
            // Apply button
            if (notifier.enrichmentResults.isNotEmpty && !notifier.isEnriching)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  key: const Key('apply_enrichment'),
                  onPressed: notifier.selectedEnrichmentIndex != null
                      ? () {
                          notifier.applyEnrichment();
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Apply Selected'),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSkeletonLoaders() {
    return [
      for (int i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            key: Key('skeleton_$i'),
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
    ];
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final isOffline = notifier.enrichmentError?.toLowerCase().contains('offline') ??
        notifier.enrichmentError?.toLowerCase().contains('no internet') ??
        false;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOffline ? Icons.wifi_off : Icons.error_outline,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            isOffline
                ? 'Offline — enrichment requires internet.\nTap to retry.'
                : notifier.enrichmentError!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('retry_enrichment'),
            onPressed: () {
              notifier.searchEnrichment(notifier.title);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No matches found on Google Books.\nTry a different title or enter details manually.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('close_enrichment'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    BookEnrichment result,
    int index,
  ) {
    final theme = Theme.of(context);
    final isSelected = notifier.selectedEnrichmentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        key: Key('enrich_result_$index'),
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => notifier.selectEnrichmentResult(index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Cover thumbnail
                Container(
                  width: 48,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: theme.colorScheme.surface,
                  ),
                  child: result.coverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            result.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.book_outlined,
                              size: 24,
                            ),
                          ),
                        )
                      : const Icon(Icons.book_outlined, size: 24),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${result.authors.join(', ')} · ${_extractYear(result.publicationDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _extractYear(String? date) {
    if (date == null || date.isEmpty) return '';
    return date.substring(0, 4);
  }
}
