import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/utils/fypms_format.dart';

/// Every FYPMS status shown to people has a friendly label: no snake_case,
/// no underscores, no lowercase raw codes.
void main() {
  /// The values allowed by the latest fyp_records_workflow_status_check.
  List<String> workflowStatusesFromSql() {
    final sql = File('supabase/migrations/20260927000010_record_standing_reopen_marks.sql').readAsStringSync();
    final check = RegExp(r'fyp_records_workflow_status_check check \(workflow_status in \(([^)]*)\)')
        .firstMatch(sql)!
        .group(1)!;
    return [for (final m in RegExp(r"'([a-z_]+)'").allMatches(check)) m.group(1)!];
  }

  void expectFriendly(String label, String status) {
    expect(label, isNot(contains('_')), reason: '$status -> $label');
    expect(label, isNot(status), reason: '$status should not be shown raw');
    expect(label[0], label[0].toUpperCase(), reason: '$status -> $label starts in capitals');
  }

  test('every workflow status in the database has a label', () {
    final statuses = workflowStatusesFromSql();
    expect(statuses, hasLength(19), reason: '17 states + withdrawn + incomplete');
    expect(kWorkflowStatusLabels.keys.toSet(), statuses.toSet());
    for (final s in statuses) {
      expectFriendly(workflowStatusLabel(s), s);
      expect(fypStatusLabel(s), workflowStatusLabel(s));
    }
  });

  test('supervision request statuses read the same as on the supervisor card', () {
    expect(supervisionRequestStatusLabel('pending'), 'Awaiting decision');
    expect(supervisionRequestStatusLabel('approved'), 'Accepted');
    expect(supervisionRequestStatusLabel('rejected'), 'Declined');
    expect(supervisionRequestStatusLabel('withdrawn'), 'Withdrawn');
  });

  test('form statuses all have labels', () {
    const statuses = ['draft', 'submitted', 'under_review', 'approved', 'rejected', 'resubmission_required'];
    expect(kFormStatusLabels.keys.toSet(), statuses.toSet());
    for (final s in statuses) {
      expectFriendly(formStatusLabel(s), s);
    }
    expect(formStatusLabel('resubmission_required'), 'Resubmission required');
  });

  test('correction, milestone and progress log statuses have labels', () {
    for (final s in [
      ...kCorrectionStatusLabels.keys,
      ...kMilestoneStatusLabels.keys,
      ...kProgressLogStatusLabels.keys,
    ]) {
      expectFriendly(fypStatusLabel(s), s);
    }
    expect(progressLogStatusLabel('validated'), 'Validated');
  });

  test('unknown values fall back to sentence case without underscores', () {
    expect(fypStatusLabel('ready_to_publish'), 'Ready to publish');
    expect(workflowStatusLabel('some_new_state'), 'Some new state');
    expect(fypStatusLabel(''), '');
  });
}
