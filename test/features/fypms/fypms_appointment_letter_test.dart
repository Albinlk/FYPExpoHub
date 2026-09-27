import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/fypms_appointment_letter.dart';
import 'package:fyp_expo_hub/core/domain/fypms_supervisor_change.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/supervisor_change_widgets.dart';

final _n = PendingNomination.fromJson({
  'assignment_id': 'a-1',
  'fyp_record_id': 'r-1',
  'academic_role': 'examiner',
  'lecturer_name': 'Dr. Rahman <Hassan>',
  'lecturer_email': 'rahman@example.edu',
  'student_name': 'Aina',
  'matric_id': '2026-123456',
  'programme_code': 'CS230',
  'course_code': 'CSP650',
  'project_title': 'Smart Parking & IoT',
  'semester_label': 'Semester March - August 2026',
  'decided_at': '2026-09-20T02:00:00Z',
  'decided_by_name': 'PM Ts. Programme Head',
});

void main() {
  test('F7 letter is escaped and names role, project, semester and PU', () {
    final html = appointmentLettersHtml([_n, _n]);
    expect(html, contains('Appointment as Examiner'));
    expect(html, contains('Dr. Rahman &lt;Hassan&gt;'));
    expect(html, contains('Smart Parking &amp; IoT'));
    expect(html, contains('Semester March - August 2026'));
    expect(html, contains('20 September 2026'));
    expect(html, contains('PM Ts. Programme Head'));
    expect(html, isNot(contains('<Hassan>')));
    expect('<section class="letter">'.allMatches(html).length, 2);
    expect(appointmentLetterFileName(_n), 'appointment_examiner_2026123456.html');
  });

  testWidgets('F7 approved tab lists letters', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        pendingNominationsProvider.overrideWith((ref) async => const []),
        approvedNominationsProvider.overrideWith((ref) async => [_n]),
      ],
      child: const MaterialApp(home: PuNominationsPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('No nominations are waiting for your approval.'), findsOneWidget);
    await tester.tap(find.text('Approved · letters'));
    await tester.pumpAndSettle();
    expect(find.text('Examiner: Dr. Rahman <Hassan>'), findsOneWidget);
    expect(find.byKey(const Key('all-letters')), findsOneWidget);
    expect(find.text('Letter'), findsOneWidget);
  });
}
