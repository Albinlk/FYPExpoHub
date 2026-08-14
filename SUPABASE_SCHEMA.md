# Supabase Schema Reference — FYP Expo Hub

## Project Details
- **Project Ref**: `siedglubjcedkbrpdzgi`
- **URL**: `https://siedglubjcedkbrpdzgi.supabase.co`
- **Region**: Default (Free Tier)

## Tables (19)

### 1. profiles
User profiles linked to Supabase Auth (`auth.users`).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, FK → auth.users(id), ON DELETE CASCADE | Auth user ID |
| `email` | `text` | UNIQUE, NOT NULL | User email |
| `display_name` | `text` | NOT NULL | Display name |
| `role` | `text` | NOT NULL, CHECK ('admin', 'lecturer') | User role |
| `is_active` | `boolean` | NOT NULL, DEFAULT true | Soft delete flag |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Created timestamp |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Updated timestamp |

### 2. events
Exhibition events.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Event UUID |
| `slug` | `text` | UNIQUE, NOT NULL | URL-friendly slug |
| `title` | `text` | NOT NULL | Event title |
| `session_label` | `text` | — | e.g. "Semester March - August 2026" |
| `start_at` | `timestamptz` | NOT NULL | Event start |
| `end_at` | `timestamptz` | NOT NULL | Event end |
| `daily_hours` | `text` | — | e.g. "9:00 AM - 5:00 PM" |
| `venue` | `text` | — | Venue name |
| `location_details` | `text` | — | Detailed location |
| `map_url` | `text` | — | Google Maps URL |
| `description` | `text` | — | Event description |
| `objectives` | `jsonb` | NOT NULL, DEFAULT '[]' | List of objectives |
| `status` | `text` | DEFAULT 'active', CHECK | 'draft'\|'upcoming'\|'active'\|'completed'\|'archived' |
| `publication_status` | `text` | DEFAULT 'published', CHECK | 'draft'\|'published'\|'archived' |
| `hero_image_url` | `text` | — | Hero image path |
| `poster_url` | `text` | — | Poster image path |
| `public_contact_email` | `text` | — | Contact email |
| `faq_items` | `jsonb` | NOT NULL, DEFAULT '[]' | FAQ Q&A list |
| `updated_by` | `uuid` | FK → profiles(id) | Last editor |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Created timestamp |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Updated timestamp |
| | | `chk_events_time_order` | CHECK (end_at > start_at) |

### 3. projects
FYP projects exhibited at the event.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Project UUID |
| `event_id` | `uuid` | NOT NULL, FK → events(id) | Parent event |
| `slug` | `text` | NOT NULL, UNIQUE(event_id) | URL slug |
| `title` | `text` | NOT NULL | Project title |
| `matric_id` | `text` | — | Student matric number (public exhibition data) |
| `team_display_name` | `text` | — | Team display name |
| `programme_code` | `text` | — | e.g. "CS230" |
| `programme_name` | `text` | — | Programme name |
| `short_description` | `text` | — | Short description |
| `abstract` | `text` | — | Project abstract |
| `category` | `text` | — | Project category |
| `tech_tags` | `jsonb` | NOT NULL, DEFAULT '[]' | Technology tags |
| `student_team` | `jsonb` | NOT NULL, DEFAULT '[]' | Team members |
| `supervisor_display_name` | `text` | — | Supervisor name |
| `examiner_display_name` | `text` | — | Examiner name |
| `booth_id` | `uuid` | FK → booths(id) | Assigned booth |
| `booth_number` | `text` | — | Booth number |
| `booth_zone` | `text` | — | Booth zone |
| `presentation_day` | `text` | — | Presentation day label |
| `demo_url` | `text` | — | Demo link |
| `video_url` | `text` | — | Video link |
| `repository_url` | `text` | — | GitHub/GitLab link |
| `cover_image_url` | `text` | — | Cover image path |
| `featured` | `boolean` | NOT NULL, DEFAULT false | Featured flag |
| `industry_candidate` | `boolean` | NOT NULL, DEFAULT false | Industry candidate flag |
| `publication_status` | `text` | DEFAULT 'published', CHECK | 'draft'\|'published'\|'archived' |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Created timestamp |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Updated timestamp |

### 4–19. Remaining Tables

| Table | Key Columns | Description |
|-------|-------------|-------------|
| `booths` | id, event_id, booth_number, zone, status | Exhibition booths |
| `schedule_items` | id, event_id, event_date, start_at, end_at, title, access_type | Event schedule |
| `announcements` | id, event_id, title, body, is_pinned, published_at | Public announcements |
| `award_categories` | id, event_id, title, sort_order, status | Award categories |
| `award_winners` | id, event_id, category_id, project_id, title | Award winners |
| `lecturer_assignments` | id, event_id, project_id, lecturer_id, role, status | Lecturer-project assignments |
| `student_project_visits` | id, event_id, project_id, assignment_id, lecturer_id, status, visited_at | Visit tracking |
| `feedback_entries` | id, event_id, subject, message, rating, status | Visitor feedback |
| `imports` | id, event_id, file_name, status, summary | Import job tracking |
| `import_schedule_candidates` | id, import_id, row_number, start_at, end_at, title | Staging: schedule |
| `import_award_candidates` | id, import_id, row_number, award_category, project_title | Staging: awards |
| `import_validation_issues` | id, import_id, worksheet_name, row_number, severity, message | Import errors |
| `import_privacy_skips` | id, import_id, sheet_name, row_number, field_name, reason | Skipped private fields |
| `import_review_decisions` | id, import_id, candidate_id, action, reviewed_by | Review decisions |
| `settings` | key (PK), value (jsonb), updated_by | App settings |
| `audit_logs` | id, actor_uid, action, target_type, metadata_safe | Audit trail |

## Indexes

| Index | Table | Columns |
|-------|-------|---------|
| `idx_projects_event_publication` | projects | event_id, publication_status |
| `idx_projects_slug` | projects | slug |
| `idx_booths_event` | booths | event_id, status |
| `idx_schedule_event_date` | schedule_items | event_id, event_date, start_at |
| `idx_announcements_event` | announcements | event_id, is_pinned, created_at DESC |
| `idx_award_winners_event` | award_winners | event_id, publication_status |
| `idx_lecturer_assignments_lecturer` | lecturer_assignments | lecturer_id, status |
| `idx_lecturer_assignments_project` | lecturer_assignments | project_id, role |
| `idx_visits_event_project` | student_project_visits | event_id, project_id |
| `idx_visits_lecturer` | student_project_visits | lecturer_id, status |
| `idx_feedback_event` | feedback_entries | event_id, status, created_at DESC |
| `idx_imports_uploaded_by` | imports | uploaded_by, created_at DESC |
| `idx_audit_logs_event_created` | audit_logs | event_id, created_at DESC |

## Constraints

- `chk_events_time_order`: events.end_at > events.start_at
- `chk_schedule_time_order`: schedule_items.end_at > schedule_items.start_at
- FK cascade from events → booths, schedule_items, announcements, projects, etc.
- `unique (event_id, slug)` on projects
- `unique (event_id, booth_number)` on booths
- `unique (event_id, project_id, lecturer_id, role)` on lecturer_assignments
- `unique (event_id, project_id, lecturer_id, visit_role)` on student_project_visits
