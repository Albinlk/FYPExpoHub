import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
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
import '../data/offline_fallback.dart';
import '../supabase/supabase_client_provider.dart';
import '../supabase/supabase_database_service.dart';
import '../supabase/supabase_rpc_service.dart';
import '../supabase/supabase_realtime_service.dart';
import '../supabase/supabase_storage_service.dart';
import '../utils/fypms_key_normalizer.dart' show normalizeKeys;
import '../utils/logger.dart';
import '../widgets/project_cover_image.dart';

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

final supabaseStorageServiceProvider = Provider<SupabaseStorageService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseStorageService(client);
});

// ==============================================================================
// KEY NORMALIZER — delegates to shared map-lookup normalizer (O(1) vs 70-branch)
// ==============================================================================
Map<String, dynamic> _normalizeKeys(Map<String, dynamic> data) => normalizeKeys(data);

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
      // Placeholder rows keep an EMPTY cover url — ProjectCoverImage then
      // renders its deterministic generated gradient cover locally
      // (no third-party placehold.co requests).
      if (project.coverImageUrl == 'assets/images/project_placeholder.jpg' ||
          ProjectCoverImage.isPlaceholderUrl(project.coverImageUrl)) {
        return project.copyWith(coverImageUrl: '');
      }
      return project;
    }).toList();
  }

  @override
  List<Project> build() {
    _loadProjects();
    return const [];
  }

  /// Loads remote data and the offline-fallback asset in parallel. The
  /// fallback fills state first (near-instant content), and live Supabase
  /// rows overwrite it as soon as they arrive — the fallback is skipped
  /// entirely if remote wins the race.
  ///
  /// The remote future gets an immediate no-op catchError so its error is
  /// never unhandled in the window before the later await re-throws into
  /// the local try/catch.
  void _loadProjects() async {
    final remote = _fetchRemote().catchError(
      (Object e) => <Map<String, dynamic>>[],
    );
    try {
      final data = await OfflineFallback.load();
      final fallback = _parseProjects(data['projects'] ?? const []);
      if (state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
      }
    } catch (e) {
      logDebug('Projects fallback asset warning: $e');
    }
    try {
      final data = await remote;
      if (data.isNotEmpty) {
        state = _parseProjects(data);
      }
    } catch (e) {
      logDebug('Projects load from Supabase warning: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemote() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getProjectsOnce(publishedOnly: publishedOnly);
  }

  Future<void> refresh() async {
    try {
      final data = await _fetchRemote();
      if (data.isNotEmpty) {
        state = _parseProjects(data);
      }
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
    _loadSchedule();
    return const [];
  }

  /// Same pattern as ProjectsNotifier: fallback asset fills state first,
  /// live Supabase rows overwrite it when they arrive (remote wins).
  void _loadSchedule() async {
    final remote = _fetchRemoteSchedule().catchError(
      (Object e) => <Map<String, dynamic>>[],
    );
    try {
      final data = await OfflineFallback.load();
      final fallback = (data['scheduleItems'] ?? const [])
          .map((m) => ScheduleItem.fromJson(_normalizeKeys(m)))
          .toList();
      if (state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
      }
    } catch (e) {
      logDebug('Schedule fallback asset warning: $e');
    }
    try {
      final data = await remote;
      if (data.isNotEmpty) {
        state = data.map((m) => ScheduleItem.fromJson(_normalizeKeys(m))).toList();
      }
    } catch (e) {
      logDebug('Schedule load from Supabase warning: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteSchedule() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getScheduleOnce(publishedOnly: publishedOnly);
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
    _loadBooths();
    return const [];
  }

  /// Same pattern as ProjectsNotifier: fallback asset fills state first,
  /// live Supabase rows overwrite it when they arrive (remote wins).
  void _loadBooths() async {
    final remote = _fetchRemoteBooths().catchError(
      (Object e) => <Map<String, dynamic>>[],
    );
    try {
      final data = await OfflineFallback.load();
      final fallback = (data['booths'] ?? const [])
          .map((m) => Booth.fromJson(_normalizeKeys(m)))
          .toList();
      if (state.isEmpty && fallback.isNotEmpty) {
        state = fallback;
      }
    } catch (e) {
      logDebug('Booths fallback asset warning: $e');
    }
    try {
      final data = await remote;
      if (data.isNotEmpty) {
        state = data.map((m) => Booth.fromJson(_normalizeKeys(m))).toList();
      }
    } catch (e) {
      logDebug('Booths load from Supabase warning: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteBooths() async {
    final db = ref.read(supabaseDbServiceProvider);
    return db.getBoothsOnce(publishedOnly: publishedOnly);
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

/// Lecturer config gated on sign-in: anonymous visitors never initialize
/// the config (and therefore never fire the lecturers-table query).
final _lecturerConfigWhenSignedIn = Provider<Map<String, String>?>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return null;
  return ref.watch(lecturerConfigProvider);
});

class LecturerAuthNotifier extends Notifier<Lecturer?> {
  @override
  Lecturer? build() {
    // Only react to auth changes. The lecturer CONFIG (display names via
    // allLecturersProvider -> getLecturersOnce) is read lazily below when a
    // user is actually signed in — previously this notifier eagerly fired a
    // lecturers-table query on every anonymous page load.
    final initial = _evaluate(user: ref.read(currentAuthUserProvider));
    ref.listen(
      currentAuthUserProvider,
      (_, next) => state = _evaluate(user: next),
    );
    // Re-resolve the display name once the config arrives (only possible
    // when signed in — the gated provider is a no-op otherwise).
    ref.listen(_lecturerConfigWhenSignedIn, (_, __) {
      state = _evaluate(user: ref.read(currentAuthUserProvider));
    });
    return initial;
  }

  Lecturer? _evaluate({User? user}) {
    if (user == null || user.email == null) return null;
    // Signed in: now (and only now) read the config for the display name.
    // lecturerConfigProvider watching allLecturersProvider only triggers
    // the lecturers-table query from authenticated sessions.
    final config = ref.read(lecturerConfigProvider);
    final emailLower = user.email!.toLowerCase();
    final displayName = config[emailLower] ??
        (user.userMetadata?['display_name'] as String?) ??
        user.email!.split('@').first.toUpperCase();

    return Lecturer(
      id: user.id,
      uid: user.id,
      displayName: displayName,
      email: user.email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
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
