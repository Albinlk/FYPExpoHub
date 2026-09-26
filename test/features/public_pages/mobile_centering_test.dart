import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/app/theme/theme.dart';
import 'package:fyp_expo_hub/core/domain/models/event.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/domain/models/schedule_item.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/public_home/presentation/pages/home_page.dart';
import 'package:fyp_expo_hub/features/public_schedule/presentation/pages/schedule_page.dart';

/// Mobile-view contracts for the home hero + empty states: one compact
/// centered details line, a small concluded pill, two hero actions, even schedule tabs,
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

  Future<void> pumpMobile(
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
      routes: [GoRoute(path: '/', builder: (_, _) => child)],
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

  testWidgets('home hero details are one compact centered line on mobile',
      (tester) async {
    await pumpMobile(tester, const HomePage());

    // No DATE/TIME/VENUE labels or boxed rows on phones: icon + value only.
    expect(find.text('DATE'), findsNothing);
    final venue = find.text('Blok Kuliah, FSKM').first;
    expect(tester.widget<Text>(venue).textAlign, TextAlign.center);
    final wrap = tester.widget<Wrap>(
      find.ancestor(of: venue, matching: find.byType(Wrap)).first,
    );
    expect(wrap.alignment, WrapAlignment.center);
    // Date, time and venue are all children of that one wrapped line.
    expect(
      find.descendant(of: find.byWidget(wrap), matching: find.byType(Icon)),
      findsNWidgets(3),
    );
  });

  testWidgets('concluded state is a small centered pill on mobile', (tester) async {
    await pumpMobile(tester, const HomePage(), concludedEvent: true);

    final text = find.text('Exhibition concluded — thank you!');
    final badge = tester.widget<Text>(text.first);
    expect(badge.textAlign, TextAlign.center);
    expect(badge.softWrap, isTrue);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    // Pill, not the desktop box: tight padding and fully rounded ends.
    final pill = tester.widget<Container>(
      find.ancestor(of: text, matching: find.byType(Container)).first,
    );
    expect(pill.padding, const EdgeInsets.symmetric(horizontal: 12, vertical: 6));
    expect((pill.decoration! as BoxDecoration).borderRadius, DesignSystem.radiusFull);
  });

  testWidgets('home hero keeps one primary and one secondary action',
      (tester) async {
    await pumpMobile(tester, const HomePage());

    expect(find.widgetWithText(ElevatedButton, 'Explore Projects'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'View Schedule'), findsOneWidget);
    expect(find.text('Past Sem Projects'), findsNothing);
    expect(find.text('Lecturer Portal'), findsNothing);
  });

  testWidgets('Featured Projects header is centered on mobile, left on desktop title',
      (tester) async {
    await pumpMobile(tester, const HomePage());

    final title = tester.widget<Text>(find.text('Featured Projects').first);
    expect(title.textAlign, TextAlign.center);
  });

  testWidgets('schedule day tabs are not scrollable on mobile (even split)',
      (tester) async {
    await pumpMobile(tester, const SchedulePage());

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
      // 09:00-17:00 Malaysia time as UTC instants: local DateTimes made the
      // day tabs depend on the test machine's timezone (on UTC CI, 17:00
      // "local" became 01:00 the next day in MYT and added a third tab).
      startAt: concluded ? DateTime.utc(2026, 8, 6, 1) : DateTime.utc(2027, 8, 6, 1),
      endAt: concluded ? DateTime.utc(2026, 8, 7, 9) : DateTime.utc(2027, 8, 7, 9),
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
