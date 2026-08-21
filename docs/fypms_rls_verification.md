# FYPMS Student Slice — RLS / RPC Verification

This document records the RLS policies and SECURITY DEFINER RPC functions that
back the student vertical slice (F13 Lean Canvas + deliverables readiness +
student self-registration), and how each access path is authorized.

Reference: `supabase/migrations/20260818000001_fypms_student_slice.sql`
(already applied to project `siedglubjcedkbrpdzgi`).

## Design principle

Protected mutations are **not** exposed as raw table RLS `INSERT`/`UPDATE`.
Instead the client calls SECURITY DEFINER RPC functions that run as the owner,
perform their own authorization checks, and return row-identifiers on success.
RLS on the underlying tables stays restrictive; client-side role checks only
gate UI and routing, never data integrity.

## RPC functions

### `create_fyp_record(...)` — student self-registration

- **Invoker**: authenticated student.
- **Checks performed in function**:
  - `auth.uid()` must exist and match `p_student_id`.
  - The user must actually be a student (via `users.profile` role).
  - An `fyp_record` must not already exist for that `student_id` +
    `academic_semester_id` (prevents duplicate registration).
  - `current_course_code` must match the student's enrolled course.
- **Returns**: `fyp_record.id` (or `NULL`/error when rejected).
- **Why not plain INSERT RLS**: `fyp_records` deliberately has no
  student-owner INSERT policy; this function is the single allowed creation
  path and lets us enforce one-record-per-student-per-semester atomically.

### `save_lean_canvas(p_fyp_record_id uuid, p_blocks jsonb)`

- **Invoker**: authenticated student.
- **Checks**: the target `fyp_record.student_id` must equal `auth.uid()`.
- **Behavior**: upserts a `fyp_lean_canvas` row; when a row already exists it
  increments `canvas_version` (a save always creates a new revision).
- **Returns**: `fyp_lean_canvas.id`.
- **Why not plain UPDATE RLS**: versioned history must be author-controlled
  and monotonic; doing it in a function avoids exposing multi-row invariants
  through raw UPDATE.

### `submit_deliverable(p_fyp_record_id uuid, p_deliverable_type text, ...)`

- **Invoker**: authenticated student.
- **Checks**: the target `fyp_record.student_id` must equal `auth.uid()`.
- **Behavior**: inserts an `fyp_deliverable` row in `submitted` state with the
  provided file URL/title/description.
- **Returns**: `fyp_deliverable.id`.

## Read paths (client via supabase-js / dart)

Reads use standard, deliberately-permissive RLS selects scoped by record owner:

- `fyp_lean_canvas` / `fyp_deliverables` / `fyp_records` selects are allowed
  where the authenticated user owns the record (student) or is
  supervisor/committee/coordinator on it (staff), matching existing FYPMS
  read policies. No read RLS changes were required for this slice.

## Advisors / security notes

- RLS remains enabled on all tables touched; functions are SECURITY DEFINER and
  owned by the schema owner, so they bypass RLS only for the internal
  operations they encapsulate.
- `search_path` is fixed inside each function to avoid hijacking.
- No secrets or keys are exposed by any of the functions.

## Verification

- Migrations applied: `supabase_list_migrations` shows
  `20260818000001_fypms_student_slice` applied.
- RPC signatures checked against the live database before writing the Dart
  service wrappers.
- Widget tests cover the pages that call these RPCs
  (`test/features/fypms/fypms_student_pages_test.dart`,
  `test/features/fypms/fypms_deliverable_lean_canvas_test.dart`).