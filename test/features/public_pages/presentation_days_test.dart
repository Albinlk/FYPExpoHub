import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/public_booths/presentation/pages/booths_page.dart';
import 'package:fyp_expo_hub/features/public_booths/presentation_days.dart';
import 'package:fyp_expo_hub/features/public_lecturer/presentation/pages/lecturer_page.dart';

/// The booth and lecturer Day filters used to hard-code "Day 1 - 06 Aug
/// 2026"; they now come from the data and the current event's dates.
void main() {
  // 09:00 - 17:00 Malaysia time, 6-7 August 2026, as UTC instants.
  final start2026 = DateTime.utc(2026, 8, 6, 1);
  final end2026 = DateTime.utc(2026, 8, 7, 9);

  group('presentationDayOptions', () {
    test('no data: the event days, in the importer format', () {
      expect(presentationDayOptions(const [], eventStart: start2026, eventEnd: end2026),
          ['Day 1 - 06 Aug 2026', 'Day 2 - 07 Aug 2026']);
    });

    test('a later event gets its own dates, not 2026', () {
      expect(
        presentationDayOptions(const [null, ''],
            eventStart: DateTime.utc(2027, 3, 4, 1), eventEnd: DateTime.utc(2027, 3, 6, 9)),
        ['Day 1 - 04 Mar 2027', 'Day 2 - 05 Mar 2027', 'Day 3 - 06 Mar 2027'],
      );
    });

    test('event days are counted in Malaysia time', () {
      // 23:30 UTC on 3 March is already 4 March in Malaysia.
      expect(
        presentationDayOptions(const [],
            eventStart: DateTime.utc(2027, 3, 3, 23, 30), eventEnd: DateTime.utc(2027, 3, 4, 9)),
        ['Day 1 - 04 Mar 2027'],
      );
    });

    test("data labels are used as they are, ordered by day number", () {
      expect(
        presentationDayOptions(
          const ['Day 2 - 10 Mar 2027', 'Day 1 - 09 Mar 2027', 'Day 2 - 10 Mar 2027', 'Day 10 - 18 Mar 2027'],
          eventStart: start2026,
          eventEnd: end2026,
        ),
        ['Day 1 - 09 Mar 2027', 'Day 2 - 10 Mar 2027', 'Day 10 - 18 Mar 2027'],
      );
    });

    test('a day with no data yet is still offered from the event', () {
      expect(
        presentationDayOptions(const ['Day 1 - 06 Aug 2026'], eventStart: start2026, eventEnd: end2026),
        ['Day 1 - 06 Aug 2026', 'Day 2 - 07 Aug 2026'],
      );
    });

    test('labels without a day number are kept, after the numbered days', () {
      expect(
        presentationDayOptions(const ['Opening', 'Day 1 - 06 Aug 2026'], eventStart: start2026, eventEnd: start2026),
        ['Day 1 - 06 Aug 2026', 'Opening'],
      );
    });

    test('an end before the start still offers one day; a huge range is capped', () {
      expect(presentationDayOptions(const [], eventStart: end2026, eventEnd: start2026), ['Day 1 - 07 Aug 2026']);
      expect(
        presentationDayOptions(const [], eventStart: start2026, eventEnd: DateTime.utc(2027, 8, 6)).length,
        14,
      );
    });
  });

  group('pages', () {
    final originalErrorHandler = FlutterError.onError;
    setUp(() {
      FlutterError.onError = (details) {
        if (!details.exception.toString().contains('must initialize the supabase instance')) {
          FlutterError.dumpErrorToConsole(details);
        }
      };
    });
    tearDown(() => FlutterError.onError = originalErrorHandler);

    Future<void> pump(WidgetTester tester, String location, Widget page, List<Project> projects) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        initialLocation: location,
        routes: [GoRoute(path: '/page', builder: (_, _) => page)],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          supabaseDbServiceProvider.overrideWithValue(_StubDb()),
          publicProjectsProvider.overrideWith(() => _ProjectsStub(projects)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('booths open on the first day in the data', (tester) async {
      await pump(tester, '/page', const BoothsPage(), [
        _project('1', day: 'Day 1 - 09 Mar 2027', booth: 'DS5-01'),
        _project('2', day: 'Day 2 - 10 Mar 2027', booth: 'DS7-03'),
      ]);
      expect(tester.takeException(), isNull);
      expect(find.text('Day 1 - 09 Mar 2027'), findsWidgets);
      expect(find.text('Project 1'), findsOneWidget);
      expect(find.text('Project 2'), findsNothing);
    });

    testWidgets('booths ?day= picks a data day', (tester) async {
      await pump(tester, '/page?day=Day%202%20-%2010%20Mar%202027', const BoothsPage(), [
        _project('1', day: 'Day 1 - 09 Mar 2027', booth: 'DS5-01'),
        _project('2', day: 'Day 2 - 10 Mar 2027', booth: 'DS7-03'),
      ]);
      expect(tester.takeException(), isNull);
      expect(find.text('Project 2'), findsOneWidget);
      expect(find.text('Project 1'), findsNothing);
    });

    testWidgets('lecturer ?day= filters by a data day', (tester) async {
      await pump(tester, '/page?name=Dr.%20A&day=Day%202%20-%2010%20Mar%202027', const LecturerPage(), [
        _project('1', day: 'Day 1 - 09 Mar 2027'),
        _project('2', day: 'Day 2 - 10 Mar 2027'),
      ]);
      expect(tester.takeException(), isNull);
      expect(find.text('Day 2 - 10 Mar 2027'), findsWidgets);
      expect(find.text('Project 2'), findsOneWidget);
      expect(find.text('Project 1'), findsNothing);
    });
  });
}

Project _project(String id, {required String day, String booth = 'DS5-01'}) => Project(
      id: id,
      eventId: 'fskm-fyp-2027',
      slug: 'project-$id',
      title: 'Project $id',
      programmeCode: 'CS266',
      programmeName: 'Computer Science',
      shortDescription: 'desc',
      category: 'Computer Science',
      technologyTags: const ['AI'],
      boothNumber: booth,
      presentationDay: day,
      coverImageUrl: '',
      teamDisplayNames: const ['Ali'],
      supervisorDisplayName: 'Dr. A',
      featured: false,
      publicationStatus: 'published',
      createdAt: DateTime(2027, 1, 1),
      updatedAt: DateTime(2027, 1, 1),
      publishedAt: DateTime(2027, 1, 1),
    );

class _ProjectsStub extends ProjectsNotifier {
  _ProjectsStub(this._projects);
  final List<Project> _projects;
  @override
  List<Project> build() => _projects;
}

class _StubDb extends SupabaseDatabaseService {
  _StubDb()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));
}
