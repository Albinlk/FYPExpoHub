import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/features/lecturer_visits/presentation/pages/lecturer_visits_page.dart';

/// "My Visits" must not say "all visited" (or show an empty grid) while the
/// assignment and visit lists are still loading or have failed.
void main() {
  User user() => User(
        id: 'lecturer-uid-1',
        email: 'dr.aminah@uitm.edu.my',
        aud: 'authenticated',
        appMetadata: const {},
        userMetadata: const {},
        createdAt: DateTime(2026, 7, 1).toIso8601String(),
      );

  Future<void> pump(WidgetTester tester, List<Override> overrides, {bool settle = true}) async {
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentAuthUserProvider.overrideWith((ref) => user()),
        publicProjectsProvider.overrideWith(() => _ProjectsStub(const [])),
        ...overrides,
      ],
      child: const MaterialApp(home: LecturerVisitsPage()),
    ));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('while loading it shows a spinner, not "all visited"', (tester) async {
    final never = Completer<List<Never>>();
    await pump(tester, [
      allAssignmentsProvider.overrideWith((ref) => never.future),
      allVisitsProvider.overrideWith((ref) async => []),
    ], settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // ('Not visited' is a filter chip, not a claim about progress.)
    expect(find.textContaining(RegExp('all visited|been visited', caseSensitive: false)), findsNothing);
    expect(find.text('You have no projects assigned yet.'), findsNothing);
  });

  testWidgets('a failed load shows an error with Try Again', (tester) async {
    await pump(tester, [
      allAssignmentsProvider.overrideWith((ref) async => throw Exception('ClientException: Failed to fetch')),
      allVisitsProvider.overrideWith((ref) async => []),
    ]);
    expect(find.text("Couldn't load your visits."), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('no assignments at all says so instead of "all visited"', (tester) async {
    await pump(tester, [
      allAssignmentsProvider.overrideWith((ref) async => []),
      allVisitsProvider.overrideWith((ref) async => []),
    ]);
    expect(find.text('You have no projects assigned yet.'), findsOneWidget);
    expect(find.textContaining('All projects have been visited'), findsNothing);
  });

  testWidgets('staff with FYP Workspace roles get a link back to it', (tester) async {
    await pump(tester, [
      allAssignmentsProvider.overrideWith((ref) async => []),
      allVisitsProvider.overrideWith((ref) async => []),
      fypmsCurrentRolesProvider.overrideWith((ref) async => const ['supervisor']),
    ]);
    expect(find.byKey(const Key('fyp-workspace-link')), findsOneWidget);
    expect(find.text('FYP Workspace'), findsOneWidget);
  });

  testWidgets('no FYP Workspace roles, no Workspace link', (tester) async {
    await pump(tester, [
      allAssignmentsProvider.overrideWith((ref) async => []),
      allVisitsProvider.overrideWith((ref) async => []),
      fypmsCurrentRolesProvider.overrideWith((ref) async => const <String>[]),
    ]);
    expect(find.byKey(const Key('fyp-workspace-link')), findsNothing);
  });
}

class _ProjectsStub extends ProjectsNotifier {
  _ProjectsStub(this._projects);

  final List<Project> _projects;

  @override
  List<Project> build() => _projects;
}
