# FYP Expo Hub (FSKM FYP Expo Hub 2026)

The official web portal for the **Final Year Project Exhibition (FYP Expo)** of the Faculty of Computer and Mathematical Sciences (FSKM), UiTM. It showcases final-semester student projects, schedules, booths, announcements and award winners, and provides a "My Visits" tracking system that lets lecturers digitally sign off that they have visited student booths during the exhibition.

- **Public site:** https://fskmjasinfypexhibition.site (GitHub Pages)
- **Admin CMS:** https://admin.fskmjasinfypexhibition.site (Firebase Hosting)
- **Firebase Hosting fallback:** https://fyp-expo-hub.web.app
- **Event:** FSKM FYP Expo Hub 2026 — Semester March–August 2026, 6–7 August 2026, Lecture Block, FSKM (9:00 AM – 5:00 PM daily)

---

## Table of Contents

1. [Project Description](#project-description)
2. [Full Stack](#full-stack)
3. [Roles & Authentication](#roles--authentication)
4. [Full Functionality & Features](#full-functionality--features)
5. [System Architecture](#system-architecture)
6. [System Flow](#system-flow)
7. [Data Model](#data-model)
8. [Security Rules](#security-rules)
9. [Cloud Functions](#cloud-functions)
10. [Development & Implementation](#development--implementation)
11. [Deployment](#deployment)
12. [Project Structure](#project-structure)

---

## Project Description

FYP Expo Hub is a Flutter Web application that digitises the complete lifecycle of the FSKM FYP Exhibition:

- **For visitors** — browse the project catalogue, daily schedule, booth map, announcements, and award winners with no sign-in required.
- **For lecturers** — sign in with their UiTM email, view only the projects they are assigned to (as **Supervisor / SV** or **Examiner / EX**), mark visits as completed, and cancel a visit within a 30-minute window.
- **For admins** — run a full CMS: manage event info, schedules, projects, booths, lecturers, announcements, awards, and a "My Visits" monitoring dashboard, plus import the master Excel workbook to bulk-stage and publish content.

The app reads live from **Cloud Firestore** with a real-time streaming architecture and ships with an offline/fallback dataset so the public site still renders content even if Firestore is unreachable.

---

## Full Stack

### Frontend
| Layer | Technology |
|---|---|
| Language / framework | Flutter (Dart SDK `^3.11.0`), Flutter Web |
| State management | `flutter_riverpod` `^3.3.2` (Notifier / StreamProvider / Provider) |
| Routing | `go_router` `^17.3.0` (SPA with redirect guards) |
| Data models | `freezed` `^3.2.5` + `json_serializable` `^6.14.0`, generated via `build_runner` |
| UI helpers | `google_fonts`, custom `DesignSystem` design tokens (Inter / Montserrat, Material 3), `flutter_svg`, `cached_network_image`, `file_picker`, `intl`, `uuid` |
| URL strategy | `usePathUrlStrategy()` (clean paths, no `/#/`) |

### Backend (Firebase)
| Service | Purpose |
|---|---|
| **Firebase Authentication** | Sign-in for admins and lecturers (email/password). Admin rights granted via a custom claim `admin: true` on the ID token. |
| **Cloud Firestore** | Primary database — public collections, admin collections, import staging subcollections, audit logs, and the visit-tracking collections. |
| **Firebase Storage** | Private XLSX master workbooks (`private/imports/...`, ≤ 10 MB) and public images/posters/floor plans (`public/assets/...`, images ≤ 5 MB). |
| **Cloud Functions** | TypeScript (`firebase-functions` v4, `firebase-admin` v12, `xlsx`/SheetJS, Node 20) — master-file parsing, lecturer account lifecycle, and visit callables (see [Cloud Functions](#cloud-functions)). |
| **Firebase Hosting** | Serves the admin CMS + `fyp-expo-hub.web.app` with SPA rewrites (`**` → `/index.html`). |
| **GitHub Pages** | Serves the public domain, auto-deployed from CI on every push to `main`. |
| **App Check / Analytics** | `firebase_app_check` and `firebase_analytics` are wired into the client. |

### Tooling & CI/CD
- **Flutter SDK** at `D:\Dev\SDK\flutter`
- **Firebase CLI** v15.18.0 (login: `albin1841@uitm.edu.my`)
- **GitHub Actions** (`.github/workflows/deploy.yml`) — builds `build/web` with `--dart-define` credentials from repo secrets and deploys to Pages.
- Firebase **emulators** configured (`firestore:8080`, `auth:9099`, `functions:5001`, `hosting:5000`, `storage:9199`, UI enabled).

---

## Roles & Authentication

| Role | How authorised | Access |
|---|---|---|
| **Anonymous visitor** | No sign-in | Public pages only. Firestore rules only grant read access to documents with `publicationStatus == 'published'`. |
| **Lecturer** | Firebase Auth with a UiTM email that exists in the `lecturers` collection (or the hardcoded fallback config `albin1841@uitm.edu.my`). Determined client-side by the `lecturerAuthProvider`. | Public site + `/lecturer/visits`, `/lecturer/visits/:projectId`. Rules restrict visit reads/writes to their own assignments. |
| **Admin** | Firebase Auth user whose ID token carries the custom claim `admin: true` (set in the Firebase Console or via the Admin SDK). | Full CMS (`/admin/**`) plus admin routes on the `admin.*` domain. Rules use `request.auth.token.admin == true`. |

Route guarding lives in `lib/app/router.dart`:
- On the admin domain, `/` redirects to `/admin/sign-in` (or `/admin`) based on auth state.
- `/admin/**` redirects unauthenticated or non-admin users to `/admin/sign-in`.
- Signing in while already authenticated redirects admins to `/admin` and lecturers to `/lecturer/visits`.

---

## Full Functionality & Features

### Public site (visitors, no login)

| Page | Route | Features |
|---|---|---|
| **Home** | `/` | Hero, event countdown timer, search box, featured projects carousel, exhibition overview + objectives, quick links, mobile bottom-nav / desktop top-nav. |
| **Schedule** | `/schedule` | Daily programme (TENTATIF) — date, time, venue, audience, classification (public/internal). |
| **Projects** | `/projects`, `/projects/:slug` | Searchable, filterable catalogue (programme: CS230/CS251/CS253/CS255/CS266; category; "Industry Candidate" flag). Detail page: cover image, team, supervisor/examiner, programme, booth number, demo / video / repository links, tech tags. |
| **Booths** | `/booths` | Booth directory by number/zone and the static "Hall Layout Plan" (Level 1 Plan, Blok Kuliah, FSKM). |
| **Announcements** | `/announcements` | Pinned + published announcements. |
| **Awards** | `/awards` | Published award winners — category, project, students, supervisor, programme, sponsor, description. |
| **Lecturer Portal** | `/lecturer` | Public lookup: enter a lecturer name + role (SV/EX) to see which projects they supervise/examine. |
| **Lecturer sign-in** | `/lecturer/sign-in` | Email/password login for the My Visits mode. |
| **FAQ / Privacy** | `/faq`, `/privacy` | Event FAQ and PDPA/privacy statement. |
| **Info** | `/info` | Exhibition info page. |

### Lecturer site (My Visits mode)

| Feature | Details |
|---|---|
| **My Visits dashboard** | `/lecturer/visits` — lists only active assignments where the signed-in lecturer is the assigned SV or EX (matched by `lecturerId`, with a name-based fallback when the ID is unset). Progress summary per role (completed / total). |
| **Project visit detail** | `/lecturer/visits/:projectId` — two sections (Supervisor / Examiner). Shows visit time, note, and status chip (Visited / Not Visited / Voided). |
| **Mark as visited** | Creates a `studentProjectVisits` document with `status: 'completed'` (note optional). Firestore rules require the assignment to exist, be `active`, belong to the caller, and match the requested role/project. |
| **Cancel visit** | Deletes the completed visit so the student can be revisited. Rules restrict this to the owning lecturer **within 30 minutes** of `visitedAt`; admins can void anytime. |
| **Admin panel shortcut** | Link from the lecturer dashboard to the admin sign-in. |

### Admin CMS (protected)

| Page | Route | Features |
|---|---|---|
| **Overview Dashboard** | `/admin` | Stats (total projects, booths, schedules, files imported), quick actions, recent imports. |
| **Event Information** | `/admin/event` | Edit title, session label, dates, venue, poster, contact email, description, objectives, FAQs. |
| **Schedule Management** | `/admin/schedule` | CRUD daily schedule items with a published/draft toggle. |
| **Project Catalogue** | `/admin/projects` | CRUD projects, publish/draft toggle, covers all public project fields. |
| **Booth Management** | `/admin/booths` | Register booths, map/unmap projects to booths, delete mappings. |
| **Lecturer Management** | `/admin/lecturers` | Add lecturers (creates a `lecturers` doc; a notice explains that the Auth account must be created manually in Firebase Console → Authentication → Add user), delete lecturers, and "Backfill Lecturer IDs" (links `lecturerDisplayName` in existing assignments to `uid`s). |
| **Announcements** | `/admin/announcements` | CRUD, pin/unpin, publish/draft toggle. |
| **Student Visits** | `/admin/visits` | Live monitoring with tabs **Overview / By Lecturer / By Project / Visit Log**, role + status filters, search, **Void Visit** (with mandatory reason), and **Export CSV**. |
| **My Visits (Lecturer)** | `/lecturer/visits` | Convenience link to the lecturer view. |
| **Award Winners** | `/admin/awards` | CRUD award records (category, project, students, supervisor, sponsor, description), publish/draft toggle. |
| **Import Master File** | `/admin/imports` | Drag-and-drop `.xlsx` upload (≤ 10 MB) that kicks off parsing & staging. |
| **Import Detail** | `/admin/imports/:importId` | "Data Matching Dashboard" — reviews staged schedule + award candidates, sees validation issues, privacy skips, and publishes selected items into the public collections. |
| **Settings** | `/admin/settings` | Portal settings (file size limit, mandatory worksheet names) persisted to Firestore `settings`. |

### Cross-cutting features

- **Publication lifecycle** — every public collection carries `publicationStatus` (`draft` / `published` / `archived`). The public site streams only `published` documents; the admin site streams all.
- **Real-time updates** — Riverpod notifiers subscribe to Firestore `snapshots()`; changes appear instantly on both public and admin sites.
- **Offline fallback** — project/schedule/booth providers seed from a bundled `ExcelData` dataset and swap to Firestore data when the stream connects.
- **Audit logging** — visit and lecturer actions attempt to write to `auditLogs` (best-effort from the client; rules allow only admin read, server-only writes).

---

## System Architecture

Feature-first layered Flutter architecture:

```
lib/
├── main.dart                 # Bootstrap: Firebase init (dart-define creds), Firestore settings, runApp
├── app/
│   ├── router.dart           # go_router config, auth redirects, public/admin shells
│   ├── theme/                # DesignSystem tokens (colors, typography, radii, spacing)
│   └── widgets/              # PublicShell (nav) + AdminShell (sidebar/drawer)
├── core/
│   ├── data/                 # ExcelData offline fallback datasets
│   ├── domain/models/        # freezed models (+ generated .freezed/.g)
│   ├── firebase/             # FirestoreService (all reads/writes), firebase_providers
│   ├── state/                # Riverpod providers & notifiers
│   └── widgets/              # Shared widgets (project cover image, etc.)
└── features/                 # One folder per domain (public_*, admin_*, lecturer_*)
    └── <feature>/presentation/pages|widgets
```

Data flow pattern:
1. **UI** watches a Riverpod provider.
2. **Provider/Notifier** subscribes to a `FirestoreService` stream (`projectsStream`, `visitsStream`, …) and maps documents → typed models.
3. **Model** `fromJson` parses Firestore documents (timestamps recursively converted to ISO strings first).
4. Mutations go through notifier methods (`addX`, `updateX`, `deleteX`) which update local state optimistically **and** persist via `FirestoreService`.

---

## System Flow

### 1. Master-file import → staging → publication (admin)
```
Admin uploads master .xlsx
  → uploadFile to Storage: private/imports/{importId}/source.xlsx (storage rules: admin only, ≤10MB)
  → Firestore import record created (status: pending_review)
  → Storage object trigger fires processMasterFileImport
      → parses "TENTATIF" sheet   → scheduleCandidates (+ overlap/format validationIssues)
      → parses "PEMENANG ANUGERAH" sheet → awardCandidates (+ privacySkips for PDPA-protected personal data)
      → import status: pending_review with summary + warningCounts
  → Admin opens /admin/imports/{importId} ("Data Matching Dashboard")
      → reviews candidates side-by-side with current data
      → "Publish Selective Items" writes approved candidates into
          publicScheduleItems / publishedAwardWinners (status: published)
  → Public site streams show the new published content
```

### 2. Visit tracking flow
```
Lecturer signs in (UiTM email)
  → lecturerAuthProvider validates email against lecturers config
  → My Visits lists active assignments (SV/EX) for that lecturer
Lecturer opens a project → taps "Mark as Visited" (+ note)
  → creates studentProjectVisits doc, status: completed (rules enforce ownership/active assignment)
  → best-effort auditLogs entry (visit_marked)
  → Admin dashboard live count updates
Lecturer "Cancel Visit" (within 30 min)
  → deletes the visit doc → student can be revisited
Admin "Void Visit" (anytime, with reason)
  → updates status → 'voided', records voidedAt / voidedBy / voidReason
  → best-effort auditLogs entry (visit_voided)
Export: admin downloads student_visits.csv (client-side base64 data URI)
```

### 3. Content publication flow (per collection)
```
Admin edits content in CMS (draft) → toggles "Publish"
  → Firestore document gets publicationStatus: 'published' + publishedAt
  → Public provider (publishedOnly) stream emits new doc
  → Rules: anonymous read only if isPublished(resource)
```

### 4. Deployment flow
```
Push to main
  ├─ GitHub Actions: flutter build web --release (creds from secrets) → GitHub Pages (public domain)
  └─ (manual) firebase deploy --only firestore:rules,hosting → Firebase Hosting (admin + web.app)
```

---

## Data Model

### Public collections (streamed by the public site, `published` only)
| Collection | Document |
|---|---|
| `events` | `fskm-fyp-2026` event metadata, objectives, FAQs |
| `publicProjects` | project slug, title, matric ID, programme, category, tags, booth, images, team/supervisor/examiner names, demo/video/repo URLs, `featured`, `calonIndustri`, publication status |
| `publicScheduleItems` | date, start/end time, title, venue, audience, visibility, publication status |
| `booths` | booth number, zone, location note, floor-plan URL, linked `projectId` |
| `publicAnnouncements` | title, body, `pinned`, publication status |
| `awardCategories` | award category definitions |
| `publishedAwardWinners` | award category, project id/title, students, supervisor, programme, **sponsor**, **description**, publication status |

### Private collections (admin / authenticated users)
| Collection | Purpose |
|---|---|
| `users` | user profiles |
| `imports` | import records (`status`: processing / pending_review / completed / error, `summary`, `warningCounts`) |
| `imports/{id}/scheduleCandidates` | staged schedule rows from the workbook |
| `imports/{id}/awardCandidates` | staged award rows from the workbook |
| `imports/{id}/privacySkips` | rows skipped for PDPA personal-data protection |
| `imports/{id}/validationIssues` | overlap / missing-field / format warnings with row numbers |
| `auditLogs` | actor, action, target type/id, metadataSafe, timestamp |
| `settings` | portal configuration |
| `lecturers` | lecturer profiles (`uid`, `email`, `displayName`) |
| `projectLecturerAssignments` | links project ↔ lecturer with role (`supervisor`/`examiner`) + `status` (`active`/…) |
| `studentProjectVisits` | visit records (`status`: completed / voided, `visitRole`, `visitedAt`, `visitNote`, `voidReason`) |

### Models (freezed)
`Project`, `ScheduleItem`, `Booth`, `Announcement`, `PublishedAwardWinner` / `AwardCategory`, `Event` (+ `FaqItem`), `Lecturer`, `ProjectLecturerAssignment`, `StudentVisit`, `AuditLog`, `ImportRecord` + staging models (`ScheduleCandidate`, `AwardCandidate`, `PrivacySkip`, `ValidationIssue`).

---

## Security Rules

### Firestore (`firestore.rules`)
- **Default deny** (`match /{document=**} { allow read, write: if false; }`).
- **Public reads** allowed only when `resource.data.publicationStatus == 'published'` (or the caller is admin).
- **Admin** = authenticated + `request.auth.token.admin == true`.
- **Lecturers** (`/lecturers`): owner-or-admin read/update, admin-only delete.
- **Assignments**: owner-or-admin read; admin-only write.
- **Visits** (`studentProjectVisits`):
  - **create** — authenticated, `status == 'completed'`, `lecturerId == auth.uid`, valid `assignmentId`/`projectId`/`visitRole`, assignment is `active` and owned by the caller.
  - **update/delete** — admin, or the owning lecturer within `30 minutes` of `visitedAt`.
- **Audit logs** — admin read; client create/update/delete denied (server-only). Client writes are best-effort `try/catch` + `debugPrint` so the primary action (e.g. void visit) never fails.

### Storage (`storage.rules`)
- `private/imports/**` — admin-only read/write, ≤ 10 MB.
- `public/assets/**` — public read; admin-only writes limited to images ≤ 5 MB.

### Indexes (`firestore.indexes.json`)
- Visits: `(lecturerId, status)`, `(eventId, projectId, lecturerId, visitRole, status)`.
- Assignments: `(lecturerId, status)`, `(lecturerDisplayName, status)`.
- Projects: `(publicationStatus, programmeCode)`, `(publicationStatus, category)`.
- Schedule: `(publicationStatus, date, startAt)`.

---

## Cloud Functions

Located in `functions/` (TypeScript, Node 20, `xlsx`). **Note:** the parser and callables exist in the codebase; whether they are deployed depends on the hosting plan — see [Deployment](#deployment).

| Function | Trigger | Purpose |
|---|---|---|
| `processMasterFileImport` | Storage `onFinalize` (`private/imports/**`) | Parses the master workbook: TENTATIF → schedule candidates, PEMENANG ANUGERAH → award candidates; writes validation issues, overlap warnings, PDPA privacy skips; updates import status to `pending_review` / `error`. |
| `createLecturerAccount` | HTTPS callable (admin) | Creates the Firebase Auth user + `lecturers` doc + audit log atomically. |
| `deleteLecturerAccount` | HTTPS callable (admin) | Deletes the Auth user + `lecturers` doc + audit log (idempotent when the Auth user is already gone). |
| `backfillLecturerIds` | HTTPS callable (admin) | Matches `lecturerDisplayName` → `uid` across `projectLecturerAssignments` (exact + fuzzy) in batches of 500, writes an audit log. |
| `markStudentProjectVisited` | HTTPS callable (lecturer) | Server-verified visit creation (ownership, active assignment, duplicate check) + atomic audit log. |
| `undoStudentProjectVisit` | HTTPS callable (lecturer/admin) | Voids a completed visit; enforces the lecturer 30-minute window (admins exempt) + atomic audit log. |

> The Flutter client currently performs the visit create/void directly against Firestore (with rules enforcement) and writes audit logs best-effort. The callables in `functions/src/` provide the hardened alternative but are not called by the client (`cloud_functions` is not in `pubspec.yaml`).

---

## Development & Implementation

### Prerequisites
- Flutter SDK `^3.11.0` (installed at `D:\Dev\SDK\flutter`).
- Firebase CLI v15.x (`npm i -g firebase-tools`), authenticated to the `fyp-expo-hub` project.
- A `.env` file (gitignored) with the Firebase web app credentials:
  ```env
  FIREBASE_API_KEY=AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus
  FIREBASE_APP_ID=1:825089478411:web:1dcd07362fdf636d9ddc0e
  FIREBASE_MESSAGING_SENDER_ID=825089478411
  FIREBASE_PROJECT_ID=fyp-expo-hub
  FIREBASE_AUTH_DOMAIN=fyp-expo-hub.firebaseapp.com
  FIREBASE_STORAGE_BUCKET=fyp-expo-hub.firebasestorage.app
  ```

### Common commands
```bash
# Generate freezed / json_serializable code
flutter pub run build_runner build --delete-conflicting-outputs

# Static analysis (treat new errors as blocking; existing deprecations are informational)
flutter analyze

# Release build with credentials (values from .env)
flutter build web --release \
  --dart-define=FIREBASE_API_KEY='AIzaSyAaoWvZr70guv06Ab_f3NcThxawfCEChus' \
  --dart-define=FIREBASE_APP_ID='1:825089478411:web:1dcd07362fdf636d9ddc0e' \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID='825089478411' \
  --dart-define=FIREBASE_PROJECT_ID='fyp-expo-hub' \
  --dart-define=FIREBASE_AUTH_DOMAIN='fyp-expo-hub.firebaseapp.com' \
  --dart-define=FIREBASE_STORAGE_BUCKET='fyp-expo-hub.firebasestorage.app'

# Deploy backend + hosting
firebase deploy --only firestore:rules,hosting

# Emulators (full local suite)
firebase emulators:start
```

### Implementation notes & known constraints
- **Credentials are build-time only** — never committed. They are passed via `--dart-define` from `.env` locally and from GitHub Actions secrets in CI. If they are missing, `main.dart` logs `Firebase init error: auth/invalid-api-key` and the app falls back to the bundled seed data.
- **Public domain ≠ admin domain.** The public site runs on GitHub Pages (SPA deep links return 404 at the HTTP layer, mitigated by copying `index.html` → `404.html` in CI); the admin site runs on Firebase Hosting where SPA rewrites return HTTP 200. Consolidating onto Firebase Hosting is a documented option in the local-only `future.md`.
- **Lecturer accounts are two-step:** the admin panel writes the `lecturers` document only; the Firebase **Auth user** must be created manually (Console → Authentication → Add user) for the lecturer to be able to sign in.
- **Awards `sponsor` / `description`** are persisted as nullable fields and prefilled on edit.
- **Audit logs from the client are best-effort** (rules deny client-side writes); full audit-trail integrity requires the Cloud Function callables (Blaze plan).
- **Analysis baseline** shows pre-existing deprecation/lint infos (e.g. `withOpacity`, `surfaceVariant`, dead code in `schedule_page.dart`) — not introduced by the fixes, and not blocking.

---

## Deployment

### GitHub Pages (public domain — `fskmjasinfypexhibition.site`)
- Workflow: `.github/workflows/deploy.yml`, runs on every push to `main`.
- Steps: checkout → setup Flutter → `flutter pub get` + `flutter build web --release --base-href "/"` with `FIREBASE_*` values from repo secrets → copy `index.html` → `404.html` → upload Pages artifact → deploy.
- Required repository secrets (Settings → Secrets → Actions): `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET`.

### Firebase Hosting (admin CMS + fallback)
- Serves `build/web` for `admin.fskmjasinfypexhibition.site` and `fyp-expo-hub.web.app`.
- `firebase.json` rewrites `**` → `/index.html` so deep links like `/admin/visits` load correctly.
- Deploy: `firebase deploy --only firestore:rules,hosting` (rules deploy is included; functions deploy is `firebase deploy --only functions`).

> The trade-offs between the current two-provider setup (Option A) and migrating the public domain to Firebase Hosting (Option B) are documented in the local-only `future.md`.

---

## Project Structure

```
.
├── .env                         # Local credentials (GITIGNORED)
├── .github/workflows/deploy.yml # Pages CI
├── firebase.json                # Hosting/functions/storage/emulators config
├── firestore.rules              # Firestore security rules
├── firestore.indexes.json       # Composite indexes
├── storage.rules                # Storage security rules
├── pubspec.yaml                 # Flutter deps + fonts (Inter, Montserrat)
├── web/                         # index.html, fonts, icons, project images
├── functions/                   # Cloud Functions (TypeScript)
│   └── src/index.ts, lecturers.ts, visits.ts
└── lib/
    ├── main.dart
    ├── app/        (router, theme, shells)
    ├── core/       (models, firebase service, state, data fallback, widgets)
    └── features/
        ├── public_*        (home, schedule, projects, booths, announcements,
        │                    awards, lecturer portal, info, faq/privacy)
        ├── lecturer_auth, lecturer_visits
        └── admin_*         (auth, dashboard, event, schedule, projects, booths,
                             lecturers, announcements, visits, awards, imports, settings)
```
