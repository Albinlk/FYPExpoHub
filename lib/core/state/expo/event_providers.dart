import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event.dart';
import '../../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../../utils/logger.dart';
import 'service_providers.dart';

// ==========================================
// EVENT METADATA STATE
// ==========================================
class EventNotifier extends Notifier<Event> {
  @override
  Event build() {
    _loadFromSupabase();
    return Event(
      id: 'fskm-fyp-2026',
      title: 'FSKM FYP Expo Hub 2026',
      sessionLabel: 'Semester March - August 2026',
      startAt: DateTime(2026, 8, 6, 9, 0),
      endAt: DateTime(2026, 8, 7, 17, 0),
      dailyHours: '9:00 AM - 5:00 PM',
      venue: 'Lecture Block, FSKM',
      locationDetails:
          'Seminar Hall & Lecture Rooms, Faculty of Computer and Mathematical Sciences (FSKM)',
      mapUrl: 'https://maps.google.com/?q=FSKM+UiTM',
      description:
          'The Final Year Project Exhibition (FYP Expo) FSKM is a bi-annual event showcasing the dedication, innovation, and technical expertise developed by final-semester students of the Faculty of Computer and Mathematical Sciences (FSKM). This exhibition serves as a vital bridge connecting academic research with industry partners.',
      objectives: [
        'Showcase the creativity and system design innovations of FSKM students.',
        'Provide a professional platform for presenting and defending project research outcomes.',
        'Foster strong collaboration networks among students, faculty, and industry leaders.',
        'Recognize outstanding achievements through best project award categories.',
      ],
      status: 'active',
      heroImageUrl: 'assets/images/banner.jpg',
      posterUrl: 'assets/images/poster.jpg',
      publicContactEmail: 'fskmfypexpo@uitm.edu.my',
      faqItems: [
        const FaqItem(
          question: 'What is FYP Expo Hub?',
          answer:
              'It is the official web portal for the Final Year Project Exhibition of the Faculty of Computer and Mathematical Sciences (FSKM).',
        ),
        const FaqItem(
          question: 'Who can attend the exhibition?',
          answer:
              'The exhibition is open to all UiTM students, faculty members, and external industry visitors who are interested in final year student innovations.',
        ),
        const FaqItem(
          question: 'Are there awards given to the projects?',
          answer:
              'Projects are evaluated by a panel of industry and academic juries, and awards like Gold, Silver, Bronze, and Best Innovative Project are presented.',
        ),
      ],
      publicationStatus: 'published',
      updatedAt: DateTime.now(),
      publishedAt: DateTime.now(),
    );
  }

  void _loadFromSupabase() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getEvent('fskm-fyp-2026');
      if (data != null) {
        state = Event.fromJson(normalizeKeys(data));
      }
    } catch (e) {
      logDebug('Event load failed (using fallback): $e');
    }
  }

  void updateEvent(Event newEvent) async {
    state = newEvent.copyWith(updatedAt: DateTime.now());
    try {
      final rpc = ref.read(supabaseRpcServiceProvider);
      await rpc.updateEventConfiguration(
        eventId: newEvent.id,
        payload: newEvent.toJson(),
      );
    } catch (e) {
      logDebug('updateEvent via RPC failed: $e');
      final db = ref.read(supabaseDbServiceProvider);
      await db.setEvent(newEvent.id, newEvent.toJson());
    }
  }
}

final eventProvider = NotifierProvider<EventNotifier, Event>(
  () => EventNotifier(),
);
