# FYPMS Demo Seeding

> **Status:** development / QA only. This seed payload is INTENDED for the dev
> database `siedglubjcedkbrpdzgi` and non-production staging. It must never be
> applied to the deployed production environment, and it contains no private
> credentials (all test accounts share the demo password `Password123!`).

## What it is

`supabase/migrations/20260820000001_fypms_demo_seed.sql` provisions a linked,
full-lifecycle FYP dataset on top of the fixed-UUID test accounts created by
`20260819000001_fypms_workflow_seed.sql`. It is **idempotent**: every row uses a
fixed UUID with `ON CONFLICT DO NOTHING` / `ON CONFLICT (… ) DO UPDATE`, so it can
be re-run safely on a staged database.

## What it creates

Three FYP records (fixed ids `20000000-…-…0001..0003`):

| Record | Student | Course | Seeded state |
|--------|---------|--------|--------------|
| **A** (`…0001`) | Student 1 | CSP600 | `supervision_requested`; pending F1 request (preferred S1); F2/F3/F4 **draft** forms |
| **B** (`…0002`) | Student 2 | CSP600 | `proposal_under_review`; approved F1; supervisor S1 + examiner assigned; 3 **validated** F5 logs; proposal report v1 `under_review`; F7/F8 **under_review** (awaiting evaluation); milestones |
| **C** (`…0003`) | Student 3 | CSP650 | `project_pending_presentation`; F13 Lean Canvas v1; proposal report **approved** + final report v1 `submitted`; F7/F8 **approved** with completed evaluations; 3 deliverables; 2 correction items (1 open, 1 in_progress) + 1 confirmation; milestones; presentation slot; **unfinalized** marks summary; Expo publication **draft** |

Supporting rows it creates (idempotent):

- **CSP650 offering** for semester `2026_1` (needed so CSP650 sessions/slots and the
  `is_csp_lecturer` gates resolve). CSP600 offering already existed.
- **Sessions:** `DEF-CSP600-S1` and `DEF-CSP650-S1` (defence type) under their
  offerings; **one slot** for Record C in the CSP650 session.
- **Assignments:** supervisor/examiner rows for Records B and C.
- **Marks summary** for Record C: `is_finalized=false` with a component breakdown, so
  the CSP650 lecturer can exercise `finalize_marks` during QA.
- **Expo publication** for Record C: status `draft` with an Expo-safe public payload
  (whitelist keys only). The coordinator re-prepares it (`prepare_expo_publication`
  → `ready`) before publishing during QA.

## Idempotency contract

- Records keyed on `(academic_semester_id, student_id, current_course_code)`.
- Child rows keyed on the fixed UUID `id` (insert); reference rows resolved at
  runtime by slug/code so the seed works even if the event/semester ids differ.
- Re-running after QA mutations does **not** reset those mutations (`DO NOTHING`),
  so a dirty QA run leaves edited state intact.

## Accounts at a glance (from `fypms_workflow_seed`)

| Email | Role | Workspace |
|-------|------|-----------|
| admin@fypms.test | admin | coordinator |
| csp600.lecturer@fypms.test | csp600_lecturer | csp |
| csp650.lecturer@fypms.test | csp650_lecturer | csp |
| coordinator@fypms.test | fyp_coordinator | coordinator |
| supervisor1@fypms.test | supervisor | supervisor |
| supervisor2@fypms.test | supervisor | supervisor |
| examiner@fypms.test | examiner | examiner |
| student1@fypms.test | student | student |
| student2@fypms.test | student | student |
| student3@fypms.test | student | student |

## How to run

```bash
# Local/staging (NOT production):
supabase db push            # applies migrations incl. this seed, or
psql "$DATABASE_URL" -f supabase/migrations/20260820000001_fypms_demo_seed.sql
```

## Safety notes

- Demo-only marker is present in the header; a `DO $$ … raise exception` guard for
  non-dev environments **is not** built in, so only run it where you intend to.
- Deleting demo data: remove the rows by their fixed ids
  (`20000000-0000-0000-0000-00000000{0001..0111}` ranges) or restore before this
  migration in a throwaway database.
- No private credentials are stored or documented; the shared demo password is a
  fixture, not a production secret.