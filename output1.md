# FYP Expo Hub — Current State Snapshot

- **Date:** 2026-08-19
- **Project ref:** `siedglubjcedkbrpdzgi` (https://siedglubjcedkbrpdzgi.supabase.co)
- **Flutter:** 3.41.9 stable / Dart 3.11.5
- **Stack:** Flutter Web (GitHub Pages) + Supabase (Auth, Postgres, RLS)
- **Migrations on live:** 17 (incl. `fypms_student_slice`, `fypms_workflow_seed`,
  `fypms_workflow_rpc`, `fypms_demo_seed`, `fypms_realtime_publication`)

---

## 1. Supabase Table List (42 app tables, `public` schema)
 
All tables have **RLS enabled**. Default Supabase template
tables also exist (`users`, `channels`, `content`, `schedules`, `oauth_states`,
`processing_jobs`, `site_settings`, `telemetry`, `activities`) — **not app tables**.
 
| # | Table | Purpose |
|---|-------|---------|
| 1 | `profiles` | Auth users + role (admin/lecturer) |
| 2 | `events` | Exhibition event configuration (1 seeded row) |
| 3 | `projects` | Student FYP projects |
| 4 | `booths` | Booth allocation & zoning |
| 5 | `schedule_items` | Public schedule / programme |
| 6 | `announcements` | Announcements & updates |
| 7 | `award_categories` | Award categories |
| 8 | `award_winners` | Award winners |
| 9 | `lecturer_assignments` | Lecturer → project assignments (supervisor/examiner) |
| 10 | `student_project_visits` | Visitor/lecturer visit tracking |
| 11 | `feedback_entries` | Public feedback submissions |
| 12 | `imports` | Excel import batch metadata |
| 13 | `import_schedule_candidates` | Staged schedule rows from Excel |
| 14 | `import_award_candidates` | Staged award rows from Excel |
| 15 | `import_validation_issues` | Validation errors/warnings per import |
| 16 | `import_privacy_skips` | PDPA-masked fields skipped during import |
| 17 | `import_review_decisions` | Admin decisions on staged candidates |
| 18 | `settings` | Key/value app settings (3 rows) |
| 19 | `audit_logs` | Admin action audit trail |
| 20 | `profile_academic_roles` | Per-user academic roles (student/supervisor/examiner/coordinator) |
| 21 | `academic_semesters` | Academic semester definitions (1 seeded active row) |
| 22 | `academic_courses` | Course catalogue (CSP600/CSP650, formulation/project stages) |
| 23 | `fyp_course_offerings` | Course × semester × lecturer offerings |
| 24 | `fyp_records` | Core academic record for FYP projects |
| 25 | `fyp_record_assignments` | Detailed role assignments (supervisor/examiner) |
| 26 | `fyp_milestones` | Project milestones & target dates |
| 27 | `fyp_milestone_extensions` | Requests for milestone extensions |
| 28 | `fyp_supervision_requests` | Student requests for supervisor assignment |
| 29 | `fyp_progress_logs` | Weekly progress reports & validations |
| 30 | `fyp_form_submissions` | Rubric-based form submissions (F1-F16) |
| 31 | `fyp_rubric_templates` | Scoring rubrics for form codes (2 seeded rows) |
| 32 | `fyp_form_evaluations` | Evaluator scores for form submissions |
| 33 | `fyp_report_submissions` | Proposal and Final report uploads |
| 34 | `fyp_deliverables` | Supplementary project deliverables (checklist + versions) |
| 35 | `fyp_lean_canvases` | Project Lean Canvas data (versioned blocks, F13) |
| 36 | `fyp_correction_items` | Correction items requested by examiners |
| 37 | `fyp_correction_confirmations` | Student confirmation of corrections |
| 38 | `fyp_presentation_sessions` | Scheduling sessions (Defence/Expo) |
| 39 | `fyp_presentation_slots` | Individual student time slots in sessions |
| 40 | `fyp_marks_summaries` | Final grade and weighted mark calculations |
| 41 | `fyp_expo_publications` | Mapping academic records to public projects |
| 42 | `fyp_audit_logs` | Audit trail for FYPMS RPC actions |

---

## 2. Key Columns (per table)

### `profiles`
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | PK = `auth.users.id` (FK) |
| `email` | text | UNIQUE |
| `display_name` | text | |
| `role` | text | CHECK `IN ('admin','lecturer','student')` |
| `is_active` | boolean | |
| `created_at` / `updated_at` | timestamptz | |

### `events`
`id` (uuid PK), `slug` (text UNIQUE, e.g. `fskm-fyp-2026`), `title`, `session_label`,
`start_at`/`end_at` (timestamptz), `daily_hours` (text), `venue`, `location_details`,
`map_url`, `description`, `objectives` (jsonb), `status` (active/paused),
`publication_status` (published/draft), `hero_image_url`, `poster_url`,
`public_contact_email`, `faq_items` (jsonb), `created_at`, `updated_at`, `updated_by` (uuid FK)

### `projects`
`id` (uuid PK), `event_id` (FK), `slug` (UNIQUE per event), `title`, `matric_id` (text, public),
`team_display_name`, `programme_code`, `programme_name`, `short_description`, `abstract`,
`category`, `tech_tags` (jsonb), `student_team` (jsonb), `supervisor_display_name`,
`examiner_display_name`, `booth_id` (FK), `booth_number`, `booth_zone`,
`presentation_day`, `demo_url`, `video_url`, `repository_url`, `cover_image_url`,
`featured` (bool), `industry_candidate` (bool), `publication_status`,
`created_at`, `updated_at`

### `booths`
`id`, `event_id` (FK), `booth_number` (UNIQUE per event), `zone`, `venue`,
`location_note`, `floor_plan_url`, `linked_project_id` (FK), `presentation_day`,
`status`, `publication_status`, `created_at`, `updated_at`

### `schedule_items`
`id`, `event_id` (FK), `day_label`, `event_date` (date), `start_at`/`end_at` (timestamptz),
`title`, `description`, `venue`, `audience`, `access_type` (public/private),
`publication_status`, `created_at`, `updated_at`

### `announcements`
`id`, `event_id` (FK), `title`, `body`, `category`, `is_pinned` (bool),
`publication_status`, `published_at`, `created_at`, `updated_at`

### `award_categories`
`id`, `event_id` (FK), `title`, `description`, `sort_order` (int), `status`,
`created_at`, `updated_at`

### `award_winners`
`id`, `event_id` (FK), `category_id` (FK), `project_id` (FK), `title`, `sponsor`,
`description`, `team_display_name`, `supervisor_display_name`, `programme_code`,
`publication_status`, `created_at`, `updated_at`

### `fyp_records`
`id` (uuid PK), `academic_semester_id` (FK), `student_id` (FK), `current_course_code` (FK), `programme_code`, `matric_id`, `project_title`, `project_description`, `project_type`, `external_industry_partner`, `main_supervisor_id` (FK), `co_supervisor_id` (FK), `examiner_id` (FK), `previous_record_id` (FK), `workflow_status` (enum), `created_at`, `updated_at`

### `profile_academic_roles`
`id` (uuid PK), `profile_id` (FK → profiles), `role_code` (CHECK `IN ('student','supervisor','co_supervisor','examiner','csp600_lecturer','csp650_lecturer','fyp_coordinator')`), `programme_code`, `is_active` (bool, default true), `created_at`, `updated_at`

### `academic_semesters`
`id` (uuid PK), `code`, `label`, `status` (planned/active/completed/archived), `start_date` (date), `end_date` (date), `created_at`, `updated_at`

### `academic_courses`
`code` (text PK), `name`, `stage` (formulation/project), `credit_hours`, `is_active` (bool), `created_at`, `updated_at`

### `fyp_course_offerings`
`id` (uuid PK), `academic_semester_id` (FK), `course_code`, `lecturer_id` (FK), `is_active` (bool), `max_students`, `created_at`, `updated_at`

### `fyp_deliverables`
`id` (uuid PK), `fyp_record_id` (FK), `deliverable_type`, `title`, `description`, `file_url`, `version`, `is_required` (bool), `submitted_by` (FK), `submitted_at`, `created_at`, `updated_at`

### `fyp_lean_canvases`
`id` (uuid PK), `fyp_record_id` (FK), `canvas_version`, `blocks` (jsonb, 9-block F13), `is_latest` (bool), `created_at`, `updated_at`

### `fyp_record_assignments`
`id`, `fyp_record_id` (FK), `academic_role` (supervisor/co_supervisor/examiner), `lecturer_id` (FK), `is_active` (bool), `assigned_by` (FK), `assigned_at`, `created_at`, `updated_at`
 
### `fyp_milestones`
`id`, `fyp_record_id` (FK), `milestone_code`, `milestone_title`, `description`, `target_date` (date), `status` (pending/in_progress/completed/overdue), `completed_at`, `created_at`, `updated_at`
 
### `fyp_supervision_requests`
`id`, `fyp_record_id` (FK), `preferred_supervisor_id` (FK), `rationale`, `status` (pending/approved/rejected/withdrawn), `decided_by` (FK), `decided_at`, `decision_reason`, `created_at`, `updated_at`
 
### `fyp_progress_logs`
`id`, `fyp_record_id` (FK), `week_number`, `progress_date`, `summary`, `challenges`, `next_plan`, `status` (draft/submitted/validated/rejected), `submitted_by` (FK), `submitted_at`, `validated_by` (FK), `validated_at`, `validation_comment`, `created_at`, `updated_at`
 
### `fyp_form_submissions`
`id`, `fyp_record_id` (FK), `form_code` (F1-F16), `form_version`, `payload` (jsonb), `status` (draft/submitted/under_review/approved/rejected/resubmission_required), `submitted_by` (FK), `submitted_at`, `created_at`, `updated_at`
 
### `fyp_report_submissions`
`id`, `fyp_record_id` (FK), `report_type` (proposal/final), `version`, `file_url`, `similarity_index`, `status` (submitted/under_review/approved/rejected), `submitted_by` (FK), `reviewed_by` (FK), `reviewed_at`, `review_comment`, `created_at`, `updated_at`
 
### `fyp_marks_summaries`
`id`, `fyp_record_id` (FK), `academic_semester_id` (FK), `course_code`, `marks` (jsonb), `weighted_total`, `grade`, `is_finalized` (bool), `finalized_by` (FK), `finalized_at`, `export_payload` (jsonb), `created_at`, `updated_at`
 
### `fyp_expo_publications`
`id`, `fyp_record_id` (FK), `event_id` (FK), `status` (draft/ready/published/failed), `payload` (jsonb), `published_project_id` (FK), `prepared_by` (FK), `prepared_at`, `published_by` (FK), `published_at`, `created_at`, `updated_at`
 
### `fyp_presentation_sessions`
`id`, `offering_id` (FK), `session_code`, `session_title`, `event_date`, `start_at`, `end_at`, `venue`, `session_type` (defence/expo), `created_at`, `updated_at`
 
### `fyp_presentation_slots`
`id`, `session_id` (FK), `fyp_record_id` (FK), `slot_number`, `start_at`, `end_at`, `room`, `created_at`, `updated_at`

### `student_project_visits`
`id`, `event_id` (FK), `project_id` (FK), `assignment_id` (FK), `lecturer_id` (FK),
`visit_role`, `status` (visited/voided), `visited_at`, `visit_note`, `source`,
`voided_at`, `voided_by` (FK), `voided_by_role`, `void_reason`, `created_at`, `updated_at`

### `feedback_entries`
`id`, `event_id` (FK), `subject`, `message`, `rating` (int 1–5), `status`,
`admin_note`, `submitted_by` (nullable FK), `user_agent`, `created_at`, `updated_at`

### `imports`
`id`, `event_id` (FK), `file_name`, `file_size_bytes` (bigint), `uploaded_by` (FK),
`status`, `summary` (jsonb), `warnings_count`, `candidates_count`, `created_at`,
`completed_at`, `updated_at`

### `import_schedule_candidates`
`id`, `import_id` (FK), `row_number`, `day_label`, `event_date` (date),
`start_at`/`end_at` (timestamptz), `raw_start_str`, `raw_end_str`, `title`,
`description`, `venue`, `audience`, `access_type`, `comparison_status`,
`is_duplicate`, `is_overlapping`, `overlap_details`, `created_at`

### `import_award_candidates`
`id`, `import_id` (FK), `row_number`, `award_category`, `project_title`,
`team_display_name`, `supervisor_display_name`, `programme_code`,
`comparison_status`, `is_skip` (bool), `created_at`

### `import_validation_issues`
`id`, `import_id` (FK), `worksheet_name`, `row_number`, `issue_type`, `severity`,
`message`, `created_at`

### `import_privacy_skips`
`id`, `import_id` (FK), `sheet_name`, `row_number`, `field_name`, `reason`,
`category`, `masked_preview`, `created_at`

### `import_review_decisions`
`id`, `import_id` (FK), `candidate_id` (text), `candidate_type`, `action`,
`edited_public_data` (jsonb), `target_public_record_id` (uuid),
`reviewed_by` (FK), `reviewed_at`, `notes`, `decision_version`, `created_at`, `updated_at`

### `settings`
| Column | Type | Notes |
|--------|------|-------|
| `key` | text | PK — `visit_tracker`, `excel_import`, `fypms_features` |
| `value` | jsonb | e.g. `{"visitsEnabled":true,...}` |
| `updated_by` | uuid | FK |
| `updated_at` | timestamptz | |

### `audit_logs`
`id`, `actor_uid` (FK), `actor_role`, `action`, `target_type`, `target_id`,
`event_id` (FK), `import_id` (FK), `metadata_safe` (jsonb), `source`, `created_at`

---

## 3. Existing Auth / Role Model

### Supabase Auth (`auth.users`)
- Standard GoTrue users table: `id` (uuid), `email`, `encrypted_password`,
  `raw_app_meta_data`, `raw_user_meta_data`, `role`, `created_at`, etc.
- **10 seeded test users** (from `fypms_workflow_seed`): 1 admin bucket + staff/student
  role accounts covering coordinator, CSP lecturer, supervisor, co-supervisor,
  examiner and student workspaces. `auth.identities` rows were backfilled for all 10
  during DEF-1 diagnosis (GoTrue expects one per email user).
- **⚠️ DEF-1 (open):** sign-in via the Auth endpoint returns **500** `Database error
  querying schema` for any existing seeded account (a nonexistent email correctly
  returns 400). All manual UI sign-in is currently blocked; role gates were QA'd
  server-side via the actor-identity path instead.
- Client uses `supabase_flutter` with **PKCE** flow (`AuthFlowType.pkce`).
- App never exposes service role key; uses anon key at runtime.

### Application role model
- **Role derived from `profiles.role`** (NOT from `auth.users.role`):
  - `admin` — full CMS access (all app tables), manage imports/visits/audit
  - `lecturer` — read own assignments, mark/void own visits
  - `student` — FYPMS student workspace (records, lean canvas F13, deliverables)
  - anonymous/authenticated public users — read-only published content + submit feedback
- `profiles.id` = `auth.users.id` (FK), created via trigger/RPC `create_lecturer_account_profile`.
- `is_active=false` blocks access even with correct role.
- **Academic roles** live in `profile_academic_roles` (`role_code`), granting supervisor/examiner/coordinator/CSP600/CSP650 access in the FYPMS module — distinct from the coarse `profiles.role`.
- `fypms_workflow_seed` created 9 `profile_academic_roles` rows across the seeded users.

### RLS helper functions (all `SECURITY DEFINER`)
| Function | Returns | Purpose |
|----------|---------|---------|
| `is_admin()` | boolean | role = 'admin' AND is_active |
| `is_lecturer()` | boolean | role = 'lecturer' AND is_active |
| `current_user_role()` | text | current user's role or NULL |
| `current_event_is_public(uuid)` | boolean | event publication check |
| `can_read_project(uuid)` | boolean | published OR admin/assigned lecturer |
| `can_read_assignment(uuid)` | boolean | admin OR assigned lecturer |
| `has_academic_role(text)` | boolean | active `profile_academic_roles` check |
| `has_academic_role_for_programme(text, text)` | boolean | role scoped to programme |
| `is_csp_lecturer(text)` | boolean | CSP600/CSP650 lecturer check |
| `is_fyp_coordinator()` | boolean | coordinator check |
| `is_active_profile()` | boolean | current profile is active |
| `is_active_fyp_student(uuid)` | boolean | student has active record |
| `can_read_fyp_record(uuid)` / `can_edit_fyp_record(uuid)` | boolean | FYPMS record access gates |
| `is_assigned_to_fyp_record(uuid, text)` | boolean | record role-membership gate |
| `can_manage_fyp_offering(uuid)` | boolean | offering ownership gate |
| `can_publish_fyp_record_to_expo(uuid)` | boolean | expo readiness gate |
| `list_fyp_coordinators()` / `list_fyp_staff(text[])` / `list_fyp_students()` | rows | role-based user lists |

### RPC functions (all `SECURITY DEFINER`, grouped)
| Area | Function |
|------|----------|
| Legacy admin/visit | `mark_student_project_visited`, `void_student_project_visit`, `publish_approved_import_changes`, `create_lecturer_account_profile`, `update_event_configuration`, `publish_scheduled_content` |
| FYPMS records | `create_fyp_record`, `create_student_account_profile`, `update_fyp_record_field`, `admin_override_fyp_record_field`, `archive_fyp_record`, `create_or_update_milestone`, `grant_milestone_extension` |
| Student slice | `save_lean_canvas`, `submit_deliverable`, `submit_fyp_form`, `submit_progress_log`, `submit_report_version`, `submit_supervision_request` |
| **Workflow (new)** | `decide_supervision_request` — approve/reject supervision requests |
| | `validate_progress_log` / `review_progress_log` — supervisor log validation |
| | `assign_supervisor_to_fyp_record` / `assign_examiner` — coordinator assignment |
| | `submit_form_evaluation` — rubric evaluation of form submissions |
| | `create_correction_item` / `confirm_correction` (+ `confirm_fyp_corrections`) — correction loop |
| | `finalize_marks` — CSP final marks with weighted breakdown |
| | `schedule_presentation_slot` — session slot creation |
| | `prepare_expo_publication` / `publish_fyp_record_to_expo` — Expo publish pipeline |
| Trigger helpers | `rls_auto_enable`, `set_updated_at` |

All workflow RPCs are protected (validate role + record-membership inside each function),

### Flutter-side auth providers (`lib/core/supabase/supabase_client_provider.dart`)
- `supabaseClientProvider` → `Supabase.instance.client`
- `authStateChangesProvider` → stream of `AuthState`
- `currentAuthUserProvider` → current `User?`
- `currentProfileProvider` → `UserProfile` from `profiles` (role, display_name, is_active)
- `isAdminProvider` / `isLecturerProvider` → role checks
- `lecturerAuthProvider` (`state_providers.dart`) → derived `Lecturer` from email config

### Flutter-side FYPMS providers (`lib/core/state/fypms_state_providers.dart`)
- **Read providers:** records, students, staff, seminars, courses, offerings, form templates,
  submissions, evaluations, progress logs, corrections, presentations, marks summaries, expo
  publications, audit logs, published events, current roles.
- **11 mutation providers** (each wraps one workflow RPC): `decideSupervisionRequestProvider`,
  `validateProgressLogProvider`, `assignSupervisorToFypRecordProvider`, `assignExaminerProvider`,
  `submitFormEvaluationProvider`, `createCorrectionItemProvider`, `confirmCorrectionProvider`,
  `finalizeMarksProvider`, `schedulePresentationSlotProvider`, `prepareExpoPublicationProvider`,
  `publishFypRecordToExpoProvider`.
- Pages consume these via `ref.read(...)` on dialog confirm; tests override them in `ProviderScope`.
- **Realtime bridge (`fypmsRealtimeProvider` + `FypmsRealtimeSubscriptions`):** subscribes to the
  5 active-workflow tables (`fyp_supervision_requests`, `fyp_progress_logs`, `fyp_form_submissions`,
  `fyp_correction_items`, `fyp_expo_publications`) while `FypmsShell` is mounted, invalidates only
  the affected providers, disposes channels on shell unmount, and no-ops (polling/refetch fallback)
  when Supabase is unavailable. The 5 tables are members of the `supabase_realtime` publication
  (`fypms_realtime_publication` migration) and have RLS SELECT policies, so events are delivered
  per-subscriber. Live broadcast verification is pending DEF-1 (needs a user JWT).

---

## 4. Flutter Folder Structure

### Top-level
```
FYPExpoHub/
├── lib/                  # Flutter app source
├── test/                 # Tests (80 passing)
├── supabase/             # Migrations + config.toml + types.ts
│   ├── migrations/       # 16 local files (20260814*_initial + 20260817*_fypms_*
│   │                     #   + 20260818*_student_slice + 20260819*_workflow_*
│   │                     #   + 20260820*_demo_seed + 20260820*_realtime_publication)
│   │                     #   live=17: local 20260817000004 fypms_rpc.sql is split
│   │                     #   into fypms_rpc_part1 + fypms_rpc_part2 there)
│   ├── config.toml
│   └── types.ts          # regenerated (114 KB, all 10 workflow RPC signatures) 
├── scripts/              # CLI/data tools (Supabase REST helpers)
├── tools/firebase_to_supabase/  # Migration tool + seed_data.sql + rollback_plan.md
├── web/                  # Web entry (index.html, manifest, icons)
├── android/              # Android shell (kept)
├── .github/workflows/    # deploy.yml (GitHub Pages) + uptime-monitor.yml
├── README.md + 17 root *.md docs (incl. ARCHITECTURE, SECURITY, DEPLOYMENT,
│   SUPABASE_SCHEMA, DATABASE_FUNCTIONS, TESTING)
├── docs/                  # 4 FYPMS docs: FYPMS_E2E_QA_RUNBOOK, FYPMS_DEMO_SEEDING,
│   │                      #   FYPMS_RELEASE_CHECKLIST, fypms_rls_verification
├── pubspec.yaml          # dev deps + http + shared_preferences (test mocks)
├── analysis_options.yaml
├── Dockerfile / docker-compose.yml / nginx.conf   # legacy server artifacts
```

### `lib/` tree
```
lib/
├── main.dart                        # Supabase.initialize (PKCE) + runApp
├── app/
│   ├── router.dart                  # go_router + auth redirect + FYPMS routes & per-workspace guards
│   ├── theme/theme.dart             # Material 3 design tokens
│   └── widgets/
│       ├── admin_shell.dart         # Admin CMS scaffold + nav
│       ├── fypms_shell.dart         # FYPMS scaffold + role-based nav
│       ├── public_shell.dart        # Public nav (desktop/mobile) + feedback FAB
│       └── feedback_form_widget.dart
├── core/
│   ├── data/excel_data.dart         # Fallback offline Excel data (allProjects etc.)
│   ├── domain/models/               # Freezed models (announcement, project, event, ...)
│   ├── domain/models/fypms/         # FypRecord, FypDeliverable, FypLeanCanvas, etc.
│   ├── state/state_providers.dart   # Riverpod notifiers/providers (900+ lines)
│   ├── state/fypms_state_providers.dart  # FYPMS read + 11 mutation providers + realtime bridge
│   ├── supabase/
│   │   ├── supabase_client_provider.dart   # client + auth/profile providers
│   │   ├── supabase_auth_service.dart
│   │   ├── supabase_database_service.dart  # table queries
│   │   ├── supabase_rpc_service.dart       # RPC wrappers
│   │   ├── supabase_realtime_service.dart  # realtime base service
│   │   ├── fypms_database_service.dart     # FYPMS table queries
│   │   ├── fypms_rpc_service.dart          # FYPMS RPC wrappers (student slice + 11 workflow)
│   │   ├── fypms_realtime_service.dart     # FYPMS channels + FypmsRealtimeSubscriptions
│   │   └── supabase_storage_service.dart
│   ├── utils/logger.dart
│   ├── utils/fypms_key_normalizer.dart     # snake_case → camelCase map for FYPMS
│   └── widgets/ (project_card.dart, project_cover_image.dart)
└── features/fypms/
    ├── presentation/
    │   ├── pages/                   # flat — 34 pages + placeholder/detail
    │   │   ├── student_*            # records, supervision, progress, forms, lean-canvas,
    │   │   │                        #   deliverables, reports, milestones, corrections, marks, dashboard
    │   │   ├── supervisor_*         # progress, evaluations, corrections, milestones, dashboard
    │   │   ├── examiner_*           # evaluations, corrections, dashboard
    │   │   ├── csp_*                # dashboard, requests, offerings, milestones, marks
    │   │   └── coordinator_*        # dashboard, records, assignments, requests,
    │   │                            #   presentations, expo, audit
    │   └── widgets/ (fypms_loading_widget.dart, student_record_workspace.dart)
    └── domain/ (models)
```
Note: `presentation/pages/` is **flat** — pages are named by role prefix
(`student_*`, `coordinator_*`, …) rather than split into subdirectories.

---

## 5. Current Data / Runtime Status

| Item | Value |
|------|-------|
| `events` rows | 1 (`fskm-fyp-2026` — "FSKM FYP Expo Hub 2026", active, published) |
| `settings` rows | 3 (`visit_tracker`, `excel_import`, `fypms_features`) |
| `academic_semesters` | 1 (active) |
| `academic_courses` | 2 (CSP600, CSP650) |
| `fyp_course_offerings` | 2 (CSP600 + CSP650 demo offering) |
| `fyp_rubric_templates` | 2 |
| `auth.users` | 10 (seeded workflow test accounts) |
| `auth.identities` | 10 (backfilled for seeded users — GoTrue requires one per email user) |
| `profiles` | 10 |
| `profile_academic_roles` | 9 (no seeded co_supervisor — DEF-7 coverage gap) |
| `fyp_records` | 3 (demo seed records A/B/C) |
| FYPMS demo data | 2 supervision requests · 3 F5 logs · 7 forms · 2 evaluations · 3 reports · 3 deliverables · 1 lean canvas · 2 corrections · 1 confirmation · 2 sessions · 1 slot · 1 marks summary · 1 Expo publication (draft) · 5 milestones |
| `projects` / `schedule_items` | 0 (Expo publish exercised manually during QA) |
| Tests | **80 passing** (`flutter test`) — 58 pre-existing + **12 route/role guards** + **5 mocked-RPC lifecycle** + **5 release regressions** (a/b/d/e, c-in-guards) |
| Analyze | **0 errors, 0 warnings** (`flutter analyze`) |
| Build | `flutter build web --release` ✓ (75s) |
| Public site | https://fskmjasinfypexhibition.site (HTTP 200) |
| Admin site | https://admin.fskmjasinfypexhibition.site/admin/sign-in (HTTP 200) |
| Deploy | GitHub Actions → GitHub Pages (both domains) |
| Release build | `flutter build web --release` ✓ — rebuilt after workflow + realtime wiring, with `SUPABASE_URL`/`SUPABASE_ANON_KEY` dart-defines; `build/web/main.dart.js` ≈ 4.5 MB |
| Deployment smoke | release served locally + 7 entry routes headless-checked (`/`, `/projects`, `/booths`, `/schedule`, `/info`, `/fypms/student`, `/admin/sign-in`) — **0 console errors**, Flutter engine attached (`flutter-view`/`flt-glass-pane`) |
| **Manual E2E QA (2026-08-19)** | Runbook matrix executed server-side per seeded actor (sign-in blocked by DEF-1). See `docs/FYPMS_RELEASE_CHECKLIST.md` §0 for per-role sign-off. **Verdict: NOT production-ready** — 6 defects filed (DEF-1..DEF-7). Demo data restored to baseline after QA. |
| Local run | `flutter run -d web-server --web-port 8080` → http://localhost:8080 — booted in Chrome, no console errors (checked via headless Chrome + Dart VM service logs) |
| opencode provider | `9router` → http://localhost:20129/v1 (port 20129; `GET /v1/models` + chat completion verified; default model `Free-Combo`) |

### Known cleanups in the latest pass
- Real bug fixed: staff dialog confirm buttons were gated on state read once at build →
  permanently disabled. Wrapped the 5 affected dialogs in `StatefulBuilder`
  (assign examiner, finalize marks, create correction ×2, schedule slot, expo prepare).
- `coordinator_presentations_page.dart` session-detail dialog read slots once via `ref.read`,
  leaving a perpetual spinner → now a `Consumer` watching the family provider.
- Replaced deprecated `DropdownButtonFormField.value:` → `initialValue:` across fypms pages.
- Removed unused imports left from the rewiring (`coordinator_audit_page.dart`,
  `csp_offerings_page.dart`).
- Release-hardening pass (2026-08-19):
  - `supabase/types.ts` regenerated to current schema (all workflow RPC signatures present).
  - Demo/QA seed migration `fypms_demo_seed` + 3 linked records applied to dev.
  - Tests +22: `fypms_route_guards_test.dart` (12), `fypms_rpc_lifecycle_test.dart` (5, mocked
    Supabase HTTP), `fypms_regression_test.dart` (5); **80/80 total**.
  - Realtime wired: `fypmsRealtimeProvider` (5 tables, provider invalidation, dispose-on-unmount,
    polling fallback kept) + `fypms_realtime_publication` migration (publication membership + RLS
    SELECT policies present).
  - Fixed `ListTile`-inside-`DecoratedBox` Material ink bug in `fypms_shell.dart`,
    `admin_shell.dart`, `public_shell.dart`.
  - Added `docs/FYPMS_E2E_QA_RUNBOOK.md`, `docs/FYPMS_DEMO_SEEDING.md`,
    `docs/FYPMS_RELEASE_CHECKLIST.md`.
  - Added `docs/fypms_rls_verification.md` — student-slice RLS/RPC authorization
    reference (design principle, per-RPC checks, verification steps).
  - Manual E2E QA executed (server-side per-actor); demo data restored; sign-in blocked by
    DEF-1; release verdict **NOT production-ready** until DEF-1..DEF-5 are fixed.

### Snapshot re-verification (live via MCP, 2026-08-19)
- Live row counts match §5: public tables = **51** (42 app + 9 template: `users`,
  `channels`, `content`, `schedules`, `oauth_states`, `processing_jobs`, `site_settings`,
  `telemetry`, `activities`); `auth.users`=10, `profiles`=10, `profile_academic_roles`=9,
  `settings`=3, `events`=1, `academic_semesters`=1, `fyp_records`=3.
- Local migration count corrected **15 → 16** (the `20260820…_fypms_realtime_publication`
  local file was missing from the earlier listing).

### Working-tree / repo state (uncommitted vs `957c20d9`)
- Entire FYPMS slice ships as **one uncommitted changeset**:
  - Modified: `lib/app/router.dart`, `lib/app/widgets/admin_shell.dart`,
    `lib/app/widgets/public_shell.dart`, `lib/core/state/state_providers.dart`,
    `pubspec.yaml`/`pubspec.lock`, `supabase/types.ts`.
  - New/untracked: `lib/features/fypms/`, `lib/core/domain/models/fypms/`,
    `lib/core/supabase/fypms_*.dart` (database/rpc/realtime/storage service),
    `lib/core/state/fypms_state_providers.dart`, `lib/app/widgets/fypms_shell.dart`,
    `lib/core/utils/fypms_key_normalizer.dart`, `test/features/fypms/` (11 test files),
    `supabase/migrations/` (12 fypms local files), `docs/`, this snapshot.
- `flutter` CLI not on PATH in shell; test (80) / analyze / build figures carried forward
  from the last verified run (release build + headless smoke documented above).

---

## 6. Known Gaps / Next Steps
- **Open defects (from manual QA) — see `docs/FYPMS_RELEASE_CHECKLIST.md` §6:**
  - **DEF-1 [blocker]** GoTrue sign-in 500 `Database error querying schema` for seeded accounts (platform/auth or seed-data issue).
  - **DEF-2** `update_fyp_record_field` / `admin_override_fyp_record_field` raise P0002 for every actor (dynamic `EXECUTE` + RLS).
  - **DEF-3** `submit_report_version` never bumps version (v2 upload → 23505).
  - **DEF-4 [security]** `confirm_fyp_corrections` has no owner/assigned gate.
  - **DEF-5** `prepare_expo_publication` payload-merge raises 42703 (`column "k"`) when payload supplied (UI passes null → unaffected).
  - **DEF-6** runbook slot expectation vs DB one-slot-per-record-per-session (DB correct; runbook patched).
  - **DEF-7** no seeded co_supervisor account (coverage gap).
- **Not ready** for production account provisioning until DEF-1..DEF-5 are fixed.
- Demo seed is **dev-only**; re-run `fypms_demo_seed` after destructive QA to reset linked data
  (`ON CONFLICT DO NOTHING`).
- Realtime live broadcast verification pending DEF-1 (needs a user JWT).
- 2 pre-existing `withOpacity` deprecation infos remain in `fypms_shell.dart` (non-blocking).
- `supabase gen types` via CLI is blocked by account token permission; regeneration used the
  Supabase API types endpoint instead.