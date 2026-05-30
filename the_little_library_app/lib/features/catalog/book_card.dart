import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import 'catalog_state_provider.dart';

/// Displays a single book card in either grid or list mode.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.viewMode,
    required this.isMultiSelect,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  final Book book;
  final CatalogViewMode viewMode;
  final bool isMultiSelect;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context) {
    if (viewMode == CatalogViewMode.grid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    final statusBadge = _buildStatusBadge(context);

    return Semantics(
      label: _semanticLabel(),
      hint: 'Double-tap to view details',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover image at 3:4 aspect ratio
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildCover(context),
                    // Checkbox overlay in multi-select
                    if (isMultiSelect)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _buildCheckbox(context),
                      ),
                  ],
                ),
              ),
              // Book info
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title — clamped to 2 lines
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    // Author
                    FutureBuilder<List<Author>>(
                      future: _getPrimaryAuthor(context),
                      builder: (context, snapshot) {
                        final authorName = snapshot.data?.isNotEmpty == true
                            ? snapshot.data!.first.rawName
                            : 'Unknown Author';
                        return Text(
                          authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    // Status badge
                    if (statusBadge != null) statusBadge,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final statusBadge = _buildStatusBadge(context);

    return Semantics(
      label: _semanticLabel(),
      hint: 'Double-tap to view details',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover thumbnail (56x74)
                SizedBox(
                  width: 56,
                  height: 74,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildCover(context),
                        if (isMultiSelect) _buildCheckbox(context),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      const SizedBox(height: 2),
                      FutureBuilder<List<Author>>(
                        future: _getPrimaryAuthor(context),
                        builder: (context, snapshot) {
                          final authorName = snapshot.data?.isNotEmpty == true
                              ? snapshot.data!.first.rawName
                              : 'Unknown Author';
                          return Text(
                            authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      if (statusBadge != null) statusBadge,
                    ],
                  ),
                ),
                // Checkbox at end in multi-select
                if (isMultiSelect)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildCheckbox(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    final coverPath = book.coverImagePath;
    if (coverPath != null && coverPath.isNotEmpty) {
      return Image.file(
        File(coverPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _coverPlaceholder(context),
      );
    }
    return _coverPlaceholder(context);
  }

  Widget _coverPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.book_outlined,
        size: 48,
        color:
            Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: onToggleSelect,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }

  Widget? _buildStatusBadge(BuildContext context) {
    // Priority: checked-out > overdue > loaned > available with location > no location
    if (book.status == BookStatus.checkedOut) {
      return _badge(
        context,
        'With ${book.checkedOutTo ?? "someone"}',
        backgroundColor: const Color(0xFFE3F2FD),
        textColor: const Color(0xFF1565C0),
      );
    }

    // Check for overdue (loaned + past due — simplified: any loaned book)
    if (book.status == BookStatus.loaned) {
      // In a real app we'd compare due date with now; here we use the loaned status
      return _badge(
        context,
        'Loaned to ${book.checkedOutTo ?? "someone"}',
        backgroundColor: const Color(0xFFFFF3E0),
        textColor: const Color(0xFFE65100),
      );
    }

    // Available — show location or "No location"
    if (book.status == BookStatus.available) {
      // We'd need to look up the location; for now just show "No location" or location
      return _badge(
        context,
        'Available',
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        textColor: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return null;
  }

  Widget _badge(
    BuildContext context,
    String text, {
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Future<List<Author>> _getPrimaryAuthor(BuildContext context) async {
    // This is a simplified approach — in practice, the catalog provider
    // should include author data. For now, return empty list and let UI
    // show "Unknown Author".
    return [];
  }

  String _semanticLabel() {
    final statusText = switch (book.status) {
      BookStatus.available => 'Available',
      BookStatus.checkedOut => 'Checked out to ${book.checkedOutTo}',
      BookStatus.loaned => 'Loaned to ${book.checkedOutTo}',
    };
    return '${book.title}, by Unknown Author, $statusText';
  }
}
