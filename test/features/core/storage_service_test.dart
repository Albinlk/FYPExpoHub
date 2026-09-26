import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_storage_service.dart';

/// Student report / deliverable uploads. The object path is what the
/// storage RLS policies key on (record id in segment 2) and what
/// submissions reference, so its shape is pinned here.
void main() {
  late List<http.BaseRequest> requests;
  var status = 200;

  SupabaseStorageService service() => SupabaseStorageService(SupabaseClient(
        'https://placeholder-project.supabase.co',
        'placeholder-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.method == 'DELETE') {
            return http.Response('[]', 200, headers: {'content-type': 'application/json'});
          }
          return status == 200
              ? http.Response('{"Key":"ok"}', 200, headers: {'content-type': 'application/json'})
              : http.Response('{"statusCode":"403","error":"Unauthorized","message":"new row violates row-level security policy"}',
                  403, headers: {'content-type': 'application/json'});
        }),
      ));

  setUp(() {
    requests = [];
    status = 200;
  });

  test('uploads to {semester}/{record}/{type}/{version}/{file}', () async {
    final path = await service().uploadFile(
      bucket: 'fyp-final-reports',
      semesterCode: '2026-1',
      fypRecordId: 'rec-123',
      resourceType: 'final_report',
      version: 2,
      fileName: 'report.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
      contentType: 'application/pdf',
    );

    expect(path, '2026-1/rec-123/final_report/2/report.pdf');
    final upload = requests.single;
    expect(upload.method, 'POST');
    expect(upload.url.path,
        '/storage/v1/object/fyp-final-reports/2026-1/rec-123/final_report/2/report.pdf');
    // The record id sits in path segment 2 — can_write_fyp_storage_path()
    // relies on exactly that position.
    expect(path.split('/')[1], 'rec-123');
  });

  test('a storage-policy rejection is rethrown to the caller', () async {
    status = 403;
    await expectLater(
      service().uploadFile(
        bucket: 'fyp-final-reports',
        semesterCode: '2026-1',
        fypRecordId: 'someone-elses-record',
        resourceType: 'final_report',
        version: 1,
        fileName: 'x.pdf',
        bytes: Uint8List(0),
      ),
      throwsA(isA<StorageException>()),
    );
  });

  test('removeFile deletes that one object', () async {
    await service().removeFile(bucket: 'fyp-deliverables', path: '2026-1/rec-1/demo/1/a.zip');
    final req = requests.single;
    expect(req.method, 'DELETE');
    expect(req.url.path, '/storage/v1/object/fyp-deliverables');
  });
}
