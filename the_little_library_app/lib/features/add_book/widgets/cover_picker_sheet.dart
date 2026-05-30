/// Cover image picker bottom sheet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add_book_provider.dart';

/// Source options for cover image.
enum CoverSource { camera, gallery, online }

/// Bottom sheet for selecting cover image source.
class CoverPickerSheet extends StatelessWidget {
  const CoverPickerSheet({
    super.key,
    required this.notifier,
    required this.ref,
    required this.selectedSource,
  });

  final BookFormNotifier notifier;
  final WidgetRef ref;
  final CoverSource selectedSource;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Cover Source',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Take Photo
            ListTile(
              key: const Key('take_photo_option'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera would open here')),
                );
              },
            ),
            // Choose from Gallery
            ListTile(
              key: const Key('gallery_option'),
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image picker would open here')),
                );
              },
            ),
            // Search Online
            ListTile(
              key: const Key('search_online_option'),
              leading: const Icon(Icons.search),
              title: const Text('Search Online'),
              onTap: () {
                Navigator.of(context).pop();
                if (notifier.title.isNotEmpty) {
                  notifier.searchEnrichment(notifier.title);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a title first to search online'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
