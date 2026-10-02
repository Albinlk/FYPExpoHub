import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_users.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/academic_semester.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_enrol_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_users_page.dart';

class _FakeAdmin extends UserAdmin {
  _FakeAdmin(super.ref);
  final calls = <String>[];

  @override
  Future<List<ManagedUser>> search(String query) async => [
        ManagedUser.fromJson({
          'id': 'u1',
          'email': 'aminah@uitm.edu.my',
          'display_name': 'DR AMINAH',
          'role': 'lecturer',
          'is_active': true,
          'roles': [
            {'role_code': 'supervisor', 'programme_code': ''},
            {'role_code': 'fyp_coordinator', 'programme_code': ''},
          ],
        }),
      ];

  @override
  Future<void> setRole(String profileId, String roleCode, {String programmeCode = '', required bool active}) async =>
      calls.add('role:$profileId:$roleCode:$programmeCode:$active');

  @override
  Future<void> setActive(String profileId, bool active) async => calls.add('active:$profileId:$active');

  @override
  Future<List<Map<String, dynamic>>> enrol(String semesterId, String courseCode, List<EnrolmentRow> rows) async {
    calls.add('enrol:$semesterId:$courseCode:${rows.length}');
    return [
      {'email': rows[0].email, 'status': 'enrolled', 'account_created': true},
      {'email': rows[1].email, 'status': 'error', 'message': 'staff account'},
    ];
  }
}

final _made = <_FakeAdmin>[];

/// The fake the page created (made on first read of the provider).
_FakeAdmin get _fake => _made.last;

Future<void> _pump(WidgetTester tester, Widget home, {bool admin = false, List<Override> extra = const []}) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      userAdminProvider.overrideWith((ref) {
        final f = _FakeAdmin(ref);
        _made.add(f);
        return f;
      }),
      isFypAdminProvider.overrideWithValue(admin),
      ...extra,
    ],
    child: MaterialApp(home: home),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('U3 class-list parsing: header skipped, bad lines and duplicates reported', () {
    final (rows, problems) = parseEnrolmentCsv(
      'email,name,matric,programme\n'
      'Aina@Student.uitm.edu.my, Nur Aina, 2027123456, cs266\n'
      'not-an-email, X, 1, CS266\n'
      'aina@student.uitm.edu.my, Again, 2, CS266\n'
      'hafiz@student.uitm.edu.my;Hafiz;;CS230\n'
      'short,line\n',
    );
    expect(rows.map((r) => r.email), ['aina@student.uitm.edu.my', 'hafiz@student.uitm.edu.my']);
    expect(rows.first.programmeCode, 'CS266');
    expect(rows.last.matricId, isNull);
    expect(problems, hasLength(3));
    expect(problems.join(' '), allOf(contains('not an email'), contains('listed twice'), contains('expected email')));
  });

  testWidgets('U2 coordinator adds / removes roles but cannot remove the coordinator role', (tester) async {
    await _pump(tester, const CoordinatorUsersPage());
    expect(find.text('DR AMINAH'), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);
    final chips = tester.widgetList<InputChip>(find.byType(InputChip)).toList();
    expect(chips.firstWhere((c) => (c.label as Text).data == 'FYP coordinator').onDeleted, isNull);

    await tester.tap(find.byTooltip('Remove role').first);
    await tester.pumpAndSettle();
    expect(_fake.calls, isEmpty, reason: 'removing a role asks first');
    await tester.tap(find.widgetWithText(FilledButton, 'Remove Role'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('active-aminah@uitm.edu.my')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Deactivate'));
    await tester.pumpAndSettle();
    expect(_fake.calls, ['role:u1:supervisor::false', 'active:u1:false']);
  });

  testWidgets('U2 an admin sees the account-type control and can remove the coordinator role', (tester) async {
    await _pump(tester, const CoordinatorUsersPage(), admin: true);
    expect(find.byKey(const Key('account-aminah@uitm.edu.my')), findsOneWidget);
    final chips = tester.widgetList<InputChip>(find.byType(InputChip)).toList();
    expect(chips.firstWhere((c) => (c.label as Text).data == 'FYP coordinator').onDeleted, isNotNull);
  });

  testWidgets('U3 enrolment previews the list and reports per-student results', (tester) async {
    await _pump(tester, const CoordinatorEnrolPage(), extra: [
      fypmsSemestersProvider.overrideWith((ref) async => [
            AcademicSemester(
              id: 's27',
              code: '2027_1',
              label: 'Mar–Aug 2027',
              status: 'active',
              startDate: DateTime(2027, 3, 1),
              endDate: DateTime(2027, 8, 31),
              createdAt: DateTime(2027, 1, 1),
              updatedAt: DateTime(2027, 1, 1),
            ),
          ]),
    ]);
    await tester.enterText(
      find.byKey(const Key('enrol-text')),
      'aina@student.uitm.edu.my, Nur Aina, 2027123456, CS266\nsv@uitm.edu.my, Some Lecturer, , CS266',
    );
    await tester.pump();
    expect(find.text('2 students ready'), findsOneWidget);
    await tester.tap(find.byKey(const Key('enrol-submit')));
    await tester.pumpAndSettle();
    expect(_fake.calls, ['enrol:s27:CSP600:2']);
    expect(find.text('1 enrolled · 0 already enrolled · 1 failed'), findsOneWidget);
    expect(find.text('Enrolled · new account'), findsOneWidget);
    expect(find.text('staff account'), findsOneWidget);
  });
}
