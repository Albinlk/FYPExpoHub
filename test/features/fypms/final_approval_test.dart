import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_correction_item.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/fyp_record.dart';
import 'package:fyp_expo_hub/core/state/fypms/user_scope.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/supervisor_corrections_page.dart';

/// P12: after F12 the supervisor approves the final report (handbook Table
/// 2.1 #50).
FypRecord _rec({DateTime? approvedAt}) => FypRecord(
      mainSupervisorId: 'sup-main',
      coSupervisorId: 'sup-co',
      id: 'rec-1',
      academicSemesterId: 's26',
      studentId: 'stu-1',
      currentCourseCode: 'CSP650',
      programmeCode: 'CS266',
      projectTitle: 'Smart Campus',
      supervisorApprovedAt: approvedAt,
      workflowStatus: 'corrections_ongoing',
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );

FypCorrectionItem _item(String status) => FypCorrectionItem(
      id: 'c-$status',
      fypRecordId: 'rec-1',
      itemCode: 'CORR-1',
      description: 'Fix chapter 3.',
      severity: 'minor',
      status: status,
      createdAt: DateTime(2026, 8, 12),
      updatedAt: DateTime(2026, 8, 12),
    );

Future<void> _pump(WidgetTester tester, FypRecord record, List<FypCorrectionItem> items,
    {String uid = 'sup-main'}) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      fypmsUserScopeProvider.overrideWithValue(uid),
      assignedFypRecordsProvider.overrideWith((ref, role) async => [record]),
      fypCorrectionItemsProvider.overrideWith((ref, id) async => items),
    ],
    child: const MaterialApp(home: SupervisorCorrectionsPage()),
  ));
  await tester.pumpAndSettle();
}

FilledButton _approveButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Approve Final Report'));

void main() {
  testWidgets('waits for every correction to be confirmed', (tester) async {
    await _pump(tester, _rec(), [_item('confirmed'), _item('open')]);
    expect(find.textContaining('1 open correction item is confirmed'), findsOneWidget);
    expect(_approveButton(tester).onPressed, isNull);
  });

  testWidgets('can approve once all corrections are confirmed', (tester) async {
    await _pump(tester, _rec(), [_item('confirmed'), _item('closed')]);
    expect(find.textContaining('Ready for your approval'), findsOneWidget);
    expect(_approveButton(tester).onPressed, isNotNull);
  });

  testWidgets('shows the approval date once approved', (tester) async {
    await _pump(tester, _rec(approvedAt: DateTime(2026, 9, 20)), [_item('confirmed')]);
    expect(find.textContaining('Final report approved on'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Approve Final Report'), findsNothing);
  });

  testWidgets('a co-supervisor gets no approve button, only a note', (tester) async {
    await _pump(tester, _rec(), [_item('confirmed'), _item('closed')], uid: 'sup-co');
    expect(find.widgetWithText(FilledButton, 'Approve Final Report'), findsNothing);
    expect(find.text('Only the main supervisor can give final approval.'), findsOneWidget);
    expect(find.textContaining('Ready for your approval'), findsNothing);
    expect(find.textContaining("Awaiting the main supervisor's approval"), findsOneWidget);
  });

  testWidgets('the main supervisor sees no co-supervisor note', (tester) async {
    await _pump(tester, _rec(), [_item('confirmed')]);
    expect(_approveButton(tester).onPressed, isNotNull);
    expect(find.text('Only the main supervisor can give final approval.'), findsNothing);
  });

  test('canGiveFinalApproval matches the main supervisor only', () {
    final rec = _rec();
    expect(canGiveFinalApproval(rec, 'sup-main'), isTrue);
    expect(canGiveFinalApproval(rec, 'sup-co'), isFalse);
    expect(canGiveFinalApproval(rec, 'someone'), isFalse);
    expect(canGiveFinalApproval(rec, null), isFalse);
  });

  test('the server only lets the supervisor approve, and only after F12', () {
    final sql = File('supabase/migrations/20261010000004_supervisor_final_approval.sql').readAsStringSync();
    expect(sql, contains("is_assigned_to_fyp_record(p_fyp_record_id, 'supervisor')"));
    expect(sql, contains("status not in ('confirmed', 'closed')"));
  });
}
