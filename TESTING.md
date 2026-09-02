# Testing — FYP Expo Hub

## Test Suite

The project includes **132 Flutter tests** (unit, widget, and route-guard)
in `test/` — all runnable offline (no live backend needed).

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

Zero errors is the gate (pre-existing infos/warnings are informational).

## Test Organization

```
test/
├── widget_test.dart                      # App smoke test (placeholder client)
├── supabase_migration_test.dart          # Expo model round-trips
├── admin_router_guards_test.dart         # Admin/lecturer route guards
└── features/
    ├── core/state_providers_test.dart    # Expo notifiers: offline fallback,
    │                                     #   CRUD, publish toggle, featured
    ├── lecturer_visits/                  # My Visits detail page + dialogs
    │   └── lecturer_visit_detail_test.dart
    ├── admin_feedback/                   # Feedback model + CSV export
    ├── junior_project_guide/             # Similarity engine (Jaccard, clusters)
    └── fypms/                            # 10 files: models, route guards,
                                          #   staff/student pages, RPC lifecycle
                                          #   (mocked HTTP), defect fixes,
                                          #   regression, features
```

### Notable suites
- `fypms_rpc_lifecycle_test.dart` — the full 15-step student→CSP→coordinator
  RPC chain against a mocked HTTP transport (the strongest suite).
- `admin_router_guards_test.dart` — real `goRouterProvider` redirects:
  unauthenticated/non-admin bounce, admin & lecturer post-sign-in landing.
- `state_providers_test.dart` — the offline "seed-and-swap" fallback that
  ships in every public page load.

## Test Coverage Targets

| Feature Area | Status (Sept 2026) |
|---|---|
| Models (fromJson/toJson) | Covered (Expo + FYPMS) |
| FYPMS route guards | Covered (12 cases) |
| Admin/lecturer route guards | Covered (7 cases) |
| Lecturer visits flow (mark/void) | Covered (6 cases) |
| Expo notifiers incl. offline fallback | Covered (11 cases) |
| FYPMS staff/student pages | Covered (26 cases) |
| Junior guide similarity | Covered (17 cases) |
| Admin import staging lifecycle | Not yet covered |
| Admin CRUD pages (non-import) | Not yet covered |

## Manual Testing Checklist

### Public Site (Anonymous)
- [ ] Home page loads with event info
- [ ] Projects list displays; search/filters work
- [ ] Project detail page shows matric ID, team, booth, links
- [ ] Schedule, booths, announcements, awards, FAQ pages load
- [ ] Junior Project Guide renders past titles + similarity clusters
- [ ] Feedback floating button submits an entry
- [ ] Offline fallback: with Supabase paused, seed data (376 projects) renders

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

GitHub Actions workflow (`.github/workflows/deploy.yml`):
1. Checkout code
2. Setup Flutter
3. `flutter pub get`
4. `flutter analyze` (non-fatal infos/warnings)
5. `flutter test`
6. `flutter build web --release` with `--dart-define` credentials
7. Deploy to GitHub Pages

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
