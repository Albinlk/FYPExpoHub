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
| [ ] | S8 | Tests + docs: semester filtering, promotion, event switching; migration keeps existing data on the 2026 semester/event | H |

## 2. Missing screens (backend already exists)

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | U1 | Proper student form screens for F2, F3, F4, F7, F9, F10 … (replace the raw-JSON payload box) (#43) | H |
| [x] | U2 | User role management (admin / coordinator): search users, add / remove FYPMS roles with programme scope, activate / deactivate; audited; coordinators can't grant coordinator / admin (#42) | H |
| [x] | U3 | Student account creation and bulk enrolment (uses `create_student_account_profile`) (#42) | H |
| [ ] | U4 | Rubric editor (criteria, weights, evaluator shares, versioned) | M |
| [ ] | U5 | Edit / delete presentation sessions and slots | L |

## 3. Missing functions (need backend work)

| Done | # | Item | Pri |
|---|---|---|---|
| [ ] | F1 | Notifications (email and/or in-app) for requests, submissions, decisions, deadlines | H |
| [ ] | F2 | Account self-service: change password while signed in, edit display name | M |
| [ ] | F3 | Reopen finalized marks with a reason (audited) | M |
| [ ] | F4 | Withdraw / incomplete (TL) record statuses and flow | M |
| [ ] | F5 | Import projects and booths from the Master File | M |
| [ ] | F6 | Reports / analytics: grade distribution, supervisor workload, cohort progress | L |
| [ ] | F7 | PU appointment letters (printable record of approved nominations) | L |
| [ ] | F8 | Account lockout / MFA (G-32 remainder) | L |

## 4. Manual / configuration (not code)

| Done | # | Item |
|---|---|---|
| [ ] | C1 | Supabase Auth → Redirect URLs: add `https://fskmjasinfypexhibition.site/reset-password` and `https://admin.fskmjasinfypexhibition.site/reset-password` |
| [ ] | C2 | Create real lecturer accounts, then run *Lecturer Assignments → Match from project names* |
| [ ] | C3 | Grant `programme_head` (PU) roles if nomination approval is wanted |
| [ ] | C4 | Review the import setting *mandatory worksheets* (`COMMITTEE` will always warn) |

## Suggested order

1. S1–S3, S6, S8 (multi-semester / multi-event foundation)
2. U2 + U3 (roles and accounts)
3. U1 (student forms)
4. F1 (notifications)
5. The rest by priority
