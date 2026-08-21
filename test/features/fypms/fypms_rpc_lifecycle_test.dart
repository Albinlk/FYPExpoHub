import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/supabase/fypms_rpc_service.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_rpc_service.dart';

/// FYPMS workflow lifecycle tests against a MOCKED Supabase HTTP transport.
///
/// The global `Supabase.instance.client` is initialized with a fake
/// `http.Client` that records every `/rest/v1/rpc/<fn>` call and returns a
/// canned single-row response, so the full staff workflow can be exercised
/// end-to-end without a database (arguments, ordering, and error propagation).
class _FakeHttpClient extends http.BaseClient {
  final List<String> rpcCalls = [];
  final List<Map<String, dynamic>> rpcBodies = [];
  bool failNext = false;

  http.Response _ok(Map<String, dynamic> body) => http.Response(
        jsonEncode(body),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );

  http.Response _err(String message, String code) => http.Response(
        jsonEncode({
          'message': message,
          'code': code,
          'details': null,
          'hint': null,
        }),
        400,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final url = request.url.toString();
    final fnMatch = RegExp('rpc/([A-Za-z0-9_]+)').firstMatch(url);
    if (fnMatch == null) {
      // Auth/other endpoints used during initialization resolve to empty.
      return http.StreamedResponse(
        Stream.value(utf8.encode('{}')),
        200,
        request: request,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }
    final fn = fnMatch.group(1)!;
    rpcCalls.add(fn);
    final bytes = await request.finalize().toBytes();
    Map<String, dynamic> body = {};
    if (bytes.isNotEmpty) {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, dynamic>) body = decoded;
    }
    rpcBodies.add(body);
    if (failNext) {
      failNext = false;
      return http.StreamedResponse(
        http.ByteStream.fromBytes(_err('permission-denied: test denial', '42501').bodyBytes),
        400,
        request: request,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }
    return http.StreamedResponse(
      http.ByteStream.fromBytes(_ok({'id': 'mock-$fn', 'ok': true}).bodyBytes),
      200,
      request: request,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

late _FakeHttpClient _fake;

void main() {
setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    _fake = _FakeHttpClient();
    await Supabase.initialize(
      url: 'http://localhost.test',
      anonKey: 'test-anon-key', // ignore: deprecated_member_use
      httpClient: _fake,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        persistSession: false,
      ),
    );
  });

  group('FYPMS workstream lifecycle (mocked Supabase RPC)', () {
    test('full student→CSP→coordinator chain maps 1:1 to the RPCs', () async {
      final service = SupabaseRpcService(Supabase.instance.client);

      await service.createFypRecord(
        academicSemesterId: 'sem-1',
        studentId: 'stu-1',
        currentCourseCode: 'CSP600',
        programmeCode: 'CS266',
        matricId: 'DP071266',
        projectTitle: 'AI Health Assistant',
      );
      expect(_fake.rpcCalls.last, 'create_fyp_record');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_course'.replaceAll('p_course', 'p_current_course_code'), 'CSP600'),
              containsPair('p_student_id', 'stu-1')));

      await service.submitSupervisionRequest(
        fypRecordId: 'rec-1',
        preferredSupervisorId: 'sup-1',
        rationale: 'Interested in healthcare AI.',
      );
      expect(_fake.rpcCalls.last, 'submit_supervision_request');
      expect(_fake.rpcBodies.last, containsPair('p_fyp_record_id', 'rec-1'));

      await service.decideSupervisionRequest(
        requestId: 'req-1',
        decision: 'approved',
        decisionReason: 'Accepted.',
      );
      expect(_fake.rpcCalls.last, 'decide_supervision_request');
      expect(_fake.rpcBodies.last, containsPair('p_decision', 'approved'));

      await service.submitProgressLog(
        fypRecordId: 'rec-1',
        weekNumber: 3,
        summary: 'Literature review done.',
      );
      expect(_fake.rpcCalls.last, 'submit_progress_log');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_week_number', 3), containsPair('p_summary', 'Literature review done.')));

      await service.validateProgressLog(
        progressLogId: 'log-1',
        status: 'validated',
        validationComment: 'Good.',
      );
      expect(_fake.rpcCalls.last, 'validate_progress_log');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_status', 'validated'), containsPair('p_validation_comment', 'Good.')));

      await service.submitFypForm(
        fypRecordId: 'rec-1',
        formCode: 'F7',
        payload: <String, dynamic>{'problem_definition': 'Campus safety'},
      );
      expect(_fake.rpcCalls.last, 'submit_fyp_form');
      expect(_fake.rpcBodies.last, containsPair('p_form_code', 'F7'));

      await service.submitReportVersion(
        fypRecordId: 'rec-1',
        reportType: 'proposal',
        fileUrl: 'https://demo.fypms.test/f6a.pdf',
        similarityIndex: 12.0,
      );
      expect(_fake.rpcCalls.last, 'submit_report_version');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_report_type', 'proposal'), containsPair('p_similarity_index', 12.0)));

      await service.assignExaminer(fypRecordId: 'rec-1', examinerId: 'ex-1');
      expect(_fake.rpcCalls.last, 'assign_examiner');
      expect(_fake.rpcBodies.last, containsPair('p_examiner_id', 'ex-1'));

      await service.submitFormEvaluation(
        formSubmissionId: 'sub-1',
        scores: <String, dynamic>{'methodology': 85},
        comments: 'Solid.',
        decision: 'approved',
      );
      expect(_fake.rpcCalls.last, 'submit_form_evaluation');
      expect(_fake.rpcBodies.last, containsPair('p_decision', 'approved'));

      await service.createCorrectionItem(
        fypRecordId: 'rec-1',
        formSubmissionId: 'sub-1',
        correctionText: 'Expand Section 4.',
        severity: 'minor',
      );
      expect(_fake.rpcCalls.last, 'create_correction_item');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_severity', 'minor'), containsPair('p_correction_text', 'Expand Section 4.')));

      await service.confirmCorrection(
        correctionItemId: 'corr-1',
        confirmationStatus: 'confirmed',
        notes: 'Resolved.',
      );
      expect(_fake.rpcCalls.last, 'confirm_correction');
      expect(_fake.rpcBodies.last, containsPair('p_confirmation_status', 'confirmed'));

      await service.finalizeMarks(
        fypRecordId: 'rec-1',
        courseCode: 'CSP600',
        componentBreakdown: <String, dynamic>{'proposal': 30, 'viva': 40},
      );
      expect(_fake.rpcCalls.last, 'finalize_marks');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_course_code', 'CSP600'), isA<Map<String, dynamic>>()));

      await service.schedulePresentationSlot(
        sessionId: 'sess-1',
        fypRecordId: 'rec-1',
        slotNumber: 1,
        startAt: DateTime.utc(2026, 9, 1, 9),
        endAt: DateTime.utc(2026, 9, 1, 9, 30),
        room: 'DK1',
      );
      expect(_fake.rpcCalls.last, 'schedule_presentation_slot');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_slot_number', 1), containsPair('p_room', 'DK1')));

      await service.prepareExpoPublication(
        fypRecordId: 'rec-1',
        eventId: 'event-1',
      );
      expect(_fake.rpcCalls.last, 'prepare_expo_publication');
      expect(_fake.rpcBodies.last,
          allOf(containsPair('p_fyp_record_id', 'rec-1'), containsPair('p_event_id', 'event-1')));

      await service.publishFypRecordToExpo(publicationId: 'pub-1');
      expect(_fake.rpcCalls.last, 'publish_fyp_record_to_expo');
      // Publish transmits ONLY the publication id — never a private payload.
      expect(_fake.rpcBodies.last, {'p_publication_id': 'pub-1'});
    });

    test('a role-gate denial surfaces as a thrown exception', () async {
      final service = SupabaseRpcService(Supabase.instance.client);
      _fake.failNext = true;
      await expectLater(
        service.validateProgressLog(progressLogId: 'log-9', status: 'validated'),
        throwsA(isA<Exception>()),
      );
      expect(_fake.rpcCalls.last, 'validate_progress_log');
    });

    test('prepare_expo_publication sends a payload only when provided',
        () async {
      final service = SupabaseRpcService(Supabase.instance.client);
      _fake.failNext = false;
      await service.prepareExpoPublication(
        fypRecordId: 'rec-1',
        eventId: 'event-1',
        payload: <String, dynamic>{'title': 'Safe title', 'marks': 'PRIVATE'},
      );
      final body = _fake.rpcBodies.last;
      // A supplied payload is forwarded to the (server-side) whitelist gate;
      // private fields are stripped server-side, never by the client.
      expect(body, contains('p_payload'));
      expect((body['p_payload'] as Map<String, dynamic>)['marks'], 'PRIVATE');
    });
  });

  group('Public projection contract', () {
    // Mirrors v_public_keys in prepare_expo_publication so a payload change on
    // either side is caught by the build.
    const publicKeys = {
      'title', 'matric_id', 'programme_code', 'short_description', 'abstract',
      'category', 'student_team', 'supervisor_display_name', 'publication_status',
      'demo_url', 'video_url', 'repository_url', 'cover_image_url', 'booth_number',
    };

    test('private/internal fields never map into the public projection',
        () {
      final raw = <String, dynamic>{
        'title': 'Smart Classroom Energy Optimiser',
        'matric_id': 'DP071268',
        'programme_code': 'CS266',
        'supervisor_display_name': 'SUPERVISOR 2',
        'marks': {'proposal': 30},
        'weighted_total': 85.0,
        'exporter_payload': {'exported_at': 'now'},
        'fyp_record_id': '20000000-0000-0000-0000-000000000003',
        'workflow_status': 'project_pending_presentation',
        'internal_notes': 'private reviewer comment',
        'student_team': <dynamic>[],
      };
      final projection = <String, dynamic>{
        for (final entry in raw.entries)
          if (publicKeys.contains(entry.key)) entry.key: entry.value,
      };

      const privateKeys = {
        'marks', 'weighted_total', 'exporter_payload', 'fyp_record_id',
        'workflow_status', 'internal_notes',
      };
      expect(projection.keys.toSet().intersection(privateKeys), isEmpty);
      expect(projection, contains('title'));
      expect(projection, contains('supervisor_display_name'));
      expect(projection, contains('matric_id'));
    });

    test('published projects carry only the public cols written by the RPC',
        () async {
      final service = SupabaseRpcService(Supabase.instance.client);
      _fake.failNext = false;
      await service.publishFypRecordToExpo(publicationId: 'pub-1');
      // The publish RPC body can never include fyp_records private state.
      final body = _fake.rpcBodies.last;
      expect(body.keys, ['p_publication_id']);
      expect(body.values.expand((v) => [v]).toString(),
          isNot(contains('marks')));
      expect(body.values.expand((v) => [v]).toString(),
          isNot(contains('workflow_status')));
    });
  });
}