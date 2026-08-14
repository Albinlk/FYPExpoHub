# Import Pipeline — FYP Expo Hub

## Overview

The import pipeline allows admins to bulk-import exhibition data from a
master Excel workbook. Unlike the previous Firebase-based pipeline, parsing
happens **entirely client-side** in the Flutter Web browser — no server-side
processing or Cloud Functions are required.

## Architecture

```
Admin uploads .xlsx (≤ 10 MB)
    → In-browser parsing via `excel` package
    → Staged candidates written to import_* tables via Supabase client
    → Admin reviews candidates in the "Data Matching Dashboard"
    → Admin selects candidates to publish
    → `publish_approved_import_changes` RPC atomically inserts into live tables
```

## Required Workbook Structure

The master workbook should contain these worksheets:

### 1. `TENTATIF` (Schedule)
| Column | Required | Description |
|--------|----------|-------------|
| `Date` | Yes | Presentation date (e.g., "6 August 2026") |
| `Start Time` | Yes | Start time (e.g., "9:00 AM") |
| `End Time` | Yes | End time |
| `Title` | Yes | Session/project title |
| `Venue` | Yes | Venue location |
| `Audience` | Yes | Intended audience |
| `Classification` | Yes | Public/Internal |

### 2. `PEMENANG ANUGERAH` (Award Winners)
| Column | Required | Description |
|--------|----------|-------------|
| `Award Category` | Yes | Category name |
| `Project Title` | Yes | Title of winning project |
| `Student Name(s)` | Yes | Team member names |
| `Supervisor` | Yes | Supervisor name |
| `Programme` | Yes | e.g., "CS230" |
| `Sponsor` | No | Award sponsor |
| `Description` | No | Award description |

## Privacy Handling

During import, certain fields are classified as **PDPA-protected** and are
automatically skipped:

| Field | Reason | Handling |
|-------|--------|----------|
| Student email addresses | Personal data | Logged in `import_privacy_skips`, not stored |
| Student phone numbers | Personal data | Logged in `import_privacy_skips`, not stored |
| Confidential evaluation scores | Sensitive | Logged in `import_privacy_skips`, not stored |
| Internal admin notes | Restricted | Logged in `import_privacy_skips`, not stored |

All skipped fields are recorded in `import_privacy_skips` with:
- `sheet_name`, `row_number`, `field_name`, `reason`

## Validation

### Schedule Candidates
- **Time overlap checks**: Detects if two sessions have overlapping times
- **Date format validation**: Ensures dates are parseable
- **Required field checks**: Missing titles, times, venues

### Award Candidates
- **Duplicate detection**: Flags potential duplicate award entries
- **Project matching**: Attempts to match project title to existing projects
  (fuzzy match using normalized text)
- **Required field checks**: Missing award category, project title

### Validation Issues
All validation issues are recorded in `import_validation_issues`:
- `worksheet_name`, `row_number`, `severity` (warning/error), `message`

## Staging Tables

| Table | Purpose |
|-------|---------|
| `imports` | Import job metadata (file name, status, summary, uploaded_by) |
| `import_schedule_candidates` | Staged schedule rows awaiting review |
| `import_award_candidates` | Staged award rows awaiting review |
| `import_validation_issues` | All validation warnings/errors |
| `import_privacy_skips` | Fields skipped for privacy reasons |
| `import_review_decisions` | Admin decisions (publish/skip) per candidate |

## Publishing

After review, the admin selects candidates to publish. The app calls:
```sql
publish_approved_import_changes(p_import_id uuid)
```

This RPC function:
1. Iterates through `import_review_decisions` where `action = 'publish'`
2. For schedule candidates: inserts into `schedule_items`
3. For award candidates: inserts into `award_winners`
4. Updates `import.status` to `'published'`
5. Returns a JSON summary with counts

## Migration Tool

The `tools/firebase_to_supabase/migrate_data.js` script provides a
Firestore-export-to-SQL migration path:
```bash
node tools/firebase_to_supabase/migrate_data.js --dry-run
node tools/firebase_to_supabase/migrate_data.js --write
```

Outputs:
- `seed_data.sql`
- `migration_summary.json`
- `migration_errors.csv`
- `rollback_plan.md`
