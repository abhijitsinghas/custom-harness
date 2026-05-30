import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Client for Google Drive API operations used by the sync engine.
///
/// Wraps Google Drive REST API v3 calls. All methods are virtual so they
/// can be overridden in mocks for testing.
///
/// Folder structure on Drive:
///   `/The Little Library/`
///     catalog.db
///     change_log.db
///     version.txt
///     covers/
///       `cover-uuid`.jpg
class GoogleDriveClient {
  /// Creates a [GoogleDriveClient].
  ///
  /// [httpClient] is the authenticated HTTP client (with OAuth bearer token).
  /// [rootFolderName] defaults to "The Little Library".
  /// [knownFolderId] is the cached Drive folder ID, if already known.
  /// [maxRetries] is the maximum number of retry attempts for transient
  /// failures (default: 3 with exponential backoff).
  GoogleDriveClient({
    required this.httpClient,
    this.rootFolderName = 'The Little Library',
    this.knownFolderId,
    this.maxRetries = 3,
  });

  /// The authenticated HTTP client for Drive API calls.
  final http.Client httpClient;

  /// Maximum number of retry attempts for transient network failures.
  final int maxRetries;

  /// Name of the root folder on Drive.
  final String rootFolderName;

  /// Cached folder ID, if previously resolved.
  String? knownFolderId;

  /// Base URL for Google Drive API v3.
  static const _baseUrl = 'https://www.googleapis.com/drive/v3';
  static const _uploadUrl = 'https://www.googleapis.com/upload/drive/v3';

  // ═══════════════════════════════════════════════════════════════════════════
  // Folder operations
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ensures the root folder exists on Drive, creating it if necessary.
  /// Returns the folder ID.
  Future<String> ensureFolder() async {
    // Check if we already know the folder ID.
    if (knownFolderId != null && await _folderExists(knownFolderId!)) {
      return knownFolderId!;
    }

    // Search for existing folder by name.
    final existingId = await findFolder(rootFolderName);
    if (existingId != null) {
      knownFolderId = existingId;
      return existingId;
    }

    // Create a new folder.
    final newId = await createFolder(rootFolderName);
    knownFolderId = newId;
    return newId;
  }

  /// Check if the root folder exists on Drive.
  Future<bool> checkFolderExists() async {
    if (knownFolderId != null && await _folderExists(knownFolderId!)) {
      return true;
    }
    final found = await findFolder(rootFolderName);
    if (found != null) {
      knownFolderId = found;
      return true;
    }
    return false;
  }

  /// Find a folder by name and return its ID, or `null` if not found.
  Future<String?> findFolder(String name) async {
    final query =
        "name='$name' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    final uri = Uri.parse(
      '$_baseUrl/files?q=${Uri.encodeQueryComponent(query)}&fields=files(id,name)',
    );

    final response = await httpClient.get(uri);
    _checkResponse(response, [200]);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? [];
    if (files.isNotEmpty) {
      final folderId = files.first['id'] as String;
      knownFolderId = folderId;
      return folderId;
    }
    return null;
  }

  /// Create a new folder on Drive and return its ID.
  Future<String> createFolder(String name) async {
    final metadata = {
      'name': name,
      'mimeType': 'application/vnd.google-apps.folder',
    };

    final uri = Uri.parse('$_baseUrl/files?fields=id');
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(metadata),
    );
    _checkResponse(response, [200]);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final folderId = data['id'] as String;
    knownFolderId = folderId;
    return folderId;
  }

  /// Check if a folder with the given [folderId] exists.
  Future<bool> _folderExists(String folderId) async {
    try {
      return _withRetry(() async {
        final uri = Uri.parse('$_baseUrl/files/$folderId?fields=id');
        final response = await httpClient.get(uri);
        return response.statusCode == 200;
      });
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // File operations
  // ═══════════════════════════════════════════════════════════════════════════

  /// Upload a file to the root folder on Drive.
  ///
  /// [remotePath] is the file name (e.g. "catalog.db", "covers/abc.jpg").
  /// [bytes] is the file content.
  /// Returns the Drive file ID.
  Future<String> uploadFile(String remotePath, List<int> bytes) async {
    final folderId = knownFolderId ?? await ensureFolder();

    // Determine MIME type based on extension.
    final mimeType = _mimeTypeForPath(remotePath);

    // For multipart upload: metadata + content.
    final boundary =
        'sync_upload_boundary_${DateTime.now().millisecondsSinceEpoch}';
    final body =
        _buildMultipartUpload(remotePath, mimeType, folderId, bytes, boundary);

    final uri = Uri.parse('$_uploadUrl/files?uploadType=multipart&fields=id');
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'multipart/related; boundary=$boundary',
      },
      body: body,
    );
    _checkResponse(response, [200]);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['id'] as String;
  }

  /// Download a file from Drive by [fileId].
  /// Returns the file bytes, or `null` if not found.
  Future<List<int>?> downloadFile(String fileId) async {
    try {
      final uri = Uri.parse('$_baseUrl/files/$fileId?alt=media');
      final response = await httpClient.get(uri);
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      if (response.statusCode == 404) {
        return null;
      }
      _checkResponse(response, [200]);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Find a file by name within the root folder.
  /// Returns the file ID, or `null` if not found.
  Future<String?> findFile(String fileName, {String? parentFolderId}) async {
    final folderId = parentFolderId ?? knownFolderId ?? await ensureFolder();
    final query =
        "name='$fileName' and '$folderId' in parents and trashed=false";
    final uri = Uri.parse(
      '$_baseUrl/files?q=${Uri.encodeQueryComponent(query)}&fields=files(id,name)',
    );

    final response = await httpClient.get(uri);
    _checkResponse(response, [200]);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? [];
    if (files.isNotEmpty) {
      return files.first['id'] as String;
    }
    return null;
  }

  /// Read the version.txt file from Drive.
  /// Returns the version string (integer), or `null` if not found.
  Future<String?> readVersionFile() async {
    final fileId = await findFile('version.txt');
    if (fileId == null) return null;

    final bytes = await downloadFile(fileId);
    if (bytes == null) return null;

    return utf8.decode(bytes).trim();
  }

  /// Write (overwrite) the version.txt file on Drive.
  /// If the file doesn't exist, it will be created.
  Future<String> writeVersionFile(String version) async {
    final folderId = knownFolderId ?? await ensureFolder();
    final existingId = await findFile('version.txt');

    final bytes = utf8.encode(version);

    if (existingId != null) {
      // Update existing file.
      final uri = Uri.parse('$_uploadUrl/files/$existingId?uploadType=media');
      final response = await httpClient.patch(
        uri,
        headers: {'Content-Type': 'text/plain'},
        body: bytes,
      );
      _checkResponse(response, [200]);
      return existingId;
    } else {
      // Create new file.
      final boundary =
          'sync_upload_boundary_${DateTime.now().millisecondsSinceEpoch}';
      final body = _buildMultipartUpload(
        'version.txt',
        'text/plain',
        folderId,
        bytes,
        boundary,
      );

      final uri = Uri.parse('$_uploadUrl/files?uploadType=multipart&fields=id');
      final response = await httpClient.post(
        uri,
        headers: {
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: body,
      );
      _checkResponse(response, [200]);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['id'] as String;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Permissions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Set sharing permissions on a file for the given email addresses.
  Future<void> managePermissions(String fileId, List<String> emails) async {
    for (final email in emails) {
      final permission = {
        'type': 'user',
        'role': 'writer',
        'emailAddress': email,
      };

      final uri = Uri.parse(
        '$_baseUrl/files/$fileId/permissions?sendNotificationEmail=false',
      );
      final response = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(permission),
      );
      // Don't throw on permission errors — continue with next email.
      if (response.statusCode != 200) {
        // Log the error but continue.
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build a multipart upload body with metadata and content.
  static List<int> _buildMultipartUpload(
    String fileName,
    String mimeType,
    String folderId,
    List<int> content,
    String boundary,
  ) {
    final metadata = jsonEncode({
      'name': fileName,
      'parents': [folderId],
    });

    final parts = [
      '--$boundary',
      'Content-Type: application/json; charset=UTF-8',
      '',
      metadata,
      '--$boundary',
      'Content-Type: $mimeType',
      'Content-Transfer-Encoding: base64',
      '',
      base64Encode(content),
      '--$boundary--',
    ];

    return utf8.encode(parts.join('\r\n'));
  }

  /// Determine MIME type from a file path extension.
  static String _mimeTypeForPath(String path) {
    if (path.endsWith('.db')) return 'application/vnd.sqlite3';
    if (path.endsWith('.txt')) return 'text/plain';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    return 'application/octet-stream';
  }

  /// Validate an HTTP response, throwing on unexpected status codes.
  void _checkResponse(http.Response response, List<int> expectedCodes) {
    if (!expectedCodes.contains(response.statusCode)) {
      final message = _errorMessage(response);
      throw GoogleDriveException(
        statusCode: response.statusCode,
        message: message,
      );
    }
  }

  /// Extract a human-readable error message from a Drive API error response.
  String _errorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      if (error != null) {
        final message = error['message'] as String?;
        if (message != null) return message;

        // Check for specific error reasons.
        final errors = error['errors'] as List<dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final reason =
              (errors.first as Map<String, dynamic>)['reason'] as String?;
          if (reason == 'storageQuotaExceeded') return 'Drive storage full';
          if (reason == 'authError') return 'Authentication expired';
          if (reason == 'notFound') return 'File or folder not found';
        }
      }
    } catch (_) {}
    return 'Drive API error (status ${response.statusCode})';
  }

  /// Executes [operation] with exponential backoff retry for transient
  /// failures (US-1.3.16). Retries up to [maxRetries] times with delays
  /// of 1s, 2s, 4s, etc.
  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    var attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries || !_isTransientError(e)) {
          rethrow;
        }
        // Exponential backoff: 1s, 2s, 4s, ...
        final delay =
            Duration(milliseconds: (pow(2, attempt - 1) * 1000).toInt());
        await Future<void>.delayed(delay);
      }
    }
  }

  /// Returns true if [error] represents a transient failure worth retrying.
  bool _isTransientError(Object error) {
    if (error is http.ClientException) return true;
    if (error is TimeoutException) return true;
    if (error is GoogleDriveException) {
      // Retry on server errors (5xx) and rate limits (429).
      return error.statusCode >= 500 || error.statusCode == 429;
    }
    return false;
  }
}

/// Exception thrown by [GoogleDriveClient] on API errors.
class GoogleDriveException implements Exception {
  const GoogleDriveException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'GoogleDriveException($statusCode): $message';
}
