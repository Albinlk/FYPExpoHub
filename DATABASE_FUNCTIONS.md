# Database Functions (RPC) — FYP Expo Hub

All 5 custom PostgreSQL functions use `SECURITY DEFINER` so they execute
with the function owner's privileges, allowing them to bypass RLS
restrictions that would block the authenticated user directly.

Each function uses `auth.uid()` to identify the caller and validates
their profile role from `public.profiles`.

## 1. `mark_student_project_visited`

Marks a student project as visited by an assigned lecturer.

```sql
mark_student_project_visited(p_assignment_id uuid, p_visit_note text DEFAULT null)
RETURNS public.student_project_visits
```

**Validation logic:**
1. User must be authenticated (`auth.uid()` not NULL)
2. User must have an active profile (role: admin or lecturer)
3. Assignment must exist and be active
4. Non-admin users can only mark visits for their own assignments
5. Visit settings checked from `settings` table (visitsEnabled flag)
6. Duplicate prevention: if a completed visit exists → raise exception
7. If a voided visit exists → restore it (update status to 'completed')

**Audit logging:** Creates entry in `audit_logs` with action 'visit_marked'.

**Error codes:**
- `28000` (unauthenticated) — not signed in
- `42501` (permission-denied) — not the assigned lecturer
- `P0002` (not-found) — assignment not found
- `23505` (already-exists) — visit already completed

## 2. `void_student_project_visit`

Voids a previously completed visit. Requires a mandatory reason.

```sql
void_student_project_visit(p_visit_id uuid, p_reason text)
RETURNS public.student_project_visits
```

**Validation logic:**
1. User must be authenticated
2. `p_reason` must be non-empty
3. User must have an active profile
4. Visit must exist and be in 'completed' status
5. Non-admin users can only void their own visits
6. 30-minute undo window enforced for lecturers (configurable via `settings.visit_tracker.lecturerUndoWindowMinutes`)

**Audit logging:** Creates entry in `audit_logs` with action 'visit_voided'.

**Error codes:**
- `28000` (unauthenticated) — not signed in
- `22023` (invalid-argument) — empty reason
- `42501` (permission-denied) — cannot void other's visit
- `P0002` (not-found) — visit not found
- `55000` (failed-precondition) — already voided or undo window expired

## 3. `publish_approved_import_changes`

Atomically publishes approved import changes (schedule items and award winners).

```sql
publish_approved_import_changes(p_import_id uuid)
RETURNS jsonb
```

**Returns:** JSON object with `import_id`, `status`, `published_schedules`, `published_awards`.

**Process:**
1. User must be authenticated and have admin role
2. Import record must exist
3. Iterates through `import_review_decisions` for this import
4. For each 'publish' or 'replace_existing' decision:
   - If `candidate_type = 'schedule'`: inserts into `schedule_items`
   - If `candidate_type = 'award'`: inserts into `award_winners`
5. Updates import status to 'published' with summary
6. Creates audit log entry

**Error codes:**
- `28000` (unauthenticated)
- `42501` (permission-denied) — not admin
- `P0002` (not-found) — import not found

## 4. `create_lecturer_account_profile`

Creates or updates a lecturer profile linked to an existing auth user.

```sql
create_lecturer_account_profile(p_user_id uuid, p_email text, p_display_name text)
RETURNS public.profiles
```

**Validation logic:**
1. Caller must be authenticated and admin
2. Normalizes email (lowercase, trimmed)
3. Normalizes display name (uppercase, trimmed)
4. Inserts or updates profile with role 'lecturer'
5. Creates audit log entry

**Note:** The `p_user_id` must correspond to an existing `auth.users` record.
The admin should create the auth user first in the Supabase dashboard.

## 5. `update_event_configuration`

Updates event configuration fields from a JSON payload.

```sql
update_event_configuration(p_event_id uuid, p_payload jsonb)
RETURNS public.events
```

**Fields supported in `p_payload`:**
- `title`, `session_label`, `start_at`, `end_at`, `daily_hours`
- `venue`, `location_details`, `map_url`, `description`
- `objectives` (JSON array), `status`, `publication_status`
- `hero_image_url`, `poster_url`, `public_contact_email`
- `faq_items` (JSON array)

**Validation logic:**
1. Caller must be authenticated and admin
2. If both `start_at` and `end_at` provided, validates `end_at > start_at`
3. Uses `coalesce()` so provided fields override, missing fields keep existing values
4. Updates `updated_by` to the caller's UID
5. Creates audit log entry with list of changed fields

## Usage from Flutter

```dart
// Mark a visit
final result = await supabase.rpc('mark_student_project_visited', {
  'p_assignment_id': assignmentId,
  'p_visit_note': 'Checked project display board',
});

// Void a visit
final result = await supabase.rpc('void_student_project_visit', {
  'p_visit_id': visitId,
  'p_reason': 'Student not present at booth',
});

// Publish approved import
final result = await supabase.rpc('publish_approved_import_changes', {
  'p_import_id': importId,
});

// Create lecturer profile
final result = await supabase.rpc('create_lecturer_account_profile', {
  'p_user_id': userId,
  'p_email': 'lecturer@example.com',
  'p_display_name': 'Dr. Smith',
});

// Update event configuration
final result = await supabase.rpc('update_event_configuration', {
  'p_event_id': eventId,
  'p_payload': {
    'title': 'Updated Event Title',
    'start_at': '2026-08-06T09:00:00+08',
    'end_at': '2026-08-07T17:00:00+08',
  },
});
```
