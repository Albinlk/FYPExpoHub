# FYPMS Release Checklist

> Release gate for the FYPMS staff-workflow hardening pass.
> **Date executed:** 2026-08-22 · **Project:** `siedglubjcedkbrpdzgi` (dev)
> **QA sign-off:** ✅ **READY for provisioned-account QA** — DEF-1..5 fixed, DEF-7 seeded; realtime verified.

## 0. Manual E2E QA sign-off (executed 2026-08-22)

Executed the `docs/FYPMS_E2E_QA_RUNBOOK.md` matrix against the live dev environment
with the 11 seeded accounts (now includes `cosupervisor@fypms.test` 100…00b) and demo records A/B/C. **Sign-in via Auth endpoint now succeeds for all roles** (DEF-1 fixed), so gates were exercised via **real JWT** (`supabase_flutter` `signInWithPassword`) — not server-side bypass.

| Role | Sign-in | Workflow actions | Success states | Denied states | Verdict |
|------|---------|------------------|----------------|---------------|---------|
| student (S1/S2/S3) | ✅ fixed | F1 submit, F5, F7, canvas, deliverable, correction | ✅ F1/F5/F7/canvas/deliverable/correction-own; **report v2→v3 ✅ DEF-3** | ✅ cross-record & cross-record-edit denied; report v2 now succeeds | ✅ PASS |
| supervisor | ✅ fixed | decide F1, validate F5, evaluate F7, create correction | ✅ all (weighted_total=80.00) | ✅ pre-assign deny, unassigned deny, already-validated deny | ✅ PASS |
| co_supervisor | ✅ fixed (new `cosupervisor@fypms.test` → `/fypms/supervisor`, Record B co-assigned) | co-assign validate F5 | ✅ validated as `co_supervisor` on Record B | ✅ unassigned Record A deny | ✅ PASS |
| examiner | ✅ fixed | evaluate F8, confirm correction | ✅ (weighted_total=80.00); **confirm own correction ✅ DEF-4 still staff-only** | ✅ self-assign deny, unassigned create deny; **student1 on C now 42501 ✅ DEF-4** | ✅ PASS |
| csp600_lecturer | ✅ fixed | assign examiner, create milestone | ✅ | ✅ cross-CSP finalize deny | ✅ PASS |
| csp650_lecturer | ✅ fixed | schedule slot, finalize marks | ✅ finalize (100.00); slot: seed slot exists → duplicate slot blocked (DB design, see DEF-6) | ✅ cross-course slot deny, invalid window deny, double-finalize deny | ✅ PASS (slot note DEF-6) |
| fyp_coordinator | ✅ fixed | prepare (null + **with payload ✅ DEF-5**), publish | ✅ prepare→ready (leak=0, **marks stripped even with payload**), publish→published + projects row | ✅ draft-publish deny, non-coordinator prepare deny | ✅ PASS |
| admin | ✅ fixed | admin override field **✅ DEF-2** | ✅ project_title & programme_code & uuid fields update via `CASE` branches; audit `fyp_record_field_overridden` | ✅ unauthenticated 28000, invalid field 22023 | ✅ PASS |

Public projection + RLS: ✅ student sees **0** foreign records / marks / reports /
corrections / audit rows, **1** published public project with only whitelisted
fields (`title`, `matric_id`, `programme_code`, `short_description`, `category`,
`supervisor_display_name`, `student_team`, `publication_status`).

Realtime: ✅ structural (5 tables in `supabase_realtime` publication, RLS SELECT policies present, app channels `fypms:live` multiplex) + **live broadcast verified** (Student2 submitted F5 log on Record B, Supervisor1 saw `fyp_progress_logs` provider auto-invalidate via `fypmsRealtimeProvider` without reload) — previously **blocked by DEF-1**, now works with real JWTs.

Demo data restored after QA (report v2/v3 test rows deleted, project_title reverted, expo `OVERRIDDEN` payload reset to `draft`, correction confirm `ba57…` deleted).

## 1. Automated checks

| Check | Command | Result |
|-------|---------|--------|
| Static analysis | `flutter analyze --no-pub` | **0 errors, 0 warnings** (125 infos; 4 pre-existing `argument_type_not_assignable` in fypms pages) |
| Full test suite | `flutter test --no-pub` | **104/104 passing** (80 base + 7 new `fypms_defects_fix_test` + 17 existing) |
| - FYPMS staff page widget tests | `fypms_staff_pages_test.dart` | 20/20 |
| - FYPMS student page widget tests | `fypms_student_pages_test.dart` + models + features + deliverables | pass |
| - **Route/role guards** | `fypms_route_guards_test.dart` | 12/12 (auth gate, role homes, cross-workspace blocks — incl. `co_supervisor` → `/fypms/supervisor`) |
| - **RPC lifecycle (mocked Supabase)** | `fypms_rpc_lifecycle_test.dart` | 5/5 (full chain, denial, public projection) |
| - **Release regressions (a,b,d,e + c-in-guards)** | `fypms_regression_test.dart` | 5/5 |
| - **Defects fix (DEF-1..7)** | `fypms_defects_fix_test.dart` | 7/7 (field CASE, version bump, staff-only, payload alias, cosupervisor seeded) |
| - Project similarity (empty→empty) | `project_similarity_test.dart` | 17/17 (fixed empty→empty Jaccard after displayTags change) |
| - App smoke | `widget_test.dart`, admin feedback, supabase migration check | pass |
| Release build | `flutter build web --release` (with SUPABASE env dart-defines) | **succeeded** (`build/web/main.dart.js` ~4.5 MB, 75s) |

## 2. Supabase state (dev)

| Item | Status |
|------|--------|
| Live migrations | **48** (17 app/schema + 23 bulk-population + 8 defect fixes: `fix_auth_policies_and_rewrite_handle_new_user`, `fix_auth_null_string_columns_v2`, `fix_fyp_record_field_update_case_branches`, `fix_report_version_bump`, `fix_correction_confirm_gate_staff_only`, `fix_expo_payload_merge_alias`, `seed_co_supervisor_account` + `fix_team_display_name_brackets`) |
| Demo data | 3 linked FYP records (A/B/C), milestones, forms, evaluations, reports (now v2/v3 tested then cleaned), deliverables, corrections (2 items + 1 confirmation), sessions/slot, marks summary, Expo publication draft — **restored after QA** |
| Workflow RPCs | 10 protected SECURITY DEFINER (gated + audited), all 5 patched live |
| Realtime | 5 workflow tables members of `supabase_realtime` publication; RLS SELECT policies present; `fypms:live` multiplex verified live |
| `supabase/types.ts` | regenerated (114 KB) incl. all workflow RPC signatures |
| Seeded accounts | **11** (10 original + `cosupervisor@fypms.test` 100…00b, `co_supervisor` on Record B) |

## 3. Deployment smoke test (release build, local static server)

Served `build/web` and exercised every entry route in headless Chrome; each produced
**no console errors** and the Flutter engine attached (`flutter-view` / `flt-glass-pane`):

- `/` public home — OK
- `/projects` — OK
- `/booths` — OK
- `/schedule` — OK
- `/info` — OK
- `/fypms/student` — OK (unauthenticated → client-side redirect to `/admin/sign-in`)
- `/admin/sign-in` — OK
- `/fypms/supervisor` as `supervisor1` — OK (real JWT, Record B visible)
- `/fypms/coordinator` as `coordinator` — OK

Per-role workspace **entry routes are covered by the automated guard suite**
(`fypms_route_guards_test.dart`) **and** interactive sign-in via Auth API (`POST /auth/v1/token` 200 for 11/11 accounts, `cosupervisor` included).

## 4. Manual QA

Refer to `docs/FYPMS_E2E_QA_RUNBOOK.md`. Demo accounts are in
`docs/FYPMS_DEMO_SEEDING.md` (now incl. `cosupervisor@fypms.test`).

## 5. Definition of done

- [x] Reviewer can sign in as each seeded role and traverse a linked lifecycle — **fixed by DEF-1** (11/11 `POST /auth/v1/token` 200, Flutter UI sign-in verified for admin/student1/supervisor1/coordinator; others via API).
- [x] Coordinator can prepare a safe public payload and publish a record into the Expo Hub `projects` table (`ready`→`published`, leak=0 verified live — **including payload with `{"title":"OVERRIDDEN","marks":{"total":100}}` → marks stripped, title overridden**).
- [x] Public visitor sees only the approved public projection (verified live via RLS checks).
- [x] All automated checks, release build, and documented manual QA pass — **DEF-1..5 fixed, DEF-7 covered**.

## 6. Defects filed (discrete fix tasks — no broad rework)

| ID | Role/action | Expected vs actual (before) | Evidence (before) | Fix (migration + test) | Evidence (after) |
|----|-------------|-----------------------------|-------------------|------------------------|------------------|
| DEF-1 | ALL — sign in with seeded account | Expected 200 token; **actual 500** `Database error querying schema` | `POST /auth/v1/token` for `coordinator@fypms.test` error_id `01a029cd-…` | `fix_auth_policies_and_rewrite_handle_new_user` (policies for `supabase_auth_admin` on 8 `auth` tables + `handle_new_user` → `profiles`) + `fix_auth_null_string_columns_v2` (NULL `confirmation_token` → `''`) | `POST /auth/v1/token` **200** for 11/11 accounts (admin, student1, supervisor1, … `cosupervisor`); `auth_logs` no longer `Scan error on confirmation_token`; Flutter UI `signInWithPassword` succeeds |
| DEF-2 | student edit own field; admin override | Expected record update; **actual P0002** `not-found` from both RPCs | Reproduced for stu1, coordinator, admin | `fix_fyp_record_field_update_case_branches` — replaced dynamic `EXECUTE format(%I)` with explicit `CASE` branches per allowed field (typed `uuid` casts) | `student1@fypms.test` `update_fyp_record_field(Record A, project_title)` → **200**; `student2` on A → **42501**; `admin` `admin_override(..., main_supervisor_id)` → **200**; `fypms_defects_fix_test.dart` DEF-2 |
| DEF-3 | student upload proposal v2 (runbook 4.5) | Expected version bump → **actual 23505** duplicate `(record, report_type, 1)` | `fyp_report_submissions` unique violation | `fix_report_version_bump` — `SELECT COALESCE(MAX(version),0)+1 FOR UPDATE` scoped to `(fyp_record_id, report_type)` | `student2` `submit_report_version(Record B, proposal, v2.pdf)` → **200 version 2**, `v3.pdf` → **200 version 3** (no 23505); `fypms_defects_fix_test` DEF-3 |
| DEF-4 | SECURITY — any user confirms correction on another record | Expected denial; **actual success** — no gate | student1 confirmed `CORR-DEMO-0002` on record C | `fix_correction_confirm_gate_staff_only` — added `is_admin OR is_fyp_coordinator OR is_assigned_to_fyp_record(..., 'supervisor'/'co_supervisor'/'examiner')` | `student1` on `CORR-DEMO-0001` (Record C, not assigned) → **403** `permission-denied: Only the assigned supervisor…`; `admin` → **200**; `fypms_defects_fix_test` DEF-4 |
| DEF-5 | coordinator prepare publication with payload | Expected whitelisted payload; **actual 42703** `column "k" does not exist` | `{"title":…,"marks":…}` → 42703 | `fix_expo_payload_merge_alias` — `jsonb_each(p_payload) AS e(k,v)` | `coordinator` `prepare_expo_publication(Record C, event, {"title":"OVERRIDDEN","marks":…})` → **200** `status ready`, `payload.title=="OVERRIDDEN"` and `payload` has **no `marks`/`fyp_record_id`**; `fypms_defects_fix_test` DEF-5 |
| DEF-6 | csp650 schedule slot for record C | Runbook expected second slot; **actual 23505** — one slot per record per session is enforced | QA slot 2 same session+record → unique violation | **No fix — DB design is correct**; runbook expectation documented | — |
| DEF-7 | co_supervisor coverage gap | No seeded `co_supervisor` account | `profile_academic_roles` 0 rows for `co_supervisor` | `seed_co_supervisor_account` — `cosupervisor@fypms.test` 100…00b + `profile_academic_roles` `co_supervisor` + assignment to Record B | `cosupervisor@fypms.test` **200** sign-in → `/fypms/supervisor`, can validate F5 on Record B; `fypms_defects_fix_test` DEF-7 |

## 7. Known gaps / notes

- DEF-6 is **by design** (one slot per record per session); no migration.
- 2 pre-existing `withOpacity` deprecation infos remain in `fypms_shell.dart` (non-blocking).
- Do **not** run `fypms_demo_seed` against production.
- **Decision:** DEF-1..5 fixed and verified via real JWT + `fypms_defects_fix_test` (7/7) + runbook slices; **verdict is now READY for provisioned-account QA** (real student/staff accounts). Live `supabase_realtime` broadcast previously blocked by DEF-1 is now verified.
