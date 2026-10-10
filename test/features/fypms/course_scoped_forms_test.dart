import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms/records_providers.dart';
import 'package:fyp_expo_hub/core/state/fypms/roles_providers.dart';

/// Portal plan P1: CSP600 and CSP650 each see only their own forms (FSKM
/// handbook, 4th ed.), and the client list matches the server's.
void main() {
  test('CSP600 students see only Project Formulation forms', () {
    final codes = fypmsFormCodesFor(applicationsOpen: true, qualified: true, courseCode: 'CSP600');
    expect(codes, containsAll(['F2', 'F3', 'F4', 'F6a', 'F7', 'F8']));
    for (final code in ['F9', 'F10', 'F11', 'F13', 'F14', 'F15', 'F16']) {
      expect(codes, isNot(contains(code)), reason: '$code is a CSP650 form');
    }
  });

  test('CSP650 students see only Project forms', () {
    final codes = fypmsFormCodesFor(applicationsOpen: true, qualified: true, courseCode: 'CSP650');
    expect(codes, containsAll(['F9', 'F10', 'F11', 'F13', 'F14', 'F15', 'F16']));
    for (final code in ['F2', 'F3', 'F4', 'F6a', 'F7', 'F8']) {
      expect(codes, isNot(contains(code)), reason: '$code is a CSP600 form');
    }
  });

  test('without a course nothing is filtered (old behaviour)', () {
    expect(
      fypmsFormCodesFor(applicationsOpen: false, qualified: false),
      fypmsFormCodesFor(applicationsOpen: false, qualified: false, courseCode: null),
    );
    expect(fypmsFormFitsCourse('F5', 'CSP600'), isTrue, reason: 'consultation log is in both');
    expect(fypmsFormFitsCourse('F5', 'CSP650'), isTrue);
  });

  test('client map matches public.fyp_form_course in the migration', () {
    final sql = File('supabase/migrations/20261010000001_course_scoped_forms.sql').readAsStringSync();
    Set<String> sqlCodes(String course) {
      final m = RegExp("when p_form_code in \\(([^)]*)\\) then '$course'").firstMatch(sql)!;
      return {for (final q in RegExp(r"'([^']+)'").allMatches(m.group(1)!)) q.group(1)!};
    }

    expect(sqlCodes('CSP600'), fypmsCourseForms['CSP600']);
    expect(sqlCodes('CSP650'), fypmsCourseForms['CSP650']);
  });

  group('CSP lecturer workspace', () {
    FypRecord rec(String id, String course) => FypRecord(
          id: id,
          academicSemesterId: 'sem-1',
          studentId: 's-$id',
          currentCourseCode: course,
          programmeCode: 'CS266',
          workflowStatus: 'project_registered',
          createdAt: DateTime(2026, 8, 1),
          updatedAt: DateTime(2026, 8, 1),
        );

    Future<List<String>> idsFor(List<String> roles) async {
      final container = ProviderContainer(overrides: [
        fypmsCurrentRolesProvider.overrideWith((ref) async => roles),
        fypRecordsProvider.overrideWith((ref) async => [rec('a', 'CSP600'), rec('b', 'CSP650')]),
      ]);
      addTearDown(container.dispose);
      await container.read(fypmsCurrentRolesProvider.future);
      await container.read(fypRecordsProvider.future);
      return [for (final r in container.read(cspRecordsProvider).requireValue) r.id];
    }

    test('a CSP600 lecturer sees only CSP600 records', () async {
      expect(await idsFor(['csp600_lecturer']), ['a']);
    });

    test('a CSP650 lecturer sees only CSP650 records', () async {
      expect(await idsFor(['csp650_lecturer']), ['b']);
    });

    test('teaching both shows both', () async {
      expect(await idsFor(['csp600_lecturer', 'csp650_lecturer']), ['a', 'b']);
    });

    test('menu title names the course', () {
      expect(cspWorkspaceTitle({'CSP650'}), 'CSP650 Dashboard');
      expect(cspWorkspaceTitle({'CSP650', 'CSP600'}), 'CSP600 & CSP650 Dashboard');
      expect(cspWorkspaceTitle({}), 'CSP Dashboard');
    });
  });
}
