import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_rubric_template.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_form_submission.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_supervision_request.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_correction_item.dart';
import 'package:fyp_expo_hub/core/utils/fypms_key_normalizer.dart';

Map<String, dynamic> _n(Map<String, dynamic> row) => normalizeFypmsKeys(row);

void main() {
  group('FypRecord model', () {
    test('serializes and round-trips', () {
      final record = FypRecord(
        id: 'rec-1',
        academicSemesterId: 'sem-1',
        studentId: 'stu-1',
        currentCourseCode: 'CSP600',
        programmeCode: 'CS266',
        matricId: '2022123456',
        projectTitle: 'AI Health Assistant',
        workflowStatus: 'awaiting_supervisor_assignment',
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 1),
      );

      final json = record.toJson();
      final roundTrip = FypRecord.fromJson(json);

      expect(roundTrip.id, record.id);
      expect(roundTrip.currentCourseCode, 'CSP600');
      expect(roundTrip.workflowStatus, 'awaiting_supervisor_assignment');
    });

    test('handles nullable project fields', () {
      final record = FypRecord.fromJson(_n({
        'id': 'rec-2',
        'academic_semester_id': 'sem-1',
        'student_id': 'stu-1',
        'current_course_code': 'CSP650',
        'programme_code': 'CS266',
        'workflow_status': 'active',
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-01T00:00:00Z',
      }));

      expect(record.projectTitle, isNull);
      expect(record.matricId, isNull);
      expect(record.mainSupervisorId, isNull);
    });
  });

  group('FypRubricTemplate model', () {
    test('serializes and round-trips', () {
      final template = FypRubricTemplate.fromJson(_n({
        'id': 'rubric-1',
        'semester_id': 'sem-1',
        'rubric_code': 'PROPOSAL_SUPERVISOR',
        'rubric_name': 'Proposal Evaluation by Supervisor',
        'form_code': 'F7',
        'criteria': [
          {'name': 'Problem Statement', 'max_score': 20},
        ],
        'version': 1,
        'is_active': true,
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-01T00:00:00Z',
      }));

      expect(template.rubricCode, 'PROPOSAL_SUPERVISOR');
      expect(template.formCode, 'F7');
      expect(template.criteria, isA<List>());
      expect(template.isActive, isTrue);
    });
  });

  group('FypFormSubmission model', () {
    test('serializes and round-trips', () {
      final submission = FypFormSubmission.fromJson(_n({
        'id': 'sub-1',
        'fyp_record_id': 'rec-1',
        'form_code': 'F2',
        'form_version': 1,
        'payload': <String, dynamic>{},
        'status': 'submitted',
        'submitted_by': 'stu-1',
        'submitted_at': '2026-08-05T10:00:00Z',
        'created_at': '2026-08-05T10:00:00Z',
        'updated_at': '2026-08-05T10:00:00Z',
      }));

      expect(submission.formCode, 'F2');
      expect(submission.status, 'submitted');
      expect(submission.formVersion, 1);
    });
  });

  group('FypSupervisionRequest model', () {
    test('serializes and round-trips', () {
      final request = FypSupervisionRequest.fromJson(_n({
        'id': 'req-1',
        'fyp_record_id': 'rec-1',
        'preferred_supervisor_id': 'lec-1',
        'status': 'pending',
        'created_at': '2026-08-06T09:00:00Z',
        'updated_at': '2026-08-06T09:00:00Z',
      }));

      expect(request.preferredSupervisorId, 'lec-1');
      expect(request.status, 'pending');
    });
  });

  group('FypCorrectionItem model', () {
    test('serializes and round-trips', () {
      final item = FypCorrectionItem.fromJson(_n({
        'id': 'corr-1',
        'fyp_record_id': 'rec-1',
        'created_by': 'lec-1',
        'description': 'Fix chapter 2 citations',
        'severity': 'minor',
        'status': 'open',
        'created_at': '2026-08-07T10:00:00Z',
        'updated_at': '2026-08-07T10:00:00Z',
      }));

      expect(item.createdBy, 'lec-1');
      expect(item.status, 'open');
    });
  });

  group('normalizeFypmsKeys', () {
    test('maps snake_case FYPMS keys to camelCase', () {
      final normalized = normalizeFypmsKeys({
        'academic_semester_id': 'sem-1',
        'current_course_code': 'CSP600',
        'project_title': 'Test',
        'workflow_status': 'active',
        'is_active': true,
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-01T00:00:00Z',
        'max_students': 40,
      });

      expect(normalized['academicSemesterId'], 'sem-1');
      expect(normalized['currentCourseCode'], 'CSP600');
      expect(normalized['projectTitle'], 'Test');
      expect(normalized['workflowStatus'], 'active');
      expect(normalized['isActive'], true);
      expect(normalized['createdAt'], isNotNull);
      expect(normalized['maxStudents'], 40);
    });

    test('leaves already-camelCase keys unchanged', () {
      final normalized = normalizeFypmsKeys({
        'projectTitle': 'Test',
        'maxStudents': 10,
      });

      expect(normalized['projectTitle'], 'Test');
      expect(normalized['maxStudents'], 10);
    });
  });
}