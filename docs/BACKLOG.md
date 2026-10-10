# FYP Expo Hub — Backlog (to-do)

Open work identified on 27 Sep 2026, after R1–R11 and the G-01…G-34 gap
register were closed. Tick items as they merge; add the PR number.

Priority: **H** high · **M** medium · **L** low

## 1. Multi-semester and multi-event support

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | S1 | Semester management screen (coordinator): create, open (active), close (completed), archive semesters; one active at a time (#40) | H |
| [x] | S2 | Semester selector on every FYPMS list (records, requests, evaluations, marks, presentations), defaulting to the active semester (#40) | H |
| [x] | S3 | "Promote to CSP650" action: creates the linked next-semester record (`previous_record_id`), carrying supervisor, examiner and title (#40) | H |
| [x] | S4 | New-intake rollover: bulk-create CSP600 records for a semester from an enrolment list (#42) | M |
| [x] | S5 | Course setup screen (CSP600 / CSP650 details, offerings per semester) (#40) | M |
| [x] | S6 | Exhibition: replace the hard-wired event (`kEventSlug = fskm-fyp-2026`) with an **active event** setting; admin can create a new exhibition without overwriting the last one (#41) | H |
| [x] | S7 | Public "past exhibitions" archive: browse earlier years' projects and award winners (#41) | M |
| [x] | S8 | Tests + docs: semester filtering, promotion, event switching; migration keeps existing data on the 2026 semester/event (#52) | H |

## 2. Missing screens (backend already exists)

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | U1 | Proper student form screens for F2, F3, F4, F7, F9, F10 … (replace the raw-JSON payload box) (#43) | H |
| [x] | U2 | User role management (admin / coordinator): search users, add / remove FYPMS roles with programme scope, activate / deactivate; audited; coordinators can't grant coordinator / admin (#42) | H |
| [x] | U3 | Student account creation and bulk enrolment (uses `create_student_account_profile`) (#42) | H |
| [x] | U4 | Rubric editor (criteria, weights, evaluator shares, versioned) (#44) | M |
| [x] | U5 | Edit / delete presentation sessions and slots (#44) | L |

## 3. Missing functions (need backend work)

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | F1 | Notifications (email and/or in-app) for requests, submissions, decisions, deadlines (#45) | H |
| [x] | F2 | Account self-service: change password while signed in, edit display name (#46) | M |
| [x] | F3 | Reopen finalized marks with a reason (audited) (#47) | M |
| [x] | F4 | Withdraw / incomplete (TL) record statuses and flow (#47) | M |
| [x] | F5 | Import projects and booths from the Master File (#48) | M |
| [x] | F6 | Reports / analytics: grade distribution, supervisor workload, cohort progress (#49) | L |
| [x] | F7 | PU appointment letters (printable record of approved nominations) (#50) | L |
| [x] | F8 | Account lockout / MFA (G-32 remainder) (#51) | L |

## 4. Manual / configuration (not code)

| Done | # | Item |
|---|---|---|
| [ ] | C1 | Supabase Auth → Redirect URLs: add `https://fskmjasinfypexhibition.site/reset-password` and `https://admin.fskmjasinfypexhibition.site/reset-password` |
| [ ] | C2 | Create real lecturer accounts, then run *Lecturer Assignments → Match from project names* |
| [ ] | C3 | Grant `programme_head` (PU) roles if nomination approval is wanted — now done in-app from FYPMS → Users & Roles |
| [ ] | C4 | Review the import setting *mandatory worksheets* (`COMMITTEE` will always warn) |

These need the project owner (dashboard access or real staff data); code cannot do them. Also recommended: turn on two-step verification (My Account) for every admin and coordinator account.

## 5. UI audit and mobile (3 Oct 2026)

From a Web Interface Guidelines audit of the Flutter web app, then a mobile pass. Shared helpers live in `lib/core/widgets` (`async_state`, `busy_button`, `app_dialog`) and `lib/core/layout/responsive.dart`.

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | A1 | Friendly error and loading states with Try Again instead of raw `$e`; a failed or pending load is never shown as empty data or "0"; Settings no longer saves defaults over real values after a failed load (#53) | H |
| [x] | A2 | Confirm irreversible actions (nomination approve, Expo publish, semester status, user deactivate, role removal, account type, 2-step turn-off, slot removal); busy guards; visit dialogs keep the note on failure (#53) | H |
| [x] | A3 | Bugs: milestone Save never enabled, booths venue dropdown stale after a day change, cover "default" URL and icon matching, project Back button, awards saved without a project, schedule time validation (#53) | H |
| [x] | A4 | Accessibility and forms: labelled fields, keyboard-reachable rating stars and logo, sign-in autofill / Enter / show-password, pasted two-step codes, reduced motion, one-sentence countdown (#53) | M |
| [x] | A5 | Contrast fixes, text no smaller than 11px, `…` and plurals (#53) | M |
| [x] | A6 | Web shell: splash error and Reload, manifest portrait lock removed, admin-host framing guard, service-worker timeout, per-page titles, A4 print CSS for letters (#53) | M |
| [x] | A7 | Mobile: text scale capped at 1.3×, 48px tap targets, 24 dialogs fit and scroll, app bar titles fit, feedback and Sign Out in the menu on phones, grids scale with text, phone smoke tests and checklist in `TESTING.md` (#53) | H |
| [x] | A8 | Booths, projects, lecturer and schedule filters kept in the address bar (shareable, survive refresh) (#54) | M |
| [x] | A9 | Junior Guide filters in the address bar (same `UrlStateSync` mixin) (#57) | L |
| [x] | A10 | Heading semantics, unsaved-changes guard on long forms (rubrics, student forms), `autofillHints` beyond the sign-in screens (#57) | L |
| [x] | A11 | Undo snackbar after "Mark as Visited" (needs the RPC to return the visit id) (#57) | L |
| [x] | A12 | Remaining `.value ?? []` sites that hide load errors (about 28; the six that mattered were fixed in A1) (#57) | L |
| [x] | A13 | Home banner: the console shows `https://assets/images/banner.jpg` blocked by the content-security policy, so the image path looks wrong (#57) | L |

## 6. Portal: Exhibition, CSP600 and CSP650 (10 Oct 2026)

From a cross-check against the FSKM handbook (*Essentials of Computing Sciences: Project Administration*, 4th ed., 2022; ethics/REC section not in scope). The workflow engine already matches the handbook (forms F1–F16, marks splits, F14 gate, F12, similarity ≤ 30%); the gaps were the site's shape and a few handbook duties.

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | P1 | Portal landing at `/` with the Exhibition, CSP600 and CSP650; exhibition home at `/expo`; one sign-in at `/sign-in` (#57) | H |
| [x] | P2 | Course-aware CSP600 / CSP650: forms list, report type, student menu and CSP lecturer pages follow the course; `submit_fyp_form` refuses another course's form (migration `20261010000001`, not yet applied to live) (#57) | H |
| [x] | P3 | Coordinators can open Appointment Letters; light page headers inside FYPMS; consistent sign-out and cross-links (#57) | M |
| [x] | P4 | Applied migrations `20261010000001`–`20261010000004` (course-scoped forms, progress sessions, exhibition ↔ CSP650 link, supervisor final approval) to the live Supabase project (10 Oct 2026) | H |
| [x] | P5 | Each exhibition belongs to a CSP650 cohort (`events.academic_semester_id`, picker in the event form); Expo publishing lists and accepts only that semester's CSP650 records (migration `20261010000003`) | M |
| [x] | P6 | Publishing creates booth-visit assignments from the FYPMS supervisor / examiner (no name matching) and carries the examiner into the project (migration `20261010000003`) | M |
| [x] | P7 | Exhibition attendance on the FYPMS record: already present as `exhibition_visit_recorded` in the F14 dialog (criterion 3) | M |
| [x] | P8 | CSP650 student "My Exhibition" card on the dashboard: publication status, booth, day and a link to the project page | L |
| [x] | P9 | F9 progress presentation session type (handbook Table 2.1 #39) (migration `20261010000002`) | M |
| [x] | P10 | CSP600 lecturer "Examiners & Handover" page: assign examiners (#19) and hand the cohort over to CSP650 (#29) | M |
| [x] | P11 | Copy one student's milestones to every student in the same course (the handbook sets no week timeline, so dates stay lecturer-set) | L |
| [x] | P12 | Supervisor approves the final report after F12 (`approve_final_report`, migration `20261010000004`); deliverables checklist already matched the handbook | L |
| [ ] | P13 | Nominations: CV upload and "not a relative / close friend" declaration (App. N) | L |

## Suggested order

1. S1–S3, S6, S8 (multi-semester / multi-event foundation)
2. U2 + U3 (roles and accounts)
3. U1 (student forms)
4. F1 (notifications)
5. The rest by priority
