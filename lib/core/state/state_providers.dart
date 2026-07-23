import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/project.dart';
import '../domain/models/schedule_item.dart';
import '../domain/models/announcement.dart';
import '../domain/models/booth.dart';
import '../domain/models/award.dart';
import '../domain/models/event.dart';
import '../domain/models/import_models.dart';
import '../data/excel_data.dart';

// ==========================================
// 1. EVENT METADATA STATE
// ==========================================
class EventNotifier extends Notifier<Event> {
  @override
  Event build() {
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
        const FaqItem(
          question: 'What is FYP Expo Hub?',
          answer: 'It is the official web portal for the Final Year Project Exhibition of the Faculty of Computer and Mathematical Sciences (FSKM).'
        ),
        const FaqItem(
          question: 'Who can attend the exhibition?',
          answer: 'The exhibition is open to all UiTM students, faculty members, and external industry visitors who are interested in final year student innovations.'
        ),
        const FaqItem(
          question: 'Are there awards given to the projects?',
          answer: 'Yes, projects are evaluated by a panel of industry and academic juries, and awards like Gold, Silver, Bronze, and Best Innovative Project are presented.'
        ),
      ],
      publicationStatus: 'published',
      updatedAt: DateTime.now(),
      publishedAt: DateTime.now(),
    );
  }

  void updateEvent(Event newEvent) {
    state = newEvent.copyWith(updatedAt: DateTime.now());
  }
}

final eventProvider = NotifierProvider<EventNotifier, Event>(() {
  return EventNotifier();
});

// ==========================================
// 2. PROJECTS STATE
// ==========================================
class ProjectsNotifier extends Notifier<List<Project>> {
  @override
  List<Project> build() {
    return ExcelData.allProjects.map((m) {
      return Project(
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
      );
    }).toList();
  }

  void addProject(Project project) {
    state = [...state, project];
  }

  void updateProject(Project updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated.copyWith(updatedAt: DateTime.now()) else p
    ];
  }

  void deleteProject(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void togglePublishStatus(String id) {
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            publicationStatus: p.publicationStatus == 'published' ? 'draft' : 'published',
            publishedAt: p.publicationStatus != 'published' ? DateTime.now() : null,
            updatedAt: DateTime.now(),
          )
        else
          p
    ];
  }
}

final projectsProvider = NotifierProvider<ProjectsNotifier, List<Project>>(() {
  return ProjectsNotifier();
});

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

final projectVisitCountsProvider = NotifierProvider<ProjectVisitCountsNotifier, Map<String, int>>(() {
  return ProjectVisitCountsNotifier();
});

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
  @override
  List<ScheduleItem> build() {
    final items = ExcelData.allScheduleItems.map((m) {
      return ScheduleItem(
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
        sourceImportId: m['source_import_id'] as String?,
        sourceStagingId: m['source_staging_id'] as String?,
        createdAt: m['created_at'] as DateTime,
        updatedAt: m['updated_at'] as DateTime,
        publishedAt: m['published_at'] as DateTime?,
      );
    }).toList();
    // Also keep the existing general schedule items
    return [
      ScheduleItem(
        id: 'sch-gen-1',
        eventId: 'fskm-fyp-2026',
        date: DateTime(2026, 8, 6),
        startAt: '08:30',
        endAt: '09:00',
        title: 'Pendaftaran Juri & Peserta',
        venue: 'Blok Kuliah, FSKM',
        audience: 'Juri & Peserta',
        description: 'Sesi penyerahan kit pameran, nombor giliran, dan sarapan pagi bagi juri industri serta peserta pameran.',
        visibility: 'public',
        publicationStatus: 'published',
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
        publishedAt: DateTime(2026, 7, 1),
      ),
      ScheduleItem(
        id: 'sch-gen-2',
        eventId: 'fskm-fyp-2026',
        date: DateTime(2026, 8, 7),
        startAt: '09:00',
        endAt: '17:00',
        title: 'FYP Expo 2026 - Hari Terbuka',
        venue: 'Blok Kuliah, FSKM',
        audience: 'Awam',
        description: 'Sesi pembukaan untuk pelawat dan industri.',
        visibility: 'public',
        publicationStatus: 'published',
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
        publishedAt: DateTime(2026, 7, 1),
      ),
      ...items,
    ];
  }

  void addScheduleItem(ScheduleItem item) {
    state = [...state, item];
  }

  void updateScheduleItem(ScheduleItem updated) {
    state = [
      for (final s in state)
        if (s.id == updated.id) updated.copyWith(updatedAt: DateTime.now()) else s
    ];
  }

  void deleteScheduleItem(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void togglePublish(String id) {
    state = [
      for (final s in state)
        if (s.id == id)
          s.copyWith(
            publicationStatus: s.publicationStatus == 'published' ? 'draft' : 'published',
            publishedAt: s.publicationStatus != 'published' ? DateTime.now() : null,
            updatedAt: DateTime.now(),
          )
        else
          s
    ];
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(() {
  return ScheduleNotifier();
});

// ==========================================
// 4. PHYSICAL BOOTH ALLOCATIONS STATE
// ==========================================
class BoothsNotifier extends Notifier<List<Booth>> {
  @override
  List<Booth> build() {
    return ExcelData.allBooths.map((m) {
      return Booth(
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
      );
    }).toList();
  }

  void addBooth(Booth booth) {
    state = [...state, booth];
  }

  void updateBooth(Booth updated) {
    state = [
      for (final b in state)
        if (b.id == updated.id) updated.copyWith(updatedAt: DateTime.now()) else b
    ];
  }

  void deleteBooth(String id) {
    state = state.where((b) => b.id != id).toList();
  }
}

final boothsProvider = NotifierProvider<BoothsNotifier, List<Booth>>(() {
  return BoothsNotifier();
});

// ==========================================
// 5. ANNOUNCEMENTS STATE
// ==========================================
class AnnouncementsNotifier extends Notifier<List<Announcement>> {
  @override
  List<Announcement> build() {
    return [
      Announcement(
        id: 'ann-1',
        eventId: 'fskm-fyp-2026',
        title: 'Sesi Taklimat Penyediaan Poster Pameran',
        body: 'Semua pelajar tahun akhir FSKM yang mengambil bahagian dalam FYP Expo 2026 diwajibkan menghadiri sesi taklimat pada tarikh 1 Ogos 2026 jam 2.30 petang di Dewan Kuliah 1. Sesi ini akan mengulas format, saiz, dan susun atur poster.',
        category: 'Pemberitahuan Akademik',
        pinned: true,
        publicationStatus: 'published',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
      Announcement(
        id: 'ann-2',
        eventId: 'fskm-fyp-2026',
        title: 'Kemaskini Pemetaan Kedudukan Booth',
        body: 'Sila ambil perhatian bahawa layout kedudukan booth bagi Zon B telah dikemaskini sedikit untuk memberikan laluan pengudaraan yang lebih selesa. Sila layari seksyen "Cari Booth" di portal untuk menyemak kedudukan terbaru anda.',
        category: 'Pengumuman Logistik',
        pinned: false,
        publicationStatus: 'published',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Announcement(
        id: 'ann-3',
        eventId: 'fskm-fyp-2026',
        title: 'Pelawaan Juri Industri dari Syarikat Rakan Kongsi',
        body: 'Kami berbesar hati mengumumkan kemasukan barisan juri baru dari syarikat teknologi terkemuka seperti Petronas, Aerodyne, dan Intel Malaysia yang akan mengadili sesi expo semester ini.',
        category: 'Pengumuman Korporat',
        pinned: false,
        publicationStatus: 'published',
        publishedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void addAnnouncement(Announcement ann) {
    state = [...state, ann];
  }

  void updateAnnouncement(Announcement updated) {
    state = [
      for (final a in state)
        if (a.id == updated.id) updated.copyWith(updatedAt: DateTime.now()) else a
    ];
  }

  void deleteAnnouncement(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void togglePinned(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(pinned: !a.pinned, updatedAt: DateTime.now()) else a
    ];
  }

  void togglePublish(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(
            publicationStatus: a.publicationStatus == 'published' ? 'draft' : 'published',
            publishedAt: a.publicationStatus != 'published' ? DateTime.now() : a.publishedAt,
            updatedAt: DateTime.now(),
          )
        else
          a
    ];
  }
}

final announcementsProvider = NotifierProvider<AnnouncementsNotifier, List<Announcement>>(() {
  return AnnouncementsNotifier();
});

// ==========================================
// 6. PUBLISHED AWARD WINNERS STATE
// ==========================================
class AwardsNotifier extends Notifier<List<PublishedAwardWinner>> {
  @override
  List<PublishedAwardWinner> build() {
    final projects = ref.read(projectsProvider);
    return [
      PublishedAwardWinner(
        id: 'win-1',
        eventId: 'fskm-fyp-2026',
        awardCategoryId: 'cat-gold',
        projectId: 'proj-cs230-004',
        projectTitle: 'JELAJAH VR: AN IMMERSIVE VIRTUAL REALITY LEARNING SYSTEM WITH ADAPTIVE TIMELINE NAVIGATION FOR SECONDARY SCHOOL HISTORY EDUCATION',
        programmeCode: 'CS230',
        teamDisplayName: 'ANIQ IRFAN BIN MOHD HAFEZ',
        supervisorDisplayName: 'PN ZAMLINA BINTI ABDULLAH',
        publicationStatus: 'published',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        publishedAt: DateTime.now(),
      ),
      PublishedAwardWinner(
        id: 'win-2',
        eventId: 'fskm-fyp-2026',
        awardCategoryId: 'cat-best-innovative',
        projectId: 'proj-cs251-096',
        projectTitle: 'DEVELOPMENT OF SOCIAL MUSIC DISCOVERY PLATFORM USING PEER BASED SOCIAL NETWORKS AND HYBRID FILTERING',
        programmeCode: 'CS251',
        teamDisplayName: 'ADAM BIN MOHD AKIB',
        supervisorDisplayName: 'NURUL NAJWA BINTI ABD RAHID@RASHID',
        publicationStatus: 'published',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        publishedAt: DateTime.now(),
      ),
      PublishedAwardWinner(
        id: 'win-3',
        eventId: 'fskm-fyp-2026',
        awardCategoryId: 'cat-manual',
        projectId: 'proj-cs253-161',
        projectTitle: 'SMILEVISION VR: A GAMIFIED VIRTUAL EXPLORATION OF COSMETIC DENTAL TREATMENTS',
        programmeCode: 'CS253',
        teamDisplayName: 'AALIYA QISTINA BINTI MUHAMAD NASIR',
        supervisorDisplayName: 'MADAM AZLIN DAHLAN',
        publicationStatus: 'published',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publishedAt: DateTime.now(),
      ),
    ];
  }

  void addWinner(PublishedAwardWinner winner) {
    state = [...state, winner];
  }

  void updateWinner(PublishedAwardWinner updated) {
    state = [
      for (final w in state)
        if (w.id == updated.id) updated.copyWith(updatedAt: DateTime.now()) else w
    ];
  }

  void deleteWinner(String id) {
    state = state.where((w) => w.id != id).toList();
  }
}

final awardsProvider = NotifierProvider<AwardsNotifier, List<PublishedAwardWinner>>(() {
  return AwardsNotifier();
});

// ==========================================
// 7. EXCEL IMPORTS & STAGING WORKFLOW STATE
// ==========================================
class ImportsNotifier extends Notifier<List<ImportRecord>> {
  @override
  List<ImportRecord> build() {
    return [
      ImportRecord(
        id: 'imp-001',
        eventId: 'fskm-fyp-2026',
        sourceFilePath: 'private/imports/imp-001/FSKM_FYP_Master_v1.xlsx',
        sourceFileName: 'FSKM_FYP_Master_v1.xlsx',
        sourceFileHash: 'sha256-a94b8e23f81e',
        uploadedBy: 'admin@uitm.edu.my',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        parserVersion: 'v1.0.0',
        status: 'completed',
        summary: {'tentatif': 6, 'pemenang': 3},
        warningCounts: {'overlap': 0, 'privacy': 8},
        completedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ImportRecord(
        id: 'imp-002',
        eventId: 'fskm-fyp-2026',
        sourceFilePath: 'private/imports/imp-002/FSKM_FYP_New_Imports_v2.xlsx',
        sourceFileName: 'FSKM_FYP_New_Imports_v2.xlsx',
        sourceFileHash: 'sha256-f8e9102c0192',
        uploadedBy: 'admin@uitm.edu.my',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 4)),
        parserVersion: 'v1.0.0',
        status: 'pending_review',
        summary: {'tentatif': 3, 'pemenang': 2},
        warningCounts: {'overlap': 1, 'privacy': 4},
      ),
    ];
  }

  void addImport(ImportRecord r) {
    state = [r, ...state];
  }

  void updateImport(ImportRecord updated) {
    state = [
      for (final r in state)
        if (r.id == updated.id) updated else r
    ];
  }
}

final importsProvider = NotifierProvider<ImportsNotifier, List<ImportRecord>>(() {
  return ImportsNotifier();
});

// Staging candidate dictionaries
final scheduleCandidatesProvider = Provider.family<List<ScheduleCandidate>, String>((ref, importId) {
  if (importId == 'imp-002') {
    return [
      ScheduleCandidate(
        id: 'cand-sch-1',
        date: DateTime(2026, 8, 6),
        startAt: '10:00 AM',
        endAt: '11:00 AM',
        title: 'Sesi Pembentangan Poster Kumpulan 1',
        venue: 'Bilik Kuliah B-21',
        audience: 'Pelajar & Juri Sektor B',
        classification: 'publicCandidate',
        comparisonStatus: 'new',
        isDuplicate: false,
        isOverlapping: false,
      ),
      ScheduleCandidate(
        id: 'cand-sch-2',
        date: DateTime(2026, 8, 6),
        startAt: '11:30 AM',
        endAt: '12:30 PM',
        title: 'Penilaian Juri Sesi 1', // Overlaps with live Sesi 1
        venue: 'Blok Kuliah, FSKM',
        audience: 'Juri & Peserta',
        classification: 'needsReview',
        comparisonStatus: 'updated',
        isDuplicate: true,
        isOverlapping: true,
      ),
      ScheduleCandidate(
        id: 'cand-sch-3',
        date: DateTime(2026, 8, 7),
        startAt: '01:00 PM',
        endAt: '02:00 PM',
        title: 'Sesi Demonstrasi Sistem Web FSKM',
        venue: 'Lab Komputer 3',
        audience: 'Pelawat & Pelajar',
        classification: 'publicCandidate',
        comparisonStatus: 'new',
        isDuplicate: false,
        isOverlapping: false,
      ),
    ];
  }
  return [];
});

final awardCandidatesProvider = Provider.family<List<AwardCandidate>, String>((ref, importId) {
  if (importId == 'imp-002') {
    return [
      AwardCandidate(
        id: 'cand-aw-1',
        awardCategory: 'Anugerah Inovasi Emas',
        projectTitle: 'JELAJAH VR: AN IMMERSIVE VIRTUAL REALITY LEARNING SYSTEM WITH ADAPTIVE TIMELINE NAVIGATION FOR SECONDARY SCHOOL HISTORY EDUCATION',
        teamDisplayName: 'ANIQ IRFAN BIN MOHD HAFEZ',
        supervisorDisplayName: 'PN ZAMLINA BINTI ABDULLAH',
        programmeCode: 'CS230',
        isSkip: false,
      ),
      AwardCandidate(
        id: 'cand-aw-2',
        awardCategory: 'Anugerah Projek Terbaik CS251',
        projectTitle: 'DEVELOPMENT OF SOCIAL MUSIC DISCOVERY PLATFORM USING PEER BASED SOCIAL NETWORKS AND HYBRID FILTERING',
        teamDisplayName: 'ADAM BIN MOHD AKIB',
        supervisorDisplayName: 'NURUL NAJWA BINTI ABD RAHID@RASHID',
        programmeCode: 'CS251',
        isSkip: false,
      ),
    ];
  }
  return [];
});

final privacySkipsProvider = Provider.family<List<PrivacySkip>, String>((ref, importId) {
  if (importId == 'imp-002') {
    return [
      PrivacySkip(
        id: 'skip-1',
        skipType: 'Student MyKad / ID',
        count: 4,
        reason: 'Skip Student Identification Numbers to maintain PDPA 2010 compliance',
        worksheetName: 'Senarai_Pelajar',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      PrivacySkip(
        id: 'skip-2',
        skipType: 'Personal Email & Phone',
        count: 8,
        reason: 'Filtered student personal phone numbers and non-official email domains',
        worksheetName: 'Peserta',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }
  return [];
});

final validationIssuesProvider = Provider.family<List<ValidationIssue>, String>((ref, importId) {
  if (importId == 'imp-002') {
    return [
      const ValidationIssue(
        id: 'iss-1',
        issueType: 'overlap',
        severity: 'warning',
        message: 'Waktu bertindih dikesan: Sesi "Penilaian Juri Sesi 1" (11:30 AM - 12:30 PM) bertembung dengan Tentatif sedia ada.',
        worksheetName: 'Tentatif',
        rowNumber: 4,
      ),
      const ValidationIssue(
        id: 'iss-2',
        issueType: 'blank_row',
        severity: 'warning',
        message: 'Baris kosong dikesan dan diabaikan secara automatik semasa pengesahan.',
        worksheetName: 'Senarai_Anugerah',
        rowNumber: 12,
      ),
    ];
  }
  return [];
});
