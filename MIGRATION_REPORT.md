# Migration Status Report — FYP Expo Hub
Date: 2026-08-14
Project Ref: `siedglubjcedkbrpdzgi`

## 1. Summary

The Firebase → Supabase migration is **95% complete**. All 4 migration SQL
files have been applied successfully to the live Supabase database. The
Flutter web application is configured to use Supabase for all data operations.
The Supabase CLI is linked to the wrong project (wmpdhyhhxqcxhiaxljnd) and
cannot be used for further CLI operations.

**Status: Pending Verification**
- [x] Flutter tests (15/15 pass, verified 2026-08-16)
- [x] README update (completed 2026-08-16)
- [x] Flutter analyze (0 errors, 0 warnings; info-level lints only)
- [x] Flutter build web --release (builds with Supabase dart-defines)
- [ ] Final app smoke test on deployed site

## 2. Migration Applied

| # | File | Status | Notes |
|---|------|--------|-------|
| 1 | `20260814000001_initial_schema.sql` | Applied | 19 tables, indexes, constraints |
| 2 | `20260814000002_rls_policies.sql` | Applied | RLS on all 19 tables, 33 policies, 5 helper functions |
| 3 | `20260814000003_rpc_functions.sql` | Applied | 5 SECURITY DEFINER RPC functions + 6 helpers |
| 4 | `20260814000004_seed_data.sql` | Applied | settings (2 rows), events (1 row) |

**Fix applied:** UUID for event `fskm-fyp-2026` updated from `'fskm-fyp-2026'::uuid` (invalid) to `'1977e782-430c-5f3f-a6c7-359f74650691'::uuid`.

## 3. Verification Results

### 3.1 Schema Verification
| Check | Result |
|-------|--------|
| Tables exist | 19 tables confirmed |
| RLS enabled | All 19 tables have RLS enabled |
| Policies created | 33 policies across all tables |
| Primary keys | 19 PK indexes (one per table) |
| Foreign keys | 35 FK constraints |
| Indexes | 12 composite indexes + 1 single-column (idx_projects_slug) + 6 unique non-PK |
| Constraints | 24 CHECK constraints |

### 3.2 Data Verification
| Table | Rows | Expected | Status |
|-------|------|----------|--------|
| `settings` | 2 | 2 | OK |
| `events` | 1 | 1 | OK |
| `profiles` | 0 | 0 | OK |
| `projects` | 0 | 0 | OK |

**Seed data (verified against live DB 2026-08-16):**
```sql
settings:
  key='visit_tracker'  → value={"visitsEnabled":true,"visitOpenAt":null,"visitCloseAt":null,"allowVisitsAfterEvent":false,"allowVisitsBeforeEvent":false,"lecturerUndoWindowMinutes":30}
  key='excel_import'   → value={"maxFileSize":"10 MB","mandatoryWorksheets":"SCHEDULE, AWARD WINNERS, COMMITTEE"}

events:
  slug='fskm-fyp-2026'
  title='FSKM FYP Expo Hub 2026'
  status='active'
  publication_status='published'
```

### 3.3 Functions Verification
| Function | Type | Owner | Security |
|----------|------|-------|----------|
| `is_admin()` | Helper | postgres | SECURITY DEFINER |
| `is_lecturer()` | Helper | postgres | SECURITY DEFINER |
| `current_user_role()` | Helper | postgres | SECURITY DEFINER |
| `current_event_is_public(uuid)` | Helper | postgres | SECURITY DEFINER |
| `can_read_project(uuid)` | Helper | postgres | SECURITY DEFINER |
| `can_read_assignment(uuid)` | Helper | postgres | SECURITY DEFINER |
| `mark_student_project_visited(uuid, text)` | RPC | postgres | SECURITY DEFINER |
| `void_student_project_visit(uuid, text)` | RPC | postgres | SECURITY DEFINER |
| `publish_approved_import_changes(uuid)` | RPC | postgres | SECURITY DEFINER |
| `create_lecturer_account_profile(uuid, text, text)` | RPC | postgres | SECURITY DEFINER |
| `update_event_configuration(uuid, jsonb)` | RPC | postgres | SECURITY DEFINER |

### 3.4 Migration Tracking Table
```sql
TABLE supabase_migrations.schema_migrations (
  version TEXT PRIMARY KEY,
  dirty   BOOLEAN NOT NULL
);

Rows:
  20260814000001 | dirty=false
  20260814000002 | dirty=false
  20260814000003 | dirty=false
  20260814000004 | dirty=false
```

### 3.5 API Test
Tested via `scripts/lib/firebase_api.js` `supabaseSelect()`:
```js
supabaseSelect('events','select=id,slug,title,status')
→ Returns: [{id: "1977e782-...", slug: "fskm-fyp-2026", title: "FSKM FYP Expo Hub 2026", status: "active"}]
```
**Result:** OK — API access working with anon key.

## 4. Issues Found & Resolved

| Issue | Resolution | Status |
|-------|-----------|--------|
| Seed UUID mismatch | Changed `'fskm-fyp-2026'::uuid` to valid UUID literal | Resolved |
| MCP config wrong project_ref | Updated `opencode.json` to use correct ref | Resolved |
| CLI linked to wrong project | All operations done via MCP SQL tools | Workaround |
| SERVICE_ROLE_KEY placeholder | Not needed for current scope | No action |

## 5. Outstanding Items

| Item | Description | Owner |
|------|-------------|-------|
| Flutter test run | `flutter test` — 15/15 pass (verified 2026-08-16) | Done |
| Flutter analyze | 0 errors, 0 warnings (info-level lints only) | Done |
| Flutter web build | `flutter build web --release` builds with Supabase dart-defines | Done |
| Final app smoke test | Requires deployed GitHub Pages site + seeded data | Mobile Dev |
| TypeScript types | Generated `supabase/types.ts` — verify consumption by tooling | Backend |
| Import tool v2 | `migrate_data.js` needs real Excel test with supervisor matching | Data |
| CI secrets | Add `SUPABASE_URL` + `SUPABASE_ANON_KEY` to GitHub Actions secrets | Owner |
| Data population | Seed projects, schedule, announcements, awards for production | Data |

## 6. Rollback Plan

If data corruption or migration failure:
1. Drop all FYP tables (preserve `supabase_migrations.schema_migrations`)
2. Delete rows from `schema_migrations` for affected versions
3. Re-run migration files from `supabase/migrations/`
4. Restore from pre-migration Firestore export if needed

Detailed rollback procedure in `tools/firebase_to_supabase/migrate_data.js`
output: `rollback_plan.md`.
