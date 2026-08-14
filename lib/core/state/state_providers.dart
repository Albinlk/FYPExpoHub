import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/project.dart';
import '../domain/models/schedule_item.dart';
import '../domain/models/announcement.dart';
import '../domain/models/booth.dart';
import '../domain/models/award.dart';
import '../domain/models/event.dart';
import '../domain/models/import_models.dart';
import '../domain/models/lecturer.dart';
import '../domain/models/project_lecturer_assignment.dart';
import '../domain/models/student_visit.dart';
import '../domain/models/feedback_entry.dart';
import '../data/excel_data.dart';
import '../supabase/supabase_client_provider.dart';
import '../supabase/supabase_database_service.dart';
import '../supabase/supabase_rpc_service.dart';
import '../supabase/supabase_realtime_service.dart';
import '../utils/logger.dart';

// ==============================================================================
// SERVICE PROVIDERS
// ==============================================================================
final supabaseDbServiceProvider = Provider<SupabaseDatabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseDatabaseService(client);
});

final supabaseRpcServiceProvider = Provider<SupabaseRpcService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRpcService(client);
});

final supabaseRealtimeServiceProvider = Provider<SupabaseRealtimeService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRealtimeService(client);
});

// ==============================================================================
// KEY NORMALIZER UTILITY (PostgreSQL snake_case <-> Dart camelCase)
// ==============================================================================
Map<String, dynamic> _normalizeKeys(Map<String, dynamic> data) {
  final res = <String, dynamic>{};
  data.forEach((k, v) {
    var key = k;
    if (k == 'event_id') key = 'eventId';
    else if (k == 'matric_id') key = 'matricId';
    else if (k == 'programme_code') key = 'programmeCode';
    else if (k == 'programme_name') key = 'programmeName';
    else if (k == 'short_description') key = 'shortDescription';
    else if (k == 'tech_tags' || k == 'technology_tags') key = 'technologyTags';
    else if (k == 'booth_id') key = 'boothId';
    else if (k == 'booth_number') key = 'boothNumber';
    else if (k == 'booth_zone') key = 'boothZone';
    else if (k == 'presentation_day') key = 'presentationDay';
    else if (k == 'cover_image_url') key = 'coverImageUrl';
    else if (k == 'poster_url') key = 'posterUrl';
    else if (k == 'team_display_name' || k == 'team_display_names') key = 'teamDisplayNames';
    else if (k == 'supervisor_display_name') key = 'supervisorDisplayName';
    else if (k == 'examiner_display_name') key = 'examinerDisplayName';
    else if (k == 'demo_url') key = 'demoUrl';
    else if (k == 'video_url') key = 'videoUrl';
    else if (k == 'repository_url') key = 'repositoryUrl';
    else if (k == 'industry_candidate' || k == 'calon_industri') key = 'calonIndustri';
    else if (k == 'publication_status') key = 'publicationStatus';
    else if (k == 'created_at') key = 'createdAt';
    else if (k == 'updated_at') key = 'updatedAt';
    else if (k == 'published_at') key = 'publishedAt';
    else if (k == 'start_at') key = 'startAt';
    else if (k == 'end_at') key = 'endAt';
    else if (k == 'session_label') key = 'sessionLabel';
    else if (k == 'daily_hours') key = 'dailyHours';
    else if (k == 'location_details') key = 'locationDetails';
    else if (k == 'map_url') key = 'mapUrl';
    else if (k == 'hero_image_url') key = 'heroImageUrl';
    else if (k == 'public_contact_email') key = 'publicContactEmail';
    else if (k == 'faq_items') key = 'faqItems';
    else if (k == 'location_note') key = 'locationNote';
    else if (k == 'floor_plan_url' || k == 'static_floor_plan_url') key = 'staticFloorPlanUrl';
    else if (k == 'linked_project_id' || k == 'project_id') key = 'projectId';
    else if (k == 'is_pinned') key = 'pinned';
    else if (k == 'category_id' || k == 'award_category_id') key = 'awardCategoryId';
    else if (k == 'lecturer_id') key = 'lecturerId';
    else if (k == 'lecturer_display_name') key = 'lecturerDisplayName';
    else if (k == 'lecturer_email') key = 'lecturerEmail';
    else if (k == 'assigned_at') key = 'assignedAt';
    else if (k == 'visit_role') key = 'visitRole';
    else if (k == 'visited_at') key = 'visitedAt';
    else if (k == 'visit_note') key = 'visitNote';
    else if (k == 'voided_at') key = 'voidedAt';
    else if (k == 'voided_by') key = 'voidedBy';
    else if (k == 'void_reason') key = 'voidReason';
    else if (k == 'submitted_by' || k == 'user_id') key = 'userId';
    else if (k == 'admin_note') key = 'adminNote';
    else if (k == 'file_name' || k == 'source_file_name') key = 'sourceFileName';
    else if (k == 'file_size_bytes') key = 'fileSizeBytes';
    else if (k == 'uploaded_by') key = 'uploadedBy';
    else if (k == 'uploaded_at') key = 'uploadedAt';

    // Ensure list conversions
    if (key == 'teamDisplayNames' && v is String) {
      res[key] = [v];
    } else if (key == 'technologyTags' && v is List) {
      res[key] = v.cast<String>();
    } else {
      res[key] = v;
    }
  });
  return res;
}

// ==========================================
// 1. EVENT METADATA STATE
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
        state = Event.fromJson(_normalizeKeys(data));
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

// ==========================================
// 2. PROJECTS STATE
// ==========================================
class ProjectsNotifier extends Notifier<List<Project>> {
  ProjectsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  List<Project> _parseProjects(List<Map<String, dynamic>> dataList) {
    return dataList.map((m) {
      final norm = _normalizeKeys(m);
      final project = Project.fromJson(norm);
      if (project.coverImageUrl == 'assets/images/project_placeholder.jpg' ||
          project.coverImageUrl.isEmpty) {
        return project.copyWith(
          coverImageUrl:
              'https://placehold.co/400x250/3b82f6/ffffff?text=${Uri.encodeComponent(project.title)}',
        );
      }
      return project;
    }).toList();
  }

  @override
  List<Project> build() {
    final fallback = ExcelData.allProjects
        .map(
          (m) => Project(
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
            presentationDay: m['presentation_day'] as String?,
            coverImageUrl:
                'https://placehold.co/400x250/3b82f6/ffffff?text=${Uri.encodeComponent(m['title'] as String)}',
            posterUrl: m['poster_url'] as String?,
            teamDisplayNames: (m['team_display_names'] as List).cast<String>(),
            supervisorDisplayName: m['supervisor_display_name'] as String,
            examinerDisplayName: m['examiner_display_name'] as String?,
            demoUrl: m['demo_url'] as String?,
            videoUrl: m['video_url'] as String?,
            repositoryUrl: m['repository_url'] as String?,
            featured: m['featured'] as bool,
            calonIndustri: (m['calon_industri'] as bool?) ?? false,
            publicationStatus: m['publication_status'] as String,
            createdAt: m['created_at'] as DateTime,
            updatedAt: m['updated_at'] as DateTime,
            publishedAt: m['published_at'] as DateTime?,
          ),
        )
        .toList();

    _loadProjects();
    return fallback;
  }

  void _loadProjects() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getProjectsOnce(publishedOnly: publishedOnly);
      if (data.isNotEmpty) {
        state = _parseProjects(data);
      }
    } catch (e) {
      logDebug('Projects load from Supabase warning: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getProjectsOnce(publishedOnly: publishedOnly);
      state = _parseProjects(data);
    } catch (e) {
      logDebug('Projects refresh failed: $e');
    }
  }

  void addProject(Project project) {
    state = [...state, project];
    ref.read(supabaseDbServiceProvider).setProject(project.id, project.toJson());
  }

  void updateProject(Project updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final p in state)
        if (p.id == updated.id) data else p,
    ];
    ref.read(supabaseDbServiceProvider).setProject(updated.id, data.toJson());
  }

  void deleteProject(String id) {
    state = state.where((p) => p.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteProject(id);
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
      for (final item in state)
        if (item.id == id) toggled else item,
    ];
    ref.read(supabaseDbServiceProvider).setProject(id, toggled.toJson());
  }
}

final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  () => ProjectsNotifier(),
);

final publicProjectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(
  () => ProjectsNotifier(publishedOnly: true),
);

final featuredProjectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(publicProjectsProvider).where((p) => p.featured).toList();
});

final projectsMapProvider = Provider<Map<String, Project>>((ref) {
  return Map.fromEntries(
    ref.watch(publicProjectsProvider).map((p) => MapEntry(p.id, p)),
  );
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

final projectVisitCountsProvider =
    NotifierProvider<ProjectVisitCountsNotifier, Map<String, int>>(
      () => ProjectVisitCountsNotifier(),
    );

final mostVisitedProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(publicProjectsProvider);
  final counts = ref.watch(projectVisitCountsProvider);
  final sorted = List<Project>.from(projects)
    ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
  return sorted;
});

// ==========================================
// 3. DAILY SCHEDULE STATE
// ==========================================
class ScheduleNotifier extends Notifier<List<ScheduleItem>> {
  ScheduleNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<ScheduleItem> build() {
    final fallback = ExcelData.allScheduleItems
        .map(
          (m) => ScheduleItem(
            id: m['id'] as String,
            eventId: m['event_id'] as String,
            date: m['date'] as DateTime,
            startAt: m['start_at'] as String,
            endAt: m['end_at'] as String,
            title: m['title'] as String,
            venue: m['venue'] as String,
            audience: m['audience'] as String,
            description: m['description'] as String?,
            visibility: m['visibility'] as String,
            publicationStatus: m['publication_status'] as String,
            createdAt: m['created_at'] as DateTime,
            updatedAt: m['updated_at'] as DateTime,
            publishedAt: m['published_at'] as DateTime?,
          ),
        )
        .toList();

    _loadSchedule();
    return fallback;
  }

  void _loadSchedule() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getScheduleOnce(publishedOnly: publishedOnly);
      if (data.isNotEmpty) {
        state = data.map((m) => ScheduleItem.fromJson(_normalizeKeys(m))).toList();
      }
    } catch (e) {
      logDebug('Schedule load from Supabase warning: $e');
    }
  }

  void addScheduleItem(ScheduleItem item) {
    state = [...state, item];
    ref.read(supabaseDbServiceProvider).setScheduleItem(item.id, item.toJson());
  }

  void updateScheduleItem(ScheduleItem updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final s in state)
        if (s.id == updated.id) data else s,
    ];
    ref.read(supabaseDbServiceProvider).setScheduleItem(updated.id, data.toJson());
  }

  void deleteScheduleItem(String id) {
    state = state.where((s) => s.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteScheduleItem(id);
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
      for (final item in state)
        if (item.id == id) toggled else item,
    ];
    ref.read(supabaseDbServiceProvider).setScheduleItem(id, toggled.toJson());
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(
  () => ScheduleNotifier(),
);

final publicScheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(
  () => ScheduleNotifier(publishedOnly: true),
);

// ==========================================
// 4. PHYSICAL BOOTH ALLOCATIONS STATE
// ==========================================
class BoothsNotifier extends Notifier<List<Booth>> {
  BoothsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<Booth> build() {
    final fallback = ExcelData.allBooths
        .map(
          (m) => Booth(
            id: m['id'] as String,
            eventId: m['event_id'] as String,
            boothNumber: m['booth_number'] as String,
            zone: m['zone'] as String,
            locationNote: m['location_note'] as String,
            staticFloorPlanUrl: m['static_floor_plan_url'] as String?,
            projectId: m['project_id'] as String?,
            presentationDay: m['presentation_day'] as String?,
            publicationStatus: m['publication_status'] as String,
            createdAt: m['created_at'] as DateTime,
            updatedAt: m['updated_at'] as DateTime,
            publishedAt: m['published_at'] as DateTime?,
          ),
        )
        .toList();

    _loadBooths();
    return fallback;
  }

  void _loadBooths() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getBoothsOnce(publishedOnly: publishedOnly);
      if (data.isNotEmpty) {
        state = data.map((m) => Booth.fromJson(_normalizeKeys(m))).toList();
      }
    } catch (e) {
      logDebug('Booths load from Supabase warning: $e');
    }
  }

  void addBooth(Booth booth) {
    state = [...state, booth];
    ref.read(supabaseDbServiceProvider).setBooth(booth.id, booth.toJson());
  }

  void updateBooth(Booth updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final b in state)
        if (b.id == updated.id) data else b,
    ];
    ref.read(supabaseDbServiceProvider).setBooth(updated.id, data.toJson());
  }

  void deleteBooth(String id) {
    state = state.where((b) => b.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteBooth(id);
  }
}

final boothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(
  () => BoothsNotifier(),
);

final publicBoothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(
  () => BoothsNotifier(publishedOnly: true),
);

// ==========================================
// 5. ANNOUNCEMENTS STATE
// ==========================================
class AnnouncementsNotifier extends Notifier<List<Announcement>> {
  AnnouncementsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<Announcement> build() {
    _loadAnnouncements();
    return [];
  }

  void _loadAnnouncements() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getAnnouncementsOnce(publishedOnly: publishedOnly);
      state = data.map((m) => Announcement.fromJson(_normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Announcements load from Supabase warning: $e');
    }
  }

  void addAnnouncement(Announcement ann) {
    state = [...state, ann];
    ref.read(supabaseDbServiceProvider).setAnnouncement(ann.id, ann.toJson());
  }

  void updateAnnouncement(Announcement updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final a in state)
        if (a.id == updated.id) data else a,
    ];
    ref.read(supabaseDbServiceProvider).setAnnouncement(updated.id, data.toJson());
  }

  void deleteAnnouncement(String id) {
    state = state.where((a) => a.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteAnnouncement(id);
  }

  void togglePinned(String id) {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final toggled = state[idx].copyWith(
      pinned: !state[idx].pinned,
      updatedAt: DateTime.now(),
    );
    state = [
      for (final a in state)
        if (a.id == id) toggled else a,
    ];
    ref.read(supabaseDbServiceProvider).setAnnouncement(id, toggled.toJson());
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
      for (final item in state)
        if (item.id == id) toggled else item,
    ];
    ref.read(supabaseDbServiceProvider).setAnnouncement(id, toggled.toJson());
  }
}

final announcementsProvider =
    NotifierProvider<AnnouncementsNotifier, List<Announcement>>(
      () => AnnouncementsNotifier(),
    );

final publicAnnouncementsProvider =
    NotifierProvider<AnnouncementsNotifier, List<Announcement>>(
      () => AnnouncementsNotifier(publishedOnly: true),
    );

// ==========================================
// 6. PUBLISHED AWARD WINNERS STATE
// ==========================================
class AwardsNotifier extends Notifier<List<PublishedAwardWinner>> {
  AwardsNotifier({this.publishedOnly = false});

  final bool publishedOnly;

  @override
  List<PublishedAwardWinner> build() {
    _loadAwards();
    return [];
  }

  void _loadAwards() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getAwardWinnersOnce(publishedOnly: publishedOnly);
      state = data.map((m) => PublishedAwardWinner.fromJson(_normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Awards load from Supabase warning: $e');
    }
  }

  void addWinner(PublishedAwardWinner winner) {
    state = [...state, winner];
    ref.read(supabaseDbServiceProvider).setAwardWinner(winner.id, winner.toJson());
  }

  void updateWinner(PublishedAwardWinner updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final w in state)
        if (w.id == updated.id) data else w,
    ];
    ref.read(supabaseDbServiceProvider).setAwardWinner(updated.id, data.toJson());
  }

  void deleteWinner(String id) {
    state = state.where((w) => w.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteAwardWinner(id);
  }
}

final awardsProvider =
    NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(
      () => AwardsNotifier(),
    );

final publicAwardsProvider =
    NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(
      () => AwardsNotifier(publishedOnly: true),
    );

// ==========================================
// 7. EXCEL IMPORTS & STAGING WORKFLOW STATE
// ==========================================
class ImportsNotifier extends Notifier<List<ImportRecord>> {
  @override
  List<ImportRecord> build() {
    _loadImports();
    return [];
  }

  void _loadImports() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getImportsOnce();
      state = data.map((m) => ImportRecord.fromJson(_normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Imports load warning: $e');
    }
  }

  void addImport(ImportRecord r) {
    state = [r, ...state];
    ref.read(supabaseDbServiceProvider).setImport(r.id, r.toJson());
  }

  void updateImport(ImportRecord updated) {
    state = [
      for (final r in state)
        if (r.id == updated.id) updated else r,
    ];
    ref.read(supabaseDbServiceProvider).setImport(updated.id, updated.toJson());
  }
}

final importsProvider = NotifierProvider<ImportsNotifier, List<ImportRecord>>(
  () => ImportsNotifier(),
);

final scheduleCandidatesProvider =
    FutureProvider.family<List<ScheduleCandidate>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getScheduleCandidates(importId);
      return list.map((m) => ScheduleCandidate.fromJson(_normalizeKeys(m))).toList();
    });

final awardCandidatesProvider =
    FutureProvider.family<List<AwardCandidate>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getAwardCandidates(importId);
      return list.map((m) => AwardCandidate.fromJson(_normalizeKeys(m))).toList();
    });

final privacySkipsProvider =
    FutureProvider.family<List<PrivacySkip>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getPrivacySkips(importId);
      return list.map((m) => PrivacySkip.fromJson(_normalizeKeys(m))).toList();
    });

final validationIssuesProvider =
    FutureProvider.family<List<ValidationIssue>, String>((ref, importId) async {
      final db = ref.read(supabaseDbServiceProvider);
      final list = await db.getValidationIssues(importId);
      return list.map((m) => ValidationIssue.fromJson(_normalizeKeys(m))).toList();
    });

// ==========================================
// 8. LECTURER CONFIG & AUTH STATE
// ==========================================
const hardcodedLecturerConfig = <String, String>{
  'albin1841@uitm.edu.my': 'ALBIN LEMUEL KUSHAN',
};

final allLecturersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.read(supabaseDbServiceProvider);
  return db.getLecturersOnce();
});

final lecturerConfigProvider = Provider<Map<String, String>>((ref) {
  final all = ref.watch(allLecturersProvider);
  final result = <String, String>{};
  final list = all.asData?.value ?? [];
  for (final doc in list) {
    final email = (doc['email'] ?? doc['display_name']) as String?;
    final name = (doc['displayName'] ?? doc['display_name']) as String?;
    if (email != null && name != null) {
      result[email.toLowerCase()] = name;
    }
  }
  result.addAll(hardcodedLecturerConfig);
  return result;
});

final lecturerAuthProvider = NotifierProvider<LecturerAuthNotifier, Lecturer?>(
  LecturerAuthNotifier.new,
);

class LecturerAuthNotifier extends Notifier<Lecturer?> {
  @override
  Lecturer? build() {
    ref.listen(lecturerConfigProvider, (_, __) => _reevaluate());
    ref.listen(currentAuthUserProvider, (_, __) => _reevaluate());
    _reevaluate();
    return null;
  }

  void _reevaluate() {
    final config = ref.read(lecturerConfigProvider);
    final user = ref.read(currentAuthUserProvider);
    if (user != null && user.email != null) {
      final emailLower = user.email!.toLowerCase();
      final displayName = config[emailLower] ??
          (user.userMetadata?['display_name'] as String?) ??
          user.email!.split('@').first.toUpperCase();

      state = Lecturer(
        id: user.id,
        uid: user.id,
        displayName: displayName,
        email: user.email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      state = null;
    }
  }

  void signOut() async {
    state = null;
    await ref.read(supabaseClientProvider).auth.signOut();
  }
}

final lecturerDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(lecturerAuthProvider)?.displayName;
});

final lecturerUidProvider = Provider<String?>((ref) {
  return ref.watch(lecturerAuthProvider)?.uid;
});

// ==========================================
// 9. PROJECT LECTURER ASSIGNMENTS STATE
// ==========================================
final allAssignmentsProvider = FutureProvider<List<ProjectLecturerAssignment>>((ref) async {
  final db = ref.read(supabaseDbServiceProvider);
  final list = await db.getAssignmentsOnce();
  return list.map((m) => ProjectLecturerAssignment.fromJson(_normalizeKeys(m))).toList();
});

final lecturerAssignmentsProvider = Provider<List<ProjectLecturerAssignment>>((ref) {
  final lecturer = ref.watch(lecturerAuthProvider);
  final all = ref.watch(allAssignmentsProvider);
  if (lecturer == null) return [];
  final allList = all.asData?.value ?? [];
  return allList
      .where(
        (a) =>
            a.status == 'active' &&
            ((a.lecturerId != null && a.lecturerId == lecturer.uid) ||
                (a.lecturerId == null &&
                    a.lecturerDisplayName.toLowerCase().contains(
                      lecturer.displayName.toLowerCase(),
                    ))),
      )
      .toList();
});

// ==========================================
// 10. STUDENT VISITS STATE
// ==========================================
final allVisitsProvider = FutureProvider<List<StudentVisit>>((ref) async {
  final db = ref.read(supabaseDbServiceProvider);
  final list = await db.getVisitsOnce();
  return list.map((m) => StudentVisit.fromJson(_normalizeKeys(m))).toList();
});

final lecturerVisitsProvider = Provider<List<StudentVisit>>((ref) {
  final lecturer = ref.watch(lecturerAuthProvider);
  final all = ref.watch(allVisitsProvider);
  if (lecturer == null) return [];
  final allList = all.asData?.value ?? [];
  return allList.where((v) => v.lecturerId == lecturer.uid).toList();
});

final completedVisitsProvider = Provider<Set<String>>((ref) {
  final visits = ref.watch(lecturerVisitsProvider);
  return visits
      .where((v) => v.status == 'completed')
      .map((v) => '${v.projectId}_${v.visitRole}')
      .toSet();
});

// ==========================================
// 11. FEEDBACK ENTRIES STATE
// ==========================================
class FeedbackEntriesNotifier extends Notifier<List<FeedbackEntry>> {
  @override
  List<FeedbackEntry> build() {
    _loadFeedback();
    return [];
  }

  void _loadFeedback() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getFeedbackEntriesOnce();
      state = data.map((m) => FeedbackEntry.fromJson(_normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Feedback load warning: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final db = ref.read(supabaseDbServiceProvider);
      final data = await db.getFeedbackEntriesOnce();
      state = data.map((m) => FeedbackEntry.fromJson(_normalizeKeys(m))).toList();
    } catch (e) {
      logDebug('Feedback refresh failed: $e');
    }
  }

  void addFeedbackEntry(FeedbackEntry entry) {
    state = [entry, ...state];
    ref.read(supabaseDbServiceProvider).setFeedbackEntry(entry.id, entry.toJson());
  }

  void updateFeedbackEntry(FeedbackEntry updated) {
    final data = updated.copyWith(updatedAt: DateTime.now());
    state = [
      for (final f in state)
        if (f.id == updated.id) data else f,
    ];
    ref.read(supabaseDbServiceProvider).setFeedbackEntry(updated.id, data.toJson());
  }

  void deleteFeedbackEntry(String id) {
    state = state.where((f) => f.id != id).toList();
    ref.read(supabaseDbServiceProvider).deleteFeedbackEntry(id);
  }

  void setStatus(String id, String status) {
    final idx = state.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    final updated = state[idx].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    updateFeedbackEntry(updated);
  }

  void setAdminNote(String id, String note) {
    final idx = state.indexWhere((f) => f.id == id);
    if (idx == -1) return;
    final updated = state[idx].copyWith(
      adminNote: note,
      updatedAt: DateTime.now(),
    );
    updateFeedbackEntry(updated);
  }
}

final feedbackEntriesProvider =
    NotifierProvider<FeedbackEntriesNotifier, List<FeedbackEntry>>(
      () => FeedbackEntriesNotifier(),
    );

final myFeedbackProvider = Provider<List<FeedbackEntry>>((ref) {
  final uid = ref.watch(currentAuthUserProvider)?.id;
  if (uid == null) return const [];
  return ref.watch(feedbackEntriesProvider).where((f) => f.userId == uid).toList();
});
