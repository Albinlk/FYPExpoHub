# Architecture — FYP Expo Hub

## Overview

FYP Expo Hub is a **Flutter Web** application backed by **Supabase**
(PostgreSQL + Auth + Realtime + Storage). It contains two products:

1. **Expo Hub** — the public exhibition portal, lecturer My Visits, and the
   admin CMS.
2. **FYPMS** — the FYP Management System (student / supervisor / examiner /
   CSP lecturer / coordinator workspaces).

The architecture is feature-first with a layered service abstraction.

```
┌─────────────────────────────────────────────────┐
│                  User Browser                  │
│           (Flutter Web PWA — SPA)              │
└──────────────────┬─────────────────────────────┘
                   │ HTTPS / WebSocket (Realtime)
┌──────────────────┴─────────────────────────────┐
│                  Supabase Cloud                │
│  ┌──────────────┐  ┌────────────────────┐      │
│  │ Supabase Auth│  │ Supabase Postgres  │      │
│  │  (Auth UID)  │  │  42 tables + RLS   │      │
│  └──────────────┘  └─────────┬──────────┘      │
│                              │                 │
│                    Realtime invalidation       │
│                    + 5 Storage buckets         │
└────────────────────────────────────────────────┘
```

## Layers

### 1. Presentation Layer
- **Framework**: Flutter Web (Dart)
- **Routing**: `go_router` — SPA with role-aware redirect guards
  (admin gate, lecturer gate, FYPMS per-workspace gate)
- **Shells**: `PublicShell` (nav + feedback FAB), `AdminShell`
  (sidebar/drawer CMS), `FypmsShell` (role-conditional sidebar)
- **UI**: Material 3 with custom `DesignSystem` tokens

### 2. State Management Layer
- **Framework**: `flutter_riverpod` v3
- **Pattern**: `Notifier` (Expo CRUD) + `FutureProvider` / `.family`
  (FYPMS reads) + callable-provider wrappers for mutations
- **Files**:
  - `lib/core/state/state_providers.dart` — Expo: event, projects, schedule,
    booths, announcements, awards, imports, feedback, lecturer auth,
    assignments, visits
  - `lib/core/state/fypms_state_providers.dart` — FYPMS: role resolution,
    records, forms, logs, corrections, marks, presentations, publications,
    audit; realtime bridge provider

### 3. Domain Layer
- **Models**: `freezed` classes with `json_serializable`
- **Location**: `lib/core/domain/models/` (+ `fypms/` subfolder)
- **Key Expo models**: `Project`, `ScheduleItem`, `Booth`, `Announcement`,
  `AwardWinner`, `Event`, `StudentVisit`, `FeedbackEntry`, `ImportRecord`
- **Key FYPMS models**: `FypRecord` (17 workflow states),
  `FypSupervisionRequest`, `FypProgressLog`, `FypFormSubmission`,
  `FypFormEvaluation`, `FypReportSubmission`, `FypDeliverable`,
  `FypLeanCanvas`, `FypCorrectionItem`, `FypMilestone`, `FypMarksSummary`,
  `FypPresentationSession/Slot`, `FypExpoPublication`
- Rows are normalized (`normalizeKeys`: snake_case → camelCase, legacy-name
  fixes) before `fromJson`.

### 4. Data Layer

#### 4.1 Supabase Services (`lib/core/supabase/`)
- `supabase_client_provider.dart` — client + auth state + role providers
- Expo: `supabase_database_service.dart` (table CRUD),
  `supabase_rpc_service.dart` (visits/import/event RPCs),
  `supabase_realtime_service.dart` (announcements/visits channels),
  `supabase_storage_service.dart`, `supabase_auth_service.dart`
- FYPMS: `fypms_database_service.dart` (read-only!),
  `fypms_rpc_service.dart` (~25 RPCs), `fypms_realtime_service.dart`
  (multiplexed invalidation channel)

#### 4.2 Read Pattern
One-shot fetches + Realtime-driven invalidation (not full-table streams):
```dart
final data = await db.getFypRecordsOnce();          // read
ref.invalidate(fypRecordsProvider);                // after changes / realtime
```
Realtime channels watch announcements, student visits, and the 5 live FYPMS
workflow tables (supervision requests, progress logs, form submissions,
correction items, expo publications).

#### 4.3 Offline Fallback (Expo)
- **Seed data**: `lib/core/data/ExcelData` (bundled, 376 projects)
- **Pattern**: Providers seed with offline data, then swap when Supabase
  responds; a maintenance dialog shows if the backend is unreachable

### 5. Backend Layer

#### 5.1 Supabase Postgres (42 tables)
| Category | Tables |
|----------|--------|
| Expo public (published-only reads) | events, projects, schedule_items, booths, announcements, award_categories, award_winners |
| Expo admin/tracking | profiles, imports + 5 import_* staging, audit_logs, settings, lecturer_assignments, student_project_visits, feedback_entries |
| FYPMS core | fyp_records, fyp_record_assignments |
| FYPMS reference | academic_semesters, academic_courses, fyp_course_offerings, profile_academic_roles |
| FYPMS per-record | fyp_supervision_requests, fyp_progress_logs, fyp_form_submissions, fyp_form_evaluations, fyp_rubric_templates, fyp_report_submissions, fyp_deliverables, fyp_lean_canvases, fyp_correction_items, fyp_correction_confirmations, fyp_milestones, fyp_milestone_extensions, fyp_marks_summaries, fyp_presentation_sessions, fyp_presentation_slots |
| FYPMS bridge/audit | fyp_expo_publications, fyp_audit_logs |

#### 5.2 Security (RLS)
- All 42 tables have RLS enabled; ~119 policies
- ~55 functions: read-only helpers (`can_read_fyp_record`, `is_csp_lecturer`,
  ...) backing policies, plus ~30 SECURITY DEFINER RPCs for mutations
- All SECURITY DEFINER functions pin `search_path`
- Audit logs are RPC-written only (no client write policies)
- Storage policies are path-scoped to the owning FYP record
- See `SECURITY.md` and `SUPABASE_RLS_POLICIES.md`

#### 5.3 RPC Functions (mutations)
All critical mutations go through audited SECURITY DEFINER functions:
- Expo: `mark_student_project_visited`, `void_student_project_visit`,
  `publish_approved_import_changes`, `create_lecturer_account_profile`,
  `update_event_configuration`
- FYPMS: `create_fyp_record`, `submit_supervision_request`,
  `decide_supervision_request`, `submit_progress_log`,
  `validate_progress_log`, `submit_fyp_form` (F14–F16 feature-flagged),
  `submit_form_evaluation` (server-computed weighted totals),
  `submit_report_version`, `save_lean_canvas`, `submit_deliverable`,
  `create_correction_item`, `submit_correction_evidence`,
  `confirm_correction`, `assign_supervisor_to_fyp_record`,
  `assign_examiner`, `create_or_update_milestone`, `finalize_marks`
  (course-code cross-checked), `schedule_presentation_slot`,
  `prepare_expo_publication`, `publish_fyp_record_to_expo`,
  `archive_fyp_record`, coordinator list helpers

## Deployment Targets

| Target | Service | Purpose |
|--------|---------|---------|
| `fskmjasinfypexhibition.site` | GitHub Pages | Public-facing site |
| `admin.fskmjasinfypexhibition.site` | GitHub Pages | Admin CMS |
| `siedglubjcedkbrpdzgi.supabase.co` | Supabase | Backend (DB + Auth + Storage) |

## Key Design Decisions

### 1. Client-Side Excel Parsing
Master `.xlsx` files are parsed in the browser using the Dart `excel`
package; only parsed candidates are staged in the database. No server-side
processing, no raw file storage.

### 2. RPC Functions for All Mutations
Sensitive operations go through SECURITY DEFINER functions rather than
direct table writes. This centralizes validation, enforces state-machine
transitions, and writes audit entries server-side. Direct student UPDATE
policies were removed in the September 2026 hardening.

### 3. Read + Invalidate over Streaming
Providers use one-shot reads and refresh via realtime invalidation channels
(a multiplexed FYPMS channel saves WebSocket connections) with refetch-after-
mutation as fallback. The bundled `ExcelData` dataset guarantees the public
site renders even when Supabase is paused.

### 4. RBAC via Database Roles
Expo roles live in `profiles.role`; FYPMS roles in `profile_academic_roles`
(7 role codes). Client role checks only gate the UI — every RPC and RLS
policy re-validates server-side.

### 5. Defense-in-Depth Storage
Private FYPMS buckets enforce path-scoped read/write (`{semester}/{record}/...`);
the public-assets bucket accepts writes only from coordinators/admins.

## Data Flow

```
[User Action]
    ↓
[UI Widget] → watches → [Riverpod Provider]
    ↓                            ↑ invalidated by
[Supabase service read]     [Realtime channel / mutation]
    ↓
[RLS policy + helpers] → [rows] → normalizeKeys → fromJson → [Model]
```

For mutations:
```
[UI Action]
    ↓
[Notifier / provider wrapper]
    ↓
[Supabase.client.rpc('fn')]
    ↓
[SECURITY DEFINER function: auth check → role gate → state machine → audit]
    ↓
[Response → provider invalidation → UI update]
```
