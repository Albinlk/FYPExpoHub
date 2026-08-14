# Row Level Security (RLS) Policies — FYP Expo Hub

All 19 Supabase tables have **RLS enabled**. Access is controlled via policies
that check the `profiles.role` of the authenticated user.

## Helper Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `is_admin()` | `boolean` | TRUE if current user has role 'admin' and is active |
| `is_lecturer()` | `boolean` | TRUE if current user has role 'lecturer' and is active |
| `current_user_role()` | `text` | Returns the current user's role ('admin' \| 'lecturer' \| NULL) |
| `current_event_is_public(p_event_id)` | `boolean` | TRUE if event is published |
| `can_read_project(p_project_id)` | `boolean` | TRUE if project is published or user is admin/assigned lecturer |
| `can_read_assignment(p_assignment_id)` | `boolean` | TRUE if user is admin or assigned lecturer |

All helpers use `SECURITY DEFINER`.

## Policy Matrix

| Table | Policy | Role | Operation | Condition |
|-------|--------|------|-----------|-----------|
| **profiles** | Admins have full access to profiles | admin | ALL | `is_admin()` |
| **profiles** | Users can read own profile | authenticated | SELECT | `auth.uid() = id` |
| **events** | Public can read published events | anon | SELECT | `publication_status = 'published' OR is_admin()` |
| **events** | Admins manage events | admin | ALL | `is_admin()` |
| **projects** | Public can read published projects | anon | SELECT | `publication_status = 'published' OR is_admin() OR EXISTS(lecturer_assignments for current user)` |
| **projects** | Admins manage projects | admin | ALL | `is_admin()` |
| **booths** | Public can read active booths | anon | SELECT | `publication_status = 'published' OR is_admin()` |
| **booths** | Admins manage booths | admin | ALL | `is_admin()` |
| **schedule_items** | Public can read public schedule | anon | SELECT | `(publication_status = 'published' AND access_type = 'public') OR is_admin() OR (authenticated AND published)` |
| **schedule_items** | Admins manage schedule items | admin | ALL | `is_admin()` |
| **announcements** | Public can read published announcements | anon | SELECT | `publication_status = 'published' OR is_admin()` |
| **announcements** | Admins manage announcements | admin | ALL | `is_admin()` |
| **award_categories** | Public can read active categories | anon | SELECT | `status = 'active' OR is_admin()` |
| **award_categories** | Admins manage categories | admin | ALL | `is_admin()` |
| **award_winners** | Public can read published winners | anon | SELECT | `publication_status = 'published' OR is_admin()` |
| **award_winners** | Admins manage winners | admin | ALL | `is_admin()` |
| **lecturer_assignments** | Admins manage assignments | admin | ALL | `is_admin()` |
| **lecturer_assignments** | Lecturers read own assignments | lecturer | SELECT | `lecturer_id = auth.uid() AND status = 'active'` |
| **student_project_visits** | Admins manage visits | admin | ALL | `is_admin()` |
| **student_project_visits** | Lecturers read own visits | lecturer | SELECT | `lecturer_id = auth.uid()` |
| **student_project_visits** | Prevent direct visit mutations by non-admins | lecturer | INSERT | `is_admin()` (blocks non-admin inserts) |
| **feedback_entries** | Public can insert feedback | anon | INSERT | Subject/message length checks, rating validation |
| **feedback_entries** | Users read own feedback | authenticated | SELECT | `is_admin() OR (auth.uid() IS NOT NULL AND submitted_by = auth.uid())` |
| **feedback_entries** | Admins manage feedback | admin | ALL | `is_admin()` |
| **imports** | Admins manage imports | admin | ALL | `is_admin()` |
| **import_schedule_candidates** | Admins manage candidates | admin | ALL | `is_admin()` |
| **import_award_candidates** | Admins manage candidates | admin | ALL | `is_admin()` |
| **import_validation_issues** | Admins manage issues | admin | ALL | `is_admin()` |
| **import_privacy_skips** | Admins manage skips | admin | ALL | `is_admin()` |
| **import_review_decisions** | Admins manage decisions | admin | ALL | `is_admin()` |
| **settings** | Authenticated users read settings | authenticated | SELECT | `auth.role() = 'authenticated'` |
| **settings** | Admins manage settings | admin | ALL | `is_admin()` |
| **audit_logs** | Admins read audit logs | admin | SELECT | `is_admin()` |

## Security Notes

- `matricId` on projects is classified as **approved public exhibition data** per PDPA policy
- Private fields (personal emails, phone numbers, confidential evaluation scores, internal notes) are protected by RLS
- All write operations on sensitive tables (imports, visits, audit_logs) are restricted to **admin role only**
- Visitor mutations on `student_project_visits` must use RPC functions (direct inserts blocked for non-admins)
- `feedback_entries` can be inserted by **anonymous users** (with validation constraints)
