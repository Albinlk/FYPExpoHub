# Supabase Free Tier Limits — FYP Expo Hub

## Project: `siedglubjcedkbrpdzgi`
- URL: `https://siedglubjcedkbrpdzgi.supabase.co`
- Region: Default (Global Free Tier)
- Tier: **Free**

## Component Breakdown

| Service | Free Tier | Current Usage | Limit |
|---------|-----------|---------------|-------|
| **PostgreSQL** | 500 MB | ~0.1 MB | 500 MB |
| **Database Auth** | 50k MAU | 0 | 50k MAU |
| **Email + SMS** | 500 emails/month | 0 | 500/month |
| **Storage** | 1 GB | 0 bytes | 1 GB |
| **Storage Bandwidth** | 1 GB/month | 0 | 1 GB/month |
| **Storage Operations** | 2M/month | 0 | 2M/month |
| **Realtime** | 200 concurrent | 0 | 200 concurrent |
| **Auth Tokens** | 50k MAU | 0 | 50k MAU |
| **Database API Requests** | — | — | — |

## Schema Data Footprint

The initial schema (19 tables) uses minimal space:

| Table | Estimated Rows | Estimated Size |
|-------|---------------|----------------|
| `events` | 1 | < 1 KB |
| `settings` | 2 | < 1 KB |
| `profiles` | 0-50 | ~1 KB per row |
| `projects` | 0-500 | ~2 KB per row (with JSON fields) |
| `booths` | 0-200 | ~1 KB per row |
| `schedule_items` | 0-50 | ~1 KB per row |
| `announcements` | 0-50 | ~2 KB per row |
| `award_categories` | 0-20 | ~1 KB per row |
| `award_winners` | 0-20 | ~1 KB per row |
| `lecturer_assignments` | 0-500 | ~500 bytes per row |
| `student_project_visits` | 0-500 | ~1 KB per row |
| `feedback_entries` | 0-1000 | ~1 KB per row |
| `imports` | 0-50 | ~1 KB per row |
| `import_*` (6 tables) | 0-5000 | ~500 bytes per row |
| `audit_logs` | 0-5000 | ~1 KB per row |
| **Total Estimated** | <10,000 | <50 MB |

## Usage Optimizations

1. **No raw Excel files stored** — Parsing is client-side; only structured
   candidate rows are stored, keeping storage usage minimal.
2. **Pagination** — All frontend queries use `LIMIT/OFFSET` to avoid loading
   all records at once.
3. **Selective Realtime** — Only subscribes to announcements and visit updates,
   not all tables.
4. **Indexed queries** — All frequently-queried fields have composite indexes
   to minimize database load.
5. **Public CDN** — Project images and static assets served via external
   CDN, not Supabase Storage.

## Cost Risk Mitigation

- **Email limits**: Use a transactional email service (e.g., Brevo) for
  high-volume emails. Supabase free tier is for auth emails only.
- **Storage**: No large binary data stored in Supabase Storage.
- **Bandwidth**: Static assets served from CDN; app code from
  GitHub Pages (100 GB bandwidth on free plan).
- **Database connections**: Supabase free tier supports 50 concurrent
  connections — adequate for a single-event exhibition.
- **Auth**: PKCE auth flow used (no server-side session management needed).

## Paused Project Recovery

Free-tier Supabase projects are **paused** after 7 days of inactivity and
**deleted** after 90 days. When paused:
- The Flutter Web app shows a maintenance dialog instead of crashing
- All data and schema are preserved
- The project can be resumed from the Supabase dashboard

See `lib/app/widgets/public_shell.dart` for the paused-project handling
logic.
