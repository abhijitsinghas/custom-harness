/// Add/Edit Book Form Screen.
/// US-74 through US-117: Full form with all sections, enrichment, and duplicate detection.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/routes.dart';
import 'add_book_provider.dart';
import 'widgets/cover_picker_sheet.dart';
import 'widgets/enrichment_sheet.dart';
import 'widgets/duplicate_dialog.dart';
import 'widgets/author_input_field.dart';
import 'widgets/genre_tag_chips.dart';
import 'widgets/location_cascade.dart';

/// Add/Edit Book form screen.
///
/// In add mode: [AddBookScreen]
/// In edit mode: [AddBookScreen(editBookId: 'uuid')]
class AddBookScreen extends ConsumerWidget {
  const AddBookScreen({super.key, this.editBookId});

  /// When provided, the screen operates in edit mode, pre-filling the form
  /// with the existing book's data.
  final String? editBookId;

  BookFormParams get _params => editBookId != null
      ? BookFormParams.edit(bookId: editBookId!)
      : BookFormParams.add();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(addBookFormProvider(_params));
    final isEdit = editBookId != null;

    if (notifier.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(isEdit ? 'Edit Book' : 'Add Book')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (notifier.loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(isEdit ? 'Edit Book' : 'Add Book')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading form: ${notifier.loadError}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(addBookFormProvider(_params)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildForm(context, ref, notifier, isEdit);
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
    bool isEdit,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Book' : 'Add Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Enrich Online',
            onPressed: notifier.isQuotaExceeded
                ? null
                : () => _showEnrichmentSheet(context, ref, notifier),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBasicInfoSection(context, notifier),
                    const SizedBox(height: 8),
                    _buildAuthorsSection(context, ref, notifier),
                    const SizedBox(height: 8),
                    _buildDetailsSection(context, notifier),
                    const SizedBox(height: 8),
                    _buildClassificationSection(context, ref, notifier),
                    const SizedBox(height: 8),
                    _buildLocationSection(context, ref, notifier),
                    const SizedBox(height: 8),
                    _buildPurchaseSection(context, notifier),
                    const SizedBox(height: 8),
                    _buildCoverSection(context, ref, notifier),
                    const SizedBox(height: 8),
                    _buildNotesSection(context, notifier),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, notifier),
    );
  }

  // ── Basic Info Section ──────────────────────────────────────────────────

  Widget _buildBasicInfoSection(BuildContext context, BookFormNotifier notifier) {
    return _SectionCard(
      title: 'Basic Info',
      hasCheckmark: notifier.enrichedSections['basic'] ?? false,
      child: Column(
        children: [
          TextFormField(
            key: const Key('title_field'),
            initialValue: notifier.title.isEmpty ? null : notifier.title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter book title',
            ),
            onChanged: notifier.setTitle,
            textInputAction: TextInputAction.next,
          ),
          if (notifier.titleError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notifier.titleError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('isbn_field'),
            initialValue: notifier.isbn.isEmpty ? null : notifier.isbn,
            decoration: const InputDecoration(
              labelText: 'ISBN',
              hintText: '978-0-123456-78-9',
            ),
            onChanged: notifier.setIsbn,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          if (notifier.isbnError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notifier.isbnError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildLanguageDropdown(context, notifier),
          const SizedBox(height: 16),
          _buildFormatSegmented(context, notifier),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, BookFormNotifier notifier) {
    return DropdownButtonFormField<String?>(
      key: const Key('language_dropdown'),
      value: notifier.languageId,
      decoration: const InputDecoration(
        labelText: 'Language',
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Select language'),
        ),
        ...notifier.languages.map((lang) => DropdownMenuItem<String?>(
              value: lang.id,
              child: Text(lang.name),
            )),
      ],
      onChanged: notifier.setLanguageId,
    );
  }

  Widget _buildFormatSegmented(BuildContext context, BookFormNotifier notifier) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Format',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final format in BookFormat.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    key: Key('format_${format.name}'),
                    onPressed: () => notifier.setFormat(format),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: notifier.format == format
                          ? theme.colorScheme.primary
                          : null,
                      foregroundColor: notifier.format == format
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(kBookFormatDisplayNames[format]!),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Authors Section ─────────────────────────────────────────────────────

  Widget _buildAuthorsSection(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
  ) {
    return _SectionCard(
      title: 'Authors',
      hasCheckmark: notifier.enrichedSections['authors'] ?? false,
      child: Column(
        children: [
          if (notifier.authorNames.isNotEmpty)
            ...notifier.authorNames.map((name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          key: ValueKey('author_$name'),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => notifier.removeAuthor(name),
                        tooltip: 'Remove author',
                      ),
                    ],
                  ),
                )),
          AuthorInputField(
            notifier: notifier,
            ref: ref,
          ),
        ],
      ),
    );
  }

  // ── Details Section ─────────────────────────────────────────────────────

  Widget _buildDetailsSection(BuildContext context, BookFormNotifier notifier) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Details',
      hasCheckmark: notifier.enrichedSections['details'] ?? false,
      child: Column(
        children: [
          TextFormField(
            key: const Key('publisher_field'),
            initialValue: notifier.publisher.isEmpty ? null : notifier.publisher,
            decoration: const InputDecoration(
              labelText: 'Publisher',
              hintText: 'Publisher name',
            ),
            onChanged: notifier.setPublisher,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('edition_field'),
            initialValue: notifier.edition.isEmpty ? null : notifier.edition,
            decoration: const InputDecoration(
              labelText: 'Edition',
              hintText: 'e.g. First Edition',
            ),
            onChanged: notifier.setEdition,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('publication_date_field'),
            initialValue: notifier.publicationDate.isEmpty ? null : notifier.publicationDate,
            decoration: const InputDecoration(
              labelText: 'Publication Date',
              hintText: 'Tap to select',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1000),
                lastDate: DateTime(DateTime.now().year + 1),
              );
              if (picked != null) {
                notifier.setPublicationDate(picked.year.toString());
              }
            },
          ),
          if (notifier.publicationDateError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notifier.publicationDateError!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('page_count_field'),
            initialValue: notifier.pageCount.isEmpty ? null : notifier.pageCount,
            decoration: const InputDecoration(
              labelText: 'Page Count',
              hintText: '0',
            ),
            onChanged: notifier.setPageCount,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('description_field'),
            initialValue: notifier.description.isEmpty ? null : notifier.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Book description…',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            onChanged: notifier.setDescription,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  // ── Classification Section ──────────────────────────────────────────────

  Widget _buildClassificationSection(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
  ) {
    return _SectionCard(
      title: 'Classification',
      hasCheckmark: false,
      child: Column(
        children: [
          GenreTagChips(
            label: 'Genres',
            items: notifier.genres,
            selectedIds: notifier.genreIds,
            onAdd: notifier.addGenre,
            onRemove: notifier.removeGenre,
            onCreateNew: notifier.createAndAddGenre,
          ),
          const SizedBox(height: 16),
          GenreTagChips(
            label: 'Tags',
            items: notifier.tags,
            selectedIds: notifier.tagIds,
            onAdd: notifier.addTag,
            onRemove: notifier.removeTag,
            onCreateNew: notifier.createAndAddTag,
          ),
        ],
      ),
    );
  }

  // ── Location Section ────────────────────────────────────────────────────

  Widget _buildLocationSection(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
  ) {
    return _SectionCard(
      title: 'Location',
      hasCheckmark: false,
      child: LocationCascade(notifier: notifier, ref: ref),
    );
  }

  // ── Purchase Section ────────────────────────────────────────────────────

  Widget _buildPurchaseSection(BuildContext context, BookFormNotifier notifier) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Purchase',
      hasCheckmark: false,
      child: Column(
        children: [
          TextFormField(
            key: const Key('purchase_date_field'),
            initialValue: notifier.purchaseDate.isEmpty ? null : notifier.purchaseDate,
            decoration: const InputDecoration(
              labelText: 'Purchase Date',
              hintText: 'Tap to select',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                initialEntryMode: DatePickerEntryMode.calendar,
              );
              if (picked != null) {
                notifier.setPurchaseDate(
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('price_paid_field'),
            initialValue: notifier.pricePaid.isEmpty ? null : notifier.pricePaid,
            decoration: const InputDecoration(
              labelText: 'Price Paid',
              hintText: '0.00',
              prefixText: '\$ ',
            ),
            onChanged: notifier.setPricePaid,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          Text(
            'Condition',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BookCondition.values.map((condition) {
              final isSelected = notifier.condition == condition;
              return FilterChip(
                key: Key('condition_${condition.name}'),
                label: Text(kBookConditionDisplayNames[condition]!),
                selected: isSelected,
                onSelected: (_) => notifier.setCondition(condition),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Cover Section ───────────────────────────────────────────────────────

  Widget _buildCoverSection(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
  ) {
    return _SectionCard(
      title: 'Cover Image',
      hasCheckmark: notifier.coverImagePath != null && notifier.coverImagePath!.isNotEmpty,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 133,
            child: Container(
              key: const Key('cover_preview'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: notifier.coverImagePath != null &&
                      notifier.coverImagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(notifier.coverImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coverPlaceholder(context),
                      ),
                    )
                  : _coverPlaceholder(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                OutlinedButton.icon(
                  key: const Key('cover_take_photo'),
                  onPressed: () => _showCoverPicker(context, ref, notifier, CoverSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('cover_gallery'),
                  onPressed: () => _showCoverPicker(context, ref, notifier, CoverSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('cover_search_online'),
                  onPressed: () => _showCoverPicker(context, ref, notifier, CoverSource.online),
                  icon: const Icon(Icons.search),
                  label: const Text('Search Online'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.book_outlined,
        size: 40,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.35),
      ),
    );
  }

  void _showCoverPicker(
    BuildContext context,
    WidgetRef widgetRef,
    BookFormNotifier notifier,
    CoverSource source,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => CoverPickerSheet(
        notifier: notifier,
        ref: widgetRef,
        selectedSource: source,
      ),
    );
  }

  // ── Notes Section ───────────────────────────────────────────────────────

  Widget _buildNotesSection(BuildContext context, BookFormNotifier notifier) {
    return _SectionCard(
      title: 'Notes',
      hasCheckmark: false,
      child: TextFormField(
        key: const Key('notes_field'),
        initialValue: notifier.notes.isEmpty ? null : notifier.notes,
        decoration: const InputDecoration(
          labelText: 'Notes',
          hintText: 'Your personal notes about this book…',
          alignLabelWithHint: true,
        ),
        maxLines: 4,
        onChanged: notifier.setNotes,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  // ── Bottom Bar ──────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              key: const Key('cancel_button'),
              onPressed: notifier.isSaving ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              key: const Key('save_button'),
              onPressed: notifier.isSaving ? null : () => _handleSave(context, ref, notifier),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: notifier.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
  ) async {
    await notifier.saveBook();

    if (notifier.showingDuplicateDialog) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DuplicateDialog(
          notifier: notifier,
          ref: ref,
        ),
      );
      return;
    }

    if (notifier.saveError == null && !notifier.isSaving) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notifier.mode == BookFormMode.edit
                  ? "'${notifier.title}' updated."
                  : "'${notifier.title}' added to your library.",
            ),
          ),
        );
        context.go(kRouteCatalog);
      }
    } else if (notifier.saveError != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving book: ${notifier.saveError}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showEnrichmentSheet(
    BuildContext context,
    WidgetRef ref,
    BookFormNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EnrichmentSheet(
        notifier: notifier,
        ref: ref,
      ),
    );
  }
}

/// Section card with header and optional checkmark indicator.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.hasCheckmark = false,
  });

  final String title;
  final Widget child;
  final bool hasCheckmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.05,
                  ),
                ),
                if (hasCheckmark) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
