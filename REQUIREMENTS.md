# FYP Expo Hub — System Requirements Specification

| Item | Value |
|---|---|
| Document | Software Requirements Specification (as-built) |
| System | FYP Expo Hub + FYP Management System (FYPMS) |
| Organisation | Faculty of Computer and Mathematical Sciences (FSKM), UiTM |
| Live site | https://fskmjasinfypexhibition.site (admin CMS at `/admin`) |
| Codebase revision | `main` @ `f7dae99c` (2026-09-26) |
| Status | Derived from the source code, SQL migrations and project docs; every requirement below is traceable to code |

---

## 1. Introduction

### 1.1 Purpose

This document specifies what FYP Expo Hub does: its users, modules, functions, data, business rules, outputs and quality attributes. It is written from the implemented system (an "as-built" SRS), so it can serve both as a reference for maintainers and as the requirements chapter of an academic report. Where the implementation falls short of the documented intent, the gap is recorded in [Section 12](#12-known-gaps-and-defects) rather than silently described as working.

### 1.2 Scope

One Flutter web application serves two products that share a Supabase backend:

| Product | Purpose | Primary audience |
|---|---|---|
| **FYP Expo Hub** | Public portal for the FSKM Final Year Project Exhibition: project catalogue, booth finder, schedule, announcements, awards, past-semester project guide, lecturer booth-visit tracking, and an admin CMS | Visitors, students, lecturers, exhibition committee |
| **FYPMS** | Final Year Project Management System covering the CSP600 (Formulation) → CSP650 (Project) lifecycle: registration, supervision, progress logs, forms F1–F16, reports, evaluations, corrections, milestones, presentations, marks and publication to the Expo | Students, supervisors, examiners, CSP course lecturers, FYP coordinator |

Out of scope (not implemented): email/SMS notifications, meetings scheduling, native mobile apps, payment, third-party analytics.

### 1.3 Definitions

| Term | Meaning |
|---|---|
| CSP600 | FYP Formulation course (1 credit) — proposal stage |
| CSP650 | Final Year Project course (4 credits) — implementation stage |
| SV / EX | Supervisor / Examiner |
| Calon Industri | "Industry Candidate" — project flagged for industry interest (`industry_candidate`) |
| Booth | Physical exhibition stand identified by a number such as `DS5-17` or `BK1-03` |
| Visit | A lecturer's recorded evaluation stop at a project's booth |
| RLS | Postgres Row-Level Security, the server-side authorisation layer |
| RPC | A Postgres function called from the client (`SECURITY DEFINER` unless noted) |
| Offline fallback | Bundled dataset shown when the backend is unreachable |
| F1…F16 | Official FYP forms (e.g. F1 supervision request, F5 progress log, F13 Lean Canvas) |

---

## 2. System overview

### 2.1 Context

```
                 ┌──────────────────────────── Browser (Flutter Web, Wasm) ───────────────────────────┐
 Visitors ──────►│ PublicShell  : Home · Catalogue · Booths · Schedule · Guide · Awards · Staff · Info │
 Lecturers ─────►│              : My Visits (lecturer)                                                │
 Admins ────────►│ AdminShell   : CMS dashboard · Event · Projects · Booths · Imports · Visits · …    │
 FYPMS users ───►│ FypmsShell   : Student · Supervisor · Examiner · CSP · Coordinator workspaces      │
                 └───────────────┬───────────────────────────────────────────────┬───────────────────┘
                                 │ HTTPS (PostgREST, Auth, Storage)              │ WSS (Realtime)
                          ┌──────▼───────────────────────────────────────────────▼──────┐
                          │ Supabase: Postgres 17 + RLS · Auth (email/password, PKCE) ·  │
                          │ Storage (5 buckets) · Realtime (FYPMS channel)               │
                          └──────────────────────────────────────────────────────────────┘
 Hosting: GitHub Pages (static) · Cloudflare DNS + 302 redirect for admin.<domain> · GitHub Actions CI/CD
```

### 2.2 Architecture layers

| Layer | Implementation |
|---|---|
| Presentation | Flutter widgets; go_router with three shells (`PublicShell`, `AdminShell`, `FypmsShell`) in `lib/app/` |
| State | Riverpod 3 — `Notifier`s for Expo CRUD with optimistic updates (`lib/core/state/expo/`), `FutureProvider`s for FYPMS reads (`lib/core/state/fypms/`) |
| Domain | freezed / json_serializable models (`lib/core/domain/models/`) |
| Data | Supabase services (`lib/core/supabase/`): Expo DB/RPC/storage/realtime, FYPMS DB (read-only), FYPMS RPC (all writes) |
| Server | Postgres tables, RLS policies, policy-helper functions, `SECURITY DEFINER` RPCs, triggers (`supabase/migrations/`, 33 migrations) |

### 2.3 Technology stack

| Component | Version |
|---|---|
| Flutter (CI-pinned) | 3.44.7 stable |
| Dart SDK | ^3.11.0 |
| flutter_riverpod | 3.3.2 |
| go_router | 17.3.0 |
| supabase_flutter | 2.17.1 |
| freezed / json_serializable | 3.2.5 / 6.14.0 |
| excel / csv / file_picker | 4.0.6 / 5.1.1 / 11.0.2 |
| url_launcher / uuid / crypto | 6.3.2 / 4.6.0 / 3.0.7 |
| Backend | Supabase (Postgres 17, Auth, Storage, Realtime), free tier |
| Build target | Web — dart2wasm/skwasm with dart2js/CanvasKit fallback |

---

## 3. Users and roles

### 3.1 User classes

| User class | Authenticated? | Description | Entry point |
|---|---|---|---|
| **Visitor** (public) | No | Anyone browsing the exhibition: students, parents, industry guests, junior students researching topics | `/` |
| **Lecturer** (Expo) | Yes — `profiles.role = 'lecturer'` | Academic staff who visit assigned booths as SV/EX during the exhibition | `/lecturer/visits` |
| **Administrator** | Yes — `profiles.role = 'admin'`, active | Exhibition committee member managing all Expo content; also has coordinator-level FYPMS powers | `/admin` |
| **Student** (FYPMS) | Yes — academic role `student` | Final-year student working through CSP600/CSP650 | `/fypms/student` |
| **Supervisor / Co-supervisor** | Yes — academic role `supervisor` / `co_supervisor` | Guides assigned students; validates logs, evaluates forms, raises corrections | `/fypms/supervisor` |
| **Examiner** | Yes — academic role `examiner` | Evaluates assigned students' forms; raises corrections | `/fypms/examiner` |
| **CSP course lecturer** | Yes — `csp600_lecturer` / `csp650_lecturer` | Runs a course offering: milestones, presentation slots, marks finalisation | `/fypms/csp` |
| **FYP coordinator** | Yes — `fyp_coordinator` | Faculty-level FYP administration: records, staff assignment, supervision decisions, expo publication, audit | `/fypms/coordinator` |

### 3.2 Role storage

| Role string(s) | Stored in | Notes |
|---|---|---|
| `admin`, `lecturer`, `student` | `profiles.role` | Every new auth user receives `student` via the `handle_new_user` trigger |
| `student`, `supervisor`, `co_supervisor`, `examiner`, `csp600_lecturer`, `csp650_lecturer`, `fyp_coordinator` | `profile_academic_roles.role_code` (optionally per programme) | A user may hold several; the FYPMS navigation merges all workspaces they hold |
| `supervisor`, `examiner` | `lecturer_assignments.role`, `student_project_visits.visit_role` | Expo visit assignments (separate from FYPMS assignments) |
| `supervisor`, `co_supervisor`, `examiner` | `fyp_record_assignments.academic_role` | FYPMS per-record assignments |

### 3.3 Permission matrix (summary)

| Capability | Visitor | Lecturer | Admin | Student | SV / Co-SV | Examiner | CSP lecturer | Coordinator |
|---|---|---|---|---|---|---|---|---|
| Browse published Expo content | **Yes** | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Submit feedback | **Yes** | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Mark / cancel own booth visits | — | **Yes** (undo window) | Yes (any, no window) | — | — | — | — | — |
| Manage Expo content (CMS) | — | — | **Yes** | — | — | — | — | — |
| Import master Excel file | — | — | **Yes** | — | — | — | — | — |
| Create FYP record | — | — | Yes | **Own** | — | — | — | Yes |
| Submit F1/F5/forms/reports/canvas/evidence | — | — | Yes | **Own record** | — | — | — | Yes (on behalf) |
| Validate progress logs | — | — | Yes | — | **Assigned** | — | — | Yes |
| Decide supervision requests | — | — | Yes | — | **Assigned** | — | — | Yes |
| Evaluate forms | — | — | Yes | — | **Assigned** | **Assigned** | — | — |
| Create / confirm corrections | — | — | Yes | — | **Assigned** | **Assigned** | — | — |
| Manage milestones, schedule slots | — | — | Yes | — | — | — | **Own course** | Yes |
| Finalise marks | — | — | Yes | — | — | — | **Own course** | — |
| Assign SV / Co-SV / EX | — | — | Yes | — | — | — | Own course | **Yes** |
| Publish FYP record to Expo | — | — | Yes | — | — | — | — | **Yes** |
| Read FYPMS audit log | — | — | Yes | — | — | — | — | **Yes** |

Client-side role checks only shape the UI; every write is re-authorised by RLS or by the RPC's own role gate.

---

## 4. Module inventory

| ID | Module | Route(s) | Users | Source |
|---|---|---|---|---|
| M01 | Public shell & navigation | all public routes | Visitor | `lib/app/widgets/public_shell.dart` |
| M02 | Home | `/` | Visitor | `lib/features/public_home/` |
| M03 | Project catalogue | `/projects` | Visitor | `lib/features/public_projects/` |
| M04 | Project detail | `/projects/:slug` | Visitor | `lib/features/public_projects/` |
| M05 | Booth finder | `/booths` | Visitor | `lib/features/public_booths/` |
| M06 | Schedule | `/schedule` | Visitor | `lib/features/public_schedule/` |
| M07 | Announcements | `/announcements` | Visitor | `lib/features/public_announcements/` |
| M08 | Award winners | `/awards` | Visitor | `lib/features/public_awards/` |
| M09 | Lecturer directory lookup | `/lecturer` | Visitor, Lecturer | `lib/features/public_lecturer/` |
| M10 | Exhibition info, FAQ, Privacy | `/info`, `/faq`, `/privacy` | Visitor | `lib/features/exhibition_info/`, `faq_privacy/` |
| M11 | Past Sem Projects guide & redundancy report | `/projects/junior-guide`, `/projects/junior-guide/similar/:id` | Visitor (junior students) | `lib/features/junior_project_guide/` |
| M12 | Feedback | dialog / sheet | All | `lib/app/widgets/feedback_form_widget.dart` |
| M13 | Authentication | `/admin/sign-in`, `/lecturer/sign-in`, `/reset-password` | Staff, students | `lib/features/admin_auth/`, `lecturer_auth/` |
| M14 | Lecturer visits | `/lecturer/visits`, `/lecturer/visits/:projectId` | Lecturer, Admin | `lib/features/lecturer_visits/` |
| M15 | Admin dashboard | `/admin` | Admin | `lib/features/admin_dashboard/` |
| M16 | Event information | `/admin/event` | Admin | `lib/features/admin_event/` |
| M17 | Project management | `/admin/projects` | Admin | `lib/features/admin_projects/` |
| M18 | Schedule management | `/admin/schedule` | Admin | `lib/features/admin_schedule/` |
| M19 | Booth management | `/admin/booths` | Admin | `lib/features/admin_booths/` |
| M20 | Lecturer management | `/admin/lecturers` | Admin | `lib/features/admin_lecturers/` |
| M21 | Announcement management | `/admin/announcements` | Admin | `lib/features/admin_announcements/` |
| M22 | Award management | `/admin/awards` | Admin | `lib/features/admin_awards/` |
| M23 | Feedback management | `/admin/feedback` | Admin | `lib/features/admin_feedback/` |
| M24 | Student visit monitoring | `/admin/visits` | Admin | `lib/features/admin_visits/` |
| M25 | Master file import | `/admin/imports`, `/admin/imports/:id` | Admin | `lib/features/admin_imports/` |
| M26 | Portal settings | `/admin/settings` | Admin | `lib/features/admin_settings/` |
| M27 | FYPMS shell & access | `/fypms/**` | FYPMS users | `lib/app/widgets/fypms_shell.dart` |
| M28 | FYPMS student workspace | `/fypms/student/**` | Student | `lib/features/fypms/` |
| M29 | FYPMS supervisor workspace | `/fypms/supervisor/**` | SV / Co-SV | `lib/features/fypms/` |
| M30 | FYPMS examiner workspace | `/fypms/examiner/**` | Examiner | `lib/features/fypms/` |
| M31 | FYPMS CSP workspace | `/fypms/csp/**` | CSP lecturer | `lib/features/fypms/` |
| M32 | FYPMS coordinator workspace | `/fypms/coordinator/**` | Coordinator, Admin | `lib/features/fypms/` |
| M33 | Error handling (404) | any unknown URL | All | `lib/app/router.dart` |
| M34 | Lecturer assignments | `/admin/assignments` | Admin | `lib/features/admin_assignments/` |
| M35 | Audit log | `/admin/audit` | Admin | `lib/features/admin_audit/` |
| M36 | FYPMS PU (programme head) workspace | `/fypms/pu` | Programme head | `lib/features/fypms/` |

---

## 5. Functional requirements — Public portal

Requirement IDs use the pattern `FR-<area>-<nn>`. "Shall" statements describe implemented behaviour.

### 5.1 M01 Public shell and navigation

| ID | Requirement |
|---|---|
| FR-NAV-01 | The system shall treat viewports ≥ 768 px as desktop and < 768 px as mobile. |
| FR-NAV-02 | On desktop the system shall show a 64 px top bar with the "FYP Expo Hub" logo (→ `/`) and links: Home, Schedule, Booths, Projects, Project Guide, Announcements, Awards, Lecturer Portal; "My Visits" is added when a lecturer is signed in. |
| FR-NAV-03 | The active desktop link shall be bold with a 24 × 2 px underline (exact match for `/`, prefix match otherwise). |
| FR-NAV-04 | When no lecturer is signed in, the desktop bar shall show a "Sign In" button that opens the admin sign-in URL. |
| FR-NAV-05 | On mobile the system shall show a five-tab bottom bar: Home, Map (`/booths`), Guide (`/projects/junior-guide`), **Staff** (`/lecturer`) for visitors or **Visits** (`/lecturer/visits`) for signed-in lecturers, and Menu. Below 360 px labels are hidden. |
| FR-NAV-06 | The mobile Menu sheet shall list: Sign In (signed out only), Project Catalogue, Booths, Schedule, Project Guide, Announcements, Award Winners, Lecturer Portal (signed-in lecturers only), Exhibition Info, FAQ, Privacy Policy, and Send Feedback. |
| FR-NAV-07 | Feedback shall be reachable from a floating "Feedback" button on desktop and from the Menu sheet on mobile (no floating button on phones, so content is never covered). |
| FR-NAV-08 | The system shall use path-based URLs (no `#`) and set a per-route browser tab title (e.g. "Schedule · FYP Expo Hub"). |

### 5.2 M02 Home

| ID | Requirement |
|---|---|
| FR-HOME-01 | The hero shall show the exhibition label, the title "FYP Expo Hub" and the tagline "Exploring Innovation, Empowering Academic Futures". |
| FR-HOME-02 | The hero shall show the event date range, daily hours and venue from the event record — a labelled three-column box on desktop, a single compact icon line on mobile. |
| FR-HOME-03 | The system shall show the event status: a live Days/Hours/Mins/Secs countdown before the start, "The Exhibition is Live Now!" during the event, and an "Exhibition Concluded" badge (compact pill on mobile) after the end, at which point the timer stops. |
| FR-HOME-04 | A search box shall send the query to the catalogue (`/projects?search=<text>`) on Enter or the Search button; an empty query opens `/projects`. |
| FR-HOME-05 | The hero shall offer one primary action "Explore Projects" (→ `/projects`) and one secondary action "View Schedule" (→ `/schedule`). |
| FR-HOME-06 | A "Featured Projects" section shall show up to **6** projects ordered by the session's view count, with "View All" → `/projects`; cards open the project detail page. |
| FR-HOME-07 | An "Exhibition Overview" section shall show tiles for Exhibition Dates, Main Venue and Visiting Hours. |

### 5.3 M03 Project catalogue

| ID | Requirement |
|---|---|
| FR-CAT-01 | The catalogue shall list all published projects as cards in a grid of 3 columns (≥ 1100 px), 2 columns (≥ 768 px) or 1 column, with a fixed row height so each cover keeps ~180 px. |
| FR-CAT-02 | Search shall match, case-insensitively, the project title, any team member, the supervisor or the examiner; it shall apply 250 ms after typing stops and may be pre-filled from `?search=`. |
| FR-CAT-03 | Filters shall be: Academic Program (All, CS230, CS251, CS253, CS255, CS266), Project Category (All + 5 categories) and an "Industry Candidate — show only" chip. |
| FR-CAT-04 | "Reset Filters" shall clear the search and all filters. |
| FR-CAT-05 | On mobile, search and a "Filters" toggle shall share one row; Programme, Category and Industry Candidate collapse into an animated sheet, and the toggle badge shall show the number of active filters. |
| FR-CAT-06 | Each card shall show: a cover (real image, or a generated gradient/icon cover derived from title and category), category chip, booth chip, Industry Candidate badge where applicable, title (2 lines), "programme • presentation day", and student names. |
| FR-CAT-07 | Cards shall animate in with a staggered entrance (skipped when the OS requests reduced motion) and the cover shall fly into the detail page (hero transition). |
| FR-CAT-08 | The page shall support pull-to-refresh and a refresh button; a failed refresh keeps the current list. |
| FR-CAT-09 | With no matches the page shall show "No Projects Found — Please check your search keywords or reset filters." |

### 5.4 M04 Project detail

| ID | Requirement |
|---|---|
| FR-DET-01 | The page shall resolve `/projects/:slug` by project id or slug and show a spinner while the list loads and "Project not found" with "Back to Catalogue" if absent. |
| FR-DET-02 | The page shall show cover, category, booth, title, programme, abstract/description and technology tag chips. |
| FR-DET-03 | A sidebar shall show the student team, supervisor, examiner, matric ID, booth location (booth, zone) with a "Map" button to `/booths?search=<booth>`, and a Links & Demos block. |
| FR-DET-04 | Back shall return to `/lecturer` when opened with `?from=lecturer`, otherwise go back in history or to `/projects`. |
| FR-DET-05 | Opening the page shall increment the project's in-session view count (input to FR-HOME-06). |
| FR-DET-06 | Desktop shall split main content and sidebar 3 : 2; mobile shall stack them. |

### 5.5 M05 Booth finder

| ID | Requirement |
|---|---|
| FR-BTH-01 | The booth finder shall list projects by presentation day (Day 1 / Day 2; default Day 1), grouped by venue in hall order (BK 1–8, then DS 5–8), sorted by booth then title. |
| FR-BTH-02 | Search shall match title, booth number or student name (250 ms debounce) and may be pre-filled from `?search=`. |
| FR-BTH-03 | Filters shall be Day (always visible), Venue (derived from booth prefixes on the selected day) and Program; changing Day resets Venue. |
| FR-BTH-04 | Each row shall show a booth thumbnail (`/booth_images/booth-<n>.png`, 221 images) or a colour-coded booth badge if the image is missing, the title, first student and programme; tapping opens the project. |
| FR-BTH-05 | On mobile Venue and Program shall collapse behind the Filters toggle with a "Clear Venue & Program" control. |

### 5.6 M06 Schedule

| ID | Requirement |
|---|---|
| FR-SCH-01 | The schedule shall show one tab per event day ("Day N (D Month)") plus any extra dated items; on mobile with ≤ 2 days the tabs share the width equally. |
| FR-SCH-02 | Items shall be sorted by date and start time and shown as a timeline: start–end time, title, description, venue and audience. |
| FR-SCH-03 | Only items that are published and `access_type = public` shall be shown to visitors. |
| FR-SCH-04 | An empty day shall show "No schedule slots available for this day." |

### 5.7 M07 Announcements and M08 Awards

| ID | Requirement |
|---|---|
| FR-ANN-01 | Announcements shall list published items pinned-first then newest-first, each with category chip (highlighted when pinned), date, title and body. |
| FR-ANN-02 | With none published the page shall show "No announcements available at this time." |
| FR-AWD-01 | The awards page shall list published award winners with award title, winning project, students, supervisor and programme (falling back to "N/A"). |
| FR-AWD-02 | Before any winner is published the page shall show "Award winners have not been published yet. Check back soon!" |

### 5.8 M09 Lecturer directory lookup

| ID | Requirement |
|---|---|
| FR-LDR-01 | Without signing in, a lecturer shall be able to type their name and see projects where they are supervisor and/or examiner (case-insensitive substring match, 250 ms debounce). |
| FR-LDR-02 | Filters shall be Role (All / Supervisor / Examiner), Day (All / Day 1 / Day 2) and Type (All / Industry Candidate). |
| FR-LDR-03 | Results shall show "Found N projects" and cards that include supervisor/examiner lines; tapping opens the detail page with `?from=lecturer`. |
| FR-LDR-04 | With an empty search the page shall prompt "Please enter your name to find your projects". |

### 5.9 M10 Exhibition info, FAQ and Privacy

| ID | Requirement |
|---|---|
| FR-INF-01 | Exhibition Info shall show the event background, objectives, competition categories and location (venue and location details). |
| FR-INF-02 | The FAQ page shall show expandable questions (public access, locating a booth, parking). |
| FR-INF-03 | The Privacy page shall state the PDPA 2010 basis, what student data is and is not public, and the contact address `fskmfypexpo@uitm.edu.my`. |

### 5.10 M11 Past Sem Projects guide and redundancy report

Purpose: help junior students check whether a proposed topic has already been done, across the current CSP650 projects and CSP600 proposals.

| ID | Requirement |
|---|---|
| FR-JPG-01 | The guide shall combine two sections: **CSP650** (published Expo projects) and **CSP600** (proposals loaded from Storage `csp600-proposals/csp600-proposals.csv`, falling back to a bundled CSV of 103 proposals). |
| FR-JPG-02 | If CSP600 data cannot load, the guide shall show "CSP600 data unavailable — showing CSP650 only" and keep working. |
| FR-JPG-03 | Search shall match title, supervisor or tag (250 ms debounce) with a clear button. |
| FR-JPG-04 | Filters shall be: Section (All / CSP650 / CSP600), Academic Program, Project Category, Tech Stack (19 normalised categories), Supervisor, Session, Redundancy Status (All / Unique / Has Similar) and Industry Candidate; "Reset Filters" clears all. |
| FR-JPG-05 | Filters may be pre-set by URL parameters `search, section, programme, category, techStack, supervisor, session, redundancy, industry`. |
| FR-JPG-06 | Counters shall show "CSP650: N projects" and "CSP600: N proposals" for the filtered view. |
| FR-JPG-07 | The Browse tab shall show a table (desktop) or cards (mobile) with section pill, title, category, team, supervisor, programme, up to 3 tags (+N) and a status badge. |
| FR-JPG-08 | The status badge shall read "Unique" (green) or "N similar" (red); the red badge shall open `/projects/junior-guide/similar/:id`. |
| FR-JPG-09 | Two projects shall be considered similar if they share **≥ 2 normalised technology categories**, **or** share **≥ 3 significant title words with Jaccard ≥ 0.35** (stopwords, FYP boilerplate and programme codes removed; placeholder titles never match). |
| FR-JPG-10 | Similarity shall always be computed over the full unfiltered data set, so a project's status does not change with filters. |
| FR-JPG-11 | The Redundancy Report tab shall group similar projects transitively into clusters ("Similar by Tech Stack", "Similar by Project Title"), list cross-cohort (CSP650 + CSP600) clusters first, and label each with a High (≥ 0.5) / Medium (≥ 0.25) / Low average-overlap pill. |
| FR-JPG-12 | The Similar Projects page shall list every match with the reasons ("Shared categories", "Shared title words"); CSP650 matches open the project, CSP600 matches are marked "no detail page yet". |

### 5.11 M12 Feedback

| ID | Requirement |
|---|---|
| FR-FDB-01 | Any user shall be able to submit feedback with **Subject** (required), **Message** (required, multi-line) and an optional 1–5 star usability rating. |
| FR-FDB-02 | The form shall open as a 500 px dialog on desktop and a keyboard-aware bottom sheet on mobile. |
| FR-FDB-03 | On success the system shall show "Thank you for your feedback!"; on failure a red message "Couldn't send your feedback: <reason>". |
| FR-FDB-04 | The server shall accept feedback only when subject is 1–200 characters, message 1–2000 characters, rating null or 1–5, status `new`, and the submitter is null or the caller. |
| FR-FDB-05 | The server shall reject inserts once 30 feedback entries have been received site-wide in the past minute (admins exempt). |

### 5.12 M33 Error handling

| ID | Requirement |
|---|---|
| FR-ERR-01 | Unknown URLs shall show a branded "Page Not Found" page naming the URL, with "Go Home" and "Browse Projects" actions. |

---

## 6. Functional requirements — Authentication and lecturer visits

### 6.1 M13 Authentication

| ID | Requirement |
|---|---|
| FR-AUTH-01 | One sign-in page (`/admin/sign-in`) shall serve admins, lecturers and FYPMS users with "Official Email" (required, contains `@`) and "Password" (required, ≥ 6 characters). |
| FR-AUTH-02 | The email shall be trimmed and lower-cased; the password shall be sent unmodified. |
| FR-AUTH-03 | Sign-in errors shall be mapped to "Invalid email or password. Please try again." and "Please confirm your email address before signing in."; other errors show the server message. |
| FR-AUTH-04 | Authentication shall use Supabase email/password with the PKCE flow; sessions are refreshed automatically. |
| FR-AUTH-05 | After sign-in the user shall be sent to a safe `?from=` path if given (non-admins may not return to `/admin/**`), otherwise: admin → `/admin`, lecturer → `/lecturer/visits`, FYPMS user → their home workspace. |
| FR-AUTH-06 | `?from=` values shall be rejected unless they start with `/`, and rejected if they start with `//` or contain `://` or `\`. |
| FR-AUTH-07 | Protected routes shall redirect signed-out users to `/admin/sign-in?from=<path>`; the router shall re-evaluate guards whenever the signed-in user changes. |
| FR-AUTH-08 | On the host `admin.fskmjasinfypexhibition.site`, `/` shall redirect to `/admin/sign-in` (signed out) or `/admin` (signed in). |
| FR-AUTH-09 | `/lecturer/sign-in` shall forward to the shared sign-in page. |
| FR-AUTH-10 | Sign-out shall end the Supabase session, clear cached profile/role state and return to the public site (admin, lecturer) or sign-in (FYPMS). |
| FR-AUTH-11 | "Forgot password?" on the sign-in page shall send the Supabase recovery email with a neutral confirmation (an unknown account also reads as sent; a rate limit is reported). The link lands on `/reset-password`, where the recovery session lets the user set a new password (8+ characters, letters and digits, typed twice); an expired or reused link says so. Account lockout and MFA are not implemented — brute-force protection relies on Supabase Auth rate limits (G-32). |

### 6.2 M14 Lecturer visits (My Visits)

| ID | Requirement |
|---|---|
| FR-VIS-01 | A signed-in lecturer (or admin) shall see "My Visits": their active SV/EX assignments on published projects, with "Welcome, <name>" and Sign Out. |
| FR-VIS-02 | Progress cards shall show SV and EX visits completed out of assigned, with progress bars. |
| FR-VIS-03 | Search shall match project title, team names or booth; filters shall be Role (All/SV/EX), Status (All / Not Yet Visited / Visited / Voided) and Day. |
| FR-VIS-04 | Each card shall show the project, an SV/EX chip, day chip and a status overlay (Voided / ✓ time / Not Yet); tapping opens the visit detail page. |
| FR-VIS-05 | The detail page shall show the project header and one section per role; for each assigned role the lecturer can **Mark as Visited** (with an optional note) or **Cancel Visit** (with a reason). |
| FR-VIS-06 | Marking shall succeed only for an active profile on an active assignment owned by the caller (admins exempt) while `visit_tracker.visitsEnabled` is true and inside the visit window (`visitOpenAt` / `visitCloseAt` if set, otherwise the exhibition days in Malaysia time unless `allowVisitsBeforeEvent` / `allowVisitsAfterEvent`); a duplicate completed visit is rejected ("Visit has already been recorded."), and a previously voided visit is restored. |
| FR-VIS-07 | Cancelling shall require a non-empty reason and, for lecturers, shall only be allowed within `visit_tracker.lecturerUndoWindowMinutes` (default 30) of the visit time. |
| FR-VIS-08 | Every mark and void shall be written to `audit_logs` (`visit_marked`, `visit_voided`). |
| FR-VIS-09 | There shall be at most one visit row per event, project, lecturer and role. |

---

## 7. Functional requirements — Admin CMS

### 7.1 Common admin behaviour

| ID | Requirement |
|---|---|
| FR-ADM-01 | Only an active profile with role `admin` shall access `/admin/**`; others are redirected to sign-in. |
| FR-ADM-02 | The admin shell shall show "FYP Expo Hub CMS", the user's email and logout, a 260 px sidebar on desktop (drawer on mobile) with: Overview Dashboard, Event Information, Schedule Management, Project Catalogue, Booth Management, Lecturer Management, Lecturer Assignments, Announcements, Feedback, Student Visits, My Visits (Lecturer), Award Winners, Import Master File, FYP Management, Audit Log, Settings, and "Back to Public Portal". |
| FR-ADM-03 | Writes shall update the list optimistically and roll back on failure, showing "Not saved: <reason>" (or "You don't have permission to do that." for permission errors). |
| FR-ADM-04 | Deletions shall require confirmation: "Delete <item>? This can't be undone." |
| FR-ADM-05 | Admin lists shall never show offline-fallback rows (they cannot be persisted). |

### 7.2 Module requirements

| ID | Module | Requirement |
|---|---|---|
| FR-ADM-10 | M15 Dashboard | Show counts for Total Projects, Booths, Event Schedules, Files Imported, FYP Records and Pending (supervision) Requests; quick actions (Import, Event, Schedule, Projects); FYP Management shortcuts; recent import history with status and a link to each import. |
| FR-ADM-20 | M16 Event | Edit the event's title (required), session/semester label, start/end dates, daily hours, venue, location details, map link, description, public contact email, hero image URL, poster URL, event status (draft / upcoming / active / completed / archived) and the event FAQ (question/answer pairs; a question needs an answer). Changed links must be http(s); the email must be valid. Saving calls `update_event_configuration`, which rejects `end_at ≤ start_at` and writes audit entry `event_updated`. |
| FR-ADM-30 | M17 Projects | List projects (title, featured badge, programme, students, supervisor, examiner, booth) with a publish ↔ draft toggle, Edit and Delete. |
| FR-ADM-31 | M17 Projects | Add/Edit dialog fields: title (required), matric ID, programme code/name, short description, category, technology tags (comma-separated), student names (comma-separated), supervisor, examiner, booth number/zone, demo URL, cover image URL (blank = generated cover), Featured flag, publication status. |
| FR-ADM-32 | M17 Projects | The slug shall be derived from the title (lower-case, non-alphanumerics → `-`) and be unique per event. |
| FR-ADM-40 | M18 Schedule | List slots by date and time with a day chip; publish toggle, Edit, Delete. |
| FR-ADM-41 | M18 Schedule | Dialog fields: title (required), start and end time (accepts `09:00`, `9:00 AM`, `09.00`, ISO), venue, audience, description, event date (event days), access (public / internal "Committee/Jury"), publication status; end must be after start. |
| FR-ADM-50 | M19 Booths | List booths with zone, note, linked project or "UNASSIGNED (VACANT)" and an Active/Vacant chip; Edit, Delete. |
| FR-ADM-51 | M19 Booths | Dialog fields: booth number (required, unique per event), zone, location note, allocated project; saving links the chosen project's booth fields. |
| FR-ADM-60 | M20 Lecturers | List lecturer profiles (name, email) with Delete; Add Lecturer (UiTM email + full name, both required; name upper-cased) via `create_lecturer_account_profile`. |
| FR-ADM-61 | M20 Lecturers | "Backfill Lecturer IDs" shall match assignment display names to lecturer profiles (exact, upper-case) and report "N updated, M skipped". |
| FR-ADM-62 | M34 Assignments | List active SV/EX assignments per project (search project, lecturer or booth); lecturers can mark visits only for projects they are assigned to. |
| FR-ADM-63 | M34 Assignments | "Match from project names" shall propose an assignment wherever a project's supervisor/examiner name matches exactly one active lecturer account (titles, case, spacing and punctuation ignored), skipping existing ones and never auto-assigning ambiguous names; the admin confirms "Create N assignments". |
| FR-ADM-64 | M34 Assignments | The admin shall assign a lecturer manually (Supervisor or Examiner) and remove an assignment (visits already recorded are kept). |
| FR-ADM-70 | M21 Announcements | List pinned-first, newest-first; publish toggle, Edit, Delete; dialog: title (required), category, body, Pin, publication status. |
| FR-ADM-80 | M22 Awards | List award records; publish toggle, Edit, Delete; dialog: award name (required), sponsor, notes, winning project (copies team, supervisor, programme), publication status. |
| FR-ADM-81 | M22 Awards | An "Award Categories" section shall add, edit and delete the event's categories: title (required), description, display order (lower first) and "Shown on the public Awards page". |
| FR-ADM-90 | M23 Feedback | List feedback newest-first with subject, status chip, preview, rating, date and submitter; search subject/message/user; filter by status. |
| FR-ADM-91 | M23 Feedback | Detail dialog shows all fields and allows changing status and an admin note, or deleting the entry. |
| FR-ADM-92 | M23 Feedback | Export the filtered list to `feedback_entries_YYYY-MM-DD.csv` with formula-injection protection. |
| FR-ADM-100 | M24 Visits | Summary cards: Total Visited (completed/required), Not Visited, %, SV and EX completion, Today, Voided. |
| FR-ADM-101 | M24 Visits | Search (lecturer, project, student, booth); filters Role (All/SV/EX) and Status (All/Visited/Not Yet/Voided); tabs Overview (table/cards), By Lecturer, By Project, Visit Log. |
| FR-ADM-102 | M24 Visits | Void a completed visit with a mandatory reason (no undo-window limit for admins). |
| FR-ADM-103 | M24 Visits | Export the filtered assignments to `student_visits_YYYY-MM-DD.csv` (Lecturer, Role, Student, Project, Programme, Booth, Status, Visit Time, Note). |
| FR-ADM-110 | M25 Import | Upload an `.xlsx`/`.xls` master file, parsed entirely in the browser (no file stored server-side); the SHA-256 hash and size are recorded. A file larger than the Settings "Maximum File Size Limit" (e.g. `10 MB`, `500KB`, bytes) shall be refused before parsing. |
| FR-ADM-111 | M25 Import | Sheets named `TENTATIF`/`SCHEDULE` shall yield schedule candidates from columns A–E (day label, time range, title, venue, audience); "Day N"/"Hari N" and ISO dates, and time ranges with `-`, `–`, `to`, `hingga`, `sehingga` or `0900-1030` forms, shall be parsed, with unparseable rows flagged `date_conflict` / `invalid_time`. |
| FR-ADM-112 | M25 Import | Sheets named `ANUGERAH`/`AWARD` shall yield award candidates from columns A–E (category, team, supervisor, programme, project title). |
| FR-ADM-113 | M25 Import | Sheets named `MARKAH`/`EVALUATION`/`STUDENT_PRIVATE` shall be skipped entirely and logged as a confidential-sheet privacy skip. |
| FR-ADM-114 | M25 Import | Staging shall be one atomic, admin-only transaction (`stage_import`) with the import in status `pending_review`. |
| FR-ADM-115 | M25 Import | The review page shall show the validation checks (warnings first, then notes), and list schedule candidates, award candidates and privacy skips with flags (Already live, Changes a live item, Duplicate in file, Overlaps another item) and a per-row action Publish / Replace Existing / Skip, pre-selected (schedule: Skip if already live or duplicate, Replace Existing if it changes a live item; award: Skip if duplicate in file; otherwise Publish), and "Approve & Publish Selected". |
| FR-ADM-116 | M25 Import | Publishing (`publish_approved_import_changes`) shall be admin-only, lock the import, refuse a second publish, insert approved rows, skip rows with no date/time, mark the import `published` and write audit entry `import_published`. "Replace Existing" shall first delete the live rows the candidate matches — schedule: same event and day and the same title (case/spacing-insensitive) or the same venue at an overlapping time; awards: same award name and team — never rows inserted earlier in the same publish. |
| FR-ADM-117 | M25 Import | Before staging, the browser shall check schedule rows for duplicates in the file, rows already live (`comparison_status` `unchanged`) or changing a live item (`updated`), and same-venue overlaps (`is_overlapping`, `overlap_details`); award rows for repeats in the file and winners already published; and the workbook for mandatory worksheets from Settings (English/Malay aliases SCHEDULE ≈ TENTATIF, AWARD ≈ ANUGERAH). Findings are staged as `import_validation_issues`. |
| FR-ADM-120 | M26 Settings | Edit: maximum import file size (enforced on upload), mandatory worksheet names, Enable Student Project Visits, Allow visits before / after the exhibition (switches; stored open/close times are kept) and Lecturer Undo Window (minutes; non-integer → 30). |
| FR-ADM-130 | M35 Audit log | Show the latest 300 `audit_logs` entries newest first in Malaysia time, with search (action, target, details) and an action filter. |

---

## 8. Functional requirements — FYPMS

### 8.1 M27 Shell and access

| ID | Requirement |
|---|---|
| FR-FYP-01 | A signed-in user with no active academic role shall see "No FYPMS Access" with Sign Out. |
| FR-FYP-02 | `/fypms` shall redirect to the home workspace by priority: student → supervisor/co-supervisor → examiner → CSP lecturer → coordinator/admin. |
| FR-FYP-03 | A workspace shall only be entered by its roles (student; supervisor/co_supervisor; examiner; csp600/csp650_lecturer; programme_head (`/fypms/pu`); fyp_coordinator/admin); other paths redirect home. |
| FR-FYP-04 | The navigation shall combine the workspaces of all roles the user holds. |
| FR-FYP-05 | The shell shall subscribe to one realtime channel and refresh supervision requests, progress logs, form submissions, correction items and expo publications when they change. |
| FR-FYP-06 | Cached FYPMS data shall be discarded when the signed-in user changes (shared lab computers). |

### 8.2 M28 Student workspace

| ID | Screen | Requirement |
|---|---|---|
| FR-STU-01 | Dashboard | Show "Welcome, <email>" and the student's records with course, programme and status; empty state offers "Create FYP Record". |
| FR-STU-02 | Records | Self-register a record: semester (active semesters), course CSP600 or CSP650; CSP650 must continue the student's own CSP600 record (linked automatically). One record per semester, student and course. |
| FR-STU-03 | Record detail | Read-only project and academic details, status, supervisor, co-supervisor and examiner names and active assignments. |
| FR-STU-04 | Supervision (F1) | List supervision requests; submit an F1 naming a supervisor (required, active supervisor role), an optional co-supervisor (a different person), project area and project title (required) and rationale. One pending request per record; refused once a supervisor is assigned (changes then go through the coordinator). Record status → `supervision_requested`. |
| FR-STU-05 | Progress (F5) | One log per consultation: meeting date (not in the future, within the semester; the week is derived from the semester start), completed activity, challenges and next activity; unique per meeting date, so several meetings may fall in one week; status `submitted`. Attendance is shown against the 80 % requirement. |
| FR-STU-06 | Forms | List form submissions; submit a form (code + payload); each resubmission creates version + 1; F1 and F12 are not in the list (own flows); F14 follows the "special evaluation" feature flag; F15/F16 only once the record has qualified on F14. |
| FR-STU-07 | Lean Canvas (F13) | Edit the 9 blocks (problem, customer segments, UVP, solution, channels, revenue streams, cost structure, key metrics, unfair advantage); each save creates a new version marked latest. |
| FR-STU-08 | Deliverables | Show readiness against the textbook checklist: required final report (PDF), final report (Word), presentation slides and poster — files uploaded to `fyp-deliverables` in the record's folder; "if relevant" raw data, system with test data, setup instructions and executable — a file or an https link. |
| FR-STU-09 | Reports (F6a/F6b) | Upload a proposal or final report file to private Storage at `{semester}/{record}/{type}/{version}/{file}` with the similarity index (≤ 30 %), the plagiarism report, page and reference counts (proposal ≥ 30 pages / 15 references, final ≥ 50 / 30, at least half academic) and, for a proposal involving human subjects, the REC ethics form; the server assigns the next version. |
| FR-STU-10 | Milestones | Read-only milestones with code, title, target date and status. |
| FR-STU-11 | Corrections (F12) | List correction items; submit evidence for open / in-progress items (→ `evidence_submitted`). |
| FR-STU-12 | Marks | View per-course marks summaries: total, finalised flag and components. |
| FR-STU-14 | Supervision | Ask for a supervisor change with a reason (≥ 20 characters) and optionally a proposed supervisor (not the current supervisor or examiner); one pending request per record; its status is shown while pending. |
| FR-STU-15 | Milestones / Presentations | Request a milestone extension (reason and a later date, one pending per milestone); see the scheduled presentation slot with session, time and venue, or a clear empty state. |
| FR-STU-13 | All pages | When the student has several records, a record picker shall select the one in context. |

### 8.3 M29–M30 Supervisor and examiner workspaces

| ID | Requirement |
|---|---|
| FR-SUP-01 | The supervisor dashboard shall list records assigned to the user; the examiner dashboard lists examiner assignments. |
| FR-SUP-02 | A supervisor/co-supervisor shall review `submitted` progress logs as Validated or Rejected with an optional comment. |
| FR-SUP-03 | Evaluators named by the textbook for each form (e.g. F7 course lecturer, SV, EX; F8/F10/F11/F15/F16 SV, EX; F13 course lecturer, SV) shall score it in a rubric dialog: each criterion 0–10 × weight, with a decision and comments. The server stores the form percentage 100 × Σ(W×S) / Σ(W×10), leaves supervisor-only criteria out of an examiner's score, rejects out-of-range scores and records the evaluator's role. |
| FR-SUP-04 | Assigned staff shall create correction items (description, severity minor/major, optional linked submission; code `CORR-xxxxxxxx`) and confirm items once evidence is submitted. |
| FR-SUP-05 | The supervisor named on an F1 request (or the coordinator) shall accept or decline it from Supervision Requests; approval sets the main supervisor, the co-supervisor and the project title, creates both assignments and moves the record to `supervision_approved`. A named co-supervisor sees the request read-only. |
| FR-SUP-06 | The assigned supervisor/co-supervisor (or coordinator) shall endorse a submitted F6 report (→ under review) or return it with a comment. |
| FR-SUP-07 | At the exhibition the supervisor/examiner shall score F10 (or F15 for a qualified student) from the Expo visit detail page for projects published from FYPMS. |

### 8.4 M31 CSP course lecturer workspace

| ID | Requirement |
|---|---|
| FR-CSP-01 | The dashboard shall list the lecturer's course offerings with enrolment cap and record counts, and shortcuts to Requests, Milestones and Marks. |
| FR-CSP-02 | The lecturer shall view all active offerings (read-only). |
| FR-CSP-03 | The lecturer shall create and edit milestones (code and title required, target date, status pending/in_progress/completed/overdue) for records in their course. |
| FR-CSP-04 | The lecturer shall finalise marks for a record of their course from the computed breakdown (evaluator share × average evaluation % per form, UiTM grade); finalising is refused while any evaluation is missing or once finalised. Finalised marks of the current course export as a RES CSV (matric, programme, course, total, grade), sorted by matric. |
| FR-CSP-05 | The lecturer shall evaluate the forms the textbook assigns to the course lecturer (F2–F4, F7, F9, F13) and decide F14 per student: Progress (F9) + LMC (F13) ≥ 7.5 % is computed, the other three checks are confirmed. |
| FR-CSP-06 | The lecturer (or coordinator) shall approve a pending milestone extension, or reject it with a reason, and create presentation sessions. |

### 8.5 M32 Coordinator workspace

| ID | Requirement |
|---|---|
| FR-COO-01 | The dashboard shall show total records, expo publications and the 20 most recent records. |
| FR-COO-02 | The coordinator shall create a record for any student (semester, student, course, optional title, description, matric). |
| FR-COO-03 | The coordinator shall assign a Supervisor, Co-Supervisor or Examiner to any record from the staff list. |
| FR-COO-04 | The coordinator shall approve or reject pending supervision requests with an optional reason. |
| FR-COO-05 | The coordinator shall schedule presentation slots (record, slot number, start/end on the session date, room); scheduling moves the record to `project_pending_presentation`. |
| FR-COO-06 | The coordinator shall **prepare** an expo publication for a record against a published event (status `ready`) and **publish** it, which upserts a public `projects` row (slug = lower-case matric ID). |
| FR-COO-07 | The coordinator shall view the latest 200 FYPMS audit entries (action, time, actor role, target). |
| FR-COO-08 | The coordinator shall decide supervisor change requests (approval reassigns the supervisor with the proposed one preselected), split the CSP600 30 % across F2–F4 (Mark Allocation), edit a record field with a mandatory reason, and archive records. |
| FR-PU-01 | A programme head (`programme_head`, scoped by programme) shall approve or reject supervisor/examiner nominations on `/fypms/pu`; while a PU exists for the programme, new nominations are `pending` until decided, and a rejection deactivates the nomination. |

### 8.6 FYP record workflow

| Trigger | Resulting `workflow_status` |
|---|---|
| Record created for CSP600 | `awaiting_supervisor_assignment` |
| Record created for CSP650 | `project_registered` |
| Student submits F1 request | `supervision_requested` |
| Request approved / supervisor assigned | `supervision_approved` |
| Presentation slot scheduled | `project_pending_presentation` |
| Record archived | `project_archived` |

The schema allows 17 statuses in total (proposal, formulation, final-report and completion stages); the remaining transitions are made by coordinators/admins directly.

### 8.7 Correction lifecycle

`open` → `in_progress` → `evidence_submitted` (student) → `confirmed` (staff) → `closed`

---

## 9. Data requirements

### 9.1 Expo entities (19 tables)

| Entity | Key attributes | Rules |
|---|---|---|
| `profiles` | id (= auth user), email, display_name, role, is_active | email unique; role ∈ admin/lecturer/student |
| `events` | slug, title, session_label, start_at, end_at, daily_hours, venue, location_details, map_url, description, objectives, faq_items, status, publication_status | end > start; status ∈ draft/upcoming/active/completed/archived |
| `projects` | slug, title, matric_id, programme_code/name, short_description, abstract, category, tech_tags, student_team, supervisor, examiner, booth_id/number/zone, presentation_day, demo/video/repository/cover URLs, featured, industry_candidate, publication_status | unique (event, slug) |
| `booths` | booth_number, zone, venue, location_note, floor_plan_url, linked_project_id, presentation_day, status | unique (event, booth_number) |
| `schedule_items` | event_date, start_at, end_at, title, description, venue, audience, access_type | end > start; access ∈ public/internal |
| `announcements` | title, body, category, is_pinned, publication_status, published_at | body required |
| `award_categories`, `award_winners` | title, sponsor, description, team, supervisor, programme, project_id | — |
| `lecturer_assignments` | project, lecturer_id, display name, email, role, status | role ∈ supervisor/examiner; unique (event, project, lecturer, role) |
| `student_project_visits` | assignment, lecturer, visit_role, status, visited_at, visit_note, voided_* , void_reason | status ∈ completed/voided; one per (event, project, lecturer, role) |
| `feedback_entries` | subject, message, rating, status, admin_note, submitted_by, user_agent | rating 1–5 |
| `imports` + 5 `import_*` tables | file name/size/hash, status, summary; schedule/award candidates, validation issues, privacy skips, review decisions | admin only |
| `settings` | key, value (jsonb) | keys `visit_tracker`, `excel_import`, `fypms_features` |
| `audit_logs` | actor, role, action, target, metadata | written only by RPCs |

### 9.2 FYPMS entities (23 tables)

| Entity | Purpose |
|---|---|
| `profile_academic_roles` | Academic roles per user (optionally per programme) |
| `academic_semesters`, `academic_courses`, `fyp_course_offerings` | Semester calendar, CSP600/CSP650, offering per semester with lecturer and cap |
| `fyp_records` | One FYP per student, semester and course, with supervisors, examiner, lineage and workflow status |
| `fyp_record_assignments` | Supervisor / co-supervisor / examiner per record |
| `fyp_milestones`, `fyp_milestone_extensions` | Milestones and extension requests/decisions |
| `fyp_supervision_requests` | F1 requests (pending/approved/rejected/withdrawn) |
| `fyp_progress_logs` | F5 weekly logs (draft/submitted/validated/rejected), one per week |
| `fyp_form_submissions`, `fyp_rubric_templates`, `fyp_form_evaluations` | Versioned F-forms, weighted rubrics (seeded F7/F8), per-evaluator evaluations |
| `fyp_report_submissions` | Versioned proposal/final reports with file path and similarity index |
| `fyp_deliverables`, `fyp_lean_canvases` | Deliverables and versioned Lean Canvas |
| `fyp_correction_items`, `fyp_correction_confirmations` | F12 corrections and staff confirmations |
| `fyp_presentation_sessions`, `fyp_presentation_slots` | Defence/expo sessions and slots |
| `fyp_marks_summaries` | Per-course marks, total, grade, finalisation lock |
| `fyp_expo_publications` | Bridge from an FYP record to a public Expo project |
| `fyp_audit_logs` | FYPMS audit trail |

### 9.3 File storage

| Bucket | Public | Max size | Types | Access |
|---|---|---|---|---|
| `fyp-proposal-reports` | No | 20 MB | PDF, DOC, DOCX | Read: anyone who can read the record; write: record owner, coordinator, admin |
| `fyp-final-reports` | No | 20 MB | PDF, DOC, DOCX | As above |
| `fyp-deliverables` | No | 100 MB | Any | As above |
| `fyp-correction-evidence` | No | 20 MB | Any | As above |
| `fyp-public-assets` | Yes | 20 MB | PNG, JPEG, WebP, PDF | Read: public; write: coordinator, admin |

Students cannot overwrite or delete a file once a submitted report or deliverable references it.

### 9.4 Offline fallback data

The bundled `assets/data/offline_fallback.json` (≈ 640 KB) holds 387 projects, 221 booths and 8 schedule items; `assets/data/csp600-proposals.csv` holds 103 proposals. Public pages load it alongside the live request (not before it): it fills the list only if live rows have not arrived, and live data replaces it when the backend answers. Each public dataset reports a load status — `loading`, `live`, `offline` (bundled data showing) or `failed` (`lib/core/state/expo/load_status.dart`).

---

## 10. Non-functional requirements

### 10.1 Security

| ID | Requirement | Evidence |
|---|---|---|
| NFR-SEC-01 | All tables shall have RLS enabled; anonymous users may read only published, public content. | `20260814000002_rls_policies.sql`, `20260817000003_fypms_rls_policies.sql` |
| NFR-SEC-02 | Privileged mutations shall run in RPCs that check `auth.uid()`, role and state, and write an audit entry. | `supabase/migrations/*rpc*.sql` |
| NFR-SEC-03 | Anonymous EXECUTE shall be revoked on all mutating and listing RPCs; no arbitrary-SQL function shall exist. | `20260901000001–3` |
| NFR-SEC-04 | The site shall ship a Content Security Policy (self-only scripts plus `wasm-unsafe-eval`, Supabase and gstatic connections, `object-src 'none'`). | `web/index.html:30` |
| NFR-SEC-05 | `/admin`, `/lecturer` and `/fypms` pages shall refuse to run inside a frame (clickjacking). | `web/flutter_bootstrap.js` |
| NFR-SEC-06 | Post-login redirects shall be protected against open redirects (FR-AUTH-06). | `router_guards.dart:55-60` |
| NFR-SEC-07 | Only the anon key shall ship to the client, injected at build time; the service-role key never leaves the server. | `deploy.yml`, `main.dart` |
| NFR-SEC-08 | CSV exports shall neutralise spreadsheet formula injection. | `feedback_csv_export.dart` |
| NFR-SEC-09 | Seeded demo accounts shall be banned and their credentials randomised once a real admin exists. | `20260925000002_…` |
| NFR-SEC-10 | CI actions shall be pinned to commit SHAs and Flutter to an exact version. | `.github/workflows/*.yml` |
| NFR-SEC-11 | Release builds shall not print debug logs. | `lib/core/utils/logger.dart` |

### 10.2 Privacy (PDPA 2010)

| ID | Requirement |
|---|---|
| NFR-PRV-01 | Public pages shall show only approved exhibition data (names, matric number, titles, links); emails, phone numbers, marks, evaluations and notes shall never be public. |
| NFR-PRV-02 | The import pipeline shall skip confidential marks/evaluation sheets and record each skip. |
| NFR-PRV-03 | The staff directory RPC exposed to students shall return names and roles only, no emails. |
| NFR-PRV-04 | Feedback shall store a fixed client identifier, not the visitor's real user-agent string. |

### 10.3 Performance and capacity

| ID | Requirement |
|---|---|
| NFR-PRF-01 | The app shall be built with WebAssembly (dart2wasm/skwasm) and fall back to JavaScript on browsers without WasmGC. |
| NFR-PRF-02 | A service worker shall cache versioned build assets (stale-while-revalidate) and serve documents network-first with cache fallback. |
| NFR-PRF-03 | A branded HTML splash shall show from first byte until Flutter's first frame. |
| NFR-PRF-04 | Generated project covers shall render locally with zero network requests. |
| NFR-PRF-05 | Searches shall be debounced (250 ms); similarity results shall be cached and recomputed only when data changes. |
| NFR-PRF-06 | The system shall stay within the Supabase free tier (500 MB DB, 1 GB storage, 200 realtime connections, 50k MAU); the estimated footprint is under 50 MB. |

### 10.4 Availability and resilience

| ID | Requirement |
|---|---|
| NFR-AVL-01 | If Supabase fails to initialise or is unreachable, the public catalogue, booths and schedule shall still render from the bundled fallback, under an offline banner with Retry; a list with nothing to show shall say the server could not be reached (with Retry) rather than "nothing here". |
| NFR-AVL-02 | The app shell shall boot offline from the service-worker cache. |
| NFR-AVL-03 | An uptime monitor shall check the site every 30 minutes and open/close a GitHub "incident" issue on failure/recovery. |
| NFR-AVL-04 | Failed admin writes shall roll back optimistically applied changes. |

### 10.5 Usability, responsiveness and accessibility

| ID | Requirement |
|---|---|
| NFR-USE-01 | Every page shall work at phone width (≥ 320 px) without horizontal scrolling; the single layout breakpoint is 768 px. |
| NFR-USE-02 | Mobile page titles shall use a 28 px heading (desktop 40 px) so they fit on one line. |
| NFR-USE-03 | The mobile home hero shall fit within one screen. |
| NFR-USE-04 | Animations shall be disabled when the OS requests reduced motion. |
| NFR-USE-05 | Icon-only controls shall carry tooltips; the filter toggle exposes a semantic label with the active-filter count. |
| NFR-USE-06 | The UI shall follow the "Ink & Terracotta" design system (primary `#2A1838`, secondary `#9A3A12`, tertiary `#0B2A26`, surface `#FAF7F2`; Montserrat headings, Inter body; 4/8/12 px radii; 4–32 px spacing scale). |
| NFR-USE-07 | The app shall be installable as a PWA (standalone, maskable icons). |

### 10.6 Maintainability and quality

| ID | Requirement |
|---|---|
| NFR-MNT-01 | `flutter analyze` shall report zero issues under strict-casts / strict-inference / strict-raw-types lints. |
| NFR-MNT-02 | The automated test suite (428 tests: unit, widget, route-guard, RPC lifecycle, theme contrast) shall pass on every pull request. |
| NFR-MNT-03 | Database changes shall be delivered only as ordered SQL migrations in `supabase/migrations/`. |
| NFR-MNT-04 | Feature code shall follow `lib/features/<feature>/presentation/{pages,widgets}` with shared code in `lib/core/`. |

### 10.7 Deployment

| ID | Requirement |
|---|---|
| NFR-DEP-01 | Pull requests to `main` shall run analyze → test → Wasm release build (`ci.yml`). |
| NFR-DEP-02 | Pushes to `main` shall build and deploy to GitHub Pages, copy `index.html` to `404.html` for deep links, and stamp the service-worker cache version (`deploy.yml`). |
| NFR-DEP-03 | `admin.fskmjasinfypexhibition.site` shall 302-redirect (Cloudflare) to `https://fskmjasinfypexhibition.site/admin`. |
| NFR-DEP-04 | Rollback shall be done by reverting the commit and redeploying, and/or restoring a database backup. |

---

## 11. Outputs and reports

| Output | Producer | Format / content |
|---|---|---|
| Feedback export | Admin → Feedback | `feedback_entries_YYYY-MM-DD.csv`: ID, User ID, Subject, Message, Rating, Status, Admin Note, Created At, Updated At |
| Visit export | Admin → Student Visits | `student_visits_YYYY-MM-DD.csv`: Lecturer, Role, Student, Project, Programme, Booth, Status, Visit Time, Note |
| Visit statistics | Admin → Student Visits | Completion %, SV/EX completion, today's count, per-lecturer and per-project tallies |
| Dashboard metrics | Admin dashboard | Counts of projects, booths, schedules, imports, FYP records, pending requests |
| Redundancy report | Past Sem Projects guide | Clusters of similar projects with shared categories/words, overlap strength and cross-cohort flag |
| Import summary | Admin → Import | Candidates staged/published, privacy skips, published counts |
| Audit trails | `audit_logs`, `fyp_audit_logs` | Actor, role, action, target, safe metadata, timestamp |
| Public project record | FYPMS expo publication | A published `projects` row generated from an FYP record |

---

## 12. Known gaps and defects

Found while tracing the code for this document. None of these was executed, so "likely" means inferred from code and schema. The Status column records the fixes made since (as of 2026-09-27).

### 12.1 Admin CMS

| ID | Finding | Evidence | Severity | Status (2026-09-27) |
|---|---|---|---|---|
| G-01 | Event Start/End date fields are editable but never saved. | `admin_event_page.dart:63-68` | **High** | Fixed — PR #14 |
| G-02 | Editing a project rebuilds it from the form, wiping `presentation_day`, video/repository/poster URLs and the Industry Candidate flag. | `admin_projects_page.dart:144-170` | **High** | Fixed — PR #14 |
| G-03 | Admin feedback statuses "In Progress" / "Rejected" are not allowed by the DB check (`new/reviewed/resolved/archived`); saving them will fail. | `initial_schema.sql:231` | **High** | Fixed — PR #14 |
| G-04 | "Add Lecturer" passes a random UUID as `profiles.id`, which must reference an existing auth user — likely FK failure. | `admin_lecturers_page.dart:98` | **High** | Fixed — PR #14 |
| G-05 | Booth edit writes `presentation_day` / floor-plan URL as null; reassigning or deleting a booth leaves stale booth text on projects. | `admin_booths_page.dart:94-125` | Medium | Fixed — PR #24 |
| G-06 | Import "Replace Existing" inserts rather than replaces; duplicate/overlap detection and validation-issue display are not implemented; the max-file-size setting is not enforced. | `publish_approved_import_changes`, `import_detail_page.dart:91` | Medium | Fixed — PR #34 |
| G-07 | No UI for award categories, project–lecturer assignment, audit log viewing, event hours/FAQ/status/hero images. | — | Medium | Fixed — PR #32 (event editor), PR #33 (assignments, audit log, award categories) |
| G-08 | Visits CSV export lacks the formula-injection guard used by the feedback export. | `visit_data_table.dart:195` | Low | Fixed — PR #24 |
| G-09 | No confirmation for publish toggles, import publish or lecturer-ID backfill. | — | Low | Fixed — PR #24 |
| G-10 | Admin announcement dates print only "July" or "August". | `admin_announcements_page.dart:243` | Low | Fixed — PR #21 (with G-13) |

### 12.2 Public portal

| ID | Finding | Evidence | Severity | Status (2026-09-27) |
|---|---|---|---|---|
| G-11 | "Live Demo" / "GitHub Repository" buttons are enabled when a URL exists but do nothing. | `project_detail_page.dart:400` | **High** | Fixed — PR #14 |
| G-12 | "Featured Projects" ignores the `featured` flag; the view counter is in-memory per session, so the order is effectively creation order. | `projects_providers.dart:169-189` | Medium | Fixed — PR #21 |
| G-13 | Public announcement dates print "August" for every month except July. | `announcements_page.dart:55` | Medium | Fixed — PR #21 |
| G-14 | Booth "Map" link from a Day-2 project opens the Day-1 view and shows no booth. | `booths_page.dart:20` | Medium | Fixed — PR #21 |
| G-15 | Exhibition Info / FAQ / Privacy are not linked on desktop (no footer). | `public_shell.dart:119-141` | Low | Fixed — PR #24 |
| G-16 | Lecturer Portal "Type" dropdown sets value `'Industry'`, which is not an option. | `lecturer_page.dart:126,136` | Low | Fixed — PR #24 |
| G-17 | Home search query is not URL-encoded (`&`, `#` break it). | `home_page.dart:98-116` | Low | Fixed — PR #21 |
| G-18 | Award titles fall back to a generic label for real category ids; event `mapUrl`, `faqItems` and `publicContactEmail` are not displayed. | `awards_page.dart:10-21` | Low | Fixed — PR #24 |

### 12.3 FYPMS and lecturer visits

| ID | Finding | Evidence | Severity | Status (2026-09-27) |
|---|---|---|---|---|
| G-19 | Staff with profile role `lecturer` land in My Visits after sign-in instead of their FYPMS workspace. | `router_guards.dart:156-159` | Medium | Fixed — PR #25 |
| G-20 | F1 and F12 appear in the student form list but `submit_fyp_form` rejects them. | `roles_providers.dart:108-110` | Medium | Fixed — PR #25 |
| G-21 | CSP lecturers see Supervision Requests but the RPC does not let them decide; supervisors have no request page. | `workflow_rpc.sql:97-104` | Medium | Fixed — PR #19 (supervisor inbox; CSP read-only) |
| G-22 | Supervisor milestone page offers add/edit, but only CSP lecturers/coordinators may save milestones. | `fypms_rpc.sql:826-832` | Medium | Fixed — PR #25 |
| G-23 | Correction evidence file/note is stored only in audit metadata; deliverables take a pasted URL, not an upload. | `student_correction_evidence.sql:58-77` | Medium | Fixed — PR #25 (evidence), PR #23 (deliverable uploads) |
| G-24 | Marks total is a plain sum and grade is always null, while the UI shows "/ 100". | `security_hardening.sql:404-424` | Medium | Fixed — PR #18 (course marks, R4) |
| G-25 | No UI for report review, evaluation viewing, extensions, archiving, field overrides, session creation or file download; student/CSP presentation pages are placeholders. | — | Medium | Fixed — PR #29 |
| G-26 | Assigning a supervisor resets the workflow to `supervision_approved`; assigning a co-supervisor never sets `co_supervisor_id`. | `fypms_rpc.sql:697-716` | Medium | Fixed — PR #25 |
| G-27 | Staff UPDATE RLS policies on logs, forms, reports, canvases and corrections do not restrict columns, allowing un-audited direct edits. | `fypms_rls_policies.sql` | Medium | Fixed — PR #26 |
| G-28 | Cancel-visit dialog labels the reason "optional", but the RPC requires it. | `undo_visit_dialog.dart` | Low | Fixed — PR #24 |
| G-29 | Inactive lecturers pass the client visits guard (the RPC still refuses them). | `lecturer_providers.dart:66-87` | Low | Fixed — PR #24 |
| G-30 | Visit settings "allow before/after event" and open/close times are saved but not enforced. | `rpc_functions.sql:58-66` | Low | Fixed — PR #26 |

### 12.4 Non-functional

| ID | Finding | Severity | Status (2026-09-27) |
|---|---|---|---|
| G-31 | Public pages show no loading or error state; load failures are silent. | Medium | Fixed — PR #31 |
| G-32 | No password reset, account lockout or MFA in the UI; production Auth rate limits are unverified. | Medium | **Partially fixed** — password reset flow added (PR #30); no account lockout or MFA, brute-force protection relies on Supabase Auth rate limits |
| G-33 | No robots.txt, sitemap or Open Graph tags. | Low | Fixed — PR #24 |
| G-34 | Accessibility is minimal: one explicit `Semantics` widget, no semantic labels on images, no contrast audit. | Medium | Fixed — PR #31 (image labels, project cards as one button, 17-pair WCAG AA contrast audit) |

### 12.5 Documentation out of date

| Doc | Claim | Actual | Status (2026-09-27) |
|---|---|---|---|
| `TESTING.md`, `RELEASE_CHECKLIST.md` | 132 tests | 428 tests (all passing) | Updated |
| `README.md`, `ARCHITECTURE.md` | "ExcelData, 376 projects" | JSON asset, 387 projects / 221 booths / 8 schedule items | Updated |
| `FREE_TIER_LIMITS.md`, `DEPLOYMENT.md` | Maintenance dialog when backend is down | Offline banner / error with Retry (G-31) | Updated |
| `ARCHITECTURE.md`, `README.md` | Realtime announcements and visits | Only the FYPMS channel is wired | Updated |
| `DESIGN.md` | Navy/gold tokens | Ink & Terracotta palette | Updated |
| `DEPLOYMENT.md` | `peaceiris/actions-gh-pages` | `actions/upload-pages-artifact` + `deploy-pages` | Updated |
| `ADMIN_GUIDE.md` | Project search/filters, SV/EX assignment, award categories, live visit monitoring, date-range filter | Assignments and award categories now exist (G-07); project search/filters, live visit monitoring and a date-range filter do not | Updated |
| `IMPORT_PIPELINE.md` | Named columns, field-level PII skips, duplicate/overlap matching, 10 MB limit | Fixed positional columns A–E; whole-sheet skips only; duplicate/overlap checks and the size limit now exist (G-06) | Updated |

---

## 13. Traceability

| Area | Primary sources |
|---|---|
| Routes and guards | `lib/app/router.dart`, `lib/app/router_guards.dart` |
| Shells | `lib/app/widgets/public_shell.dart`, `admin_shell.dart`, `fypms_shell.dart` |
| Public features | `lib/features/public_*`, `junior_project_guide`, `exhibition_info`, `faq_privacy` |
| Admin features | `lib/features/admin_*` |
| FYPMS | `lib/features/fypms`, `lib/core/state/fypms`, `lib/core/supabase/fypms_*` |
| Schema, RLS, RPCs | `supabase/migrations/` (48 files) |
| Web shell | `web/index.html`, `web/flutter_bootstrap.js`, `web/sw.js`, `web/manifest.json` |
| CI/CD | `.github/workflows/ci.yml`, `deploy.yml`, `uptime-monitor.yml` |
| Tests | `test/` (428 tests) |
