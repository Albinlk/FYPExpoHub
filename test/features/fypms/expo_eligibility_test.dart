import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/features/fypms/domain/expo_eligibility.dart';

FypRecord _rec(String id, String course, String semester) => FypRecord(
      id: id,
      academicSemesterId: semester,
      studentId: 's-$id',
      currentCourseCode: course,
      programmeCode: 'CS266',
      workflowStatus: 'project_registered',
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );

/// P5 / P6: the exhibition is CSP650's; publishing creates the booth-visit
/// assignments from FYPMS instead of name matching.
void main() {
  final records = [_rec('a', 'CSP600', 's26'), _rec('b', 'CSP650', 's26'), _rec('c', 'CSP650', 's25')];

  test('only CSP650 records can be exhibited', () {
    expect(exhibitableRecords(records).map((r) => r.id), ['b', 'c']);
  });

  test('an exhibition linked to a semester only offers that cohort', () {
    expect(exhibitableRecords(records, eventSemesterId: 's26').map((r) => r.id), ['b']);
  });

  test('the server enforces the same rule and creates visit assignments', () {
    final sql = File('supabase/migrations/20261010000003_exhibition_csp650_link.sql').readAsStringSync();
    expect(sql, contains('add column if not exists academic_semester_id'));
    expect(sql, contains("is distinct from 'CSP650'"));
    expect(sql, contains('insert into public.lecturer_assignments'));
    expect(sql, contains("a.pu_status = 'approved'"), reason: 'only approved staff get visit assignments');
  });
}
