import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/announcement.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/public_announcements/presentation/pages/announcements_page.dart';
import 'package:fyp_expo_hub/features/public_booths/presentation/pages/booths_page.dart';

Project _project(String id, {bool featured = false, String day = 'Day 1 - 06 Aug 2026', String booth = 'DS5-01'}) =>
    Project(
      id: id,
      eventId: 'fskm-fyp-2026',
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
      featured: featured,
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

class _AnnouncementsStub extends AnnouncementsNotifier {
  _AnnouncementsStub(this._items);
  final List<Announcement> _items;
  @override
  List<Announcement> build() => _items;
}

class _StubDb extends SupabaseDatabaseService {
  _StubDb()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));
}

void main() {
  final originalErrorHandler = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      if (!details.exception.toString().contains('must initialize the supabase instance')) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
  });
  tearDown(() => FlutterError.onError = originalErrorHandler);

  Future<void> pump(WidgetTester tester, String location, Widget page, List<Override> overrides) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(path: '/booths', builder: (_, _) => page),
        GoRoute(path: '/announcements', builder: (_, _) => page),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [supabaseDbServiceProvider.overrideWithValue(_StubDb()), ...overrides],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  test('G-12: featured projects come first, then the visit order, max 6', () {
    final visitOrder = [for (var i = 1; i <= 8; i++) _project('$i', featured: i == 5 || i == 8)];
    final shown = featuredForHome(visitOrder);
    expect(shown.map((p) => p.id), ['5', '8', '1', '2', '3', '4']);
    expect(featuredForHome(visitOrder.where((p) => !p.featured).toList()).length, 6,
        reason: 'no featured projects: same as before');
  });

  testWidgets('G-13: announcements show the real month', (tester) async {
    final sept = Announcement(
      id: 'a1',
      eventId: 'fskm-fyp-2026',
      title: 'Results released',
      body: 'Check the portal.',
      category: 'Important',
      pinned: false,
      publicationStatus: 'published',
      publishedAt: DateTime.utc(2026, 9, 5, 2),
      createdAt: DateTime.utc(2026, 9, 5, 2),
      updatedAt: DateTime.utc(2026, 9, 5, 2),
    );
    await pump(tester, '/announcements', const AnnouncementsPage(), [
      publicAnnouncementsProvider.overrideWith(() => _AnnouncementsStub([sept])),
    ]);
    expect(find.textContaining('5 September 2026'), findsOneWidget);
    expect(find.textContaining('August'), findsNothing);
  });

  testWidgets('G-14: /booths?day= opens on that day with the booth searched', (tester) async {
    await pump(
      tester,
      Uri(path: '/booths', queryParameters: {'search': 'DS7-03', 'day': 'Day 2 - 07 Aug 2026'}).toString(),
      const BoothsPage(),
      [
        publicProjectsProvider.overrideWith(() => _ProjectsStub([
              _project('1', booth: 'DS5-01'),
              _project('2', booth: 'DS7-03', day: 'Day 2 - 07 Aug 2026'),
            ])),
      ],
    );
    expect(find.text('Project 2'), findsOneWidget, reason: 'the Day 2 booth is listed');
    expect(find.text('Project 1'), findsNothing);
    expect(find.text('No Booths Found'), findsNothing);
  });
}
