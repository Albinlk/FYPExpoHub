# Architecture — FYP Expo Hub

## Overview

FYP Expo Hub is a **Flutter Web** application backed by **Supabase**
(PostgreSQL + Auth + Realtime). The architecture is feature-first with a
layered service abstraction.

```
┌─────────────────────────────────────────────────┐
│                  User Browser                  │
│           (Flutter Web PWA — SPA)               │
└──────────────────┬──────────────────────────────┘
                   │
                   │ HTTPS / WebSocket (Realtime)
                   │
┌──────────────────┴──────────────────────────────┐
│                  Supabase Cloud                  │
│  ┌──────────────┐  ┌────────────────────┐        │
│  │ Supabase Auth│  │ Supabase Postgres  │        │
│  │  (Auth UID)  │  │   (with RLS)       │        │
│  └──────────────┘  └────────────────────┘        │
│                        │                         │
│                    Realtime                     │
│                      Stream                      │
└─────────────────────────────────────────────────┘
```

## Layers

### 1. Presentation Layer
- **Framework**: Flutter Web (Dart)
- **Routing**: `go_router` — SPA with redirect guards
- **UI**: Material 3 with custom `DesignSystem` tokens

### 2. State Management Layer
- **Framework**: `flutter_riverpod` v3
- **Pattern**: `Notifier` + `StreamProvider` / `FutureProvider`
- **Notifiers** (9 files in `lib/core/state/`):
  - `event_notifier.dart`
  - `project_notifier.dart`
  - `schedule_notifier.dart`
  - `booth_notifier.dart`
  - `announcement_notifier.dart`
  - `award_notifier.dart`
  - `visit_notifier.dart`
  - `auth_notifier.dart`
  - `import_notifier.dart`

### 3. Domain Layer
- **Models**: `freezed` sealed classes with `json_serializable`
- **Location**: `lib/core/domain/models/`
- **Key models**: `Project`, `ScheduleItem`, `Booth`, `Announcement`,
  `AwardWinner`, `Event`, `StudentVisit`, `ImportRecord`

### 4. Data Layer

#### 4.1 Supabase Service
- **Provider**: `lib/core/supabase/supabase_client_provider.dart`
- **Services** (5 files in `lib/core/supabase/`):
  - `supabase_service.dart` — generic table operations
  - `supabase_event_service.dart` — events
  - `supabase_project_service.dart` — projects
  - `supabase_visit_service.dart` — visits
  - `supabase_import_service.dart` — imports

#### 4.2 Stream Providers
Each notifier subscribes to a Supabase Realtime stream:
```dart
Stream<List<Project>> projectStream = supabase
  .from('projects')
  .stream(['id'])
  .map((rows) => rows.map((r) => Project.fromJson(r)).toList());
```

#### 4.3 Offline Fallback
- **Seed data**: `lib/core/data/ExcelData`
- **Pattern**: Providers seed with offline data, then swap to Supabase
  data when the stream connects
- **Paused project**: Shows maintenance dialog instead of crashing

### 5. Backend Layer

#### 5.1 Supabase Postgres (19 tables)
| Category | Tables |
|----------|--------|
| Public (published) | events, projects, schedule_items, booths, announcements, award_categories, award_winners |
| Auth-related | profiles |
| Admin/Import | imports, import_schedule_candidates, import_award_candidates, import_validation_issues, import_privacy_skips, import_review_decisions |
| Tracking | lecturer_assignments, student_project_visits, audit_logs |
| Config | settings |

#### 5.2 Security (RLS)
- All tables have RLS enabled
- 6 helper functions (SECURITY DEFINER)
- 23 RLS policies
- See `SUPABASE_RLS_POLICIES.md`

#### 5.3 RPC Functions
- 5 SECURITY DEFINER functions
- Critical mutations go through RPCs (not direct table writes)
- See `DATABASE_FUNCTIONS.md`

## Deployment Targets

| Target | Service | Purpose |
|--------|---------|---------|
| `fskmjasinfypexhibition.site` | GitHub Pages | Public-facing site |
| `admin.fskmjasinfypexhibition.site` | GitHub Pages | Admin CMS |
| `siedglubjcedkbrpdzgi.supabase.co` | Supabase | Backend (DB + Auth) |

## Key Design Decisions

### 1. Client-Side Excel Parsing
Excel files are parsed in the browser using the Dart `excel` package.
No server-side processing (Edge Functions) is needed — this reduces
cost and complexity while staying within Free Tier limits.

### 2. No Raw Excel Storage
Raw `.xlsx` files are never stored on Supabase Storage. Only parsed
candidate data is staged in the database. This avoids exceeding the
1 GB free storage limit.

### 3. RPC Functions for Mutations
Sensitive operations (visit marking, import publishing, profile creation)
go through PostgreSQL functions rather than direct table writes. This
centralizes validation logic and provides an audit trail.

### 4. Offline-First Design
The app uses a "seed-and-swap" pattern: providers start with bundled
offline data and seamlessly switch to Supabase when the connection
is established. This ensures the public site is always functional.

### 5. RBAC via Database Roles
User roles (`admin`, `lecturer`) are stored in `profiles.role`, not in
Supabase Auth metadata. This allows admins to change roles without
re-authentication and supports audit logging.

## Data Flow

```
[User Action]
    ↓
[UI Widget] → calls → [Riverpod Notifier]
    ↓                          ↓
[StreamProvider] ← subscribes ← [Supabase Stream]
    ↓
[Supabase Realtime] → [Postgres Table (with RLS)]
    ↓
[Auth UID] → [profiles.role check] → [RLS Policy] → [Access granted/denied]
```

For mutations:
```
[UI Action]
    ↓
[Notifier method]
    ↓
[Supabase.client.rpc('function_name')]
    ↓
[SECURITY DEFINER function]
    ↓
[RLS validation + business rules + audit log]
    ↓
[Response → Notifier → UI update]
```
