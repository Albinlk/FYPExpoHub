# FYP Expo Hub (FSKM FYP Expo Hub 2026)

The official web portal for the **Final Year Project Exhibition (FYP Expo)** of the Faculty of Computer and Mathematical Sciences (FSKM), UiTM. It showcases final-semester student projects, schedules, booths, announcements and award winners, and provides a "My Visits" tracking system that lets lecturers digitally sign off that they have visited student booths during the exhibition.

- **Public site:** https://fskmjasinfypexhibition.site (GitHub Pages)
- **Admin CMS:** https://admin.fskmjasinfypexhibition.site (GitHub Pages)
- **Backend:** Supabase Project `siedglubjcedkbrpdzgi` — https://siedglubjcedkbrpdzgi.supabase.co
- **Event:** FSKM FYP Expo Hub 2026 — Semester March–August 2026, 6–7 August 2026, Lecture Block, FSKM (9:00 AM – 5:00 PM daily)

---

## Table of Contents

1. [Project Description](#project-description)
2. [Full Stack](#full-stack)
3. [Roles & Authentication](#roles--authentication)
4. [Features](#features)
5. [System Architecture](#system-architecture)
6. [System Flow](#system-flow)
7. [Data Model](#data-model)
8. [Security (RLS Policies)](#security-rls-policies)
9. [Database Functions (RPC)](#database-functions-rpc)
10. [Development & Implementation](#development--implementation)
11. [Deployment](#deployment)
12. [Project Structure](#project-structure)
13. [Documentation](#documentation)

---

## Project Description

FYP Expo Hub is a Flutter Web application that digitises the complete lifecycle of the FSKM FYP Exhibition:

- **For visitors** — browse the project catalogue, daily schedule, booth map, announcements, and award winners with no sign-in required.
- **For lecturers** — sign in with their UiTM email, view only the projects they are assigned to (as **Supervisor / SV** or **Examiner / EX**), mark visits as completed, and void a visit at any time with a mandatory reason.
- **For admins** — run a full CMS: manage event info, schedules, projects, booths, lecturers, announcements, awards, and a "My Visits" monitoring dashboard, plus import the master Excel workbook to bulk-stage and publish content.

The app reads live from **Supabase Postgres** via the Realtime API and ships with an offline/fallback dataset so the public site still renders content even if Supabase is paused/unreachable.

---

## Full Stack

### Frontend
| Layer | Technology |
|---|---|
| Language / framework | Flutter (Dart SDK `^3.11.0`), Flutter Web |
| State management | `flutter_riverpod` `^3.3.2` (Notifier / StreamProvider / Provider) |
| Routing | `go_router` `^17.3.0` (SPA with redirect guards) |
| Data models | `freezed` `^3.2.5` + `json_serializable` `^6.14.0`, generated via `build_runner` |
| UI helpers | `google_fonts`, custom `DesignSystem` design tokens (Inter / Montserrat, Material 3), `flutter_svg`, `cached_network_image`, `file_picker`, `intl`, `uuid`, `excel` (in-app Excel parsing) |
| Supabase client | `supabase_flutter` `^2.8.4` |
| URL strategy | `usePathUrlStrategy()` (clean paths, no `/#/`) |

### Backend (Supabase)
| Service | Purpose |
|---|---|
| **Supabase Auth** | Sign-in for admins and lecturers (email/password). Admin role stored in `profiles.role`. |
| **Supabase Postgres** | Primary database — 19 tables with Row Level Security (RLS), 6 helper functions, 5 RPC functions. |
| **Supabase Realtime** | Live data streaming via Riverpod `StreamProvider` over Postgres. |
| **Supabase Edge Functions** | N/A — Excel parsing is done client-side in Flutter (via `excel` package), no server-side processing needed. |
| **GitHub Pages** | Serves both public domain and admin CMS (single-host). SPA rewrites handled via `404.html` fallback. |
| **Storage** | Static images and documents served from external CDN (not Supabase Storage). No raw Excel files persisted. |

### Tooling & CI/CD
- **Flutter SDK** at `D:\Dev\SDK\flutter`
- **Supabase CLI** — linked to `fyp-expo-hub` project (use `npx supabase` commands)
- **GitHub Actions** (`.github/workflows/deploy.yml`) — builds `build/web` with `--dart-define` credentials from repo secrets and deploys to Pages

---

## Roles & Authentication

| Role | How authorised | Access |
|---|---|---|
| **Anonymous visitor** | No sign-in | Public pages only. RLS policies only allow read access to rows where `publication_status = 'published'`. |
| **Lecturer** | Supabase Auth with a UiTM email that exists in `profiles` (role: `lecturer`). | Public site + `/lecturer/visits`, `/lecturer/visits/:projectId`. RLS restricts visit reads/writes to their own assignments. |
| **Admin** | Supabase Auth user whose `profiles.role` is `admin`. | Full CMS (`/admin/**`). |

Route guarding lives in the router:
- On the public domain, `/` serves the public shell.
- `/admin/**` redirects unauthenticated or non-admin users to `/admin/sign-in`.
- `/lecturer/**` redirects to `/lecturer/sign-in` for unauthenticated users.

---

## Features

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
| **My Visits dashboard** | `/lecturer/visits` — lists only active assignments where the signed-in lecturer is the assigned SV or EX. Progress summary per role (completed / total). |
| **Project visit detail** | `/lecturer/visits/:projectId` — two sections (Supervisor / Examiner). Shows visit time, note, and status chip (Visited / Not Visited / Voided). |
| **Mark as visited** | Calls the `mark_student_project_visited` RPC function to create a visit record with `status: 'completed'` (note optional). The RPC validates ownership, active assignment, and duplicate prevention. |
| **Void visit** | Calls the `void_student_project_visit` RPC function with a mandatory reason. The function enforces admin-or-owner access. |
| **Admin panel shortcut** | Link from the lecturer dashboard to the admin sign-in. |

### Admin CMS (protected)

| Page | Route | Features |
|---|---|---|
| **Overview Dashboard** | `/admin` | Stats (total projects, booths, schedules, files imported), quick actions, recent imports. |
| **Event Information** | `/admin/event` | Edit title, session label, dates, venue, poster, contact email, description, objectives, FAQs. |
| **Schedule Management** | `/admin/schedule` | CRUD daily schedule items with a published/draft toggle. |
| **Project Catalogue** | `/admin/projects` | CRUD projects, publish/draft toggle, covers all public project fields. |
| **Booth Management** | `/admin/booths` | Register booths, map/unmap projects to booths, delete mappings. |
| **Lecturer Management** | `/admin/lecturers` | Add lecturers (creates a `profiles` row — the Auth user must be created manually in Supabase Studio → Authentication → Users), delete lecturers, and "Backfill Lecturer IDs". |
| **Announcements** | `/admin/announcements` | CRUD, pin/unpin, publish/draft toggle. |
| **Student Visits** | `/admin/visits` | Live monitoring with tabs **Overview / By Lecturer / By Project / Visit Log**, role + status filters, search, **Void Visit** (with mandatory reason), and **Export CSV**. |
| **My Visits (Lecturer)** | `/lecturer/visits` | Convenience link to the lecturer view. |
| **Award Winners** | `/admin/awards` | CRUD award records (category, project, students, supervisor, sponsor, description), publish/draft toggle. |
| **Import Master File** | `/admin/imports` | Drag-and-drop `.xlsx` upload (≤ 10 MB) that triggers in-browser parsing via the `excel` package. |
| **Import Detail** | `/admin/imports/:importId` | "Data Matching Dashboard" — reviews staged schedule + award candidates, sees validation issues, privacy skips, and publishes selected items into the live tables via the `publish_approved_import_changes` RPC function. |
| **Settings** | `/admin/settings` | Portal settings (file size limit, mandatory worksheet names) persisted to `settings` table. |

### Cross-cutting features

- **Publication lifecycle** — every public table carries `publication_status` (`draft` / `published` / `archived`). The public site queries only `published` rows; the admin site queries all.
- **Realtime updates** — Riverpod notifiers subscribe to Supabase Realtime streams; changes appear instantly on both public and admin sites.
- **Offline fallback** — project/schedule/booth providers seed from a bundled `ExcelData` dataset and swap to Supabase data when the stream connects.
- **Audit logging** — write actions create entries in `audit_logs` (best-effort from the client; RLS restricts to admin read + server-side writes via RPC).

---

## System Architecture

Feature-first layered Flutter architecture with a Supabase service layer:

```
lib/
├── main.dart                  # Bootstrap: Supabase init (dart-define creds), runApp
├── app/
│   ├── router.dart            # go_router config, auth redirects, public/admin shells
│   ├── theme/                 # DesignSystem tokens (colors, typography, radii, spacing)
│   └── widgets/               # PublicShell (nav) + AdminShell (sidebar/drawer)
├── core/
│   ├── supabase/              # Supabase client provider + service files (5 files)
│   ├── data/                  # ExcelData offline fallback datasets
│   ├── domain/models/         # freezed models (+ generated .freezed/.g)
│   ├── state/                 # Riverpod providers & notifiers (9 files)
│   └── widgets/               # Shared widgets (project cover image, etc.)
└── features/                  # One folder per domain (public_*, admin_*, lecturer_*)
    └── <feature>/presentation/pages|widgets
```

Data flow pattern:
1. **UI** watches a Riverpod provider.
2. **Provider/Notifier** subscribes to a Supabase Realtime stream and maps rows → typed models.
3. **Model** `fromJson` parses Supabase rows.
4. Mutations go through notifier methods that call Supabase client methods or RPC functions.

---

## System Flow

### 1. Master-file import → staging → publication (admin)
```
Admin uploads master .xlsx
  → Parsed in-browser via `excel` package
  → Staged candidates written to import_* tables (status: pending_review)
  → Admin opens /admin/imports/{importId} ("Data Matching Dashboard")
      → reviews candidates side-by-side with current data
      → "Publish Selective Items" calls publish_approved_import_changes RPC
          → writes approved candidates into live tables (schedule_items, award_winners)
  → Public site streams show the new published content
```

### 2. Visit tracking flow
```
Lecturer signs in (UiTM email)
  → supabase_auth_provider validates email against profiles table
  → My Visits lists active assignments (SV/EX) for that lecturer
Lecturer opens a project → taps "Mark as Visited" (+ note)
  → calls mark_student_project_visited RPC
      → validates ownership, active assignment, duplicate check
      → creates student_project_visits row, status: completed
      → creates audit_logs entry (visit_marked)
  → Admin dashboard live count updates
Lecturer "Void Visit" (with mandatory reason)
  → calls void_student_project_visit RPC
      → validates ownership
      → updates status → 'voided', records voided_at / voided_by / void_reason
      → creates audit_logs entry (visit_voided)
Export: admin downloads student_visits.csv (client-side base64 data URI)
```

### 3. Content publication flow (per table)
```
Admin edits content in CMS (draft) → toggles "Publish"
  → Row gets publication_status = 'published' + updated_at
  → Public provider query re-emits the row
  → RLS: anonymous read only if publication_status = 'published'
```

### 4. Deployment flow
```
Push to main
  └─ GitHub Actions: flutter build web --release (creds from secrets) → GitHub Pages
```

---

## Data Model

### Public tables (streamed by the public site, `published` only)
| Table | Rows |
|---|---|
| `events` | `fskm-fyp-2026` event metadata, objectives, FAQs |
| `projects` | project slug, title, matric ID, programme, category, tags, booth, images, team/supervisor/examiner names, demo/video/repo URLs, `featured`, `industry_candidate`, publication status |
| `schedule_items` | date, start/end time, title, venue, audience, visibility, publication status |
| `booths` | booth number, zone, location note, floor-plan URL, linked `project_id` |
| `announcements` | title, body, `is_pinned`, publication status |
| `award_categories` | award category definitions |
| `award_winners` | award category, project id/title, students, supervisor, programme, sponsor, description, publication status |

### Private tables (admin / authenticated users)
| Table | Purpose |
|---|---|
| `profiles` | user profiles (email, display_name, role, is_active) |
| `imports` | import records (status, summary, warning_counts) |
| `import_schedule_candidates` | staged schedule rows from the workbook |
| `import_award_candidates` | staged award rows from the workbook |
| `import_validation_issues` | overlap / missing-field / format warnings with row numbers |
| `import_privacy_skips` | rows skipped for PDPA personal-data protection |
| `import_review_decisions` | publish/skip decisions per candidate |
| `audit_logs` | actor, action, target type/id, metadata_safe, timestamp |
| `settings` | portal configuration (key-value JSON) |
| `lecturer_assignments` | links project ↔ lecturer with role (`supervisor`/`examiner`) + `status` |
| `student_project_visits` | visit records (status: completed / voided, visit_role, visited_at, visit_note, void_reason) |

### Models (freezed)
`Project`, `ScheduleItem`, `Booth`, `Announcement`, `PublishedAwardWinner` / `AwardCategory`, `Event` (+ `FaqItem`), `Lecturer`, `ProjectLecturerAssignment`, `StudentVisit`, `AuditLog`, `ImportRecord` + staging models (`ScheduleCandidate`, `AwardCandidate`, `PrivacySkip`, `ValidationIssue`).

---

## Security (RLS Policies)

All 19 Supabase tables have **Row Level Security (RLS)** enabled. Access is
controlled via policies that check the authenticated user's role from
`profiles.role`.

### Default policies
- **Anonymous visitors** can `SELECT` rows where `publication_status = 'published'`.
- **Authenticated lecturers** can read their own assignments and visits.
- **Admins** (role = 'admin') have full access to all tables.
- **No direct writes** allowed for non-admin users on sensitive tables
  (imports, audit_logs, settings, lecturer_assignments, student_project_visits).

### Key restrictions
- Writes to `student_project_visits` must go through RPC functions
  (`mark_student_project_visited`, `void_student_project_visit`).
- Writes to `imports` and staging tables are admin-only.
- Audit log reads are admin-only.

See [`SUPABASE_RLS_POLICIES.md`](./SUPABASE_RLS_POLICIES.md) for the full policy matrix.

---

## Database Functions (RPC)

All 5 custom PostgreSQL functions use `SECURITY DEFINER` so they execute
with the function owner's privileges.

| Function | Role Required | Purpose |
|---|---|---|
| `mark_student_project_visited(p_assignment_id, p_visit_note?)` | lecturer/admin | Creates a visit record with validation (ownership, active assignment, duplicate prevention). |
| `void_student_project_visit(p_visit_id, p_reason)` | lecturer/admin | Voids a completed visit; enforces admin-or-owner access. |
| `publish_approved_import_changes(p_import_id)` | admin | Publishes reviewed candidates into live tables. |
| `create_lecturer_account_profile(p_user_id, p_email, p_display_name)` | admin | Creates or updates a lecturer profile. |
| `update_event_configuration(p_event_id, p_payload)` | admin | Updates event configuration fields from a JSON payload. |

See [`DATABASE_FUNCTIONS.md`](./DATABASE_FUNCTIONS.md) for full details.

---

## Development & Implementation

### Prerequisites
- Flutter SDK `^3.11.0` (installed at `D:\Dev\SDK\flutter`).
- [Supabase CLI](https://supabase.com/docs/guides/cli) (`npm i -g supabase`).
- Supabase project access (project ref: `siedglubjcedkbrpdzgi`).

### Environment variables
Build-time credentials are passed via `--dart-define`. Never commit real values.

```env
SUPABASE_URL=https://siedglubjcedkbrpdzgi.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```

### Common commands
```bash
# Generate freezed / json_serializable code
flutter pub run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Release build with credentials
flutter build web --release \
  --dart-define=SUPABASE_URL='https://siedglubjcedkbrpdzgi.supabase.co' \
  --dart-define=SUPABASE_ANON_KEY='<your-anon-key>'

# Supabase CLI (if needed)
supabase login
supabase db push
```

### Implementation notes & known constraints
- **Credentials are build-time only** — never committed. Passed via `--dart-define` locally and from GitHub Actions secrets in CI. If they are missing, `main.dart` logs a warning and the app falls back to the bundled seed data.
- **Offline fallback** — the `ExcelData` seed dataset allows the public site to function even if Supabase is paused or unreachable. A maintenance dialog is shown when the backend is unavailable.
- **Lecturer accounts are two-step:** the admin panel writes the `profiles` row only; the Supabase Auth user must be created manually (Studio → Authentication → Users) for the lecturer to sign in.
- **No raw Excel files** are stored on Supabase Storage — parsing happens client-side in the browser via the `excel` package.
- **`matricId`** on projects is classified as approved public exhibition metadata per PDPA policy.

---

## Deployment

### GitHub Pages (public domain — `fskmjasinfypexhibition.site`)
- Workflow: `.github/workflows/deploy.yml`, runs on every push to `main`.
- Steps: checkout → setup Flutter → `flutter pub get` + `flutter build web --release --base-href "/"` with `SUPABASE_*` values from repo secrets → copy `index.html` → `404.html` → upload Pages artifact → deploy.
- Required repository secrets (Settings → Secrets → Actions): `SUPABASE_URL`, `SUPABASE_ANON_KEY`.

### Supabase
- Live database: project `siedglubjcedkbrpdzgi`.
- Schema migrations: `supabase/migrations/` (4 files, all applied).
- TypeScript types: `supabase/types.ts`.
- Admin access: Supabase Studio at https://supabase.com/project/_/studio

---

## Project Structure

```
.
├── .github/workflows/deploy.yml    # Pages CI
├── .env                              # Local credentials (GITIGNORED)
├── supabase/
│   ├── config.toml                   # Project configuration
│   ├── migrations/                   # SQL migrations (4 files)
│   └── types.ts                      # Generated TypeScript types
├── tools/
│   └── firebase_to_supabase/
│       └── migrate_data.js           # Firestore export → SQL tool
├── scripts/
│   ├── .env                          # Supabase credentials
│   └── lib/
│       ├── config.js                 # Environment configuration
│       └── firebase_api.js           # Supabase REST helpers
├── pubspec.yaml                      # Flutter deps + fonts (Inter, Montserrat)
├── web/                              # index.html, fonts, icons, project images
├── lib/
│   ├── main.dart
│   ├── app/          (router, theme, shells)
│   ├── core/
│   │   ├── supabase/ (client provider + services)
│   │   ├── data/     (offline fallback datasets)
│   │   ├── domain/   (models)
│   │   ├── state/    (Riverpod providers)
│   │   └── widgets/  (shared widgets)
│   └── features/
│       ├── public_*
│       ├── lecturer_auth, lecturer_visits
│       └── admin_*
└── *.md                             # Documentation (see below)
```

---

## Documentation

| Document | Status | Description |
|---|---|---|
| [SUPABASE_MIGRATION.md](./SUPABASE_MIGRATION.md) | Complete | Migration guide from Firebase → Supabase |
| [SUPABASE_SCHEMA.md](./SUPABASE_SCHEMA.md) | Complete | Database schema reference (19 tables) |
| [SUPABASE_RLS_POLICIES.md](./SUPABASE_RLS_POLICIES.md) | Complete | Row Level Security policy matrix |
| [DATABASE_FUNCTIONS.md](./DATABASE_FUNCTIONS.md) | Complete | RPC function documentation |
| [FREE_TIER_LIMITS.md](./FREE_TIER_LIMITS.md) | Complete | Cost and limit analysis |
| [MIGRATION_REPORT.md](./MIGRATION_REPORT.md) | Complete | Migration status report |
| [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) | Complete | Pre-release verification checklist |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Complete | System architecture overview |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Complete | Detailed deployment instructions |
| [TESTING.md](./TESTING.md) | Complete | Testing documentation |
| [ADMIN_GUIDE.md](./ADMIN_GUIDE.md) | Complete | Admin CMS usage guide |
| [IMPORT_PIPELINE.md](./IMPORT_PIPELINE.md) | Complete | Excel import workflow |
| [SECURITY.md](./SECURITY.md) | Complete | Security policy and practices |
