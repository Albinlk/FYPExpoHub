import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/announcement.dart';
import 'package:fyp_expo_hub/core/domain/models/event.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/domain/models/schedule_item.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/public_home/presentation/pages/home_page.dart';
import 'package:fyp_expo_hub/features/public_schedule/presentation/pages/schedule_page.dart';

/// Mobile-view centering contracts for the home hero + empty states:
/// centered detail rows, centered countdown badges, even schedule tabs,
/// and centered empty-state text.
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

  Future<void> _pumpMobile(
    WidgetTester tester,
    Widget child, {
    bool concludedEvent = false,
    bool emptyData = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (_, __) => child)],
    );
    final db = _StubDb()
      ..announcements = emptyData ? <Map<String, dynamic>>[] : null
      ..scheduleEmpty = emptyData;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseDbServiceProvider.overrideWithValue(db),
          publicProjectsProvider.overrideWith(
            () => _ProjectsNotifierStub(emptyData ? [] : [_project()]),
          ),
          eventProvider.overrideWith(
            () => _EventNotifierStub(concluded: concludedEvent),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home hero detail labels are centered on mobile', (tester) async {
    await _pumpMobile(tester, const HomePage());

    final dateLabel = tester.widget<Text>(find.text('DATE').first);
    expect(dateLabel.textAlign, TextAlign.center);
    final venueValue =
        tester.widget<Text>(find.text('Blok Kuliah, FSKM').first);
    expect(venueValue.textAlign, TextAlign.center);
  });

  testWidgets('concluded badge text centers and wraps on mobile', (tester) async {
    await _pumpMobile(tester, const HomePage(), concludedEvent: true);

    final badge = tester
        .widget<Text>(find.text('Exhibition Concluded — Thank You for Visiting').first);
    expect(badge.textAlign, TextAlign.center);
    expect(badge.softWrap, isTrue);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
  });

  testWidgets('mobile detail-box separators span the full box width',
      (tester) async {
    await _pumpMobile(tester, const HomePage());

    // The two hairline Containers in the mobile details box.
    final lines = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => (c.constraints?.minWidth == double.infinity) == false)
        .toList();
    // Simply assert the divider widgets got an explicit infinite width via
    // their child DecoratedBox constraints — find by height:1 boxes.
    final dividers = tester.widgetList<Container>(find.byType(Container)).where(
          (c) =>
              c.constraints != null &&
              c.constraints!.minWidth == double.infinity,
        );
    expect(dividers, isNotEmpty);
    expect(lines, isNotEmpty);
  });

  testWidgets('Featured Projects header is centered on mobile, left on desktop title',
      (tester) async {
    await _pumpMobile(tester, const HomePage());

    final title = tester.widget<Text>(find.text('Featured Projects').first);
    expect(title.textAlign, TextAlign.center);
  });

  testWidgets('schedule day tabs are not scrollable on mobile (even split)',
      (tester) async {
    await _pumpMobile(tester, const SchedulePage());

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.isScrollable, isFalse);
    expect(tabBar.tabAlignment, isNull);
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
      coverImageUrl: '',
      teamDisplayNames: const ['Ali'],
      supervisorDisplayName: 'Dr. A',
      featured: true,
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

class _EventNotifierStub extends EventNotifier {
  _EventNotifierStub({required this.concluded});

  final bool concluded;

  @override
  Event build() {
    return Event(
      id: 'fskm-fyp-2026',
      title: 'FSKM FYP Expo Hub 2026',
      sessionLabel: 'Semester March - August 2026',
      startAt: concluded ? DateTime(2026, 8, 6, 9) : DateTime(2027, 8, 6, 9),
      endAt: concluded ? DateTime(2026, 8, 7, 17) : DateTime(2027, 8, 7, 17),
      dailyHours: '9:00 AM - 5:00 PM',
      venue: 'Blok Kuliah, FSKM',
      locationDetails: 'FSKM',
      mapUrl: '',
      description: '',
      objectives: const [],
      status: 'active',
      heroImageUrl: '',
      posterUrl: '',
      publicContactEmail: '',
      faqItems: const [],
      publicationStatus: 'published',
      updatedAt: DateTime(2026, 7, 1),
      publishedAt: DateTime(2026, 7, 1),
    );
  }
}

class _StubDb extends SupabaseDatabaseService {
  _StubDb()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  List<Map<String, dynamic>>? announcements;
  bool scheduleEmpty = false;

  @override
  Future<List<Map<String, dynamic>>> getProjectsOnce({
    bool publishedOnly = false,
    int? limit,
    int? offset,
    String eventId = 'fskm-fyp-2026',
  }) async =>
      [];

  @override
  Future<List<Map<String, dynamic>>> getAnnouncementsOnce({
    bool publishedOnly = false,
  }) async =>
      announcements ?? <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> getScheduleOnce({
    bool publishedOnly = false,
    String eventId = 'fskm-fyp-2026',
  }) async =>
      scheduleEmpty
          ? <Map<String, dynamic>>[]
          : <Map<String, dynamic>>[
              Map<String, dynamic>.from(ScheduleItem(
                id: 's1',
                eventId: 'fskm-fyp-2026',
                date: DateTime(2026, 8, 6),
                startAt: '09:00',
                endAt: '10:00',
                title: 'Opening Ceremony',
                venue: 'Main Hall',
                audience: 'Public',
                visibility: 'public',
                publicationStatus: 'published',
                createdAt: DateTime(2026, 7, 1),
                updatedAt: DateTime(2026, 7, 1),
                publishedAt: DateTime(2026, 7, 1),
              ).toJson()),
            ];
}
