# FYP Expo Hub (FSKM FYP Expo Hub 2026)

The official web portal for the **Final Year Project Exhibition (FYP Expo)** of the Faculty of Computer and Mathematical Sciences (FSKM), UiTM — plus **FYPMS**, an integrated FYP Management System used across the semester. The Expo site showcases final-semester student projects, schedules, booths, announcements and award winners, with a "My Visits" tracking system for lecturers. FYPMS digitises the full FYP workflow (records, supervision, forms, progress logs, reports, corrections, marks, presentations) for students, supervisors, examiners, CSP lecturers and coordinators.

- **Public site:** https://fskmjasinfypexhibition.site (GitHub Pages)
- **Admin CMS:** https://admin.fskmjasinfypexhibition.site (GitHub Pages)
- **Backend:** Supabase Project `siedglubjcedkbrpdzgi` — https://siedglubjcedkbrpdzgi.supabase.co
- **Event:** FSKM FYP Expo Hub 2026 — Semester March–August 2026, 6–7 August 2026 (completed; site remains live as the project archive)

---

## Table of Contents

1. [Project Description](#project-description)
2. [Full Stack](#full-stack)
3. [Roles & Authentication](#roles--authentication)
4. [Features](#features)
5. [FYPMS (FYP Management System)](#fypms-fyp-management-system)
6. [System Architecture](#system-architecture)
7. [Data Model](#data-model)
8. [Security (RLS Policies)](#security-rls-policies)
9. [Development & Implementation](#development--implementation)
10. [Deployment](#deployment)
11. [Project Structure](#project-structure)
12. [Documentation](#documentation)

---

## Project Description

FYP Expo Hub is a Flutter Web application with two products on one codebase:

- **Expo Hub** — the public exhibition portal:
  - **For visitors** — browse the project catalogue, daily schedule, booth map, announcements, and award winners with no sign-in required. Includes the CSP600 Junior Project Guide (past-title browsing with similarity/redundancy clustering).
  - **For lecturers** — sign in with their UiTM email, view only the projects they are assigned to (as **Supervisor / SV** or **Examiner / EX**), mark visits as completed, and void a visit with a mandatory reason.
  - **For admins** — run a full CMS: event info, schedules, projects, booths, lecturers, announcements, awards, feedback moderation, a "My Visits" monitoring dashboard, and the master-Excel import/staging pipeline.
- **FYPMS** — the semester-long FYP management system (`/fypms/**`): student, supervisor, examiner, CSP lecturer and coordinator workspaces over FYP records, forms (F1–F16), progress logs, report versions, deliverables, lean canvases, corrections, milestones, marks and presentations, with a bridge that publishes finished records into the public Expo catalogue.

The Expo site reads live from **Supabase Postgres** and ships with a bundled offline/fallback dataset (376 projects) so the public site still renders even if Supabase is paused/unreachable.

---

## Full Stack

### Frontend
| Layer | Technology |
|---|---|
| Language / framework | Flutter (Dart SDK `^3.11.0`), Flutter Web |
| State management | `flutter_riverpod` `^3.3.2` (Notifier / FutureProvider / Provider) |
| Routing | `go_router` `^17.3.0` (SPA with role-aware redirect guards) |
| Data models | `freezed` + `json_serializable`, generated via `build_runner` |
| UI helpers | `google_fonts`, custom `DesignSystem` tokens (Inter / Montserrat, Material 3), `flutter_svg`, `cached_network_image`, `file_picker`, `intl`, `uuid`, `excel` (in-browser Excel parsing), `csv` |
| Supabase client | `supabase_flutter` `^2.8.4` (PKCE auth flow) |
| URL strategy | `usePathUrlStrategy()` (clean paths, no `/#/`) |

### Backend (Supabase)
| Service | Purpose |
|---|---|
| **Supabase Auth** | Sign-in for admins, lecturers and FYPMS users (email/password). Roles come from `profiles.role` + `profile_academic_roles`. |
| **Supabase Postgres** | Primary database — **42 tables** with Row Level Security, **~55 functions** (helpers + SECURITY DEFINER RPCs). |
| **Supabase Realtime** | Live-change invalidation: announcements, student visits, and 5 FYPMS workflow tables (multiplexed channel). |
| **Supabase Storage** | 5 FYPMS buckets (4 private path-scoped + 1 public), path convention `{semester}/{record}/{type}/{version}/{file}`. |
| **GitHub Pages** | Serves both public domain and admin CMS (single host). SPA rewrites via `404.html` fallback. |

### Tooling & CI/CD
- **Flutter SDK** at `D:\Dev\SDK\flutter`
- **Supabase CLI** — linked to the `fyp-expo-hub` project
- **GitHub Actions** (`.github/workflows/deploy.yml`) — `flutter analyze` + `flutter test` gates, then builds `build/web` with `--dart-define` credentials from repo secrets and deploys to Pages. An `uptime-monitor.yml` cron probes the public site.

---

## Roles & Authentication

| Role | How authorised | Access |
|---|---|---|
| **Anonymous visitor** | No sign-in | Public pages only. RLS allows reads only where `publication_status = 'published'`. |
| **Lecturer (Expo)** | Supabase Auth with a UiTM email in `profiles` (`role: 'lecturer'`) | Public site + `/lecturer/visits` for assigned projects (SV/EX). |
| **Admin** | `profiles.role = 'admin'` | Full Expo CMS (`/admin/**`). |
| **FYPMS users** | `profile_academic_roles` rows (`student`, `supervisor`, `co_supervisor`, `examiner`, `csp600_lecturer`, `csp650_lecturer`, `fyp_coordinator`) | Role-scoped workspaces under `/fypms/**`. |

Route guarding lives in the router:
- `/admin/**` redirects unauthenticated or non-admin users to `/admin/sign-in`.
- `/lecturer/**` requires sign-in; signed-in lecturers coming from the sign-in page land on `/lecturer/visits`.
- `/fypms/**` requires authentication; users are redirected to their home workspace by role priority (student > supervisor > examiner > CSP > coordinator) and blocked from workspaces they hold no role in.

---

## Features

### Expo Hub — public site (no login)

| Page | Route | Features |
|---|---|---|
| **Home** | `/` | Hero, search box, featured projects carousel, exhibition overview, quick links. |
| **Schedule** | `/schedule` | Daily programme (TENTATIF). |
| **Projects** | `/projects`, `/projects/:slug` | Searchable catalogue (programme / category / "Industry Candidate" filter) + detail pages with team, supervisor/examiner, booth, links, tech tags. |
| **Junior Project Guide** | `/projects/junior-guide` | CSP600 past-title browser with similarity clustering to detect redundant proposals. |
| **Booths** | `/booths` | Booth directory + static hall layout plan. |
| **Announcements** | `/announcements` | Pinned + published announcements. |
| **Awards** | `/awards` | Published award winners. |
| **Lecturer Portal** | `/lecturer`, `/lecturer/sign-in` | Public SV/EX lookup + My Visits sign-in. |
| **FAQ / Privacy / Info** | `/faq`, `/privacy`, `/info` | FAQ, PDPA statement, exhibition info. |
| **Feedback** | (floating button) | Anonymous/authenticated feedback entries moderated in the CMS. |

### Expo Hub — lecturer My Visits
- `/lecturer/visits` — lists active SV/EX assignments with progress summary.
- `/lecturer/visits/:projectId` — per-role sections; **Mark as Visited** (optional note) via `mark_student_project_visited` RPC; **Cancel Visit** with mandatory reason via `void_student_project_visit` RPC.

### Expo Hub — Admin CMS (`/admin/**`)
Overview dashboard, event info, schedule, projects, booths, lecturers, announcements, awards, feedback moderation, visits monitoring (Overview / By Lecturer / By Project / Visit Log + CSV export), master-file import (drag-drop `.xlsx` parsed in-browser → staged candidates → selective publish RPC), settings.

### Cross-cutting
- **Publication lifecycle** — `draft` / `published` / `archived` on all public tables; anonymous reads see `published` only.
- **Offline fallback** — the public site seeds from a bundled `ExcelData` dataset (376 projects) and swaps to Supabase rows when available.
- **Audit logging** — every mutating RPC writes `audit_logs` / `fyp_audit_logs` server-side; no client write path.

---

## FYPMS (FYP Management System)

Five role-aware workspaces under `/fypms`:

| Workspace | Pages | Highlights |
|---|---|---|
| **Student** | 12 | FYP records (self-registration), supervision requests (F1), weekly progress logs (F5), forms F1–F16 (JSON payload), Lean Canvas editor with versioning, report uploads to Storage with versioning, typed deliverables checklist, corrections evidence submission, milestones, marks |
| **Supervisor** | 6 | Assigned records, progress review (validate/reject), form evaluations (rubric-weighted, server-computed), correction items |
| **Examiner** | 4 | Assigned records, form evaluations, correction items |
| **CSP Lecturer** | 6 | Own offerings dashboard, supervision requests, milestones, marks finalisation (weighted totals, finalise lock) |
| **Coordinator** | 7 | All records, supervisor/examiner assignment, request decisions, presentation scheduling, **Expo publication bridge** (prepare → publish records into the public catalogue), audit log viewer |

All FYPMS mutations go through **SECURITY DEFINER RPCs** (~25 functions) that validate `auth.uid()`, enforce role gates, maintain workflow state, and write audit entries. Realtime invalidation keeps dashboards live.

---

## System Architecture

Feature-first layered Flutter architecture with a Supabase service layer:

```
lib/
├── main.dart                  # Bootstrap: Supabase init (dart-define creds), runApp
├── app/
│   ├── router.dart            # go_router config, role-aware redirects, 3 shells
│   ├── theme/theme.dart       # DesignSystem tokens (colors, typography, spacing)
│   └── widgets/               # PublicShell, AdminShell, FypmsShell, feedback form
├── core/
│   ├── supabase/              # Client provider + auth/db/rpc/realtime/storage services
│   │                          #   + FYPMS variants (db, rpc, realtime)
│   ├── data/excel_data.dart   # Bundled offline fallback dataset (generated)
│   ├── domain/models/         # freezed models (Expo + fypms/ subfolder)
│   ├── state/                 # state_providers.dart + fypms_state_providers.dart
│   ├── utils/                 # key normalizer (snake_case → camelCase), logger
│   └── widgets/               # Shared widgets (project cards, cover images)
└── features/
    ├── public_*               # Expo public pages
    ├── lecturer_auth, lecturer_visits
    ├── admin_*                # Expo CMS pages
    ├── fypms/                 # FYPMS pages (student/supervisor/examiner/csp/coordinator)
    └── junior_project_guide   # CSP600 past-title browser + similarity engine
```

Data flow pattern:
1. **UI** watches a Riverpod provider.
2. **Provider/Notifier** fetches from Supabase (one-shot reads with realtime-driven invalidation) and maps rows → typed models via `normalizeKeys` + `fromJson`.
3. **Mutations** call SECURITY DEFINER RPCs, then invalidate the affected providers.

---

## Data Model

### Expo Hub tables (19)
`events`, `projects`, `schedule_items`, `booths`, `announcements`, `award_categories`, `award_winners` (public, `published`-only reads) — `profiles`, `imports` + 5 `import_*` staging tables, `audit_logs`, `settings`, `lecturer_assignments`, `student_project_visits`, `feedback_entries` (admin/auth-scoped).

### FYPMS tables (23)
Core: `fyp_records` (17-state workflow), `fyp_record_assignments`. Reference: `academic_semesters`, `academic_courses`, `fyp_course_offerings`, `profile_academic_roles`. Per-record: `fyp_supervision_requests`, `fyp_progress_logs`, `fyp_form_submissions`, `fyp_form_evaluations`, `fyp_rubric_templates`, `fyp_report_submissions`, `fyp_deliverables`, `fyp_lean_canvases`, `fyp_correction_items`, `fyp_correction_confirmations`, `fyp_milestones`, `fyp_milestone_extensions`, `fyp_marks_summaries`, `fyp_presentation_sessions`, `fyp_presentation_slots`. Bridge/audit: `fyp_expo_publications`, `fyp_audit_logs`.

Full column reference: [`SUPABASE_SCHEMA.md`](./SUPABASE_SCHEMA.md).

---

## Security (RLS Policies)

All **42 tables** have **RLS enabled** with role-scoped policies (~119 policies):
- Anonymous visitors read only `published` public rows.
- FYPMS rows are visible to the record's owner, assigned staff, course lecturer, coordinator and admin via `can_read_fyp_record()`.
- All mutations go through audited SECURITY DEFINER RPCs; direct student UPDATE policies were removed (September 2026 hardening).
- Storage buckets are path-scoped to the owning FYP record; the public-assets bucket is coordinator/admin-write-only.
- `list_fyp_students/staff/coordinators()` are gated to coordinator/CSP/admin.

See [`SECURITY.md`](./SECURITY.md) (including the accepted-risk register) and [`SUPABASE_RLS_POLICIES.md`](./SUPABASE_RLS_POLICIES.md).

---

## Development & Implementation

### Prerequisites
- Flutter SDK `^3.11.0`
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- Supabase project access (ref: `siedglubjcedkbrpdzgi`)

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

# Run the test suite (132 tests)
flutter test

# Release build with credentials
flutter build web --release \
  --dart-define=SUPABASE_URL='https://siedglubjcedkbrpdzgi.supabase.co' \
  --dart-define=SUPABASE_ANON_KEY='<your-anon-key>'

# Supabase CLI
supabase login
supabase db push
```

### Implementation notes & known constraints
- **Credentials are build-time only.** If missing, the app falls back to bundled seed data.
- **Offline fallback** — `ExcelData` seeds providers; a maintenance dialog appears when the backend is unreachable.
- **Demo accounts** — 11 `@fypms.test` accounts exist on the live project for development testing (see SECURITY.md accepted-risk register). **Disable before production.**
- **Realtime** — one-shot reads + realtime invalidation channels (announcements, visits, 5 FYPMS tables); not full-table streaming.
- **No raw Excel files** are stored — parsing is client-side via the `excel` package.

---

## Deployment

- **Workflow:** `.github/workflows/deploy.yml` — on push to `main`: `pub get` → `flutter analyze` → `flutter test` → `flutter build web --release --base-href "/"` with `SUPABASE_*` secrets → copy `index.html` → `404.html` → deploy to Pages.
- **Required repository secrets:** `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- **Database:** migrations in `supabase/migrations/` (applied via Supabase MCP/CLI; the live project also carries a historical `populate_projects` migration series from the initial bulk import).

---

## Project Structure

```
.
├── .github/workflows/deploy.yml     # Pages CI (analyze + test + build + deploy)
├── .github/workflows/uptime-monitor.yml
├── .env.example                     # Environment template (no real keys)
├── supabase/
│   ├── config.toml
│   ├── migrations/                   # SQL migrations
│   └── types.ts                     # Generated TypeScript types
├── assets/data/csp600-proposals.csv # Junior guide dataset
├── web/                             # index.html, fonts, icons
├── lib/                             # Dart source (see System Architecture)
├── test/                            # 132 tests (unit + widget + route guards)
└── *.md                             # Documentation (see below)
```

---

## Documentation

| Document | Description |
|---|---|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System architecture (Expo + FYPMS) |
| [SUPABASE_SCHEMA.md](./SUPABASE_SCHEMA.md) | Database schema reference (42 tables) |
| [SUPABASE_RLS_POLICIES.md](./SUPABASE_RLS_POLICIES.md) | Row Level Security policy matrix |
| [DATABASE_FUNCTIONS.md](./DATABASE_FUNCTIONS.md) | RPC function documentation |
| [SECURITY.md](./SECURITY.md) | Security policy, hardening log, accepted risks |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Deployment instructions |
| [TESTING.md](./TESTING.md) | Testing guide |
| [ADMIN_GUIDE.md](./ADMIN_GUIDE.md) | Expo CMS usage guide |
| [IMPORT_PIPELINE.md](./IMPORT_PIPELINE.md) | Excel import workflow |
| [FREE_TIER_LIMITS.md](./FREE_TIER_LIMITS.md) | Cost and limit analysis |
| [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md) | Pre-release verification |
