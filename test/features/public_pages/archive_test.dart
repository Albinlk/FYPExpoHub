import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/award.dart';
import 'package:fyp_expo_hub/core/domain/models/project.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/admin_event/presentation/widgets/exhibitions_section.dart';
import 'package:fyp_expo_hub/features/public_archive/archive_data.dart';
import 'package:fyp_expo_hub/features/public_archive/presentation/pages/archive_page.dart';

final _events = [
  ExhibitionSummary.fromRow({
    'id': 'e27', 'slug': 'fskm-fyp-2027', 'title': 'FSKM FYP Expo 2027',
    'start_at': '2027-08-05T01:00:00Z', 'is_current': true,
  }),
  ExhibitionSummary.fromRow({
    'id': 'e26', 'slug': 'fskm-fyp-2026', 'title': 'FSKM FYP Expo Hub 2026',
    'start_at': '2026-08-06T01:00:00Z', 'venue': 'Blok Kuliah', 'is_current': false,
  }),
];

Project _project() => Project(
      id: 'p1',
      eventId: 'e26',
      slug: 'smart-campus',
      title: 'Smart Campus Energy',
      matricId: '2024123456',
      programmeCode: 'CS266',
      programmeName: 'Computer Science',
      shortDescription: 'Cuts classroom energy use.',
      category: 'IoT',
      technologyTags: const [],
      coverImageUrl: '',
      teamDisplayNames: const ['Aisyah'],
      supervisorDisplayName: 'DR AMINAH',
      featured: false,
      calonIndustri: false,
      publicationStatus: 'published',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

void main() {
  tearDown(() => ActiveEvent.slug = kDefaultEventSlug);

  test('S6 bundled offline data is only used for the default exhibition', () {
    expect(ActiveEvent.usesBundledData, isTrue);
    ActiveEvent.slug = 'fskm-fyp-2027';
    expect(kEventSlug, 'fskm-fyp-2027');
    expect(ActiveEvent.usesBundledData, isFalse);
  });

  testWidgets('S7 archive lists past exhibitions only', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [exhibitionsProvider.overrideWith((ref) async => _events)],
      child: const MaterialApp(home: Scaffold(body: ArchivePage())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('FSKM FYP Expo Hub 2026'), findsOneWidget);
    expect(find.text('2026 · Blok Kuliah'), findsOneWidget);
    expect(find.text('FSKM FYP Expo 2027'), findsNothing, reason: 'the current one is the main site');
  });

  testWidgets('S7 a past exhibition shows its winners and projects', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        archivedEventProvider.overrideWith((ref, slug) async => (
              _events[1],
              [_project()],
              [
                PublishedAwardWinner(
                  id: 'w1',
                  eventId: 'e26',
                  awardCategoryId: '',
                  projectTitle: 'Gold Innovation Award',
                  teamDisplayName: 'Aisyah',
                  publicationStatus: 'published',
                  createdAt: DateTime(2026, 8, 7),
                  updatedAt: DateTime(2026, 8, 7),
                ),
              ],
            )),
      ],
      child: const MaterialApp(home: Scaffold(body: ArchivedEventPage(slug: 'fskm-fyp-2026'))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Gold Innovation Award'), findsOneWidget);
    expect(find.text('Smart Campus Energy'), findsOneWidget);
    await tester.tap(find.text('Smart Campus Energy'));
    await tester.pumpAndSettle();
    expect(find.text('Cuts classroom energy use.'), findsOneWidget);
  });

  testWidgets('S6 admin sees which exhibition is current and can switch others', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [exhibitionsProvider.overrideWith((ref) async => _events)],
      child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: ExhibitionsSection()))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('fskm-fyp-2027 · 2027 · current'), findsOneWidget);
    expect(find.byKey(const Key('make-current-fskm-fyp-2026')), findsOneWidget);
    expect(find.byKey(const Key('make-current-fskm-fyp-2027')), findsNothing);
  });
}
