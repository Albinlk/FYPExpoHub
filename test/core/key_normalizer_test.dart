import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record_assignment.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_rubric_template.dart';
import 'package:fyp_expo_hub/core/supabase/row_mappers.dart';
import 'package:fyp_expo_hub/core/utils/fypms_key_normalizer.dart';

/// Columns whose snake_case name had no camelCase mapping, so the model
/// field was silently left at its default.
void main() {
  test('rubric evaluator shares survive the row mapping', () {
    final rubric = FypRubricTemplate.fromJson(normalizeFypmsKeys({
      'id': 'r1',
      'rubric_code': 'F9',
      'rubric_name': 'Progress presentation',
      'form_code': 'F9',
      'criteria': <dynamic>[],
      'version': 2,
      'is_active': true,
      'evaluator_shares': {'supervisor': 60, 'examiner': 40},
      'created_at': '2026-10-01T00:00:00Z',
      'updated_at': '2026-10-01T00:00:00Z',
    }));
    expect(rubric.evaluatorShares, {'supervisor': 60, 'examiner': 40});
  });

  test('an assignment keeps who made it', () {
    final a = FypRecordAssignment.fromJson(normalizeFypmsKeys({
      'id': 'a1',
      'fyp_record_id': 'rec1',
      'academic_role': 'examiner',
      'lecturer_id': 'lect1',
      'is_active': true,
      'assigned_by': 'coord1',
      'assigned_at': '2026-10-01T00:00:00Z',
      'created_at': '2026-10-01T00:00:00Z',
      'updated_at': '2026-10-01T00:00:00Z',
    }));
    expect(a.assignedBy, 'coord1');
  });

  test('feedback keeps its user agent', () {
    final f = feedbackFromRow({
      'id': 'f1',
      'event_id': 'e1',
      'subject': 'Hi',
      'message': 'Nice',
      'status': 'new',
      'user_agent': 'Mozilla/5.0',
      'created_at': '2026-10-01T00:00:00Z',
    });
    expect(f.userAgent, 'Mozilla/5.0');
  });
}
