/// Custom exceptions for DAO operations.
library;

/// Thrown when an operation attempts to modify/delete a built-in entity
/// that is protected from modification.
class BuiltInEntityException implements Exception {
  BuiltInEntityException(this.message);
  final String message;

  @override
  String toString() => 'BuiltInEntityException: $message';
}

/// Thrown when attempting to delete an entity still referenced by other
/// entities (e.g., an author linked to books).
class ReferencedEntityException implements Exception {
  ReferencedEntityException(this.message);
  final String message;

  @override
  String toString() => 'ReferencedEntityException: $message';
}
