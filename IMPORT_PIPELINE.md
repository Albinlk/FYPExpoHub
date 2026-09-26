# Import Pipeline — FYP Expo Hub

## Overview

The import pipeline allows admins to bulk-import exhibition data from a
master Excel workbook. Unlike the previous Firebase-based pipeline, parsing
happens **entirely client-side** in the Flutter Web browser — no server-side
processing or Cloud Functions are required.

**Scope:** the pipeline imports **schedule items and award winners only**.
Projects, booths, lecturers and event information are managed in their own
admin pages, not through the Master File.

## Architecture

```
Admin uploads .xlsx (size checked against Settings → Max File Size, default "10 MB")
    → In-browser parsing via `excel` package
    → Checks (lib/features/admin_imports/domain/import_checks.dart) flag
      duplicates, overlaps and rows already live, and add validation issues
    → `stage_import` RPC writes the import + all staged rows in one transaction
    → Admin reviews candidates, checks and flags on /admin/imports/:importId
    → Admin picks an action per row (defaults pre-selected)
    → `publish_approved_import_changes` RPC atomically replaces/inserts live rows
```

### File size limit
The `excel_import.maxFileSize` setting (Settings page, default `10 MB`) is
enforced **before** the file is decoded. `parseFileSize()` accepts a number
with an optional unit — `B`, `KB`, `MB` or `GB`, case-insensitive, decimals
allowed (e.g. `10 MB`, `500KB`, `2.5 mb`, `1048576` = bytes; 1 KB = 1024 B).
An oversized file is refused with a message naming the limit; an unreadable
setting means no limit is applied.

### Mandatory worksheets
The `excel_import.mandatoryWorksheets` setting (comma-separated, default
`TENTATIF, PEMENANG ANUGERAH`) is checked case-insensitively as a substring of
the workbook's sheet names, with English/Malay aliases treated alike:

| Setting mentions | Also satisfied by |
|---|---|
| `SCHEDULE` | `TENTATIF` (and vice versa) |
| `AWARD` | `ANUGERAH` (and vice versa) |

Each missing sheet becomes a `missing_worksheet` warning (the import still
stages).

## Required Workbook Structure

The parser reads a sheet as **schedule** if its name contains `TENTATIF` or
`SCHEDULE`, and as **awards** if it contains `ANUGERAH` or `AWARD`. Row 1 is a
header and is skipped; columns are read **by position**, not by header name.
Sheets whose name contains `MARKAH`, `EVALUATION` or `STUDENT_PRIVATE` are
skipped entirely (see Privacy Handling); other sheets are ignored.

### 1. `TENTATIF` / `SCHEDULE` (Schedule)
| Column | Required | Description |
|--------|----------|-------------|
| A — Day | No (default `Day 1`) | A date (`2026-08-06`) or `Day 2` / `Hari 2`, counted from the event's first day |
| B — Time | Yes | Time range, e.g. `9:00 AM - 10:30 AM`, `1:00 - 2:30 PM`, `0900-1030`, `09.00 hingga 10.30` |
| C — Title | Yes | Session title (rows without one are ignored) |
| D — Venue | No (default `FSKM Complex`) | Venue location |
| E — Audience | No (default `General`) | Intended audience |

### 2. `PEMENANG ANUGERAH` / `AWARD` (Award Winners)
| Column | Required | Description |
|--------|----------|-------------|
| A — Award | No (default `Best Project`) | Award name (stored as the winner's title) |
| B — Team | Yes | Team / student display name (rows without one are ignored) |
| C — Supervisor | No | Supervisor name |
| D — Programme | No (default `CS230`) | Programme code |
| E — Project title | No (defaults to the team name) | Title of winning project |

## Privacy Handling

Only the positional columns listed above are read, so other columns (e.g.
student emails or phone numbers) never leave the browser. Whole sheets that
hold **PDPA-protected** data are skipped:

| Sheet name contains | Reason | Handling |
|-------|--------|----------|
| `MARKAH`, `EVALUATION` or `STUDENT_PRIVATE` | Confidential evaluation / marks | Logged in `import_privacy_skips` (`field_name` = "Entire Sheet", `category` = `confidential_sheet`), rows not stored |

All skipped sheets are recorded in `import_privacy_skips` with:
- `sheet_name`, `row_number`, `field_name`, `reason`, `category`

## Validation

Checks run in the browser (`lib/features/admin_imports/domain/import_checks.dart`)
before staging. Titles and venues are compared case- and spacing-insensitively.

### Schedule Candidates
- **Unreadable day or time** — the row is staged without a date/time and
  flagged; it cannot be published until fixed (the RPC skips it and counts
  it as `skipped_incomplete`).
- **Duplicate in file** — same day, title and start time as an earlier row.
- **Already live** — same day, title, start, end and venue as a live item.
- **Changes a live item** — same day and title as a live item but a
  different time or venue.
- **Overlap** — same (non-empty) venue at an overlapping time as another
  item with a different title, earlier in the file or live.

### Award Candidates
- **Duplicate in file** — the same award + team earlier in the file (the row
  is marked skip).
- **Already published** — the same award + team is already a published winner.

### Staged flags
The checks annotate each staged row (`stage_import` copies them into the
candidate tables since `20260927000001`):

| Column | Values | Set when |
|---|---|---|
| `comparison_status` | `new` / `unchanged` / `updated` | `new` = nothing like it is live; `unchanged` = identical item already live; `updated` = same day + title live with a different time or venue |
| `is_duplicate` (schedule) | boolean | duplicate in the file, or `unchanged` |
| `is_skip` (awards) | boolean | duplicate award + team in the file |
| `is_overlapping` | boolean | overlap found (schedule) |
| `overlap_details` | text | e.g. `Overlaps "Opening" 09:00–10:00 in Hall A` |

### Validation Issues
All validation issues are recorded in `import_validation_issues`:
- `worksheet_name`, `row_number`, `issue_type`, `severity`
  (`error` / `warning` / `info`), `message`

| `issue_type` | Severity | Raised for |
|---|---|---|
| `date_conflict` | warning | Day label that is neither a date nor "Day n" / "Hari n" |
| `invalid_time` | warning | Time range that can't be read or runs backwards |
| `duplicate` | warning (in file) / info (already live or published) | Duplicate rows, see above |
| `changed` | info | Schedule row that changes a live item |
| `overlap` | warning | Same venue at an overlapping time |
| `missing_worksheet` | warning | A mandatory worksheet (Settings) is absent |
| `unrecognized_worksheet` | warning | No schedule or award rows found in any sheet |

The review page lists these checks (warnings first, then notes) above the
candidate lists.

## Staging Tables

| Table | Purpose |
|-------|---------|
| `imports` | Import job metadata (file name, status, summary, uploaded_by) |
| `import_schedule_candidates` | Staged schedule rows awaiting review |
| `import_award_candidates` | Staged award rows awaiting review |
| `import_validation_issues` | All validation warnings/errors |
| `import_privacy_skips` | Fields skipped for privacy reasons |
| `import_review_decisions` | Admin decisions per candidate (`publish` / `replace_existing` / `skip`; the table also allows `save_draft`, `mark_internal`, `retain_existing`) |

## Publishing

On `/admin/imports/:importId` each row shows its flags (**Already live**,
**Changes a live item**, **Duplicate in file**, **Overlaps another item**) and
a Publish / Replace Existing / Skip choice, pre-selected by
`defaultImportAction()`:

| Row | Default action |
|---|---|
| Schedule: `unchanged` or `is_duplicate` | Skip |
| Schedule: `updated` | Replace existing |
| Award: `is_skip` (duplicate in file) | Skip |
| Anything else (incl. an award already published — it is only listed as an `info` check) | Publish |

After review the app calls:
```sql
publish_approved_import_changes(p_import_id uuid)
```

This RPC function (admin only; an import can be published once):
1. Iterates through `import_review_decisions`, acting on `publish`,
   `replace_existing`, `save_draft` and (schedule only) `mark_internal`;
   `skip` rows are left alone
2. Schedule candidates without a date or time are skipped
   (`skipped_incomplete`)
3. **Replace existing** first deletes the live rows the candidate matches:
   - **schedule** — same event and same day, and either the same title
     (case/spacing-insensitive) **or** the same venue at an overlapping time
   - **awards** — same event, same award name (winner title) and same team
     (case-insensitive)

   Rows inserted earlier in the **same publish** are never deleted (they carry
   the publish timestamp), so two "replace" rows cannot remove each other
4. Inserts the candidate into `schedule_items` / `award_winners`
   (`save_draft` → draft, `mark_internal` → internal access, else published)
5. Updates `imports.status` to `'published'` and writes the counts to
   `imports.summary` and an `import_published` row in `audit_logs`
6. Returns a JSON summary: `published_schedules`, `published_awards`,
   `replaced_schedules`, `replaced_awards`, `skipped_incomplete`

## Migration Tool (removed)

The one-time Firebase migration tooling (`tools/firebase_to_supabase/`,
including `migrate_data.js` and its `seed_data.sql` output) was removed from
the repository in September 2026 after the migration completed. See
`MIGRATION_REPORT.md` for the historical record.
- `migration_summary.json`
- `migration_errors.csv`
- `rollback_plan.md`
