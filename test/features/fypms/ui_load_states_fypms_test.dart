import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/fypms/academic_semester.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_enrol_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/coordinator_semesters_page.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/widgets/supervisor_change_widgets.dart';

/// A12: a failed load must read as a failure with Try Again, never as
/// "nothing here" (every course "not offered", no change requests, an empty
/// semester picker).
AcademicSemester _sem() => AcademicSemester(
      id: 's26',
      code: '2026_1',
      label: 'Mar–Aug 2026',
      status: 'active',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 8, 31),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Future<void> _pump(WidgetTester tester, Widget home, List<Override> overrides) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: home)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('semesters: failed offerings show an error, not "not offered" everywhere', (tester) async {
    var offeringLoads = 0;
    await _pump(tester, const CoordinatorSemestersPage(), [
      fypmsSemestersProvider.overrideWith((ref) async => [_sem()]),
      fypmsOfferingsProvider.overrideWith((ref) async {
        offeringLoads++;
        throw Exception('ClientException: Failed to fetch');
      }),
      fypmsCoursesProvider.overrideWith((ref) async => []),
      fypStaffProvider.overrideWith((ref, roles) async => []),
    ]);
    expect(find.text("Couldn't load courses and offerings."), findsOneWidget);
    expect(find.textContaining('not offered'), findsNothing);

    final before = offeringLoads;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(offeringLoads, greaterThan(before), reason: 'Try Again reloads the offerings');
  });

  testWidgets('change requests: a failed load shows an error card instead of hiding', (tester) async {
    await _pump(tester, const Scaffold(body: SupervisorChangeRequestsPanel()), [
      pendingSupervisorChangesProvider.overrideWith((ref) async => throw Exception('boom')),
      supervisorsDirectoryProvider.overrideWith((ref) async => []),
    ]);
    expect(find.text("Couldn't load supervisor change requests."), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('change requests: none waiting still shows nothing', (tester) async {
    await _pump(tester, const Scaffold(body: SupervisorChangeRequestsPanel()), [
      pendingSupervisorChangesProvider.overrideWith((ref) async => []),
      supervisorsDirectoryProvider.overrideWith((ref) async => []),
    ]);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('enrolment: failed semesters show an error, not an empty picker', (tester) async {
    await _pump(tester, const CoordinatorEnrolPage(), [
      fypmsSemestersProvider.overrideWith((ref) async => throw Exception('boom')),
    ]);
    expect(find.text("Couldn't load semesters."), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });
}
