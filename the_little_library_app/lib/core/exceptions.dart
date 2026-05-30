/// Shared exception types for the application.
library;

/// Thrown when the device has no internet connectivity or a network
/// operation fails due to lack of connection.
class OfflineException implements Exception {
  const OfflineException([this.message = 'No internet connection']);

  final String message;

  @override
  String toString() => 'OfflineException: $message';
}
