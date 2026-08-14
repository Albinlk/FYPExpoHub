# Admin Guide — FYP Expo Hub

## Accessing the Admin CMS

1. Navigate to https://fskmjasinfypexhibition.site/admin/sign-in
2. Sign in with your Supabase Auth credentials
3. If you don't have access, contact an existing admin to create a `profiles` row for you

> **Important:** Creating a lecturer or admin account is a two-step process:
> 1. Create the Supabase Auth user (Studio → Authentication → Users → Add user)
> 2. Create or update the `profiles` row with `role = 'admin'` or `'lecturer'`

## Dashboard Overview

The `/admin` dashboard shows:
- **Total Projects** — count of all projects
- **Total Booths** — count of all registered booths
- **Total Schedule Items** — count of all schedule entries
- **Files Imported** — count of completed import jobs
- **Recent Imports** — last 5 import jobs with status
- **Quick Actions** — links to key management pages

## Event Information

`/admin/event`
- Edit event title, session label, dates, venue
- Update daily hours and location details
- Set event status (draft/upcoming/active/completed/archived)
- Set publication status (draft/published/archived)
- Manage FAQ items (add/remove/edit)
- Set hero image and poster URLs

## Project Catalogue

`/admin/projects`
- List all projects with publication status
- Search by title, slug, or matric ID
- Filter by programme, category, featured flag
- Edit project details:
  - Title, slug, team display name
  - Matric ID (public exhibition data)
  - Programme code and name
  - Supervisor and examiner names
  - Short description, abstract
  - Tech tags
  - Demo, video, repository URLs
  - Cover image URL
  - Booth assignment
  - Presentation day
  - Industry candidate flag
  - Featured flag
- Toggle publication status (draft/published/archived)

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
- Assign projects to lecturers as Supervisor (SV) or Examiner (EX)
- "Backfill Lecturer IDs" — matches display names to Supabase UIDs
- Delete lecturer assignments

## Announcements

`/admin/announcements`
- List all announcements
- Create new announcements (title, body, is_pinned)
- Edit existing announcements
- Toggle publication status
- Pin/unpin announcements

## Awards

`/admin/awards`
- Manage award categories
- CRUD award winner records
- Assign projects to awards
- Toggle publication status

## Student Visits

`/admin/visits`
- Live monitoring of visit progress
- Tabs: Overview / By Lecturer / By Project / Visit Log
- Filters: role, status, date range
- Search by lecturer name or project
- **Void Visit** button — requires a mandatory reason
- **Export CSV** — downloads visits as a CSV file (generated client-side)

## Import Master File

`/admin/imports`
1. Click "Upload XLSX" and select the master workbook
2. Wait for in-browser parsing to complete
3. Review validation issues and privacy skips
4. Navigate to the import detail page

`/admin/imports/:importId`
- **Data Matching Dashboard** — side-by-side comparison of staged vs. live data
- Review schedule candidates and award candidates
- See validation issues (overlaps, missing fields)
- See privacy-skipped fields
- Make publish/retain decisions per candidate
- Click "Publish Approved Changes" to call the `publish_approved_import_changes` RPC

## Settings

`/admin/settings`
- View and edit portal settings
- Settings are stored as key-value pairs in the `settings` table
- Changes take effect immediately

## Audit Log

All admin actions are logged in `audit_logs`:
- `visit_marked` — when a visit is marked complete
- `visit_voided` — when a visit is voided
- `import_created` — when an import job is created
- `import_published` — when approved changes are published
- `profile_created` — when a new profile is created

The audit log is read-only for all users (no direct writes from the client).
