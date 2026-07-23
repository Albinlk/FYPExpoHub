import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/project.dart';
import '../domain/models/schedule_item.dart';
import '../domain/models/announcement.dart';
import '../domain/models/booth.dart';
import '../domain/models/award.dart';
import '../domain/models/event.dart';
import '../domain/models/import_models.dart';
import '../data/excel_data.dart';
import '../firebase/firestore_service.dart';

final _fs = FirestoreService.instance;

// ==========================================
// 1. EVENT METADATA STATE
// ==========================================
class EventNotifier extends Notifier<Event> {
  @override
  Event build() {
    _loadFromFirestore();
    return Event(
      id: 'fskm-fyp-2026',
      title: 'FSKM FYP Expo Hub 2026',
      sessionLabel: 'Semester Mac - Ogos 2026',
      startAt: DateTime(2026, 8, 6, 9, 0),
      endAt: DateTime(2026, 8, 7, 17, 0),
      dailyHours: '9:00 AM - 5:00 PM',
      venue: 'Blok Kuliah, FSKM',
      locationDetails: 'Dewan Seminar & Bilik Kuliah, Fakulti Sains Komputer dan Matematik (FSKM)',
      mapUrl: 'https://maps.google.com/?q=FSKM+UiTM',
      description: 'The Final Year Project Exhibition (FYP Expo) FSKM is a bi-annual event showcasing the dedication, innovation, and technical expertise developed by final-semester students of the Faculty of Computer and Mathematical Sciences (FSKM). This exhibition serves as a vital bridge connecting academic research with industry partners.',
      objectives: [
        'Showcase the creativity and system design innovations of FSKM students.',
        'Provide a professional platform for presenting and defending project research outcomes.',
        'Foster strong collaboration networks among students, faculty, and industry leaders.',
        'Recognize outstanding achievements through best project award categories.'
      ],
      status: 'active',
      heroImageUrl: 'assets/images/banner.jpg',
      posterUrl: 'assets/images/poster.jpg',
      publicContactEmail: 'fskmfypexpo@uitm.edu.my',
      faqItems: [
        const FaqItem(question: 'What is FYP Expo Hub?', answer: 'It is the official web portal for the Final Year Project Exhibition of the Faculty of Computer and Mathematical Sciences (FSKM).'),
        const FaqItem(question: 'Who can attend the exhibition?', answer: 'The exhibition is open to all UiTM students, faculty members, and external industry visitors who are interested in final year student innovations.'),
        const FaqItem(question: 'Are there awards given to the projects?', answer: 'Projects are evaluated by a panel of industry and academic juries, and awards like Gold, Silver, Bronze, and Best Innovative Project are presented.'),
      ],
      publicationStatus: 'published',
      updatedAt: DateTime.now(),
      publishedAt: DateTime.now(),
    );
  }

  void _loadFromFirestore() async {
    final data = await _fs.getEvent('fskm-fyp-2026');
    if (data != null) {
      state = Event.fromJson(data);
    }
  }

  void updateEvent(Event newEvent) {
    state = newEvent.copyWith(updatedAt: DateTime.now());
    _fs.setEvent(newEvent.id, newEvent.toJson());
  }
}

final eventProvider = NotifierProvider<EventNotifier, Event>(() => EventNotifier());

// ==========================================
// 2. PROJECTS STATE
// ==========================================
class ProjectsNotifier extends Notifier<List<Project>> {
  StreamSubscription? _sub;

  @override
  List<Project> build() {
    _sub = _fs.projectsStream().listen((dataList) {
      state = dataList.map((m) => Project.fromJson(m)).toList();
    });
    ref.onDispose(() => _sub?.cancel());
    return ExcelData.allProjects.map((m) => Project(
      id: m['id'] as String,
      eventId: m['event_id'] as String,
      slug: m['slug'] as String,
      title: m['title'] as String,
      matricId: m['matric_id'] as String?,
      programmeCode: m['programme_code'] as String,
      programmeName: m['programme_name'] as String,
      shortDescription: m['short_description'] as String,
      category: m['category'] as String,
      technologyTags: (m['technology_tags'] as List).cast<String>(),
      boothId: m['booth_id'] as String?,
      boothNumber: m['booth_number'] as String?,
      boothZone: m['booth_zone'] as String?,
      coverImageUrl: '/project_images/${m['id'] as String}.png',
      posterUrl: m['poster_url'] as String?,
      teamDisplayNames: (m['team_display_names'] as List).cast<String>(),
      supervisorDisplayName: m['supervisor_display_name'] as String,
      examinerDisplayName: m['examiner_display_name'] as String?,
      demoUrl: m['demo_url'] as String?,
      videoUrl: m['video_url'] as String?,
      repositoryUrl: m['repository_url'] as String?,
      featured: m['featured'] as bool,
      publicationStatus: m['publication_status'] as String,
      createdAt: m['created_at'] as DateTime,
      updatedAt: m['updated_at'] as DateTime,
      publishedAt: m['published_at'] as DateTime?,
    )).toList();
  }

  void addProject(Project project) {
    state = [...state, project];
    _fs.setProject(project.id, project.toJson());
  }

  void updateProject(Project updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final p in state)
        if (p.id == updated.id) data else p
    ];
    _fs.setProject(updated.id, data.toJson());
  }

  void deleteProject(String id) {
    state = state.where((p) => p.id != id).toList();
    _fs.deleteProject(id);
  }

  void togglePublishStatus(String id) {
    final idx = state.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = state[idx];
    final toggled = p.copyWith(
      publicationStatus: p.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: p.publicationStatus != 'published' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final p in state)
        if (p.id == id) toggled else p
    ];
    _fs.setProject(id, toggled.toJson());
  }
}

final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(() => ProjectsNotifier());

final featuredProjectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(projectsProvider).where((p) => p.featured).toList();
});

// ==========================================
// 2b. PROJECT VISIT TRACKING
// ==========================================
class ProjectVisitCountsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void recordVisit(String projectId) {
    state = {...state, projectId: (state[projectId] ?? 0) + 1};
  }
}

final projectVisitCountsProvider = NotifierProvider<ProjectVisitCountsNotifier, Map<String, int>>(() => ProjectVisitCountsNotifier());

final mostVisitedProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(projectsProvider);
  final counts = ref.watch(projectVisitCountsProvider);
  final sorted = List<Project>.from(projects)
    ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
  return sorted;
});

// ==========================================
// 3. DAILY SCHEDULE (TENTATIF) STATE
// ==========================================
class ScheduleNotifier extends Notifier<List<ScheduleItem>> {
  StreamSubscription? _sub;

  @override
  List<ScheduleItem> build() {
    _sub = _fs.scheduleStream().listen((dataList) {
      state = dataList.map((m) => ScheduleItem.fromJson(m)).toList();
    });
    ref.onDispose(() => _sub?.cancel());
    return [];
  }

  void addScheduleItem(ScheduleItem item) {
    state = [...state, item];
    _fs.setScheduleItem(item.id, item.toJson());
  }

  void updateScheduleItem(ScheduleItem updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final s in state)
        if (s.id == updated.id) data else s
    ];
    _fs.setScheduleItem(updated.id, data.toJson());
  }

  void deleteScheduleItem(String id) {
    state = state.where((s) => s.id != id).toList();
    _fs.deleteScheduleItem(id);
  }

  void togglePublish(String id) {
    final idx = state.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final s = state[idx];
    final toggled = s.copyWith(
      publicationStatus: s.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: s.publicationStatus != 'published' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final s in state)
        if (s.id == id) toggled else s
    ];
    _fs.setScheduleItem(id, toggled.toJson());
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(() => ScheduleNotifier());

// ==========================================
// 4. PHYSICAL BOOTH ALLOCATIONS STATE
// ==========================================
class BoothsNotifier extends Notifier<List<Booth>> {
  StreamSubscription? _sub;

  @override
  List<Booth> build() {
    _sub = _fs.boothsStream().listen((dataList) {
      state = dataList.map((m) => Booth.fromJson(m)).toList();
    });
    ref.onDispose(() => _sub?.cancel());
    return ExcelData.allBooths.map((m) => Booth(
      id: m['id'] as String,
      eventId: m['event_id'] as String,
      boothNumber: m['booth_number'] as String,
      zone: m['zone'] as String,
      locationNote: m['location_note'] as String,
      staticFloorPlanUrl: m['static_floor_plan_url'] as String?,
      projectId: m['project_id'] as String?,
      publicationStatus: m['publication_status'] as String,
      createdAt: m['created_at'] as DateTime,
      updatedAt: m['updated_at'] as DateTime,
      publishedAt: m['published_at'] as DateTime?,
    )).toList();
  }

  void addBooth(Booth booth) {
    state = [...state, booth];
    _fs.setBooth(booth.id, booth.toJson());
  }

  void updateBooth(Booth updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final b in state)
        if (b.id == updated.id) data else b
    ];
    _fs.setBooth(updated.id, data.toJson());
  }

  void deleteBooth(String id) {
    state = state.where((b) => b.id != id).toList();
    _fs.deleteBooth(id);
  }
}

final boothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(() => BoothsNotifier());

// ==========================================
// 5. ANNOUNCEMENTS STATE
// ==========================================
class AnnouncementsNotifier extends Notifier<List<Announcement>> {
  StreamSubscription? _sub;

  @override
  List<Announcement> build() {
    _sub = _fs.announcementsStream().listen((dataList) {
      state = dataList.map((m) => Announcement.fromJson(m)).toList();
    });
    ref.onDispose(() => _sub?.cancel());
    return [];
  }

  void addAnnouncement(Announcement ann) {
    state = [...state, ann];
    _fs.setAnnouncement(ann.id, ann.toJson());
  }

  void updateAnnouncement(Announcement updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final a in state)
        if (a.id == updated.id) data else a
    ];
    _fs.setAnnouncement(updated.id, data.toJson());
  }

  void deleteAnnouncement(String id) {
    state = state.where((a) => a.id != id).toList();
    _fs.deleteAnnouncement(id);
  }

  void togglePinned(String id) {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final toggled = state[idx].copyWith(pinned: !state[idx].pinned, updatedAt: DateTime.now());
    state = [
      for (final a in state)
        if (a.id == id) toggled else a
    ];
    _fs.setAnnouncement(id, toggled.toJson());
  }

  void togglePublish(String id) {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final a = state[idx];
    final toggled = a.copyWith(
      publicationStatus: a.publicationStatus == 'published' ? 'draft' : 'published',
      publishedAt: a.publicationStatus != 'published' ? DateTime.now() : a.publishedAt,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final a in state)
        if (a.id == id) toggled else a
    ];
    _fs.setAnnouncement(id, toggled.toJson());
  }
}

final announcementsProvider = NotifierProvider<AnnouncementsNotifier, List<Announcement>>(() => AnnouncementsNotifier());

// ==========================================
// 6. PUBLISHED AWARD WINNERS STATE
// ==========================================
class AwardsNotifier extends Notifier<List<PublishedAwardWinner>> {
  StreamSubscription? _sub;

  @override
  List<PublishedAwardWinner> build() {
    _sub = _fs.awardWinnersStream().listen((dataList) {
      state = dataList.map((m) => PublishedAwardWinner.fromJson(m)).toList();
    });
    ref.onDispose(() => _sub?.cancel());
    return [];
  }

  void addWinner(PublishedAwardWinner winner) {
    state = [...state, winner];
    _fs.setAwardWinner(winner.id, winner.toJson());
  }

  void updateWinner(PublishedAwardWinner updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final w in state)
        if (w.id == updated.id) data else w
    ];
    _fs.setAwardWinner(updated.id, data.toJson());
  }

  void deleteWinner(String id) {
    state = state.where((w) => w.id != id).toList();
    _fs.deleteAwardWinner(id);
  }
}

final awardsProvider = NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(() => AwardsNotifier());

// ==========================================
// 7. EXCEL IMPORTS & STAGING WORKFLOW STATE
// ==========================================
class ImportsNotifier extends Notifier<List<ImportRecord>> {
  StreamSubscription? _sub;

  @override
  List<ImportRecord> build() {
    _sub = _fs.importsStream().listen((dataList) {
      state = dataList.map((m) => ImportRecord.fromJson(m)).toList();
    });
    ref.onDispose(() => _sub?.cancel());
    return [];
  }

  void addImport(ImportRecord r) {
    state = [r, ...state];
    _fs.setImport(r.id, r.toJson());
  }

  void updateImport(ImportRecord updated) {
    state = [
      for (final r in state)
        if (r.id == updated.id) updated else r
    ];
    _fs.setImport(updated.id, updated.toJson());
  }
}

final importsProvider = NotifierProvider<ImportsNotifier, List<ImportRecord>>(() => ImportsNotifier());

// Staging candidate dictionaries (stream-based)
final scheduleCandidatesProvider = StreamProvider.family<List<ScheduleCandidate>, String>((ref, importId) {
  return _fs.scheduleCandidatesStream(importId).map((list) {
    return list.map((m) => ScheduleCandidate.fromJson(m)).toList();
  });
});

final awardCandidatesProvider = StreamProvider.family<List<AwardCandidate>, String>((ref, importId) {
  return _fs.awardCandidatesStream(importId).map((list) {
    return list.map((m) => AwardCandidate.fromJson(m)).toList();
  });
});

final privacySkipsProvider = StreamProvider.family<List<PrivacySkip>, String>((ref, importId) {
  return _fs.privacySkipsStream(importId).map((list) {
    return list.map((m) => PrivacySkip.fromJson(m)).toList();
  });
});

final validationIssuesProvider = StreamProvider.family<List<ValidationIssue>, String>((ref, importId) {
  return _fs.validationIssuesStream(importId).map((list) {
    return list.map((m) => ValidationIssue.fromJson(m)).toList();
  });
});
