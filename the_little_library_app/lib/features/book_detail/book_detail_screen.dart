import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/repositories/database_provider.dart';
import 'book_detail_provider.dart';

// ─── Reusable info card widget ──────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Single key-value row inside an info card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.isStrike = false});

  final String label;
  final String value;
  final bool isStrike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 16),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: isStrike ? TextDecoration.lineThrough : null,
                color: isStrike
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cover Hero ─────────────────────────────────────────────────────────────

class _CoverHero extends StatelessWidget {
  const _CoverHero({required this.book, required this.isDeleted});

  final Book book;
  final bool isDeleted;

  @override
  Widget build(BuildContext context) {
    final hasLocalCover = book.coverImagePath != null && book.coverImagePath!.isNotEmpty;
    final hasRemoteCover = book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty;

    Widget imageWidget;
    if (hasLocalCover) {
      imageWidget = Image.file(
        File(book.coverImagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const _CoverPlaceholder(),
      );
    } else if (hasRemoteCover) {
      imageWidget = Image.network(
        book.coverImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _CoverPlaceholder();
        },
        errorBuilder: (_, __, ___) => const _CoverPlaceholder(),
      );
    } else {
      imageWidget = const _CoverPlaceholder();
    }

    if (isDeleted) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: Opacity(opacity: 0.6, child: imageWidget),
      );
    }

    return Semantics(
      label: 'Cover image for ${book.title}',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: imageWidget,
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Icon(
        Icons.book_outlined,
        size: 80,
        color: theme.colorScheme.outline.withValues(alpha: 0.35),
      ),
    );
  }
}

// ─── Status Section ─────────────────────────────────────────────────────────

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.state});

  final BookDetailState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Status: ${state.statusText}',
            child: _StatusBadge(
              status: state.book.status,
              isDeleted: state.isDeleted,
            ),
          ),
          if (!state.isDeleted) ...[
            const SizedBox(height: 12),
            _StatusActions(book: state.book),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.isDeleted = false});

  final BookStatus status;
  final bool isDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bgColor, fgColor) = switch (status) {
      BookStatus.available => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      BookStatus.checkedOut => (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      BookStatus.loaned => (const Color(0xFFFFF3E0), const Color(0xFFE65100)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (status) {
              BookStatus.available => Icons.check_circle_outline,
              BookStatus.checkedOut => Icons.logout,
              BookStatus.loaned => Icons.handshake_outlined,
            },
            size: 16,
            color: fgColor,
          ),
          const SizedBox(width: 6),
          Text(
            kBookStatusDisplayNames[status] ?? status.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        switch (book.status) {
          BookStatus.available => _CheckoutButton(bookId: book.id),
          BookStatus.checkedOut => const _ReturnToShelfButton(),
          BookStatus.loaned => const _ReturnedButton(),
        },
        if (book.status == BookStatus.available)
          _LoanButton(bookId: book.id),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.icon(
      onPressed: () => context.push('/checkout/$bookId'),
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Check Out'),
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: const Size(120, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _LoanButton extends StatelessWidget {
  const _LoanButton({required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.tonalIcon(
      onPressed: () => context.push('/loan/$bookId'),
      icon: const Icon(Icons.handshake_outlined, size: 18),
      label: const Text('Loan to Someone'),
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        minimumSize: const Size(120, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _ReturnToShelfButton extends StatelessWidget {
  const _ReturnToShelfButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.login, size: 18),
      label: const Text('Return to Shelf'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(120, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _ReturnedButton extends StatelessWidget {
  const _ReturnedButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.check, size: 18),
      label: const Text('Returned'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(120, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// ─── Loan History ────────────────────────────────────────────────────────────

class _LoanHistoryCard extends StatelessWidget {
  const _LoanHistoryCard({required this.loans});

  final List<BookLoan> loans;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Loan History',
      children: loans.isEmpty
          ? [
              Text(
                'No loan history. This book has never been checked out or loaned.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ]
          : loans.map((loan) => _LoanItem(loan: loan)).toList(growable: false),
    );
  }
}

class _LoanItem extends StatelessWidget {
  const _LoanItem({required this.loan});

  final BookLoan loan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = loan.borrowerName.isNotEmpty
        ? loan.borrowerName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.borrowerName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _loanMeta(loan),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _loanMeta(BookLoan loan) {
    final parts = <String>[];
    final isReturned = loan.returnedDate != null;
    if (isReturned) {
      parts.add('Checked out');
    } else {
      parts.add('Loaned');
    }

    final loaned = _formatDate(loan.loanedDate);
    final returned = loan.returnedDate != null ? _formatDate(loan.returnedDate!) : null;
    if (returned != null) {
      parts.add('· $loaned – $returned');
    } else {
      final due = loan.dueDate != null ? ' (due ${_formatDate(loan.dueDate!)})' : '';
      parts.add('· since $loaned$due');
    }

    if (isReturned) {
      parts.add('· Returned');
    }
    return parts.join(' ');
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM d, y').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Bottom Action Bar ──────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.book,
    required this.onDelete,
    required this.onRestore,
  });

  final Book book;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomActionItem(
            icon: Icons.edit_outlined,
            label: 'Edit',
            semanticsLabel: 'Edit, button',
            onTap: () => context.push('/book/edit/${book.id}'),
          ),
          _BottomActionItem(
            icon: Icons.share_outlined,
            label: 'Share',
            semanticsLabel: 'Share, button',
            onTap: () => _shareBook(context, book),
          ),
          _BottomActionItem(
            icon: Icons.history_outlined,
            label: 'History',
            semanticsLabel: 'History, button',
            onTap: () => context.push('/change-history/${book.id}'),
          ),
          if (book.isDeleted)
            _BottomActionItem(
              icon: Icons.restore_outlined,
              label: 'Restore',
              semanticsLabel: 'Restore, button',
              onTap: onRestore,
              color: theme.colorScheme.primary,
            )
          else
            _BottomActionItem(
              icon: Icons.delete_outline,
              label: 'Delete',
              semanticsLabel: 'Delete, button',
              onTap: onDelete,
              color: theme.colorScheme.error,
            ),
        ],
      ),
    );
  }

  Future<void> _shareBook(BuildContext context, Book book) async {
    try {
      await SharePlus.instance.share(ShareParams(text: book.title));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share. Please try again.'),
          ),
        );
      }
    }
  }
}

class _BottomActionItem extends StatelessWidget {
  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: color ?? theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color ?? theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

/// Book detail screen showing full information for a single book.
/// US-50 through US-73: Full book detail view with all info cards, status
/// actions, loan history, bottom action bar, and soft-delete/restore.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookDetailProvider(id));

    return Scaffold(
      body: state.when(
        data: (detail) => _BookDetailBody(state: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(context, err.toString()),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Failed to load book details',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _BookDetailBody extends ConsumerStatefulWidget {
  const _BookDetailBody({required this.state});

  final BookDetailState state;

  @override
  ConsumerState<_BookDetailBody> createState() => _BookDetailBodyState();
}

class _BookDetailBodyState extends ConsumerState<_BookDetailBody> {
  void _showDeleteDialog(BuildContext context) {
    final book = widget.state.book;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Book?'),
        content: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: book.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    ' will be hidden but can be restored later from Deleted Books.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _doDelete(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _doDelete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final book = widget.state.book;
    try {
      final db = ref.read<AppDatabase>(databaseProvider);
      final bookDao = db.bookDao;
      await bookDao.softDeleteBook(book.id, deviceUser: 'local');
      if (context.mounted) {
        context.pop();
        messenger.showSnackBar(
          SnackBar(content: Text('${book.title} has been deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _restoreBook(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final book = widget.state.book;
    try {
      final db = ref.read<AppDatabase>(databaseProvider);
      final bookDao = db.bookDao;
      await bookDao.restoreBook(book.id, deviceUser: 'local');
      if (context.mounted) {
        ref.invalidate(bookDetailProvider(book.id));
        messenger.showSnackBar(
          SnackBar(content: Text('${book.title} has been restored')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to restore: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = Theme.of(context);
    final isDeleted = state.isDeleted;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  state.book.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    decoration: isDeleted ? TextDecoration.lineThrough : null,
                    shadows: [
                      Shadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                background: _CoverHero(
                  book: state.book,
                  isDeleted: isDeleted,
                ),
              ),
            ),

            if (isDeleted)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: theme.colorScheme.errorContainer,
                  child: Center(
                    child: Text(
                      '[Deleted]',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: _StatusSection(state: state),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            SliverToBoxAdapter(
              child: _BasicInfoCard(state: state),
            ),

            SliverToBoxAdapter(
              child: _AuthorsCard(authors: state.authors),
            ),

            SliverToBoxAdapter(
              child: _DetailsCard(book: state.book),
            ),

            SliverToBoxAdapter(
              child: _ClassificationCard(
                genres: state.genres,
                tags: state.tags,
              ),
            ),

            SliverToBoxAdapter(
              child: _LocationCard(
                room: state.room,
                cupboard: state.cupboard,
                shelf: state.shelf,
              ),
            ),

            SliverToBoxAdapter(
              child: _PurchaseCard(book: state.book),
            ),

            SliverToBoxAdapter(
              child: _NotesCard(notes: state.book.notes),
            ),

            SliverToBoxAdapter(
              child: _LoanHistoryCard(loans: state.loanHistory),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),

        // Bottom action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomActionBar(
            book: state.book,
            onDelete: () => _showDeleteDialog(context),
            onRestore: () => _restoreBook(context),
          ),
        ),
      ],
    );
  }
}

// ─── Info Cards ──────────────────────────────────────────────────────────────

class _BasicInfoCard extends StatelessWidget {
  const _BasicInfoCard({required this.state});

  final BookDetailState state;

  @override
  Widget build(BuildContext context) {
    final book = state.book;
    return _InfoCard(
      title: 'Basic',
      children: [
        _InfoRow(
          label: 'Title',
          value: book.title,
          isStrike: state.isDeleted,
        ),
        _InfoRow(
          label: 'ISBN',
          value: book.isbn ?? '—',
        ),
        _InfoRow(
          label: 'Language',
          value: state.language?.name ?? '—',
        ),
        _InfoRow(
          label: 'Format',
          value: book.format != null
              ? kBookFormatDisplayNames[book.format] ?? book.format!.name
              : '—',
        ),
      ],
    );
  }
}

class _AuthorsCard extends StatelessWidget {
  const _AuthorsCard({required this.authors});

  final List<Author> authors;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Authors',
      children: authors.isEmpty
          ? [
              Text(
                '—',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ]
          : authors
              .map((a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      a.rawName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ))
              .toList(growable: false),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (book.publisher != null) {
      rows.add(_InfoRow(label: 'Publisher', value: book.publisher!));
    }
    if (book.edition != null) {
      rows.add(_InfoRow(label: 'Edition', value: book.edition!));
    }
    if (book.publicationDate != null) {
      rows.add(_InfoRow(label: 'Published', value: book.publicationDate!));
    }
    if (book.pageCount != null) {
      rows.add(_InfoRow(label: 'Pages', value: '${book.pageCount}'));
    }
    if (book.description != null && book.description!.isNotEmpty) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            book.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ),
      );
    }

    return _InfoCard(
      title: 'Details',
      children: rows,
    );
  }
}

class _ClassificationCard extends StatelessWidget {
  const _ClassificationCard({required this.genres, required this.tags});

  final List<Genre> genres;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _InfoCard(
      title: 'Classification',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genres',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 16),
            Flexible(
              flex: 2,
              child: genres.isEmpty
                  ? Text(
                      'None',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    )
                  : Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 4,
                      children: genres
                          .map((g) => Chip(
                                label: Text(g.name),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(growable: false),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 16),
            Flexible(
              flex: 2,
              child: tags.isEmpty
                  ? Text(
                      'None',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    )
                  : Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 4,
                      children: tags
                          .map((t) => Chip(
                                label: Text('#${t.name}'),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                labelStyle: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ))
                          .toList(growable: false),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({this.room, this.cupboard, this.shelf});

  final Room? room;
  final Cupboard? cupboard;
  final Shelve? shelf;

  @override
  Widget build(BuildContext context) {
    final hasLocation = room != null || cupboard != null || shelf != null;
    return _InfoCard(
      title: 'Location',
      children: [
        _InfoRow(
          label: 'Room',
          value: hasLocation ? (room?.name ?? '—') : 'None',
        ),
        _InfoRow(
          label: 'Cupboard',
          value: hasLocation ? (cupboard?.name ?? '—') : 'None',
        ),
        _InfoRow(
          label: 'Shelf',
          value: hasLocation ? (shelf?.name ?? '—') : 'None',
        ),
      ],
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (book.purchaseDate != null) {
      rows.add(_InfoRow(label: 'Date', value: _formatDate(book.purchaseDate!)));
    }
    if (book.pricePaid != null) {
      rows.add(_InfoRow(
        label: 'Price',
        value: '\$${book.pricePaid!.toStringAsFixed(2)}',
      ));
    }
    if (book.condition != null) {
      rows.add(_InfoRow(
        label: 'Condition',
        value: kBookConditionDisplayNames[book.condition] ?? book.condition!.name,
      ));
    }

    return _InfoCard(title: 'Purchase', children: rows);
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM d, y').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    final hasNotes = notes != null && notes!.trim().isNotEmpty;
    return _InfoCard(
      title: 'Notes',
      children: [
        Text(
          hasNotes
              ? notes!
              : 'No notes yet. Tap Edit to add some.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}
