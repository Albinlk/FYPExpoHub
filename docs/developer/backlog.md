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
| [x] | C1 | Supabase Auth → Redirect URLs: `https://fskmjasinfypexhibition.site/reset-password` and `https://fyp.fskmjasinfypexhibition.site/reset-password` (done 11 Oct 2026; `admin.` only redirects, so it needs none) |
| [x] | C2 | Create real lecturer accounts (done 11 Oct 2026). Booth-visit assignments now come from FYPMS when projects are published (#58), so name matching is no longer needed |
| [x] | C3 | Grant `programme_head` (PU) roles if nomination approval is wanted — now done in-app from FYPMS → Users & Roles |
| [x] | C4 | Review the import setting *mandatory worksheets* (`COMMITTEE` will always warn) |

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
| [x] | P2 | Course-aware CSP600 / CSP650: forms list, report type, student menu and CSP lecturer pages follow the course; `submit_fyp_form` refuses another course's form (migration `20261010000001`) (#57) | H |
| [x] | P3 | Coordinators can open Appointment Letters; light page headers inside FYPMS; consistent sign-out and cross-links (#57) | M |
| [x] | P4 | Applied migrations `20261010000001`–`20261010000004` (course-scoped forms, progress sessions, exhibition ↔ CSP650 link, supervisor final approval) to the live Supabase project (10 Oct 2026; shipped in #57, #58) | H |
| [x] | P5 | Each exhibition belongs to a CSP650 cohort (`events.academic_semester_id`, picker in the event form); Expo publishing lists and accepts only that semester's CSP650 records (migration `20261010000003`) (#58) | M |
| [x] | P6 | Publishing creates booth-visit assignments from the FYPMS supervisor / examiner (no name matching) and carries the examiner into the project (migration `20261010000003`) (#58) | M |
| [x] | P7 | Exhibition attendance on the FYPMS record: already present as `exhibition_visit_recorded` in the F14 dialog (criterion 3); no change needed | M |
| [x] | P8 | CSP650 student "My Exhibition" card on the dashboard: publication status, booth, day and a link to the project page (#58) | L |
| [x] | P9 | F9 progress presentation session type (handbook Table 2.1 item 39) (migration `20261010000002`) (#58) | M |
| [x] | P10 | CSP600 lecturer "Examiners & Handover" page: assign examiners (handbook Table 2.1 item 19) and hand the cohort over to CSP650 (item 29) (#58) | M |
| [x] | P11 | Copy one student's milestones to every student in the same course (the handbook sets no week timeline, so dates stay lecturer-set) (#58) | L |
| [x] | P12 | Supervisor approves the final report after F12 (`approve_final_report`, migration `20261010000004`); deliverables checklist already matched the handbook (#58) | L |
| [x] | P13 | Nominations: the nominating lecturer (CSP lecturer or coordinator) attaches the nominee's CV and the "not a relative / close friend" declaration; the PU approves only once both are there (App. N; migration `20261010000005`, bucket `fyp-nomination-cvs`; applied to live 10 Oct 2026) (#59) | L |

## 7. Portal redesign audit (10 Oct 2026)

From a `redesign-existing-projects` audit of the portal page, checked in the production build at 375, 800, 1280 and 1920 px.

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | R1 | Desktop nav no longer runs under Sign In: all links from 1440 px, five plus More from 1024 px, three plus More below (#60, #61) | H |
| [x] | R2 | Portal content capped at 1200 px, hero text at 760 px (#60) | M |
| [x] | R3 | One sign-in prompt: the hero's extra Sign In button removed (#60) | M |
| [x] | R4 | After the exhibition its card leads to the year's winners (#60) | M |
| [x] | R5 | Feedback button shrinks to an icon below 1024 px; the portal leaves room for it (#60) | M |
| [x] | R6 | Exhibition card tinted and labelled "No sign-in needed"; CSP650 rocket icon replaced; radial hero gradient (#60) | L |
| [x] | R7 | `h1` letter-spacing fixed to -0.02em (it was -0.02 px) (#60) | L |
| [x] | R8 | Nav highlighting compares the path only, so a `?query` no longer unselects the tab (#60) | L |

## 8. Exhibition home, FYP Workspace and "Scholar + Lab" design (11 Oct 2026)

The exhibition is the homepage; CSP600 / CSP650 sit behind sign-in and will move to `fyp.fskmjasinfypexhibition.site`. Visual direction "Scholar + Lab": serif headlines, mono for codes and numbers, graph paper, numbered sections.

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | W1 | `/` is the exhibition home (`/expo` redirects); portal page removed; "Exhibition" nav link dropped; FYP Workspace band on the home page (#62) | H |
| [x] | W2 | Host-ready routing: `CSP_HOST` build define, `_siteHostGuard`, `/go` hop limited to our hosts (#62) | H |
| [x] | W3 | Workspace moved to `fyp.fskmjasinfypexhibition.site`: Cloudflare Pages project `fyp-workspace` deployed from the same build, `CSP_HOST` repo variable set (11 Oct 2026); main-site `/fypms` → `fyp.`, exhibition pages on `fyp.` → main site (#65) | M |
| [x] | W4 | Shared sign-in across the two sites: session in cookies on `.fskmjasinfypexhibition.site` (`lib/core/supabase/shared_session_storage.dart`) (#71) | L |
| [x] | D1 | Design system: Fraunces + JetBrains Mono, type and colour tokens, `GraphPaper`, `SectionHeader`, `StatBlock`, `CodeTag`, `BrandMark`; DESIGN.md for Google Stitch (#62) | H |
| [x] | D2 | Apply to the public site: new exhibition home, project cards, section headers, code tags (#62) | H |
| [x] | D3 | Follow-ups: Past Projects Guide counts in mono, graph-paper sign-in page, full desktop menu from 1312 px (measured with the real fonts) (#63) | L |
| [x] | N1 | Side menus grouped: the Workspace menu has one collapsible section per role (only the current one open) with labelled groups; the exhibition admin menu is grouped into Exhibition, Projects & booths, Lecturers & visits and System (#67) | M |

## 9. Documentation and handbook (16 Oct 2026)

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | H1 | Docs reorganised under `docs/`: user guides in `docs/guides/`, developer docs in `docs/developer/`, superseded reports in `docs/developer/history/` (#72) | H |
| [x] | H2 | Role guides with Mermaid diagrams and tutorials: accounts, visitor, student, lecturer, coordinator, exhibition admin (#72) | H |
| [x] | H3 | Developer docs refreshed against the live project: hosts and sign-in, architecture diagrams, ER diagrams, RPC catalogue, CI/CD diagram (#72) | M |
| [x] | H4 | Handbook site (MkDocs Material) built into `/handbook/` on both hosts, strict build in CI; Help links in all three menus (#72) | M |
| [x] | H5 | Interactive handbook: task finder, tick-off checklists, status explorers, Open-in-app buttons, Desktop/Phone tabs; app Help opens the section for the current page (#73) | M |

**UI inconsistencies found while writing the guides** (fixed 17 Oct 2026)

| Done | # | Item | Pri |
|---|---|---|---|
| [x] | X1 | Co-supervisors see **Approve Final Report**, but only the main supervisor may approve (`supervisor_corrections_page.dart`) | H |
| [x] | X2 | An account with no role that signs in on the exhibition stays on `/sign-in` with no message (`router_guards.dart` `_postLoginRedirect`) | H |
| [x] | X3 | Statuses shown as raw words ("proposal under review", "pending") instead of friendly labels (`fypms_format.dart`, student supervision page) | M |
| [x] | X4 | Rubric dialog opens empty when updating an existing score (`rubric_evaluation_dialog.dart`) | M |
| [x] | X5 | Booth and lecturer day filters hard-code 2026 dates (`booths_page.dart`, `lecturer_page.dart`) | M |
| [x] | X6 | Wording: PU reject dialog vs server message; "Not Yet Visited" / "Not Yet" / "Not Visited"; menu labels vs page titles; "Sign out" vs "Sign Out"; admin email hint shown to students | L |
| [x] | X7 | Status values nothing sets: imports `completed/error/cancelled`, expo publication `draft/failed`, content `archived`, supervision request `withdrawn`, correction `closed`; default worksheet setting still "TENTATIF, PEMENANG ANUGERAH" | L |
| [x] | X8 | My Visits has no link back to the FYP Workspace | L |

## Suggested order

1. S1–S3, S6, S8 (multi-semester / multi-event foundation)
2. U2 + U3 (roles and accounts)
3. U1 (student forms)
4. F1 (notifications)
5. The rest by priority
