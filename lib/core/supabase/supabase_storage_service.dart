import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Storage helpers for FYPMS resource uploads.
///
/// Path convention: {semester_code}/{fyp_record_id}/{resource_type}/{version}/{file_name}
class SupabaseStorageService {
  final SupabaseClient _client;

  SupabaseStorageService(this._client);

  /// Uploads a file to a FYPMS bucket.
  /// Returns the object key (path) on success.
  Future<String> uploadFile({
    required String bucket,
    required String semesterCode,
    required String fypRecordId,
    required String resourceType,
    required int version,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      final path =
          '$semesterCode/$fypRecordId/$resourceType/$version/$fileName';
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      return path;
    } catch (e) {
      logDebug('Supabase storage uploadFile error: $e');
      rethrow;
    }
  }

  /// Creates a signed URL for private FYPMS resources.
  Future<String?> createSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) async {
    try {
      final url = await _client.storage
          .from(bucket)
          .createSignedUrl(path, expiresInSeconds);
      return url;
    } catch (e) {
      logDebug('Supabase storage createSignedUrl error: $e');
      return null;
    }
  }

  /// Creates a public URL for fyp-public-assets.
  String publicUrl({required String bucket, required String path}) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Removes an object.
  Future<void> removeFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      logDebug('Supabase storage removeFile error: $e');
      rethrow;
    }
  }
}