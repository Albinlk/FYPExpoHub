import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/domain/models/event.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/features/admin_event/presentation/pages/admin_event_page.dart';

final saved = <Event>[];

class _EventStub extends EventNotifier {
  @override
  Event build() => Event(
        id: 'fskm-fyp-2026',
        title: 'FSKM FYP Expo Hub 2026',
        sessionLabel: 'Semester March - August 2026',
        startAt: DateTime.utc(2026, 9, 22, 1),
        endAt: DateTime.utc(2026, 9, 23, 9),
        dailyHours: '9:00 AM - 5:00 PM',
        venue: 'Blok Kuliah, FSKM',
        locationDetails: 'FSKM',
        mapUrl: '',
        description: '',
        objectives: const [],
        status: 'upcoming',
        heroImageUrl: 'assets/images/banner.jpg', // legacy seed value
        posterUrl: '',
        publicContactEmail: 'fyp@uitm.edu.my',
        faqItems: const [FaqItem(question: 'Is parking free?', answer: 'Yes, at Lot B.')],
        publicationStatus: 'published',
        updatedAt: DateTime(2026, 9, 1),
      );

  @override
  Future<void> updateEvent(Event newEvent) async {
    saved.add(newEvent);
    state = newEvent;
  }
}

void main() {
  setUp(saved.clear);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [eventProvider.overrideWith(_EventStub.new)],
      child: const MaterialApp(home: AdminEventPage()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('G-07 event editor loads and saves hours, status, links and FAQ', (tester) async {
    await pump(tester);
    expect(find.text('9:00 AM - 5:00 PM'), findsOneWidget);
    expect(find.text('Is parking free?'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('event-hours')), '10:00 AM – 4:00 PM');
    await tester.enterText(find.byKey(const Key('event-hero')), 'https://cdn.example.com/hero.jpg');
    await tester.tap(find.byKey(const Key('event-status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Active (running)').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add question'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('faq-q-1')), 'Can visitors bring food?');
    await tester.enterText(find.byKey(const Key('faq-a-1')), 'Only in the foyer.');
    await tester.tap(find.byTooltip('Remove question').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    final e = saved.single;
    expect(e.dailyHours, '10:00 AM – 4:00 PM');
    expect(e.heroImageUrl, 'https://cdn.example.com/hero.jpg');
    expect(e.status, 'active');
    expect(e.faqItems.map((f) => f.question), ['Can visitors bring food?']);
    expect(e.publicContactEmail, 'fyp@uitm.edu.my');
  });

  testWidgets('G-07 non-http links and unanswered FAQ are refused', (tester) async {
    await pump(tester);
    // An untouched legacy value does not block saving.
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(saved.single.heroImageUrl, 'assets/images/banner.jpg');
    saved.clear();

    await tester.enterText(find.byKey(const Key('event-hero')), 'javascript:alert(1)');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Hero image must be an http(s) link.'), findsOneWidget);
    expect(saved, isEmpty);

    await tester.enterText(find.byKey(const Key('event-hero')), '');
    await tester.enterText(find.byKey(const Key('faq-a-0')), '');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('FAQ "Is parking free?" needs an answer.'), findsOneWidget);
    expect(saved, isEmpty);
  });
}
