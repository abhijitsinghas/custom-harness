// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Little Library';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navAddBook => 'Add Book';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navLocations => 'Locations';

  @override
  String get navActiveLoans => 'Active Loans';

  @override
  String get navActivity => 'Activity';

  @override
  String get navDeletedBooks => 'Deleted Books';

  @override
  String get navSettings => 'Settings';

  @override
  String get navExport => 'Export';

  @override
  String get navShareLibrary => 'Share Library';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionClose => 'Close';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get syncStatusSynced => 'Synced just now';

  @override
  String syncStatusPending(int count) {
    return 'Offline — $count pending';
  }

  @override
  String get syncStatusError => 'Sync error — tap for details';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorOffline =>
      'You are offline. Changes will sync when connected.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get loadingLabel => 'Loading…';

  @override
  String get emptyStateLabel => 'Nothing here yet.';

  @override
  String get noResultsLabel => 'No results found.';
}
