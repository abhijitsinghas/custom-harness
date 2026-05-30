import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:thelittlelibrary/data/sync/google_drive_client.dart';

/// Tests for GoogleDriveClient — foundational methods for sync engine.
///
/// Uses a manual mock HTTP client to simulate Google Drive API responses.

/// Manual mock HTTP client for testing.
class _MockHttpClient extends http.BaseClient {
  final Map<String, _StubResponse> _stubs = {};
  final List<_RequestLog> requests = [];

  void stubGet(String urlContains, {int statusCode = 200, String body = '{}', List<int>? bodyBytes}) {
    _stubs['GET:$urlContains'] = _StubResponse(statusCode: statusCode, body: body, bodyBytes: bodyBytes);
  }

  void stubPost(String urlContains, {int statusCode = 200, String body = '{}'}) {
    _stubs['POST:$urlContains'] = _StubResponse(statusCode: statusCode, body: body);
  }

  void stubPatch(String urlContains, {int statusCode = 200, String body = '{}'}) {
    _stubs['PATCH:$urlContains'] = _StubResponse(statusCode: statusCode, body: body);
  }

  void stubThrow(String urlContains, Exception exception) {
    _stubs['THROW:$urlContains'] = _StubResponse(exception: exception);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(_RequestLog(request.method, request.url.toString()));

    final key = '${request.method}:${request.url.toString()}';

    // Check for throw stub (contains matching).
    for (final entry in _stubs.entries) {
      if (entry.key.startsWith('THROW:') &&
          request.url.toString().contains(entry.key.substring(6))) {
        throw entry.value.exception!;
      }
    }

    // Find matching stub.
    _StubResponse? stub;
    for (final entry in _stubs.entries) {
      if (key.contains(entry.key.split(':').last)) {
        stub = entry.value;
        break;
      }
    }

    if (stub == null) {
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"files": []}')),
        200,
      );
    }

    return http.StreamedResponse(
      Stream.value(stub.bodyBytes ?? utf8.encode(stub.body ?? '{}')),
      stub.statusCode,
    );
  }
}

class _StubResponse {
  final int statusCode;
  final String? body;
  final List<int>? bodyBytes;
  final Exception? exception;

  _StubResponse({this.statusCode = 200, this.body, this.bodyBytes, this.exception});
}

class _RequestLog {
  final String method;
  final String url;
  _RequestLog(this.method, this.url);
}

void main() {
  late _MockHttpClient mockClient;
  late GoogleDriveClient driveClient;

  setUp(() {
    mockClient = _MockHttpClient();
    driveClient = GoogleDriveClient(
      httpClient: mockClient,
      rootFolderName: 'The Little Library',
    );
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Folder operations
  // ═══════════════════════════════════════════════════════════════════════════
  group('GoogleDriveClient — folder operations', () {
    test('should find or create "/The Little Library/" folder on Drive', () async {
      // Stub folder listing: empty (not found).
      mockClient.stubGet('files?q=', body: '{"files": []}');
      // Then stub folder creation.
      mockClient.stubPost('files?fields=id', body: '{"id": "folder-123"}');

      final folderId = await driveClient.ensureFolder();

      expect(folderId, 'folder-123');
      expect(driveClient.knownFolderId, 'folder-123');
    });

    test('should return folder ID for existing "The Little Library" folder', () async {
      mockClient.stubGet(
        'files?q=',
        body: '{"files": [{"id": "existing-folder-456", "name": "The Little Library"}]}',
      );

      final folderId = await driveClient.findFolder('The Little Library');

      expect(folderId, 'existing-folder-456');
      expect(driveClient.knownFolderId, 'existing-folder-456');
    });

    test('should create folder when it does not exist (first-device setup)', () async {
      // Folder not found.
      mockClient.stubGet('files?q=', body: '{"files": []}');
      // Create folder.
      mockClient.stubPost('files?fields=id', body: '{"id": "new-folder-789"}');

      final folderId = await driveClient.createFolder('The Little Library');

      expect(folderId, 'new-folder-789');
      expect(driveClient.knownFolderId, 'new-folder-789');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // File operations
  // ═══════════════════════════════════════════════════════════════════════════
  group('GoogleDriveClient — file operations', () {
    setUp(() {
      driveClient.knownFolderId = 'folder-abc';
    });

    test('should upload catalog.db to Drive folder', () async {
      mockClient.stubPost('uploadType=multipart', body: '{"id": "file-catalog-001"}');

      final fileId = await driveClient.uploadFile('catalog.db', [1, 2, 3]);

      expect(fileId, 'file-catalog-001');
    });

    test('should upload change_log.db to Drive folder', () async {
      mockClient.stubPost('uploadType=multipart', body: '{"id": "file-changelog-001"}');

      final fileId = await driveClient.uploadFile('change_log.db', []);

      expect(fileId, 'file-changelog-001');
    });

    test('should upload cover images to covers/ subfolder', () async {
      mockClient.stubPost('uploadType=multipart', body: '{"id": "file-cover-001"}');

      final fileId = await driveClient.uploadFile('covers/abc.jpg', [1, 2, 3]);

      expect(fileId, 'file-cover-001');
    });

    test('should download a file from Drive', () async {
      final fileBytes = [10, 20, 30];
      mockClient.stubGet('alt=media', bodyBytes: fileBytes, body: '');

      final result = await driveClient.downloadFile('file-to-download');

      expect(result, fileBytes);
    });

    test('should read version.txt to get current version', () async {
      // Stub file listing to find version.txt.
      // The mock stub matching is by URL contains, so we need to differentiate.
      mockClient.stubGet(
        'files?q=',
        body: '{"files": [{"id": "version-file-id", "name": "version.txt"}]}',
      );
      // The downloadFile method will then GET with alt=media.
      // But our mock returns 200 for unmatched stubs. Let's add a specific stub.
      // Actually, findFile returns the ID, then downloadFile uses the ID directly.
      // downloadFile URL: files/{fileId}?alt=media
      // Our default stub returns '{"files": []}' which is not valid for download.
      // Let me add a stub for the download URL.
      mockClient.stubGet('version-file-id?alt=media', bodyBytes: utf8.encode('42'), body: '');

      final version = await driveClient.readVersionFile();

      expect(version, '42');
    });

    test('should overwrite version.txt with new version', () async {
      // Find existing version.txt.
      mockClient.stubGet(
        'files?q=',
        body: '{"files": [{"id": "version-file-existing", "name": "version.txt"}]}',
      );
      // Patch to update.
      mockClient.stubPatch('uploadType=media', body: '{"id": "version-file-existing"}');

      final fileId = await driveClient.writeVersionFile('5');

      expect(fileId, 'version-file-existing');
    });

    test('should set file permissions for sharing', () async {
      mockClient.stubPost('permissions', body: '{}');

      // Should not throw.
      await driveClient.managePermissions('file-123', ['user@example.com']);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Error handling
  // ═══════════════════════════════════════════════════════════════════════════
  group('GoogleDriveClient — error handling', () {
    test('should handle 404 when folder not found', () async {
      // First the findFolder returns 404.
      mockClient.stubGet(
        'files?q=',
        statusCode: 404,
        body: '{"error": {"message": "File not found", "errors": [{"reason": "notFound"}]}}',
      );

      // The ensureFolder calls findFolder first, which will throw on 404.
      expect(
        () => driveClient.ensureFolder(),
        throwsA(isA<GoogleDriveException>()),
      );
    });

    test('should handle storage quota exceeded error', () async {
      // Folder not found.
      mockClient.stubGet('files?q=', body: '{"files": []}');
      // Create folder fails with quota.
      mockClient.stubPost(
        'files?fields=id',
        statusCode: 403,
        body: '{"error": {"message": "Storage quota exceeded", "errors": [{"reason": "storageQuotaExceeded"}]}}',
      );

      expect(
        () => driveClient.ensureFolder(),
        throwsA(isA<GoogleDriveException>()),
      );
    });

    test('should handle 401 unauthorized (expired token)', () async {
      mockClient.stubGet(
        'files?q=',
        statusCode: 401,
        body: '{"error": {"message": "Invalid Credentials", "errors": [{"reason": "authError"}]}}',
      );

      expect(
        () => driveClient.findFolder('test'),
        throwsA(
          predicate<GoogleDriveException>((e) => e.statusCode == 401),
        ),
      );
    });

    test('should handle network timeout during upload/download', () async {
      // Set known folder ID to avoid ensureFolder call.
      driveClient.knownFolderId = 'folder-abc';
      // Then make the upload throw a network error.
      mockClient.stubThrow('uploadType=multipart', Exception('Connection timed out'));

      expect(
        () => driveClient.uploadFile('test.db', []),
        throwsA(isA<Exception>()),
      );
    });
  });
}
