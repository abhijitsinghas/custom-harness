import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import 'book_card.dart';
import 'catalog_state_provider.dart';
import 'catalog_widgets.dart';
import 'fab_speed_dial.dart';
import 'sync_status_bar.dart';

/// Drawer item definition.
class _DrawerItem {
  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.semanticsLabel,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String semanticsLabel;
  final String route;
}

/// Navigation drawer with 9 items matching catalog.html mockup.
/// US-0.4.2, US-0.4.3: 9 navigation items with icons and routes.
class _LibraryDrawer extends StatelessWidget {
  const _LibraryDrawer();

  static const _items = <_DrawerItem>[
    _DrawerItem(
      title: 'Library (Catalog)',
      icon: Icons.book_outlined,
      semanticsLabel: 'Library, Catalog, button',
      route: kRouteCatalog,
    ),
    _DrawerItem(
      title: 'Locations',
      icon: Icons.location_on_outlined,
      semanticsLabel: 'Locations, button',
      route: kRouteLocations,
    ),
    _DrawerItem(
      title: 'Recent Activity',
      icon: Icons.history_outlined,
      semanticsLabel: 'Recent Activity, button',
      route: kRouteActivity,
    ),
    _DrawerItem(
      title: 'Active Loans',
      icon: Icons.handshake_outlined,
      semanticsLabel: 'Active Loans, button',
      route: kRouteActiveLoans,
    ),
    _DrawerItem(
      title: 'Genres',
      icon: Icons.category_outlined,
      semanticsLabel: 'Genres, button',
      route: kRouteSettingsGenres,
    ),
    _DrawerItem(
      title: 'Tags',
      icon: Icons.label_outlined,
      semanticsLabel: 'Tags, button',
      route: kRouteSettingsTags,
    ),
    _DrawerItem(
      title: 'Languages',
      icon: Icons.language_outlined,
      semanticsLabel: 'Languages, button',
      route: kRouteSettingsLanguages,
    ),
    _DrawerItem(
      title: 'Deleted Books',
      icon: Icons.delete_outline,
      semanticsLabel: 'Deleted Books, button',
      route: kRouteDeleted,
    ),
    _DrawerItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      semanticsLabel: 'Settings, button',
      route: kRouteSettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.local_library,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Little Library',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            // Drawer items
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Semantics(
                    label: item.semanticsLabel,
                    child: ListTile(
                      key: Key(item.semanticsLabel),
                      leading: Semantics(
                        label: '${item.title} icon',
                        child: Icon(item.icon),
                      ),
                      title: Text(item.title),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.route);
                      },
                      minVerticalPadding: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Catalog screen — the main home screen of the app.
/// Displays the full catalog with search, filters, sort, grid/list toggle,
/// multi-select, pull-to-refresh, and empty states.
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    final notifier = ref.read(catalogProvider.notifier);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: Semantics(
          label: 'Open navigation menu',
          child: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
                Navigator.of(context).pop();
              }
              scaffoldKey.currentState?.openDrawer();
            },
            tooltip: 'Open navigation menu',
          ),
        ),
        title: const Text('The Little Library'),
      ),
      drawer: const _LibraryDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Sync status bar
            const SyncStatusBar(),
            // Search bar
            const CatalogSearchBar(),
            // Filter chips
            const CatalogFilterChips(),
            // Toolbar with sort and view toggle
            const CatalogToolbar(),
            // Location nudge banner
            const LocationNudgeBanner(),
            // Content area
            Expanded(
              child: _buildContent(context, ref, state, notifier),
            ),
          ],
        ),
      ),
      floatingActionButton: state.isMultiSelect
          ? null
          : const FabSpeedDial(),
      // Multi-select bottom bar
      bottomSheet: state.isMultiSelect && state.selectedIds.isNotEmpty
          ? const MultiSelectBar()
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CatalogState state,
    CatalogNotifier notifier,
  ) {
    // Loading state — show skeleton cards
    if (state.isLoading && state.books.isEmpty) {
      return _buildLoadingGrid(context, state.viewMode);
    }

    // Error state
    if (state.error != null && state.books.isEmpty) {
      return ErrorState(message: state.error!);
    }

    // Empty state — no books at all
    if (state.books.isEmpty && !state.isLoading) {
      if (state.searchQuery.isNotEmpty) {
        return const EmptySearchState();
      }
      if (state.filters.hasActiveFilters) {
        return const EmptyFilterState();
      }
      return const EmptyCatalogState();
    }

    // Has books — show grid or list
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            notifier.loadMore();
          }
          return false;
        },
        child: state.viewMode == CatalogViewMode.grid
            ? _buildGrid(context, state, notifier)
            : _buildList(context, state, notifier),
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context, CatalogViewMode viewMode) {
    if (viewMode == CatalogViewMode.grid) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return const SkeletonBookCard(viewMode: CatalogViewMode.grid);
          },
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: const SkeletonBookCard(viewMode: CatalogViewMode.list),
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    CatalogState state,
    CatalogNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: GridView.builder(
        key: const Key('book_grid'),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: state.books.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.books.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final book = state.books[index];
          final isSelected = state.selectedIds.contains(book.id);

          return BookCard(
            key: ValueKey(book.id),
            book: book,
            viewMode: CatalogViewMode.grid,
            isMultiSelect: state.isMultiSelect,
            isSelected: isSelected,
            onTap: () {
              if (state.isMultiSelect) {
                notifier.toggleSelection(book.id);
              } else {
                context.push('/book/${book.id}');
              }
            },
            onLongPress: () {
              if (!state.isMultiSelect) {
                notifier.enterMultiSelect(book.id);
              }
            },
            onToggleSelect: () {
              notifier.toggleSelection(book.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    CatalogState state,
    CatalogNotifier notifier,
  ) {
    return ListView.builder(
      key: const Key('book_list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: state.books.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.books.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final book = state.books[index];
        final isSelected = state.selectedIds.contains(book.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BookCard(
            key: ValueKey(book.id),
            book: book,
            viewMode: CatalogViewMode.list,
            isMultiSelect: state.isMultiSelect,
            isSelected: isSelected,
            onTap: () {
              if (state.isMultiSelect) {
                notifier.toggleSelection(book.id);
              } else {
                context.push('/book/${book.id}');
              }
            },
            onLongPress: () {
              if (!state.isMultiSelect) {
                notifier.enterMultiSelect(book.id);
              }
            },
            onToggleSelect: () {
              notifier.toggleSelection(book.id);
            },
          ),
        );
      },
    );
  }
}
