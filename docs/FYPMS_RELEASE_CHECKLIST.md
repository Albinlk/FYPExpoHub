# FYPMS Release Checklist

> Release gate for the FYPMS staff-workflow hardening pass.
> **Date executed:** 2026-08-19 · **Project:** `siedglubjcedkbrpdzgi` (dev)
> **QA sign-off:** ⛔ **NOT READY for production account provisioning** — defects filed below.

## 0. Manual E2E QA sign-off (executed 2026-08-19)

Executed the `docs/FYPMS_E2E_QA_RUNBOOK.md` matrix against the live dev environment
with the 10 seeded accounts and demo records A/B/C. Sign-in via the Auth endpoint
failed for **every** account (see DEF-1), so the role gates were exercised
server-side with the exact actor identity (`request.jwt.claim.sub` = seeded user),
which is the same `auth.uid()` path the UI RPCs use.

| Role | Sign-in | Workflow actions | Success states | Denied states | Verdict |
|------|---------|------------------|----------------|---------------|---------|
| student (S1/S2/S3) | ❌ DEF-1 | F1 submit, F5, F7, canvas, deliverable, correction | ✅ F1/F5/F7/canvas/deliverable/correction-own | ✅ cross-record & cross-record-edit denied; report v2 ❌ DEF-3 | ⚠️ PASS with defects |
| supervisor | ❌ DEF-1 | decide F1, validate F5, evaluate F7, create correction | ✅ all (weighted_total=80.00) | ✅ pre-assign deny, unassigned deny, already-validated deny | ✅ PASS |
| co_supervisor | ❌ DEF-1 | co-assign + validate | ✅ | ✅ (via supervisor gates) | ✅ PASS (role granted for QA) |
| examiner | ❌ DEF-1 | evaluate F8, confirm correction | ✅ (weighted_total=80.00) | ✅ self-assign deny, unassigned create deny | ✅ PASS |
| csp600_lecturer | ❌ DEF-1 | assign examiner, create milestone | ✅ | ✅ cross-CSP finalize deny | ✅ PASS |
| csp650_lecturer | ❌ DEF-1 | schedule slot, finalize marks | ✅ finalize (100.00); slot: seed slot exists → duplicate slot blocked (DB design, see DEF-6) | ✅ cross-course slot deny, invalid window deny, double-finalize deny | ✅ PASS (slot note DEF-6) |
| fyp_coordinator | ❌ DEF-1 | prepare (null payload), publish | ✅ prepare→ready (leak=0), publish→published + projects row | ✅ draft-publish deny, non-coordinator prepare deny | ✅ PASS (payload-supplied path ❌ DEF-5) |
| admin | ❌ DEF-1 | admin override field | ❌ DEF-2 (P0002) | — | ❌ FAIL (DEF-2) |

Public projection + RLS: ✅ student sees **0** foreign records / marks / reports /
corrections / audit rows, **1** published public project with only whitelisted
fields (`title`, `matric_id`, `programme_code`, `short_description`, `category`,
`supervisor_display_name`, `student_team`, `publication_status`).

Realtime: ✅ structural (5 tables added to `supabase_realtime` publication, RLS
SELECT policies present, app channels wired). Live broadcast / two-session
verification **blocked by DEF-1** (no user JWT obtainable).

Demo data was restored after QA (`fypms_demo_seed` re-run; QA-created rows
cascade-removed; published `projects` row deleted; temporary `co_supervisor`
role grant removed).

## 1. Automated checks

| Check | Command | Result |
|-------|---------|--------|
| Static analysis | `flutter analyze --no-pub` | **0 errors, 0 warnings** (267 info-level lints pre-existing) |
| Full test suite | `flutter test --no-pub` | **80/80 passing** |
| - FYPMS staff page widget tests | `fypms_staff_pages_test.dart` | 20/20 |
| - FYPMS student page widget tests | `fypms_student_pages_test.dart` + models + features + deliverables | pass |
| - **Route/role guards** | `fypms_route_guards_test.dart` | 12/12 (auth gate, role homes, cross-workspace blocks) |
| - **RPC lifecycle (mocked Supabase)** | `fypms_rpc_lifecycle_test.dart` | 5/5 (full chain, denial, public projection) |
| - **Release regressions (a,b,d,e + c-in-guards)** | `fypms_regression_test.dart` | 5/5 |
| - App smoke | `widget_test.dart`, admin feedback, supabase migration check | pass |
| Release build | `flutter build web --release` (with SUPABASE env dart-defines) | **succeeded** (`build/web/main.dart.js` ~4.5 MB) |

## 2. Supabase state (dev)

| Item | Status |
|------|--------|
| Live migrations | 17 (added `fypms_demo_seed`, `fypms_realtime_publication`) |
| Demo data | 3 linked FYP records (A/B/C), milestones, forms, evaluations, reports, deliverables, corrections, sessions/slot, marks summary, Expo publication draft — **restored after QA** |
| Workflow RPCs | 10 protected SECURITY DEFINER (gated + audited), live |
| Realtime | 5 workflow tables members of `supabase_realtime` publication; RLS SELECT policies present |
| `supabase/types.ts` | regenerated (114 KB) incl. all workflow RPC signatures |

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

Per-role workspace **entry routes are covered by the automated guard suite**
(`fypms_route_guards_test.dart`) rather than interactive login (which requires
manual credentials): student → `/fypms/student`, supervisor/co-supervisor →
`/fypms/supervisor`, examiner → `/fypms/examiner`, CSP → `/fypms/csp`,
coordinator/admin → `/fypms/coordinator`, plus cross-workspace blocking.

## 4. Manual QA

Refer to `docs/FYPMS_E2E_QA_RUNBOOK.md`. Demo accounts are in
`docs/FYPMS_DEMO_SEEDING.md`.

## 5. Definition of done

- [ ] Reviewer can sign in as each seeded role and traverse a linked lifecycle — **blocked by DEF-1**.
- [x] Coordinator can prepare a safe public payload and publish a record into the Expo Hub `projects` table (`ready`→`published`, leak=0 verified live).
- [x] Public visitor sees only the approved public projection (verified live via RLS checks).
- [ ] All automated checks, release build, and documented manual QA pass — **DEF-2..DEF-5 remain**.

## 6. Defects filed (discrete fix tasks — no broad rework)

| ID | Role/action | Expected vs actual | Evidence |
|----|-------------|--------------------|----------|
| DEF-1 | ALL — sign in with seeded account | Expected 200 token; **actual 500** `Database error querying schema` for any existing account (nonexistent email correctly returns 400) | `POST /auth/v1/token?grant_type=password` for `coordinator@fypms.test` etc.; error_id returned by GoTrue. Blocks all manual UI sign-in. Platform-auth / seed-account data issue. |
| DEF-2 | student edit own field; admin override | Expected record update; **actual P0002** `not-found: FYP record not found.` from `update_fyp_record_field` and `admin_override_fyp_record_field` for every actor (dynamic `EXECUTE … RETURNING` + RLS interaction) | Reproduced for stu1, coordinator, admin. |
| DEF-3 | student upload proposal v2 (runbook 4.5) | Expected version bump → **actual 23505** duplicate `(record, report_type, 1)`; `submit_report_version` always inserts version 1 | Unique violation on `fyp_report_submissions_fyp_record_id_report_type_version_key`. |
| DEF-4 | SECURITY — any authenticated user confirms a correction on another student's record | Expected denial; **actual success** — `confirm_fyp_corrections` has no owner/assigned gate | student1 confirmed `CORR-DEMO-0002` on record C (not their record). |
| DEF-5 | coordinator prepare publication with payload | Expected whitelisted payload; **actual 42703** `column "k" does not exist` in `prepare_expo_publication` payload-merge branch (coordinator UI passes null → UI path unaffected) | Supplied `{"title":…,"marks":…}` payload → 42703. |
| DEF-6 | csp650 schedule slot for record C | Runbook expected a second slot; **actual 23505** — one slot per record per session is enforced by `fyp_presentation_slots(session_id, fyp_record_id)` unique (seed already has slot 1). DB design is correct; **runbook expectation to fix** (schedule a different record, or document one-slot-per-record). | QA attempt slot 2 same session+record → unique violation. |

## 7. Known gaps / notes

- Interactive per-role sign-in smoke test is documented for the reviewer (manual) — blocked until DEF-1 is fixed.
- Realtime bridge is optional/additive; polling/refetch-after-mutation remains the fallback; live broadcast verification pending DEF-1 (needs a user JWT).
- No `co_supervisor` seeded account exists (DEF-7: coverage gap — role was granted temporarily for QA; consider adding a seeded co_supervisor account).
- 2 pre-existing `withOpacity` deprecation infos remain in `fypms_shell.dart` (non-blocking).
- Do **not** run `fypms_demo_seed` against production.
- **Decision:** because DEF-1..DEF-5 are unresolved, FYPMS is **NOT ready** for production account provisioning (real student/staff accounts). Re-run this checklist after the defects are fixed.