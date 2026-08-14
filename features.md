# FYP Expo Hub — Functions & Features Reference

The official web portal for the **Final Year Project Exhibition (FYP Expo)** of the Faculty of Computer and Mathematical Sciences (FSKM), UiTM, Malaysia. A Flutter Web + Firebase application that digitises the full exhibition lifecycle: project catalogue, daily schedule, booth map, announcements, award winners, a lecturer **"My Visits"** booth sign-off system, a visitor feedback facility, and a complete admin CMS with Excel master-file import.

- **Public site:** https://fskmjasinfypexhibition.site (GitHub Pages)
- **Admin CMS:** https://admin.fskmjasinfypexhibition.site (Firebase Hosting)
- **Fallback:** https://fyp-expo-hub.web.app
- **Event:** FSKM FYP Expo Hub 2026 — 6–7 August 2026, Lecture Block, FSKM (9:00 AM – 5:00 PM daily)

---

## Table of Contents

1. [Stack Overview](#1-stack-overview)
2. [Roles & Authentication](#2-roles--authentication)
3. [Routing Map](#3-routing-map)
4. [Public Site Features (no login)](#4-public-site-features-no-login)
5. [Lecturer "My Visits" Features](#5-lecturer-my-visits-features)
6. [Admin CMS Features](#6-admin-cms-features)
7. [Cross-Cutting Features](#7-cross-cutting-features)
8. [State Layer — Riverpod Notifiers & Functions](#8-state-layer--riverpod-notifiers--functions)
9. [FirestoreService — Data Access Functions](#9-firesstoreservice--data-access-functions)
10. [Cloud Functions (TypeScript)](#10-cloud-functions-typescript)
11. [Firestore Security Rules](#11-firestore-security-rules)
12. [Data Model](#12-data-model)
13. [SDK Configuration](#13-sdk-configuration)

---

## 1. Stack Overview

### Frontend
| Layer | Technology |
|---|---|
| Language / framework | Flutter (Dart `^3.11.0`), Flutter Web |
| State management | `flutter_riverpod` `^3.3.2` (Notifier / StreamProvider / FutureProvider / Provider) |
| Routing | `go_router` `^17.3.0` (SPA, auth redirect guards) |
| Data models | `freezed` + `json_serializable` (generated via `build_runner`) |
| UI | `google_fonts`, Material 3 custom design tokens (Inter / Montserrat), `flutter_svg`, `cached_network_image`, `file_picker`, `intl`, `uuid` |
| URL strategy | `usePathUrlStrategy()` (clean paths, no `/#/`) |

### Backend (Firebase)
| Service | Purpose |
|---|---|
| **Authentication** | Email/password. Admin via custom claim `admin: true`. Lecturer by UiTM email whitelist in `lecturers` collection. |
| **Cloud Firestore** | Primary database — public collections, admin collections, import staging subcollections, audit logs, visit tracking. |
| **Firebase Storage** | Private XLSX master files (`private/imports/...`, ≤ 10 MB), public assets (`public/assets/...`, ≤ 5 MB). |
| **Cloud Functions** | TypeScript (`firebase-functions` v4, `firebase-admin` v12, `xlsx`, Node 20) — master-file parsing, lecturer lifecycle, visit callables. |
| **Firebase Hosting** | Admin CMS + `fyp-expo-hub.web.app`, SPA rewrites `**` → `/index.html`. |
| **GitHub Pages** | Public domain, auto-deployed via GitHub Actions on push to `main`. |
| **App Check / Analytics** | `firebase_app_check`, `firebase_analytics` wired in to the client. |

### Data flow pattern
1. A UI watches a Riverpod provider.
2. The provider/notifier subscribes to a `FirestoreService` stream (`projectsStream`, `visitsStream`, …) and maps documents → typed freezed models (timestamps recursively converted to ISO strings first).
3. Mutations go through notifier methods (`addX`, `updateX`, `deleteX`) which update local state optimistically **and** persist via `FirestoreService`.
4. Public providers use `publishedOnly: true` queries scoped with `where('publicationStatus', '==', 'published')` so Firestore rules permit anonymous reads.

**Bootstrap (`lib/main.dart`):** `main()` calls `WidgetsFlutterBinding.ensureInitialized()`, `usePathUrlStrategy()`, reads Firebase credentials from build-time `--dart-define` env vars only (never committed), `Firebase.initializeApp(...)` inside try/catch, enables Firestore offline persistence (`Settings(persistenceEnabled: true, cacheSizeBytes: CACHE_SIZE_UNLIMITED)`), then `runApp(ProviderScope(child: FYPExpoHubApp()))`. The app renders `MaterialApp.router` with `AppTheme.lightTheme`.

---

## 2. Roles & Authentication

| Role | How authorised | Access |
|---|---|---|
| **Anonymous visitor** | No sign-in | Public pages only. Rules allow read only on documents where `publicationStatus == 'published'`. |
| **Lecturer** | Firebase Auth with a UiTM email present in the `lecturers` collection (or hardcoded fallback `albin1841@uitm.edu.my`). Determined client-side by `lecturerAuthProvider`. | Public site + `/lecturer/visits`, `/lecturer/visits/:projectId`. Rules restrict visits to own assignments. |
| **Admin** | ID token carries custom claim `admin: true` (set via Firebase Console / Admin SDK). | Full CMS `/admin/**`. Rules use `request.auth.token.admin == true`. |

### Auth providers & helpers
- `firebaseAuthProvider` → `FirebaseAuth.instance`; `firestoreProvider` → `FirebaseFirestore.instance`; `firebaseStorageProvider` → `FirebaseStorage.instance`.
- `authStateChangesProvider` (`StreamProvider<User?>`) — exposes the auth state stream.
- `isAdminProvider` (`FutureProvider<bool>`) — reads `currentUser`, calls `getIdTokenResult()` (cached token, no forced refresh), returns `true` only if `claims['admin'] == true`.
- `lecturerAuthProvider` (`LecturerAuthNotifier extends Notifier<Lecturer?>`) — `build()` listens to `lecturerConfigProvider` (Firestore `lecturers` + `hardcodedLecturerConfig`) and `authStateChangesProvider`; `_reevaluate()` maps a signed-in user's lowercased email to a `Lecturer` (uid/displayName/email) if present, else `null`.
- `lecturerDisplayNameProvider`, `lecturerUidProvider` — selector providers.
- `LecturerAuthNotifier.signOut()` — clears lecturer state (Firebase auth not affected).

### Sign-in UI
- **`admin_auth/sign_in_page.dart`** (`/admin/sign-in`) — `_signIn()`: validates form → `signInWithEmailAndPassword` → `getIdTokenResult(true)` (forced refresh); if claim `admin == true` → `context.go('/admin')`; else if `lecturerAuthProvider` resolves → `context.go('/lecturer/visits')`; otherwise signs the user back out with an "account does not have access" error. Maps Firebase errors (`invalid-login-credentials`, `invalid-email`, `user-disabled`, `too-many-requests`, `network-request-failed`) to friendly messages. Also has `_goToMainSite()` JS redirect back to the public homepage.
- **`lecturer_auth/lecturer_sign_in_page.dart`** (`/lecturer/sign-in`) — redirect stub: on `initState`, post-frame `context.go('/admin/detail/sign-in')`. Accepts a `?name=` query param (not otherwise used).

### Route guarding (`app/router.dart` — `goRouterProvider`)
- Redirect waits for the auth stream to resolve; falls back to `FirebaseAuth.instance.currentUser`.
- Admin domain (`admin.fskmjasinfypexhibition.site`) root `/` → `/admin/sign-in` if not authed, else `/admin`.
- Any `/admin/**` path (except sign-in) redirects unauthenticated **and** non-admin users to `/admin/sign-in`.
- An already-authed user visiting `/admin/sign-in` is redirected to `/admin` (admin) or `/lecturer/visits` (lecturer).

---

## 3. Routing Map

| Route | Page | Shell |
|---|---|---|
| `/` | HomePage | Public |
| `/info` | InfoPage | Public |
| `/schedule` | SchedulePage | Public |
| `/projects`, `/projects/:slug` | ProjectsPage, ProjectDetailPage | Public |
| `/booths` | BoothsPage | Public |
| `/announcements` | AnnouncementsPage | Public |
| `/awards` | AwardsPage | Public |
| `/lecturer` | LecturerPage (public lookup) | Public |
| `/lecturer/sign-in` | LecturerSignInPage | Public |
| `/lecturer/visits` | LecturerVisitsPage | Public |
| `/lecturer/visits/:projectId` | LecturerVisitDetailPage | Public |
| `/faq`, `/privacy` | FaqPrivacyPage | Public |
| `/admin/sign-in` | SignInPage | Standalone (no shell) |
| `/admin` | DashboardPage | Admin |
| `/admin/event` | AdminEventPage | Admin |
| `/admin/schedule` | AdminSchedulePage | Admin |
| `/admin/projects` | AdminProjectsPage | Admin |
| `/admin/booths` | AdminBoothsPage | Admin |
| `/admin/announcements` | AdminAnnouncementsPage | Admin |
| `/admin/feedback` | AdminFeedbackPage | Admin |
| `/admin/awards` | AdminAwardsPage | Admin |
| `/admin/visits` | AdminVisitsPage | Admin |
| `/admin/imports`, `/admin/imports/:importId` | AdminImportsPage, ImportDetailPage | Admin |
| `/admin/lecturers` | AdminLecturersPage | Admin |
| `/admin/settings` | AdminSettingsPage | Admin |

### App shells & shared widgets
- `public_shell.dart` — desktop top nav / mobile bottom `NavigationBar` + floating **Feedback FAB**.
  - `_openAdminPortal()` — JS redirect (`dart:js_interop`) to `https://admin.fskjasinfypexhibition.site/admin/sign-in`.
  - Desktop nav links: Home, Schedule, Booths, Projects, Announcements, Awards, Lecturer Portal; **My Visits** appears only when `lecturerAuthProvider` is non-null; **Sign In** button otherwise.
  - Mobile `_showMobileMenu()` — bottom sheet with Sign In, Booths, Schedule, Announcements, Award Winners, My Visits, Exhibition Info, FAQ, Privacy.
- `admin_shell.dart` — desktop sidebar / mobile drawer: Overview, Event Information, Schedule Management, Project Catalogue, Booth Management, Lecturer Management, Announcements, Feedback, Student Visits, My Visits (Lecturer), Award Winners, Import Master File, Settings + "Back to Public Portal" (`_goToPublicPortal()`). `_logout()` signs out and navigates to `/`.
- `feedback_form_widget.dart` — `FeedbackFormWidget.show(context, ref)`: desktop dialog / mobile bottom sheet; `_submit()` validates, builds a `FeedbackEntry` (uuid `id`, optional `userId`, `eventId: 'fskm-fyp-2026'`, subject, message, optional 1–5 `rating`, `userAgent: 'Flutter Web'`, `status: 'new'`) and writes via `feedbackEntriesProvider.notifier.addFeedbackEntry`.

---

## 4. Public Site Features (no login)

| Page | Features & functions |
|---|---|
| **Home** (`/`) `home_page.dart` | Hero banner with gradient, "FSKM FINAL YEAR PROJECT EXHIBITION" badge, search box (submitting → `/projects?search=...`), info chips (date/time/venue), a live `_CountdownTimer` (rebuilds every 1 s against `DateTime(2026,8,6,9,0)`; Days/Hours/Mins/Secs), 3 CTAs (Explore Catalogue, Lecturer Portal, View Schedule). **Featured Projects** section lists top-10 `mostVisitedProjectsProvider` as a grid (desktop 3-col) / list (mobile). Exhibition Overview strip with Dates / Venue / Visiting Hours tiles. |
| **Schedule** (`/schedule`) `schedule_page.dart` | Daily programme timeline. Watches `publicScheduleProvider` (published only), groups into Day 1 (6 Aug) / Day 2 (7 Aug) TabBar. Each item shows start–end time, Internal badge, title, description, venue, audience. |
| **Projects** (`/projects`, `/projects/:slug`) `projects_page.dart`, `project_detail_page.dart` | Catalogue: search (debounced 250ms, pre-filled from `?search=`), `_programmes` (CS230/CS251/CS253/CS255/CS266) + `_categories` dropdowns, **Industry Candidate** checkbox, Reset Filters, pull-to-refresh + refresh `IconButton` (`publicProjectsProvider.notifier.refresh()`). Detail page: cover, category/booth pills, abstract + description, tech chips, student team, supervisor/examiner, matric ID, booth locator with **Map** button (`/booths?search=<boothNumber>`), Live Demo and GitHub Repository buttons (disabled when URL empty). `_goBack()` respects `?from=lecturer` for back navigation. **Visit counting:** each page render records a local visit via `projectVisitCountsProvider.notifier.recordVisit(project.id)` (once per open, deduped per-instance) to drive "most visited" homepage ordering. |
| **Booths** (`/booths`) `booths_page.dart` | Booth directory grouped by day → venue → booth. Filters: day / venue / programme dropdowns (venue resets on day change), debounced search. Venue prefixes (`DS5`, `BK1`…) prettified via `_prettyVenueByPrefix` and ordered by canonical `_venueOrder`; booth cards render `Image.network('/booth_images/booth-<no>.png')` with `CircleAvatar` fallback; `_boothSortKey` sorts numerically `BK5-03`. |
| **Announcements** (`/announcements`) `announcements_page.dart` | Published announcements, pinned first then newest; push-pin icon + category pill for pinned items. |
| **Awards** (`/awards`) `awards_page.dart` | Published award winners. `_getAwardTitle` maps category ids (`cat-gold` → "Gold Innovation Award", `cat-best-innovative`, `cat-manual` → custom title, default "Final Year Project Award"); shows winners, students, supervisor, programme, "UiTM Official Award" pill. |
| **Lecturer Portal** (`/lecturer`) `lecturer_page.dart` | Public lookup of projects by lecturer: name input (debounced 250ms), role filter (All/Supervisor/Examiner) on `supervisorDisplayName`/`examinerDisplayName`, day + "Industry Candidate" filters; results render `ProjectCard`s linking to detail. |
| **Exhibition Info** (`/info`) `info_page.dart` | Event description, objectives, competition categories, venue + placeholder map. |
| **FAQ / Privacy** (`/faq`, `/privacy`) `faq_privacy_page.dart` | Hard-coded FAQ list; PDPA privacy statement (student data isolation — matric IDs, emails, phones, evaluations never stored in public collections). |

---

## 5. Lecturer "My Visits" Features

Signed-in lecturers see only projects they are assigned to (as **Supervisor / SV** or **Examiner / EX**).

| Feature | Details |
|---|---|
| **My Visits dashboard** (`lecturer_visits_page.dart`) | If `lecturerAuthProvider` is null → sign-in prompt. Otherwise lists `lecturerAssignmentsProvider` (active assignments matched by `lecturerId`, with a name-based fallback when `lecturerId` is unset). Progress cards (`_VisitProgressCard`) per role showing `completed / total` + `LinearProgressIndicator`. Filters: role chips (SV/EX), status (Not Visited / Visited / Voided), day chips, search on title/teams/booth. Each card opens `/lecturer/visits/:projectId`. Admin users get an "Admin Panel" shortcut. |
| **Visit detail** (`lecturer_visit_detail_page.dart`) | `/lecturer/visits/:projectId`. Two sections (Supervisor / Examiner). Status chip: Visited / Voided / Not Visited (based on visit status). For completed: visit time (`_formatDateTime` → "d MMM yyyy, HH:mm"), optional note, plus **Cancel Visit** button. For un-visited/voided: full-width **Mark as Visited** button. Not-assigned roles show "You are not assigned to this role." |
| **Mark as visited** | `_markVisited(project, assignmentId, role)`: shows `showMarkVisitedDialog`; **local duplicate guard** (`completed` visit already exists for `projectId + visitRole` → SnackBar error); writes a `studentProjectVisits` doc (`status: 'completed'`, `visitedAt/createdAt/updatedAt` = `serverTimestamp`, `visitNote`, `source: 'lecturer'`); best-effort `auditLogs` entry `visit_marked`; handles `already-exists` / `permission-denied` errors. |
| **Cancel / Undo visit** | `_undoVisit(visit)`: shows `showUndoVisitDialog` → optional reason; **Firestore update** sets `status: 'voided'` + `voidedAt`, `voidedBy`, `voidReason`, `updatedAt` (soft-delete semantics — a voided visit can be re-marked). Best-effort `auditLogs` entry `visit_voided` with `voidedByRole: 'lecturer'`. |
| **Dialogs** | `mark_visited_dialog.dart` — `showMarkVisitedDialog(context, project, role)` returns `Future<Map<String,String>?>` (`{'note': ...}`); info rows + optional note field. `undo_visit_dialog.dart` — `showUndoVisitDialog(context)` returns `Future<String?>` reason (optional field, placeholder "Example: Student not at booth"). |

> **Note:** there is **no 30-minute time window** in the current client logic. The only enforced rule is one **completed** visit per (project, role); voiding just flips status so the project becomes revisit capable. (Firestore rules still define a 30-minute lecturer undo window — see [§11](#11-firestore-security-rules) — and the Cloud Function callables also enforce it.)

---

## 6. Admin CMS Features

All admin pages are reached via `AdminShell`; mutations go through the corresponding Riverpod notifier (optimistic local update + Firestore write).

| Page | Features & functions |
|---|---|
| **Overview Dashboard** (`admin_dashboard/dashboard_page.dart`) | Stats `GridView`: total projects, total booths, schedule items, files imported. Quick actions (Import / Event / Schedule / Projects). Recent imports list with status pill (`Pending Review` / `Published`) linking to the import detail. |
| **Event Information** (`admin_event/admin_event_page.dart`) | `_loadEvent()` populates `title / sessionLabel / venue` fields from `eventProvider`; keeps in sync via `ref.listen`; `_save()` persists via `eventProvider.notifier.updateEvent` → writes `events/fskm-fyp-2026`. **Note:** start/end date fields are shown but not persisted by this page. |
| **Schedule Management** (`admin_schedule/admin_schedule_page.dart`) | `_showAddEditDialog` form: title, venue, audience, description, startAt, endAt, Day 1/Day 2 dropdown, Access (public/internal), Publication status. Save → `addScheduleItem` / `updateScheduleItem`. Rows show Day chip, time range, ACCESS pill and a publish toggle (`togglePublish(id)`), edit/delete icons. |
| **Project Catalogue** (`admin_projects/admin_projects_page.dart`) | Full CRUD dialog: title, matric id, programme code/name, shortDescription, category, tech tags (comma-separated), student team names, supervisor/examiner, booth fields, demo URL, cover image URL, `featured` checkbox, publication dropdown. `slug` auto-derived (`title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')`). List rows with FEATURED badge, meta, publish toggle (`togglePublishStatus`), edit/delete. |
| **Booth Management** (`admin_booths/admin_booths_page.dart`) | `_showAddEditDialog`: booth number, zone, location note, project-mapping dropdown (Vacant or select a project). Allocating a project also **syncs the linked `Project`** with `boothId/boothNumber/boothZone` (two-document coordinated write). Rows show Active/Vacant pill, edit/delete. |
| **Lecturer Management** (`admin_lecturers/admin_lecturers_page.dart`) | `_showAddLecturerDialog` creates a `lecturers` doc (uid via `Uuid().v4()`; note explains Auth account must be created manually in Firebase Console). Delete via `_confirmDeleteLecturer` → `FirestoreService.deleteLecturer`. `_backfillLecturerIds()` matches `lecturerDisplayName` in assignments to `lecturers` uids (uppercase match, counts patched/skipped). Lists Firestore lecturers + hardcoded `DEFAULT` entries. |
| **Announcements** (`admin_announcements/admin_announcements_page.dart`) | CRUD + pinned checkbox + publication dropdown. Row actions: `togglePinned`, `togglePublish`, edit/delete. |
| **Student Visits** (`admin_visits/`) | Tabs: **Overview / By Lecturer / By Project / Visit Log**. Stats in `admin_visits_page.dart`: `svTotal/exTotal` (active assignments), completed, pending, `visitedToday` (completed today), voided. Role (SV/EX) + status filters + search (lecturer/project/students/booth). `_voidVisit(visit)`: dialog → Firestore update `status: 'voided'` + audit log `visit_voided` (`voidedByRole: 'admin'`). `_exportCsv(...)` → `exportVisitsCsv` → web-only base64 `data: text/csv` download as `student_visits.csv`. |
| **Visit data table** (`admin_visits/visit_data_table.dart`) | `VisitDataTable` — desktop `DataTable` (Lecturer, Role, Students, Project, Booth, Status, Time, Action/Void). Mobile: cards. Top-level `exportVisitsCsv(assignments, visits, projects)` + `_escapeCsv` escaping. |
| **Summary cards** (`admin_visits/summary_cards.dart`) | `SummaryCardsRow` — Total Visited, Not Visited, Percentage, SV Completed, EX Completed, Today, Voided. |
| **Award Winners** (`admin_awards/admin_awards_page.dart`) | CRUD via `awardsProvider.notifier`: title, sponsor, description, winning-project dropdown, status. Saved award fills `teamDisplayName`, `supervisorDisplayName`, `programmeCode` from the selected project. |
| **Import Master File** (`admin_imports/admin_imports_page.dart`) | Drag-drop zone + tap to pick (`FirestoreService.pickExcelFile()`, `xlsx` only). `_uploadAndProcess()` uploads to `private/imports/<importId>/<file>` (≤ 10 MB), creates the imports record (`status: pending_review`), navigates to `/admin/imports/:importId`. |
| **Import Detail / Data Matching Dashboard** (`admin_imports/import_detail_page.dart`) | Tabs: Event Metadata, Schedule Candidates, Award Candidates, Privacy Skips, Validation Warnings, Change Summary. Auto-selects all candidates. `_publishSelective()` publishes selected into `publicScheduleItems` / `publishedAwardWinners` (category `cat-imported`), marks import complete, navigates to `/admin`. |
| **Settings** (`admin_settings/admin_settings_page.dart`) | `_loadSettings()` reads `settings` doc `excel_import`; `maxFileSize` (default `10 MB`) + `mandatoryWorksheets` (default `SCHEDULE, AWARD WINNERS, COMMITTEE`); `_save()` persists to Firestore. |

---

## 7. Cross-Cutting Features

- **Publication lifecycle** — every public collection carries `publicationStatus` (`draft` / `published` / `archived`). Public providers query `where('publicationStatus', '==', 'published')`; admin providers read everything.
- **Real-time updates** — Riverpod notifiers subscribe to Firestore `snapshots()`; public & admin pages update live.
- **Offline fallback** — projects / schedule / booths / event providers seed from the bundled `ExcelData` dataset (in `lib/core/data/excel_data.dart`) and swap to Firestore data once the stream connects.
- **Audit logging** — best-effort `auditLogs` writes from the client for `visit_marked`, `visit_voided`, `lecturer_created / lecturer_deleted / lecturer_ids_backfilled` (server-side via functions). Rules permit admin read; client writes are wrapped in try/catch so primary actions never fail.
- **CSV export (web)** — both admin visits and admin feedback generate `data:text/csv;base64,...` URLs and trigger a JS anchor click using `dart:js_interop` / `dart:js_interop_unsafe`.
- **App Check + Analytics** are initialized with Firebase from the client.
- **`flutter analyze` baseline** has pre-existing deprecation/lint infos (`withOpacity`, `surfaceVariant`, dead code in `schedule_page.dart`) that are non-blocking.

---

## 8. State Layer — Riverpod Notifiers & Functions

### Providers (`lib/core/state/state_providers.dart`)

| Provider | Type | Public functions |
|---|---|---|
| `eventProvider` (`EventNotifier`) | Notifier<Event> | `updateEvent(Event)` → writes `events/<id>`; fallback event applied on build |
| `projectsProvider` / `publicProjectsProvider` (`ProjectsNotifier`) | Notifier<List<Project>> | `refresh()`, `addProject`, `updateProject`, `deleteProject`, `togglePublishStatus(id)`; cover placeholder swap; builds from `ExcelData` then Firestore stream |
| `featuredProjectsProvider` | Provider<List<Project>> | derives `p.featured` |
| `projectsMapProvider` | Provider<Map<String, Project>> | O(1) id → project lookup |
| `projectVisitCountsProvider` (`ProjectVisitCountsNotifier`) | Notifier<Map<String,int>> | `recordVisit(projectId)` (in-memory only) |
| `mostVisitedProjectsProvider` | Provider<List<Project>> | sorted by visit count |
| `scheduleProvider` / `publicScheduleProvider` (`ScheduleNotifier`) | Notifier<List<ScheduleItem>> | `addScheduleItem`, `updateScheduleItem`, `deleteScheduleItem`, `togglePublish(id)` |
| `boothsProvider` / `publicBoothsProvider` (`BoothsNotifier`) | Notifier<List<Booth>> | `addBooth`, `updateBooth`, `deleteBooth` |
| `announcementsProvider` / `publicAnnouncementsProvider` (`AnnouncementsNotifier`) | Notifier<List<Announcement>> | `addAnnouncement`, `updateAnnouncement`, `deleteAnnouncement`, `togglePinned(id)`, `togglePublish(id)` |
| `awardsProvider` / `publicAwardsProvider` (`AwardsNotifier`) | Notifier<List<PublishedAwardWinner>> | `addWinner`, `updateWinner`, `deleteWinner` |
| `importsProvider` (`ImportsNotifier`) | Notifier<List<ImportRecord>> | `addImport`, `updateImport` |
| `scheduleCandidatesProvider`, `awardCandidatesProvider`, `privacySkipsProvider`, `validationIssuesProvider` | StreamProvider.family | stream import subcollections |
| `allLecturersProvider` | StreamProvider<List<Map>> | Firestore lecturers |
| `lecturerConfigProvider` | Provider<Map<String,String>> | Firestore + `hardcodedLecturerConfig` (email → displayName) |
| `lecturerAuthProvider` (`LecturerAuthNotifier`) | Notifier<Lecturer?> | `signOut()`; `_reevaluate()` email whitelist check |
| `allAssignmentsProvider` | StreamProvider<List<ProjectLecturerAssignment>> | assignments stream |
| `lecturerAssignmentsProvider` | Provider<List<ProjectLecturerAssignment>> | filters by current lecturer + `status == 'active'` |
| `allVisitsProvider` | StreamProvider<List<StudentVisit>> | visits stream |
| `lecturerVisitsProvider` | Provider<List<StudentVisit>> | filter by lecturer uid |
| `completedVisitsProvider` | Provider<Set<String>> | keys `'<projectId>_<visitRole>'` |
| `feedbackEntriesProvider` (`FeedbackEntriesNotifier`) | Notifier<List<FeedbackEntry>> | `refresh()`, `addFeedbackEntry`, `updateFeedbackEntry`, `deleteFeedbackEntry`, `setStatus(id, status)`, `setAdminNote(id, note)` |
| `myFeedbackProvider` | Provider<List<FeedbackEntry>> | feedback of current user |

---

## 9. FirestoreService — Data Access Functions

`lib/core/firebase/firestore_service.dart` — singleton access layer. Timestamps in documents are recursively converted to ISO strings via `_convertTimestamps`.

### Streams
| Method | Collection |
|---|---|
| `projectsStream({publishedOnly})` | `publicProjects` |
| `scheduleStream({publishedOnly})` | `publicScheduleItems` |
| `boothsStream({publishedOnly})` | `booths` |
| `announcementsStream({publishedOnly})` | `publicAnnouncements` |
| `awardWinnersStream({publishedOnly})` | `publishedAwardWinners` |
| `importsStream()` | `imports` |
| `scheduleCandidatesStream(importId)` / `awardCandidatesStream` / `privacySkipsStream` / `validationIssuesStream` | subcollections under `imports/{id}` |
| `lecturersStream()` | `lecturers` |
| `assignmentsStream()` | `projectLecturerAssignments` (ordered by `updatedAt` desc) |
| `visitsStream()` | `studentProjectVisits` (ordered `createdAt` desc, `limit(1000)`) |
| `auditLogsStream()` | `auditLogs` (ordered `createdAt` desc, `limit(200)`) |
| `feedbackEntriesStream()` | `feedbackEntries` (ordered `createdAt` desc) |

### Single docs & mutations
- Projects: `getProjectsOnce({publishedOnly})`, `setProject(id, data)`, `deleteProject(id)`
- Schedule: `setScheduleItem`, `deleteScheduleItem`
- Booths: `setBooth`, `deleteBooth`
- Announcements: `setAnnouncement`, `deleteAnnouncement`
- Awards: `setAwardWinner`, `deleteAwardWinner`
- Events: `getEvent(eventId)`, `setEvent(id, data)`
- Settings: `getSetting(settingId)`, `setSetting(id, data)`
- Imports: `setImport(id, data)`
- Lecturers: `getLecturer(uid)`, `setLecturer(uid, data)`, `deleteLecturer(uid)`
- Assignments: `getAssignment(id)`, `setAssignment(id, data)`
- Visits: `getVisit(id)`, `setVisit(id, data)`
- Audit logs: `setAuditLog(id, data)`
- Feedback: `getFeedbackEntriesOnce()`, `setFeedbackEntry`, `deleteFeedbackEntry`

### File upload
- `uploadFile(localPath, destinationPath, bytes)` — `FirebaseStorage.ref(destinationPath).putData(bytes)` (web-compatible `Uint8List`).
- `pickExcelFile()` (static) — `FilePicker.pickFiles(type: custom, allowedExtensions: ['xlsx'])`.

---

## 10. Cloud Functions (TypeScript)

Located in `functions/src` (`index.ts`, `lecturers.ts`, `visits.ts`). **Note:** these exist in the codebase; deployment depends on the platform plan (see README Deployment).

| Function | Trigger | Purpose |
|---|---|---|
| `processMasterFileImport` | Storage `onFinalize` (`private/imports/**`) | Sets import `status: processing`; downloads XLSX; lazy-loads `sheetjs`. **TENTATIF** sheet → `scheduleCandidates` with overlap detection (`timeToMinutes`, `normaliseMalayDate` — Malay month names), `validationIssues` (missing fields / overlap / invalid time), batching ≤ 500. **PEMENANG ANUGERAH** sheet → `awardCandidates` (`isSkip: false`) + `privacySkips` when STUDENT_ID/MATRIK/NO_TEL/EMAIL present (PDPA). Updates import → `pending_review` with summary + warningCounts; else `error`. |
| `createLecturerAccount` | HTTPS callable (admin) | Creates Auth user + `lecturers` doc + `auditLogs` (`lecturer_created`) atomically. Validates email/password (≥6 chars); guards `auth/email-already-exists`. |
| `deleteLecturerAccount` | HTTPS callable (admin) | Deletes Auth user + `lecturers` doc + audit log; idempotent when user not found (deletes doc and returns success). |
| `backfillLecturerIds` | HTTPS callable (admin) | Builds name→uid map; matches assignments with null/empty `lecturerId` by `lecturerDisplayName` (exact + fuzzy substring) in batches of 500; writes `lecturerIds_backfilled` audit log; returns `{ patched, skipped }`. |
| `markStudentProjectVisited` | HTTPS callable (lecturer) | Server-verified visit creation: validates assignment ownership + `status == 'active'` + role/project/event match, duplicate check, writes visit + audit log `visit_marked` atomically. |
| `undoStudentProjectVisit` | HTTPS callable (lecturer/admin) | Voids a visit; requests a `reason`; enforces 30-minute window for lecturers (admin exempt); batch-updates visit + audit log `visit_voided`. |

> The Flutter client currently performs visit create/void directly against Firestore (rules-enforced) and writes audit logs best-effort; it does not call the callables (`cloud_functions` is not in `pubspec.yaml`).

---

## 11. Firestore Security Rules

Summary of `firestore.rules`:
- **Default deny**: `match /{document=**} { allow read, write: if false; }`.
- Public collections (`events`, `publicScheduleItems`, `publicProjects`, `booths`, `publicAnnouncements`, `awardCategories`, `publishedAwardWinners`): `allow read: if isPublished(resource) || isAdmin(); allow write: if isAdmin();`
- `users`: owner-or-admin read; admin write.
- `imports` + subcollections: admin read/write; subcollections contain raw parser output (`write: false`).
- `auditLogs`: admin read; client create/update/delete denied (server-only via functions).
- `settings`: admin read/write.
- `feedbackEntries`: anyone may `create` if body has required `subject`/`message`/`createdAt`/`updatedAt` fields (strings); read/update/delete admin-only.
- `lecturers`: owner-or-admin read; owner-or-admin create/update; admin delete.
- `projectLecturerAssignments`: owner-or-admin read; admin write.
- `studentProjectVisits`:
  - read: admin or owning lecturer.
  - **create**: authenticated, `status == 'completed'`, `lecturerId == auth.uid`, valid `assignmentId`/`projectId`/`visitRole` in `['supervisor','examiner']`, and the referenced assignment is `status == 'active'`.
  - **update / delete**: admin, or owning lecturer within **30 minutes** of `visitedAt` (`request.time - resource.data.visitedAt < duration.value(30, 'm')`).

### Storage rules (`storage.rules`)
- `private/imports/**` — admin-only read/write, ≤ 10 MB.
- `public/assets/**` — public read; admin-only writes limited to images ≤ 5 MB.

### Firestore indexes (`firestore.indexes.json`)
- Visits: `(lecturerId, status)`, `(eventId, projectId, lecturerId, visitRole, status)`.
- Assignments: `(lecturerId, status)`, `(lecturerDisplayName, status)`.
- Projects: `(publicationStatus, programmeCode)`, `(publicationStatus, category)`.
- Schedule: `(publicationStatus, date, startAt)`.

---

## 12. Data Model

### Models (freezed, `lib/core/domain/models/`)
`Project`, `ScheduleItem`, `Booth`, `Announcement`, `PublishedAwardWinner` / `AwardCategory`, `Event` (+ `FaqItem`), `Lecturer`, `ProjectLecturerAssignment`, `StudentVisit`, `AuditLog`, `FeedbackEntry`, plus import staging models `ImportRecord`, `ScheduleCandidate`, `AwardCandidate`, `PrivacySkip`, `ValidationIssue`.

### Collections
| Collection | Purpose |
|---|---|
| `events` | event metadata (`fskm-fyp-2026`), objectives, FAQs |
| `publicProjects` | project slug, title, matric id, programme, category, tags, booths, team/supervisor/examiner, URLs, `featured`, `calonIndustri` |
| `publicScheduleItems` | date, times, title, venue, audience, visibility |
| `booths` | number, zone, note, floor plan URL, linked `projectId` |
| `publicAnnouncements` | title, body, `pinned` |
| `awardCategories` / `publishedAwardWinners` | award definitions + winners (with `sponsor`, `description`) |
| `users` | user profiles |
| `imports` + subcollections | import records + `scheduleCandidates` / `awardCandidates` / `privacySkips` / `validationIssues` / `reviewDecisions` |
| `auditLogs` | actor, action, target, metadataSafe, timestamp |
| `settings` | portal configuration (`excel_import`) |
| `lecturers` | `uid`, `email`, `displayName` |
| `projectLecturerAssignments` | project ↔ lecturer link with role + status (`active`) |
| `studentProjectVisits` | `status` (completed/voided), `visitRole`, `visitedAt`, `visitNote`, `voidReason` |
| `feedbackEntries` | subject, message, rating, admin note, status |

---

## 13. SDK Configuration

- Flutter SDK `^3.11.0` (installed at `D:\Dev\SDK\flutter`); Firebase CLI v15.x.
- Credentials delivered via `--dart-define` (local `.env` / CI secrets): `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET`.
- Codegen: `flutter pub run build_runner build --delete-conflicting-outputs`.
- Deploy: `firebase deploy --only firestore:rules,hosting`; emulators configured in `firebase.json` (firestore 8080, auth 9099, functions 5001, hosting 5000, storage 9199, UI enabled).
- CI: `.github/workflows/deploy.yml` builds `build/web` and deploys the public site to GitHub Pages on every push to `main`.

---

*Generated from the FYP Expo Hub codebase (Flutter `lib/` + Firebase `functions/`).*