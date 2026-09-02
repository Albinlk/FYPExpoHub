# Security Policy — FYP Expo Hub

## Supabase Project
- **Project Ref**: `siedglubjcedkbrpdzgi`
- **URL**: `https://siedglubjcedkbrpdzgi.supabase.co`

## Authentication

### Auth Provider
- **Supabase Auth** (email/password provider)
- Users sign in with their UiTM email address
- No third-party providers configured (keep simple, control access)

### User Roles
Roles are stored in the `profiles.role` column (`'admin'` or `'lecturer'`),
NOT in Supabase Auth user metadata. Role assignment is managed by admins
through the CMS.

| Role | How granted | How enforced |
|------|-------------|--------------|
| **admin** | Profile row with `role='admin'` created by an existing admin | RLS policies + RPC function checks via `is_admin()` helper |
| **lecturer** | Profile row with `role='lecturer'` created by an admin | RLS policies + RPC function checks via `is_lecturer()` helper |
| **anonymous** | No Supabase Auth session | RLS `anon` policies (public reads only) |

## Row Level Security (RLS)

All **42 tables** (19 Expo Hub + 23 FYPMS) have RLS enabled. See
[`SUPABASE_RLS_POLICIES.md`](./SUPABASE_RLS_POLICIES.md)
for the Expo policy matrix; FYPMS policies live in
`supabase/migrations/20260817000003_fypms_rls_policies.sql` and the
September 2026 hardening migrations.

### Key Policies
- **Default deny** — no data is accessible without an explicit policy
- **Anonymous visitors** — read-only access to published public data
  (`publication_status = 'published'`)
- **Authenticated lecturers** — read access to their own assignments and visits
- **Admins** — full CRUD access to all tables
- **No direct writes** for non-admin users on sensitive tables:
  `student_project_visits`, `imports`, `import_*`, `audit_logs`, `settings`,
  `lecturer_assignments`

### Visitor Visit Mutations
Visit creation and voiding must use **RPC functions**, not direct table writes:
- `mark_student_project_visited()` — validates ownership, active assignment, duplicate prevention
- `void_student_project_visit()` — requires non-empty reason, enforces ownership

## Sensitive Data Handling

### Private Fields (Protected)
These fields are **never exposed** to anonymous visitors:
- Student email addresses
- Student phone numbers
- Confidential evaluation scores
- Internal admin notes
- Import file contents
- Audit log details (admin-only)

### Approved Public Data
Per PDPA policy, the following student data is **approved for public display**:
- `matric_id` (matriculation number) — shown on project detail pages
- Student names — shown in team lists
- Project titles and descriptions
- Demo/video/repository URLs

## API Key Security

### Client-side
- Use the **anon key** (`SUPABASE_ANON_KEY`) in the Flutter app
- The anon key is embedded via `--dart-define` at build time
- RLS policies enforce data access — the anon key cannot bypass RLS
- **Never** use the service role key on the client

### Server-side / Scripts
- The service role key (`SUPABASE_SERVICE_ROLE_KEY`) was historically used by
  local migration tooling (now removed); if you need it, obtain it from the
  Supabase dashboard and keep it in a gitignored `.env`
- The service role key **bypasses all RLS** — treat as a secret

## Secrets Management

| Secret | Location | Git-tracked? |
|--------|----------|--------------|
| `SUPABASE_URL` | `.env`, `--dart-define`, GitHub Actions secrets | No |
| `SUPABASE_ANON_KEY` | `.env`, `--dart-define`, GitHub Actions secrets | No |
| `SUPABASE_SERVICE_ROLE_KEY` | Local gitignored `.env` only | No |
| Firebase credentials | Removed | N/A |

## Known Accepted Risks (Development)

| Risk | Status | Rationale |
|------|--------|-----------|
| 11 `@fypms.test` demo accounts are **live** with a shared password documented in tracked seed migrations (`20260819000001`, `20260822142935`) | **Accepted** | Accounts are kept for development testing only. **Must be disabled or password-rotated before any real student data enters the project.** |
| Anon key committed in `.env.example` | Accepted | Anon keys are publishable by design; RLS is the control. Rotate after initial release (checklist item below). |

## Security Audit Checklist

- [x] All 42 tables have RLS enabled
- [x] Default deny (no blanket allow policies)
- [x] Anonymous access restricted to published public data
- [x] Lecturer visit mutations go through RPC functions
- [x] Audit log table is write-restricted (admin/owner only)
- [x] No service role key in client code
- [x] `matric_id` classified as approved public data per PDPA
- [ ] Production anon key rotation (after initial release)
- [ ] Enable Supabase Auth rate limiting
- [ ] Disable `@fypms.test` demo accounts before production (see Accepted Risks above)

## Security Hardening (September 2026)

Applied via `supabase/migrations/20260901000001..3_security_hardening*.sql`:

- **Private storage buckets** (`fyp-proposal-reports`, `fyp-final-reports`,
  `fyp-deliverables`, `fyp-correction-evidence`) — anon read access removed;
  reads/writes now path-scoped to the owning FYP record via
  `can_read_fyp_storage_path()` / `can_write_fyp_storage_path()`
- **`fyp-public-assets`** — writes restricted to coordinator/admin
- **`list_fyp_students/staff/coordinators()`** — now gated to FYP coordinator /
  CSP lecturer / admin (previously callable by anyone, leaking PII)
- **Student self-UPDATE policies removed** on `fyp_records`, progress logs,
  form submissions, report submissions, deliverables, lean canvases — all
  edits flow through audited SECURITY DEFINER RPCs
- **`fyp_marks_summaries`** — CSP lecturers SELECT-only (bypassing
  `finalize_marks` is no longer possible)
- **`is_csp_lecturer()`** — unknown course codes now deny instead of falling
  back to CSP600
- **`finalize_marks`** — cross-checks the record's actual course code
- **`exec_sql_batch()` dropped** — leftover anon-executable arbitrary-SQL
  function from the populate_projects scratch migrations
- **Anon EXECUTE revoked** on all mutating RPCs; RLS-policy-referenced
  helpers (read-only booleans, false for anon) intentionally keep anon grants
