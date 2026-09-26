# Testing — FYP Expo Hub

## Test Suite

The project includes **428 Flutter tests, all passing** (unit, widget,
route-guard and theme-audit; `flutter test`, September 2026) in 51 files
under `test/` — all runnable offline (no live backend needed).

### Running Tests

```bash
# Ensure dependencies are installed
flutter pub get

# Run all tests
flutter test

# Run a specific test file
flutter test test/features/lecturer_visits/lecturer_visit_detail_test.dart

# Run with coverage
flutter test --coverage
```

### Static Analysis

```bash
flutter analyze
```

The lint backlog is cleared, so CI runs `flutter analyze` strictly: any new
info or warning fails the PR (see `.github/workflows/ci.yml`).

## Test Organization

```
test/
├── widget_test.dart                      # App smoke test (placeholder client)
├── supabase_migration_test.dart          # Expo model round-trips
├── app/theme_contrast_test.dart          # G-34 WCAG AA contrast audit (17 pairs)
└── features/
    ├── admin_router_guards_test.dart     # Admin/lecturer route guards
    ├── admin_event_editor_test.dart      # G-07 event editor (hours, links, FAQ)
    ├── admin_g07_part2_test.dart         # G-07 assignments, audit log,
    │                                     #   award categories
    ├── admin_import_checks_test.dart     # G-06 import checks + review defaults
    ├── admin_public_polish_test.dart     # G-05/18/28/29 booths, awards, visits
    ├── admin_settings_test.dart          # G-30 visit-window settings
    ├── admin_auth/                       # Sign-in + G-32 password reset
    ├── admin_feedback/                   # Feedback model + CSV export
    ├── admin_lecturers/                  # Lecturers page
    ├── admin_projects/                   # Project edit page
    ├── core/                             # 8 files: Expo notifiers (offline
    │                                     #   fallback, CRUD, publish, featured),
    │                                     #   row mappers, storage, links, covers
    ├── lecturer_visits/                  # My Visits detail page + dialogs,
    │   └── lecturer_visit_detail_test.dart  #   R9 F10 scoring from a visit
    ├── junior_project_guide/             # Similarity engines (Jaccard, titles)
    ├── public_pages/                     # 6 files: G-31 load states, 404,
    │                                     #   mobile nav/filters/centering
    └── fypms/                            # 20 files: models, route guards,
                                          #   staff/student pages, RPC lifecycle
                                          #   (mocked HTTP), rubrics, course
                                          #   marks, attendance, reports,
                                          #   R8 special evaluation (F14),
                                          #   R11 report thresholds, RES export,
                                          #   supervisor change / PU, G-25
                                          #   workflows, defect fixes, regression
```

### Notable suites
- `fypms_rpc_lifecycle_test.dart` — the full 15-step student→CSP→coordinator
  RPC chain against a mocked HTTP transport (the strongest suite).
- `features/admin_router_guards_test.dart` — real `goRouterProvider` redirects:
  unauthenticated/non-admin bounce, admin & lecturer post-sign-in landing.
- `state_providers_test.dart` — the offline "seed-and-swap" fallback that
  ships in every public page load.
- `public_load_state_test.dart` — G-31 load status (`loading` / `live` /
  `offline` / `failed`), the Retry placeholder and the offline banner.
- `app/theme_contrast_test.dart` — G-34 audit: 17 text/background pairs from
  `DesignSystem` must each reach WCAG AA (4.5 : 1).

## Test Coverage Targets

| Feature Area | Status (Sept 2026) |
|---|---|
| Models (fromJson/toJson) | Covered (Expo + FYPMS) |
| FYPMS route guards | Covered (`fypms_route_guards_test.dart`) |
| Admin/lecturer route guards | Covered (`admin_router_guards_test.dart`) |
| Lecturer visits flow (mark/void, R9 F10 score) | Covered (`lecturer_visit_detail_test.dart`) |
| Expo notifiers incl. offline fallback | Covered (`state_providers_test.dart`, `offline_fallback_test.dart`) |
| Public load states (G-31) | Covered (`public_load_state_test.dart`) |
| Theme contrast audit (G-34) | Covered (`theme_contrast_test.dart`, 17 pairs) |
| FYPMS staff/student pages | Covered (`fypms_staff_pages_test.dart`, `fypms_student_pages_test.dart`) |
| FYPMS special evaluation (R8, F14) | Covered (`fypms_special_evaluation_test.dart`) |
| FYPMS report minimums + REC form (R11) | Covered (`fypms_report_thresholds_test.dart`) |
| FYPMS RES export (R11) | Covered (`fypms_res_export_test.dart`) |
| FYPMS supervisor change / PU approval (R11) | Covered (`fypms_supervisor_change_test.dart`) |
| FYPMS extensions, sessions, record admin (G-25) | Covered (`fypms_g25_workflows_test.dart`) |
| Junior guide similarity | Covered (`project_similarity_test.dart`, `title_similarity_test.dart`) |
| Password reset (G-32) | Covered (`password_reset_test.dart`) |
| Admin event editor (G-07) | Covered (`admin_event_editor_test.dart`) |
| Admin assignments, audit log, award categories (G-07) | Covered (`admin_g07_part2_test.dart`) |
| Admin import checks + review defaults (G-06) | Covered (`admin_import_checks_test.dart`) |
| Admin CRUD pages (booths, awards, lecturers, projects, settings) | Partly covered (`admin_public_polish_test.dart`, `admin_lecturers_page_test.dart`, `admin_project_edit_test.dart`, `admin_settings_test.dart`) |
| Import publish RPC (server side) | Not covered by `flutter test` — verify in the SQL editor |

## Manual Testing Checklist

### Public Site (Anonymous)
- [ ] Home page loads with event info
- [ ] Projects list displays; search/filters work
- [ ] Project detail page shows matric ID, team, booth, links
- [ ] Schedule, booths, announcements, awards, FAQ pages load
- [ ] Junior Project Guide renders past titles + similarity clusters
- [ ] Feedback floating button submits an entry
- [ ] Offline fallback: with Supabase paused, the bundled dataset (387
      projects, 221 booths, 8 schedule items) renders under an offline banner

### Lecturer Site
- [ ] Sign in with lecturer account
- [ ] My Visits dashboard shows assigned SV/EX projects
- [ ] Mark project as visited (note optional) — appears instantly
- [ ] Cancel/void visit — reason required; status becomes voided
- [ ] Duplicate visit attempt surfaces friendly error

### Admin Site
- [ ] Sign in with admin account
- [ ] All CMS pages load
- [ ] Create/edit/publish project; toggle draft/published
- [ ] Import master .xlsx → staging → Data Matching Dashboard → publish
- [ ] Visits monitoring tabs + CSV export
- [ ] Feedback moderation (status + admin note)

### FYPMS
- [ ] Student: create record, submit F1 request, progress log, form,
      report upload (Storage), lean canvas version, deliverable,
      correction evidence
- [ ] Supervisor: review log, evaluate form, create correction
- [ ] Examiner: evaluate + corrections pages load
- [ ] CSP: approve request, milestone, finalize marks (lock enforced)
- [ ] Coordinator: assign roles, schedule presentation, publish record to
      Expo → appears on public /projects

## CI Configuration

Two GitHub Actions workflows run the same gates (Flutter pinned to 3.44.7):

| Workflow | Trigger | Steps |
|---|---|---|
| `.github/workflows/ci.yml` | Pull request to `main` | checkout → setup Flutter → `flutter pub get` → `flutter analyze` (strict) → `flutter test` → `flutter build web --release --wasm` smoke build |
| `.github/workflows/deploy.yml` | Push to `main` | same analyze + test gates → Wasm release build with `--dart-define` credentials → `404.html` copy + service-worker version stamp → `actions/upload-pages-artifact` → `actions/deploy-pages` |

## Supabase Database Testing

```bash
# Using the Supabase CLI
supabase login
supabase db diff
```

Role-simulation SQL (run via MCP / SQL editor):
```sql
begin;
set local request.jwt.claims to '{"sub":"<uid>","role":"authenticated"}';
set local role authenticated;
select count(*) from public.fyp_records;  -- should be only the caller's rows
rollback;
```
