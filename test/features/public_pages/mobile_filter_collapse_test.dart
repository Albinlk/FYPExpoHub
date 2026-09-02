import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/core/widgets/collapsible_filter_panel.dart';
import 'package:fyp_expo_hub/features/junior_project_guide/presentation/pages/junior_project_browser_page.dart';
import 'package:fyp_expo_hub/features/public_booths/presentation/pages/booths_page.dart';
import 'package:fyp_expo_hub/features/public_projects/presentation/pages/projects_page.dart';

/// Mobile (<768px) collapsible-filter behaviour for the three public pages:
/// collapsed by default, badge count, expand via toggle, Day stays visible on
/// Booths. Pages read GoRouterState (deep-link ?search=), so they are mounted
/// inside a real GoRouter. Pre-existing mobile row overflows in
/// project_row_widget are filtered (same convention as the route-guard suites).
void main() {
  final originalErrorHandler = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      final message = details.exception.toString();
      final filtered = message.contains('RenderFlex overflowed') ||
          message.contains('must initialize the supabase instance');
      if (!filtered) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
  });
  tearDown(() => FlutterError.onError = originalErrorHandler);

  Future<void> _pumpMobile(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => child),
        GoRoute(
          path: '/projects',
          builder: (_, __) => child,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseDbServiceProvider.overrideWithValue(_StubDb()),
          publicProjectsProvider
              .overrideWith(() => _ProjectsNotifierStub([_project()])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CollapsibleFilterPanel (unit)', () {
    testWidgets('collapsed default, badge shows active count',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _PanelHarness(activeCount: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header always visible; collapsed fields hidden; badge shows count.
      expect(find.text('PILLS'), findsOneWidget);
      expect(find.text('Field A'), findsNothing);
      expect(find.text('Filters · 2'), findsOneWidget);
    });

    testWidgets('toggle expands to show 2-column fields, collapses again',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: _PanelHarness(activeCount: 0))),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Field A'), findsOneWidget);
      expect(find.text('Field B'), findsOneWidget);
      expect(find.text('Field C'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Field A'), findsNothing);
    });
  });

  testWidgets('JuniorProjectBrowserPage mobile: collapsed by default with pills visible',
      (tester) async {
    await _pumpMobile(tester, const JuniorProjectBrowserPage());

    // Search + section pills + toggle visible. (The list rows below also
    // carry CSP650/CSP600 section badges, so findsWidgets is correct.)
    expect(find.text('CSP650'), findsWidgets);
    expect(find.text('CSP600'), findsWidgets);
    expect(find.text('Filters'), findsOneWidget);

    // Dropdowns hidden until expanded.
    expect(find.text('Academic Program'), findsNothing);
    expect(find.text('Tech Stack'), findsNothing);
  });

  testWidgets('JuniorProjectBrowserPage mobile: toggle expands and shows filters',
      (tester) async {
    await _pumpMobile(tester, const JuniorProjectBrowserPage());

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Academic Program'), findsOneWidget);
    expect(find.text('Project Category'), findsOneWidget);
    expect(find.text('Tech Stack'), findsOneWidget);
    expect(find.text('Reset Filters'), findsOneWidget);
  });

  testWidgets('ProjectsPage mobile: collapsed by default, chip visible, dropdowns hidden',
      (tester) async {
    await _pumpMobile(tester, const ProjectsPage());

    expect(find.text('Industry Candidate'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Academic Program'), findsNothing);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Academic Program'), findsOneWidget);
    expect(find.text('Project Category'), findsOneWidget);
    expect(find.text('Reset Filters'), findsOneWidget);
  });

  testWidgets('BoothsPage mobile: Day stays visible, Venue/Program collapse',
      (tester) async {
    await _pumpMobile(tester, const BoothsPage());

    // Day dropdown (the page's organizing principle) stays visible.
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);

    // Venue/Program hidden until expanded.
    expect(find.text('Venue'), findsNothing);
    expect(find.text('Program'), findsNothing);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Venue'), findsOneWidget);
    expect(find.text('Program'), findsOneWidget);
    expect(find.text('Clear Venue & Program'), findsOneWidget);
  });
}

/// Stateful harness so the toggle actually flips expansion state.
class _PanelHarness extends StatefulWidget {
  final int activeCount;

  const _PanelHarness({required this.activeCount});

  @override
  State<_PanelHarness> createState() => _PanelHarnessState();
}

class _PanelHarnessState extends State<_PanelHarness> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CollapsibleFilterPanel(
          header: const TextField(),
          headerTrailing: const Text('PILLS'),
          activeCount: widget.activeCount,
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          filterFields: const [
            Text('Field A'),
            Text('Field B'),
            Text('Field C'),
          ],
          resetControl: TextButton(
            onPressed: () {},
            child: const Text('Reset'),
          ),
        ),
      ],
    );
  }
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

class _ProjectsNotifierStub extends ProjectsNotifier {
  _ProjectsNotifierStub(this._projects);

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
  Future<List<Map<String, dynamic>>> getBoothsOnce({
    bool publishedOnly = false,
  }) async =>
      [];
}
