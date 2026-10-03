import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/core/utils/url_state.dart';
import 'package:fyp_expo_hub/features/public_booths/presentation/pages/booths_page.dart';
import 'package:fyp_expo_hub/features/public_lecturer/presentation/pages/lecturer_page.dart';
import 'package:fyp_expo_hub/features/public_projects/presentation/pages/projects_page.dart';

/// Filters live in the address bar (`?day=…&venue=…`) so a refresh or a shared
/// link reopens the same view, and a stale or hand-edited link cannot break a
/// dropdown.
void main() {
  group('urlWithQuery', () {
    test('keeps the path clean when nothing is set', () {
      expect(urlWithQuery('/booths', {'day': null, 'venue': '', 'search': '  '}), '/booths');
    });

    test('encodes values and drops empties', () {
      expect(
        urlWithQuery('/booths', {'day': 'Day 2 - 07 Aug 2026', 'venue': null, 'search': 'ai & ml'}),
        '/booths?day=Day+2+-+07+Aug+2026&search=ai+%26+ml',
      );
    });

    test('an empty path gives just the query, as the address-bar writer needs', () {
      expect(urlWithQuery('', {'day': '2'}), '?day=2');
      expect(urlWithQuery('', {'day': null}), '');
    });
  });

  group('pages restore filters from the link', () {
    Future<void> pump(WidgetTester tester, String location, Widget page) async {
      tester.view.physicalSize = const Size(1280, 1800);
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
          publicProjectsProvider.overrideWith(() => _ProjectsStub([_project()])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('booths: day, venue and programme from the link; unknown values are ignored', (tester) async {
      await pump(
        tester,
        '/page?day=Day%202%20-%2007%20Aug%202026&venue=Nowhere&program=Nope&search=one',
        const BoothsPage(),
      );
      expect(tester.takeException(), isNull, reason: 'a stale venue must not break the dropdown');
      expect(find.text('Day 2 - 07 Aug 2026'), findsWidgets);
      expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, 'one');
    });

    testWidgets('projects: search, programme and industry from the link', (tester) async {
      await pump(tester, '/page?search=one&programme=CS266&industry=true', const ProjectsPage());
      expect(tester.takeException(), isNull);
      expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, 'one');
    });

    testWidgets('projects: a bogus programme is ignored, not crashed on', (tester) async {
      await pump(tester, '/page?programme=ZZ999&category=Nonsense', const ProjectsPage());
      expect(tester.takeException(), isNull);
    });

    testWidgets('lecturer: name and filters from the link', (tester) async {
      await pump(tester, '/page?name=Dr.%20A&role=Supervisor&day=Day%201%20-%2006%20Aug%202026', const LecturerPage());
      expect(tester.takeException(), isNull);
      expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, 'Dr. A');
      expect(find.text('Found 0 projects:'), findsNothing);
    });

    testWidgets('lecturer: unknown role and day are ignored', (tester) async {
      await pump(tester, '/page?name=x&role=Boss&day=Someday', const LecturerPage());
      expect(tester.takeException(), isNull);
    });
  });
}

Project _project() => Project(
      id: 'p1',
      eventId: 'fskm-fyp-2026',
      slug: 'project-one',
      title: 'Project One',
      programmeCode: 'CS266',
      programmeName: 'Computer Science',
      shortDescription: 'desc',
      category: 'Computer Science',
      technologyTags: const ['AI'],
      boothNumber: 'BK1-01',
      coverImageUrl: '',
      teamDisplayNames: const ['Ali'],
      supervisorDisplayName: 'Dr. A',
      featured: false,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
      publishedAt: DateTime(2026, 7, 1),
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

  @override
  Future<List<Map<String, dynamic>>> getProjectsOnce({
    bool publishedOnly = false,
    int? limit,
    int? offset,
    String eventId = 'fskm-fyp-2026',
  }) async =>
      [];

  @override
  Future<List<Map<String, dynamic>>> getBoothsOnce({bool publishedOnly = false}) async => [];
}
