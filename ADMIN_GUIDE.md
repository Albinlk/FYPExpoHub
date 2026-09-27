# Admin Guide — FYP Expo Hub

## Accessing the Admin CMS

1. Navigate to https://fskmjasinfypexhibition.site/admin/sign-in
2. Sign in with your Supabase Auth credentials
3. If you don't have access, contact an existing admin to create a `profiles` row for you

> **Important:** Creating a lecturer or admin account is a two-step process:
> 1. Create the Supabase Auth user (Studio → Authentication → Users → Add user)
> 2. Create or update the `profiles` row with `role = 'admin'` or `'lecturer'`
>
> After that, **FYPMS → Users & Roles** (`/fypms/coordinator/users`) grants
> or revokes academic roles (supervisor, examiner, CSP lecturer, programme
> head / PU, coordinator), deactivates accounts and, for admins, changes the
> account role — no SQL needed. Students are created in bulk from
> **Enrol Students** (see *FYPMS administration* below).

### My Account

Click your email in the top bar (the person icon on phones) to open
**My Account**:
- **Display name** — shown to students and colleagues.
- **Change password** — asks for the current password; the new one needs
  8+ characters with letters and numbers.
- **Two-step verification** — scan the QR code with an authenticator app
  (Google / Microsoft Authenticator…) and confirm a code. From then on
  sign-in asks for a code, and your **admin / coordinator powers only work
  after the code is entered** (enforced in the database, not just the
  screen). Turn it off from the same place. If the phone is lost, another
  admin removes the factor in Studio → Authentication → Users.

Repeated wrong passwords are slowed down by Supabase Auth's sign-in rate
limit (Dashboard → Authentication → Rate Limits); there is no separate
per-account lockout.

## Dashboard Overview

The `/admin` dashboard shows:
- **Total Projects** — count of all projects
- **Total Booths** — count of all registered booths
- **Total Schedule Items** — count of all schedule entries
- **Files Imported** — count of completed import jobs
- **Recent Imports** — last 5 import jobs with status
- **Quick Actions** — links to key management pages

## Event Information

`/admin/event` — **Update Event Information**

| Field | Notes |
|---|---|
| Exhibition title | Required |
| Session / semester label | e.g. "Semester 2026/1" |
| Start / end date | The end date must not be before the start date |
| Daily hours | e.g. "9:00 AM – 5:00 PM" |
| Primary venue / hall, location details | Building, floor, parking… |
| Map link | Must be an `http(s)` link |
| Description | Event description |
| Public contact email | Must look like an email address |
| Hero image URL, poster URL | Must be `http(s)` links |
| Event status | Draft / Upcoming / Active (running) / Completed / Archived |
| Event FAQ | Add, edit and remove question/answer pairs; a question needs an answer |

Links are only checked when you change them, so an older non-link value
already stored does not block saving. Click **Save Changes** to publish the
edits.

### Exhibitions (one per year)

The **Exhibitions** section on the same page lists every exhibition. Exactly
one is **current** — the public site, the CMS pages and imports all work on
it.
- **New exhibition** — slug (e.g. `fskm-fyp-2027`), title, dates, venue.
- **Make current** — switches the site to that exhibition. The previous one
  keeps all its projects, booths and winners and appears on the public
  **Past Exhibitions** page (`/archive`).

## Project Catalogue

`/admin/projects`
- List all projects with publication status (no search or filters on this page)
- Add / edit project details:
  - Title
  - Matric ID (public exhibition data)
  - Programme code and name
  - Student name(s), supervisor and examiner names
  - Short description, project category
  - Tech tags
  - Demo URL
  - Cover image URL
  - Booth number and zone
  - Featured flag ("Highlight as Featured Project")
  - Publication status (Published / Draft)
- Fields the dialog doesn't show (presentation day, video/repository/poster
  links, Industry Candidate flag) are kept when you save
- Toggle publication status (Published ↔ Draft; unpublishing asks for
  confirmation)

### Import projects & booths

**Import** (next to *Add Project*) loads many projects at once into the
current exhibition from the Master File's project sheet (a worksheet whose
name contains PROJEK / PROJECT / BOOTH / GERAI, else the first sheet) or a
CSV. The first row is a header; columns are matched by name in English or
Malay — *Title / Tajuk* (required), *Students / Nama Pelajar*, *Matric*,
*Programme*, *Supervisor / Penyelia*, *Examiner / Pemeriksa*,
*Booth / No Gerai*, *Zone / Zon*, *Category*, *Tags*, *Description*, *Day*.
Several students or tags in one cell are separated by `;` or `,`.

The preview marks each row *New*, *Already listed* (same title in this
exhibition — skipped unless **Update projects already listed** is on) or a
problem (no title, the same title or booth twice in the file, a booth that
belongs to another project). Imported projects and booths are **drafts**
unless **Publish … now** is on. The result lists anything the database
refused, e.g. a booth that another project took meanwhile.

## Schedule Management

`/admin/schedule`
- List all schedule items sorted by date/time
- Add new schedule items
- Edit existing items (date, times, title, venue, audience, classification)
- Toggle publication status
- Note: time overlap validation is performed during import

## Booth Management

`/admin/booths`
- List all booths with status
- Register new booths (number, zone, location details)
- Map projects to booths
- Delete booth assignments

## Lecturer Management

`/admin/lecturers`
- List all lecturer profiles
- Add new lecturers (creates a `profiles` row — Auth user must be created separately)
- Delete lecturers
- "Backfill Lecturer IDs" — links assignments that have no lecturer account
  to the lecturer whose name matches exactly
- Project assignments are managed on the Lecturer Assignments page (below)

## Lecturer Assignments

`/admin/assignments`

Lecturers can mark visits **only** for projects they are assigned to, so
every SV/EX pairing needs an active assignment.

- **Match from project names** — compares each project's supervisor and
  examiner names with active lecturer accounts (titles, case, spacing and
  punctuation ignored) and proposes the missing assignments. The summary
  shows how many names have no lecturer account and how many match more than
  one (those are never auto-assigned). Click **Create N assignments** to
  confirm.
- **Assign** — add a lecturer to a project manually as Supervisor or Examiner.
- **Remove** — delete an assignment from its chip; visits already recorded
  are kept.
- Search by project, lecturer or booth.

## Announcements

`/admin/announcements`
- List all announcements
- Create new announcements (title, body, is_pinned)
- Edit existing announcements
- Toggle publication status
- Pin/unpin announcements

## Awards

`/admin/awards`
- **Award Categories** section — add, edit and delete categories for the event: title
  (e.g. "Gold Innovation Award"), optional description, display order
  (lower first) and "Shown on the public Awards page"; winners are then filed
  under a category
- CRUD award winner records
- Assign projects to awards
- Toggle publication status

## Student Visits

`/admin/visits`
- Monitoring of visit progress (not live-updating: the Expo realtime channel
  is not wired, so reload for new visits)
- Tabs: Overview / By Lecturer / By Project / Visit Log
- Filters: role (All / SV / EX), status (All / Visited / Not Yet / Voided)
- Search lecturers, projects, students or booths
- **Void Visit** button — requires a mandatory reason
- **Export CSV** — downloads visits as a CSV file (generated client-side)

## Import Master File

The Master File import covers **schedule items and award winners only**
(see `IMPORT_PIPELINE.md` for the workbook layout and every check).

`/admin/imports`
1. Click **Upload & Parse .xlsx** and select the master workbook. Files
   larger than the **Maximum File Size Limit** in Settings are refused before
   parsing.
2. Wait for in-browser parsing and checks to complete
3. Open the import with **Review & Publish**

`/admin/imports/:importId` — **Review Master File Import**
- **Checks** card — the validation issues, warnings first, then notes:
  unreadable days/times, duplicates, rows that change a live item, overlaps,
  missing mandatory worksheets
- Schedule candidates (TENTATIF) and award candidates (PEMENANG ANUGERAH),
  each flagged where it applies:

  | Flag | Meaning |
  |---|---|
  | Already live | An identical item is already published |
  | Changes a live item | Same day + title is live with a different time or venue |
  | Duplicate in file | The row repeats an earlier row of the same file |
  | Overlaps another item | Same venue at an overlapping time |

- Choose **Publish**, **Replace Existing** or **Skip** per row. Sensible
  defaults are pre-selected: for schedule rows Skip when "Already live" or
  "Duplicate in file", Replace Existing for "Changes a live item", otherwise
  Publish; for award rows Skip when "Duplicate in file" or already published,
  otherwise Publish.
- **Replace Existing really replaces**: it first deletes the live item(s) the
  row matches (schedule: same day and same title, or same venue at an
  overlapping time; awards: same award and team), then inserts the row.
- See privacy-skipped (confidential) sheets
- Click **Approve & Publish Selected** to call the
  `publish_approved_import_changes` RPC. An import can only be published once.

## Settings

`/admin/settings`
- View and edit portal settings
- **Excel Master File Parsing** — Maximum File Size Limit (default `10 MB`;
  accepts e.g. `10 MB`, `500KB`, `2.5 mb` or plain bytes; enforced on upload)
  and Mandatory Worksheet Names (default `TENTATIF, PEMENANG ANUGERAH`;
  English/Malay aliases SCHEDULE ≈ TENTATIF and AWARD ≈ ANUGERAH count)
- **Visit Tracker Settings** — enable visits, allow visits before/after the
  exhibition, lecturer undo window (minutes)
- Settings are stored as key-value pairs in the `settings` table
- Changes take effect immediately

## FYPMS administration (coordinator)

The coordinator (and admins) manage the FYP workflow from `/fypms`:

| Page | What it does |
|---|---|
| Semesters & Courses | Create semesters, move them planned → active → completed (activating one completes the previous active one), course names / credit hours, and each semester's course offerings and lecturer |
| Top-bar semester selector | Every staff list follows the chosen semester; *All semesters* shows history. Records of past semesters stay as they were |
| All Records → ⋮ | *Promote to CSP650…* (after finalized, passing CSP600 marks; creates the linked CSP650 record in a later semester), *Mark incomplete (TL)…*, *Mark withdrawn…*, *Reinstate…*, *Reopen finalized marks…* (reason required; the course lecturer is notified to finalize again), *Archive…* |
| Users & Roles | Grant / revoke academic roles, deactivate accounts |
| Enrol Students | Paste or upload a CSV (email, name, programme, matric); creates missing logins (students then use *Forgot password?*) and their FYP records for the chosen semester and course |
| Rubrics | Edit a form's criteria, weights and evaluator shares; saving creates a new version — earlier evaluations keep the version they were scored with |
| Presentations | Create, edit or delete sessions; remove slots |
| Reports | Status counts, grade distribution, supervisor workload (CSV) for the chosen semester |
| Appointment Letters | Approved supervisor / examiner appointments with printable letters (the PU sees the same under Nominations) |

The bell in the top bar shows each user's notifications — new requests,
submissions, decisions, assignments, corrections and finalized marks. They
are in-app only (email would need a custom SMTP provider).

## Audit Log

`/admin/audit` — the latest 300 recorded actions, newest first, in Malaysia
time. Search by action, target or details, and filter by action.

Admin and lecturer actions are logged in `audit_logs`, for example:
- `visit_marked` — when a visit is marked complete
- `visit_voided` — when a visit is voided
- `import_created` — when an import job is created
- `import_published` — when approved changes are published
- `profile_created` — when a new profile is created
- `event_created`, `current_event_changed` — exhibitions (S6)
- `projects_imported` — a project / booth import, with its counts (F5)

FYPMS actions go to `fyp_audit_logs` (FYPMS → Audit Logs), e.g. semester
changes, promotions, role grants, enrolments, rubric versions, session
edits, `record_withdrawn` / `record_incomplete` / `record_reinstated`,
`course_marks_reopened` (with the previous total and grade) and
`display_name_changed`.

The audit log is read-only for all users (no direct writes from the client).
