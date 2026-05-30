/// Cascading location dropdowns (Room → Cupboard → Shelf).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add_book_provider.dart';

/// Cascading dropdowns for hierarchical location selection.
class LocationCascade extends StatelessWidget {
  const LocationCascade({
    super.key,
    required this.notifier,
    required this.ref,
  });

  final BookFormNotifier notifier;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Room dropdown
        Expanded(
          child: DropdownButtonFormField<String?>(
            key: const Key('room_dropdown'),
            value: notifier.selectedRoomId,
            decoration: const InputDecoration(
              labelText: 'Room',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('None'),
              ),
              ...notifier.rooms.map((room) => DropdownMenuItem<String?>(
                    value: room.id,
                    child: Text(room.name),
                  )),
            ],
            onChanged: notifier.setSelectedRoom,
          ),
        ),
        const SizedBox(width: 8),
        // Cupboard dropdown
        Expanded(
          child: DropdownButtonFormField<String?>(
            key: const Key('cupboard_dropdown'),
            value: notifier.selectedCupboardId,
            decoration: const InputDecoration(
              labelText: 'Cupboard',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('None'),
              ),
              ...notifier.cupboards.map((cupboard) => DropdownMenuItem<String?>(
                    value: cupboard.id,
                    child: Text(cupboard.name),
                  )),
            ],
            onChanged: notifier.setSelectedCupboard,
          ),
        ),
        const SizedBox(width: 8),
        // Shelf dropdown
        Expanded(
          child: DropdownButtonFormField<String?>(
            key: const Key('shelf_dropdown'),
            value: notifier.selectedShelfId,
            decoration: const InputDecoration(
              labelText: 'Shelf',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('None'),
              ),
              ...notifier.shelves.map((shelf) => DropdownMenuItem<String?>(
                    value: shelf.id,
                    child: Text(shelf.name),
                  )),
            ],
            onChanged: notifier.setSelectedShelf,
          ),
        ),
      ],
    );
  }
}
