import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_marks_summary.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/features/fypms/domain/res_export.dart';

FypRecord _record(String id, String matric, {String course = 'CSP650', String title = 'AI Health'}) => FypRecord(
      id: id,
      academicSemesterId: 'sem',
      studentId: 's-$id',
      currentCourseCode: course,
      programmeCode: 'CS266',
      matricId: matric,
      projectTitle: title,
      workflowStatus: 'project_ongoing',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

FypMarksSummary _marks(String record, {String course = 'CSP650', bool finalized = true, double total = 78.456, String? grade = 'A-'}) =>
    FypMarksSummary(
      id: 'm-$record-$course',
      fypRecordId: record,
      academicSemesterId: 'sem',
      courseCode: course,
      marks: const {},
      weightedTotal: total,
      grade: grade,
      isFinalized: finalized,
      finalizedAt: finalized ? DateTime.utc(2026, 9, 26, 17) : null, // 27 Sep in Malaysia
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );

void main() {
  test('R11 RES export: finalized, current-course rows only, sorted by matric', () {
    final rows = [
      (_record('b', '2026200002', title: '=HYPERLINK("x")'), [_marks('b')]),
      (_record('a', '2026100001'), [_marks('a'), _marks('a', course: 'CSP600', total: 60)]),
      (_record('c', '2026300003'), [_marks('c', finalized: false)]),
    ];
    expect(resExportCount(rows), 2);
    final lines = buildResExportCsv(rows).trim().split('\n');
    expect(lines.first, resExportHeader);
    expect(lines, hasLength(3), reason: 'unfinalized and past-course marks are not exported');
    expect(lines[1], '2026100001,CS266,CSP650,AI Health,78.46,A-,2026-09-27');
    expect(lines[2], startsWith('2026200002,'));
    expect(lines[2], contains("\"'=HYPERLINK(\"\"x\"\")\""), reason: 'formula-looking titles are neutralised');
  });
}
