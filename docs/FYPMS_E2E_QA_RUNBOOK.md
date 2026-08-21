# FYPMS End-to-End QA Runbook

> **Scope:** Manual, role-by-role verification of the FYP Expo Hub FYPMS module
> against the demo dataset (`20260820000001_fypms_demo_seed`).
> Run after `flutter analyze`, `flutter test`, and `flutter build web --release`
> all pass, and after the automated suites
> (`test/features/fypms/fypms_route_guards_test.dart`,
> `test/features/fypms/fypms_rpc_lifecycle_test.dart`,
> `test/features/fypms/fypms_regression_test.dart`) are green.
>
> **Date prepared:** 2026-08-19 · **Project:** `siedglubjcedkbrpdzgi` (dev/demo)
> · **Environment:** local web-server at `http://localhost:8080`.

---

## 1. Demo accounts (fixtures from `fypms_workflow_seed`)

All passwords are the shared **demo-only** password `Password123!`. These are test
fixtures; they MUST NOT be provisioned into the deployed production environment.

| Role | Email | Lands at (router home) |
|------|-------|------------------------|
| Admin | `admin@fypms.test` | `/fypms/coordinator` |
| CSP600 Lecturer | `csp600.lecturer@fypms.test` | `/fypms/csp` |
| CSP650 Lecturer | `csp650.lecturer@fypms.test` | `/fypms/csp` |
| FYP Coordinator | `coordinator@fypms.test` | `/fypms/coordinator` |
| Supervisor 1 | `supervisor1@fypms.test` | `/fypms/supervisor` |
| Supervisor 2 | `supervisor2@fypms.test` | `/fypms/supervisor` |
| Examiner | `examiner@fypms.test` | `/fypms/examiner` |
| Student 1 | `student1@fypms.test` | `/fypms/student` |
| Student 2 | `student2@fypms.test` | `/fypms/student` |
| Student 3 | `student3@fypms.test` | `/fypms/student` |

Cross-workspace navigation is guarded in `lib/app/router.dart`
(`_roleAllowsWorkspace`); a route outside your roles redirects to your home workspace.

## 2. Demo records (from `fypms_demo_seed`)

| Record | Student | Course | Seeded state | QA purpose |
|--------|---------|--------|--------------|------------|
| A | Student 1 | CSP600 | `supervision_requested`; F1 **pending**; F2/F3/F4 drafts | Earliest stage |
| B | Student 2 | CSP600 | `proposal_under_review`; supervisor **S1** approved; 3 **validated** F5 logs; proposal report `under_review`; examiner assigned; **F7/F8 await evaluation** | Mid stage |
| C | Student 3 | CSP650 | `project_pending_presentation`; F13 Lean Canvas; proposal+final reports; deliverables; 2 correction items; presentation slot; marks summary **not finalized**; Expo publication **draft** | Deepest stage |

---

## 3. Auth and route-guard checks

1. Open `http://localhost:8080` unauthenticated.
2. Navigate to `/fypms/student` → expect redirect to `/admin/sign-in` (auth guard).
3. Sign in as each role and confirm the landing workspace in the table above.
4. As **Student 1**, force `/fypms/supervisor` → expect redirect to `/fypms/student`.
5. As **Examiner**, force `/fypms/csp` → expect redirect to `/fypms/examiner`.
6. As a user with no roles, force `/fypms` → expect the "No FYPMS Access" shell screen.

## 4. Student flows

### 4.1 Create / update record (Student 3)
- **Steps:** `Records → New Record`; choose semester `2026_1`, programme `CS266`,
  course `CSP650`; save.
- **Success:** record created via `create_fyp_record`; audit `fyp_record_created`;
  workflow `project_registered` (CSP650).
- **Denied:** Student 3 tries to create a record **for Student 1** →
  `permission-denied: Only coordinators, administrators, or the student themselves can create FYP records.`

### 4.2 F1 supervision request (Student 1 / Record A)
- **Steps:** open Record A → Supervision → submit request preferring `Supervisor 1`.
- **Success:** `fyp_supervision_requests` row `pending`; record → `supervision_requested`.
- **Denied:** Student 2 submits F1 on Record A →
  `permission-denied: Only the record owner can submit a supervision request.`

### 4.3 F5 progress log (Student 2 / Record B)
- **Steps:** Progress → add a week-4 log, submit.
- **Success:** row `submitted`, `submitted_by` = student, `validated_at` null.
- **Denied:** Student 1 submits a log on Record B → owner gate rejects.

### 4.4 Form submission (Student 2 / Record B, F7)
- **Steps:** Forms → fill and submit F7.
- **Success:** `fyp_form_submissions` row `submitted`.

### 4.5 Report upload (Student 2 / Record B, F6a v2)
- **Steps:** Reports → upload a new proposal PDF.
- **Expected success (current behaviour):** `fyp_report_submissions` row `submitted`.
  ⚠️ **DEF-3 (known):** `submit_report_version` does not bump versions — a second
  upload of the same `report_type` hits the `(record, report_type, 1)` unique
  constraint (23505). Versioned re-upload is a fix task; today only the first
  submission works.

### 4.6 Lean Canvas F13 (Student 3 / Record C)
- **Steps:** Lean Canvas → save blocks.
- **Success:** new `fyp_lean_canvases` row, previous `is_latest=false`.

### 4.7 Deliverables (Student 3 / Record C)
- **Steps:** Deliverables → submit `demo` / `poster`; re-submit `demo`.
- **Success:** row created at version 1 then bumped to version 2.

### 4.8 Correction response (Student 3 / Record C)
- **Steps:** Corrections → respond to `CORR-DEMO-0001` (student self-service
  `confirm_fyp_corrections`).
- **Success:** item status advances; confirmation recorded.
- **Denied:** Student 3 responds to a correction on Record B → not the owner.

## 5. Supervisor flows (Supervisor 1)

### 5.1 Accept F1 (Record A, after coordinator assigns S1)
- **Steps:** Coordinator first assigns Supervisor 1 to Record A
  (`assign_supervisor_to_fyp_record`). Then sign in as S1, Records → Record A →
  decide the pending F1 → approve.
- **Success:** `fyp_supervision_requests.status=approved`, `decided_by=S1`;
  `main_supervisor_id=S1`; `workflow_status=supervision_approved`; active `supervisor`
  assignment row; audit `supervision_request_approved`.
- **Denied (pre-assignment):** S1 attempts to decide Record A's F1 before being
  assigned → `permission-denied: Only the assigned supervisor or coordinator can decide supervision requests.`

### 5.2 Validate F5 (Student 1 pairing on Record B, or new log)
- **Steps:** open Record B (S1 is assigned) → validate a `submitted` log.
- **Success:** `status=validated`, `validated_by=S1`, `validated_at` set.
- **Denied (unassigned record):** Supervisor 2 (not assigned to B) validates a
  Record B log → `permission-denied: Only assigned supervisors can validate progress logs.`
- **Denied (wrong state):** S1 tries to validate an already-`validated` log →
  `failed-precondition: Only submitted progress logs can be validated.`

### 5.3 Evaluate assigned form (Record B, F7)
- **Steps:** Evaluations → open F7 → score rubric criteria → decision `approved`.
- **Success:** `fyp_form_evaluations` row (evaluator S1), `weighted_total` computed
  from the PROPOSAL_SUPERVISOR rubric; F7 submission → `approved`; audit `form_evaluated`.
- **Denied:** S1 evaluates F8 (an examiner form is fine, but an *unassigned* record's
  form is not) → gate rejects non-assigned records.

### 5.4 Create correction (Record B)
- **Steps:** Corrections → Add Correction → `minor`.
- **Success:** `fyp_correction_items` row `open`, auto `item_code` `CORR-…`;
  audit `correction_item_created`.
- **Denied:** S1 creates a correction on a record they are not assigned to →
  `permission-denied: Only assigned supervisors or examiners can create corrections.`

## 6. Examiner flows (Examiner)

### 6.1 Submit evaluation (Record B, F8)
- **Steps:** Evaluations → open F8 → score criteria → decision `approved`.
- **Success:** evaluation row (evaluator Examiner, PROPOSAL_EXAMINER rubric),
  `weighted_total` computed; F8 → `approved`; audit `form_evaluated`.

### 6.2 Review correction + confirm F12 (Record C, CORR-DEMO-0001)
- **Steps:** Corrections → open item `CORR-DEMO-0001` → confirm/close it
  (`confirm_correction`, status `confirmed`).
- **Success:** `fyp_correction_confirmations` row recorded; item → `confirmed`;
  audit `correction_confirmed`.
- **Denied:** Examiner tries to confirm a correction on an **unassigned** record →
  gate rejects.

### 6.3 Cannot self-assign
- **Steps:** Examiner attempts to assign themselves as examiner on a record
  (`assign_examiner` via coordinator screen is not reachable; direct RPC call).
- **Denied:** `permission-denied: Only the CSP lecturer or coordinator can assign examiners.`
  (Examiner holds no `fyp_coordinator` / CSP role.)

## 7. CSP lecturer flows (CSP600 / CSP650)

### 7.1 Assign examiner (Record A as CSP600)
- **Steps:** Assignments → Record A → pick `Examiner` → save.
- **Success:** `examiner_id` set; active `examiner` assignment; audit `examiner_assigned`.
- **Denied:** CSP650 lecturer assigns examiner on a **CSP600** record → CSP role
  mismatch (`is_csp_lecturer('CSP600')` false) → permission denied.

### 7.2 Create milestone (Record A/B as CSP600)
- **Steps:** Milestones → add milestone.
- **Success:** row created (via `create_or_update_milestone`, upsert on code).
- **Denied:** student/non-CSP attempts create_or_update_milestone on the record → gate.

### 7.3 Schedule session slot (Record C, CSP650)
- **Steps:** Presentations → `DEF-CSP650-S1` → Schedule Slot for Record C, slot 2,
  valid start/end, assign a room.
- **Expected success (current behaviour):** one slot per record per session is
  enforced by `fyp_presentation_slots(session_id, fyp_record_id)`. Record C already
  holds slot 1 in this session, so scheduling a second slot for the **same record**
  returns 23505 (⚠️ **DEF-6**, runbook expectation). Schedule a slot for a record that
  has none (e.g., Record B) to observe the success path.
- **Denied:** CSP600 lecturer schedules into the CSP650 session → `is_csp_lecturer('CSP650')`
  gate rejects.
- **Denied (invalid window):** `end_at <= start_at` → `invalid-argument`.

### 7.4 Finalize marks (Record C, CSP650)
- **Steps:** Marks → Record C → enter breakdown → Finalize.
- **Success:** `fyp_marks_summaries.is_finalized=true`, `weighted_total` = sum of
  breakdown, `finalized_by=CSP650`, audit `course_marks_finalized`.
- **Denied (wrong CSP):** CSP600 lecturer finalizes a CSP650 course → permission denied.
- **Denied (double finalize):** re-running finalize on the same course →
  `failed-precondition: Marks are already finalized for this course.`

## 8. Coordinator flows (Coordinator)

### 8.1 Prepare safe public payload (Record C)
- **Steps:** Expo → Record C → Prepare Publication (accept the auto-derived payload,
  or paste an override containing a private key like `marks`).
- **Success:** `fyp_expo_publications.status='ready'`; payload contains **only**
  whitelist keys (`title`, `matric_id`, `programme_code`, `short_description`,
  `abstract`, `category`, `student_team`, `supervisor_display_name`,
  `publication_status`, and optional `demo_url`/`video_url`/`repository_url`/
  `cover_image_url`/`booth_number`). A private key such as `marks`, `fyp_record_id`,
  `exporter_payload` is stripped.
- **Denied:** any non-coordinator role calls prepare → permission denied.

### 8.2 Review it, then publish into existing projects
- **Steps:** Expo → verify payload fields rendered → Publish.
- **Success:** `fyp_expo_publications.status='published'`, `published_project_id`
  set; a row is upserted into **public.projects** (slug from `matric_id`, status
  `published`); audit `expo_publication_published`.
- **Denied (draft):** publishing while status is still `draft` →
  `failed-precondition: Publication must be in ready state before publishing.`
- **Denied (unprepared):** a record with **no** publication row → nothing to publish.

## 9. Public visitor verification

1. While signed out, open the public site `/` (or `/projects`).
2. Confirm the **published** project (Record C payload) appears with only public
   fields: title, matric_id, programme code, short description/abstract, category,
   student team names, supervisor display name.
3. Confirm **internal data does not appear**: no `fyp_records`, `marks`,
   `fyp_marks_summaries`, `fyp_report_submissions`, `fyp_correction_items`,
   `fyp_audit_logs`, `workflow_status`, `exporter_payload`, internal UUIDs.
4. Confirm Records A and B (not prepared/published) have **no** public project row.

## 10. Authorization matrix (expected states)

| Action | Allowed | Denied (expected) |
|--------|---------|-------------------|
| Create own record | student, coordinator, admin | other students |
| Submit F1 / F5 / F7 / report / canvas | record owner | any non-owner |
| Decide F1 | assigned supervisor/co-sup, coordinator, admin | other students, unassigned staff |
| Validate F5 | assigned supervisor/co-sup, coordinator, admin | unassigned staff, students |
| Evaluate form | assigned supervisor/co-sup/examiner | unassigned staff |
| Create/confirm correction | assigned supervisor/co-sup/examiner | unassigned staff, students |
| Assign examiner | CSP lecturer (course) or coordinator/admin | examiner, students |
| Schedule slot | CSP lecturer (offering course) or coordinator/admin | others |
| Finalize marks | CSP lecturer (course) or admin | others |
| Prepare/publish Expo | coordinator or admin | everyone else |
| Read a record | owner, assigned staff, course CSP, coordinator, admin | other students |
| See public projects | everyone (published only) | draft/unpublished, internal tables |

## 11. Exit conditions

- [ ] All success states above observed at least once.
- [ ] Every "Denied" box reproduced with the documented error message.
- [ ] No uncaught exceptions in the browser console or `flutter run` log.
- [ ] `flutter analyze` clean; `flutter test` passes; `flutter build web --release` succeeds.
- [ ] Public projection verified to leak no private/internal fields.