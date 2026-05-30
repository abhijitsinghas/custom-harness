import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import 'catalog_state_provider.dart';

/// Search bar with voice mic icon and ranking dropdown.
class CatalogSearchBar extends ConsumerWidget {
  const CatalogSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            // Magnifying glass icon
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.outline,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            // Search text field
            Expanded(
              child: TextField(
                key: const Key('search_field'),
                decoration: const InputDecoration(
                  hintText: 'Search books, authors…',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: ref.read(catalogProvider.notifier).setSearchQuery,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            // Voice mic icon
            Semantics(
              label: 'Voice search',
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(Icons.mic, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice search listening…')),
                    );
                  },
                  tooltip: 'Voice search',
                ),
              ),
            ),
            // Ranking dropdown
            _RankingDropdown(ranking: state.ranking),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _RankingDropdown extends ConsumerWidget {
  const _RankingDropdown({required this.ranking});

  final SearchRanking ranking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<SearchRanking>(
        value: ranking,
        isDense: true,
        items: const [
          DropdownMenuItem(value: SearchRanking.relevance, child: Text('Relevance')),
          DropdownMenuItem(value: SearchRanking.recency, child: Text('Recency')),
          DropdownMenuItem(value: SearchRanking.alphabetical, child: Text('Alphabetical')),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(catalogProvider.notifier).setRanking(value);
          }
        },
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

/// Horizontally scrollable filter chips row.
class CatalogFilterChips extends ConsumerWidget {
  const CatalogFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    final filters = state.filters;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          _FilterChip(
            label: 'Genre ▾',
            isSelected: filters.genreIds != null && filters.genreIds!.isNotEmpty,
            semanticsLabel: 'Filter by Genre${filters.genreIds != null && filters.genreIds!.isNotEmpty ? ", ${filters.genreIds!.length} selected" : ", collapsed"}',
            onTap: () {
              // TODO: Open genre selection dialog
            },
          ),
          _FilterChip(
            label: 'Language ▾',
            isSelected: filters.languageId != null,
            semanticsLabel: 'Filter by Language${filters.languageId != null ? ", selected" : ", collapsed"}',
            onTap: () {
              // TODO: Open language selection dialog
            },
          ),
          _FilterChip(
            label: 'Location ▾',
            isSelected: filters.locationRoomId != null,
            semanticsLabel: 'Filter by Location${filters.locationRoomId != null ? ", selected" : ", collapsed"}',
            onTap: () {
              // TODO: Open location selection dialog
            },
          ),
          _FilterChip(
            label: 'Status ▾',
            isSelected: filters.status != null,
            semanticsLabel: 'Filter by Status${filters.status != null ? ", ${filters.status!.name}" : ", collapsed"}',
            onTap: () {
              _showStatusFilter(context, ref);
            },
          ),
          _FilterChip(
            label: 'Format ▾',
            isSelected: filters.format != null,
            semanticsLabel: 'Filter by Format${filters.format != null ? ", selected" : ", collapsed"}',
            onTap: () {
              _showFormatFilter(context, ref);
            },
          ),
          _FilterChip(
            label: 'Condition ▾',
            isSelected: filters.condition != null,
            semanticsLabel: 'Filter by Condition${filters.condition != null ? ", selected" : ", collapsed"}',
            onTap: () {
              _showConditionFilter(context, ref);
            },
          ),
          _FilterChip(
            label: 'Tags ▾',
            isSelected: filters.tagIds != null && filters.tagIds!.isNotEmpty,
            semanticsLabel: 'Filter by Tags${filters.tagIds != null && filters.tagIds!.isNotEmpty ? ", ${filters.tagIds!.length} selected" : ", collapsed"}',
            onTap: () {
              // TODO: Open tag selection dialog
            },
          ),
          _FilterChip(
            label: 'Purchase Date ▾',
            isSelected: filters.purchaseDateFrom != null || filters.purchaseDateTo != null,
            semanticsLabel: 'Filter by Purchase Date${filters.purchaseDateFrom != null || filters.purchaseDateTo != null ? ", selected" : ", collapsed"}',
            onTap: () {
              // TODO: Open date range picker
            },
          ),
          _FilterChip(
            label: 'Show Deleted',
            isSelected: filters.showDeleted,
            semanticsLabel: 'Show Deleted${filters.showDeleted ? ", active" : ", collapsed"}',
            onTap: () {
              ref.read(catalogProvider.notifier).updateFilters(
                    showDeleted: !filters.showDeleted,
                  );
            },
          ),
          _FilterChip(
            label: 'Checked Out by Me',
            isSelected: filters.checkedOutByMe,
            semanticsLabel: 'Checked Out by Me${filters.checkedOutByMe ? ", active" : ", collapsed"}',
            onTap: () {
              ref.read(catalogProvider.notifier).updateFilters(
                    checkedOutByMe: !filters.checkedOutByMe,
                  );
            },
          ),
        ],
      ),
    );
  }

  void _showStatusFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Filter by Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (final status in BookStatus.values)
                ListTile(
                  title: Text(kBookStatusDisplayNames[status] ?? status.name),
                  trailing: ref.watch(catalogProvider).filters.status == status
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    final current = ref.read(catalogProvider).filters.status;
                    ref.read(catalogProvider.notifier).updateFilters(
                          status: current == status ? null : status,
                        );
                    Navigator.of(context).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showFormatFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Filter by Format', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (final format in BookFormat.values)
                ListTile(
                  title: Text(kBookFormatDisplayNames[format] ?? format.name),
                  trailing: ref.watch(catalogProvider).filters.format == format
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    final current = ref.read(catalogProvider).filters.format;
                    ref.read(catalogProvider.notifier).updateFilters(
                          format: current == format ? null : format,
                        );
                    Navigator.of(context).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showConditionFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Filter by Condition', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (final condition in BookCondition.values)
                ListTile(
                  title: Text(kBookConditionDisplayNames[condition] ?? condition.name),
                  trailing: ref.watch(catalogProvider).filters.condition == condition
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    final current = ref.read(catalogProvider).filters.condition;
                    ref.read(catalogProvider.notifier).updateFilters(
                          condition: current == condition ? null : condition,
                        );
                    Navigator.of(context).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/// Single filter chip.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        label: semanticsLabel,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toolbar with sort dropdown and grid/list toggle.
class CatalogToolbar extends ConsumerWidget {
  const CatalogToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    final notifier = ref.read(catalogProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Sort dropdown
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CatalogSort>(
                value: state.sort,
                isDense: true,
                items: const [
                  DropdownMenuItem(value: CatalogSort.title, child: Text('Title')),
                  DropdownMenuItem(value: CatalogSort.author, child: Text('Author')),
                  DropdownMenuItem(
                      value: CatalogSort.recentlyAdded, child: Text('Recently Added')),
                  DropdownMenuItem(
                      value: CatalogSort.purchaseDate, child: Text('Purchase Date')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    notifier.setSort(value);
                  }
                },
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          // Grid/List toggle
          Semantics(
            label: 'Grid view',
            child: IconButton(
              key: const Key('view_grid'),
              icon: const Icon(Icons.grid_on),
              onPressed: () => notifier.setViewMode(CatalogViewMode.grid),
              color: state.viewMode == CatalogViewMode.grid
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              tooltip: 'Grid view',
            ),
          ),
          Semantics(
            label: 'List view',
            child: IconButton(
              key: const Key('view_list'),
              icon: const Icon(Icons.view_list),
              onPressed: () => notifier.setViewMode(CatalogViewMode.list),
              color: state.viewMode == CatalogViewMode.list
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              tooltip: 'List view',
            ),
          ),
        ],
      ),
    );
  }
}

/// "None" location nudge banner.
class LocationNudgeBanner extends ConsumerWidget {
  const LocationNudgeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    final notifier = ref.read(catalogProvider.notifier);

    if (state.unplacedBookCount == 0 || state.filters.showUnplaced) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${state.unplacedBookCount} books need a shelf — tap to assign',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                notifier.updateFilters(showUnplaced: !state.filters.showUnplaced);
              },
              child: Text(
                state.filters.showUnplaced ? 'Show All' : 'Assign',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select bottom bar.
class MultiSelectBar extends ConsumerWidget {
  const MultiSelectBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);

    if (!state.isMultiSelect || state.selectedIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final count = state.selectedIds.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              '$count selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _showDeleteConfirmation(context, ref);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Open location picker
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Change location for $count books')),
                );
              },
              child: const Text('Change Location'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final count = ref.read(catalogProvider).selectedIds.length;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Books'),
          content: Text('Are you sure you want to delete $count book${count == 1 ? '' : 's'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(catalogProvider.notifier).deleteSelected();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

/// Empty state for first launch (no books at all).
class EmptyCatalogState extends StatelessWidget {
  const EmptyCatalogState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Your library is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first book to get started.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: const [
                // These buttons are handled by the CatalogScreen's FAB
                // but we show them here for completeness
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for no search results.
class EmptySearchState extends StatelessWidget {
  const EmptySearchState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No books match your search',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or adjust your filters.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for no filter results.
class EmptyFilterState extends ConsumerWidget {
  const EmptyFilterState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No books on this shelf',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No books match your current filters.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(catalogProvider.notifier).clearFilters();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry button.
class ErrorState extends ConsumerWidget {
  const ErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(catalogProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton card for loading state.
class SkeletonBookCard extends StatelessWidget {
  const SkeletonBookCard({super.key, required this.viewMode});

  final CatalogViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    if (viewMode == CatalogViewMode.grid) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 120,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 74,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 120,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
