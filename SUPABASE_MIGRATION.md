# Supabase Migration Guide — FYP Expo Hub

## Overview

This document describes the complete migration from Google Firebase to Supabase Free Tier for the FYP Expo Hub project. The migration preserves all functionality while eliminating all Firebase dependencies and maintaining a $0 cost baseline.

## Prerequisites

1. A Supabase project at [supabase.com](https://supabase.com)
2. **Project Ref**: `siedglubjcedkbrpdzgi`
3. **Project URL**: `https://siedglubjcedkbrpdzgi.supabase.co`
4. **Anon (public) key**: Obtain from **Project Settings → API → anon service role (JWT)**

## Migration Steps

### Step 1: Configure MCP (if using OpenCode)

Add the Supabase MCP server to `~/.config/opencode/opencode.json`:

```jsonc
{
  "mcp": {
    "supabase": {
      "type": "remote",
      "url": "https://mcp.supabase.com/mcp?project_ref=siedglubjcedkbrpdzgi&features=docs,account,database,debugging,development,functions,branching",
      "enabled": true
    }
  }
}
```

Run `opencode mcp auth supabase` to authenticate.

### Step 2: Apply Database Migrations

```bash
# Link to the project
supabase link --project-ref siedglubjcedkbrpdzgi

# Push all migration files
supabase db push --include-all --yes --linked
```

If the CLI has stale local migration state, apply SQL directly:

```bash
# Or use the MCP SQL tool to execute each migration file in order:
# 1. supabase/migrations/20260814000001_initial_schema.sql
# 2. supabase/migrations/20260814000002_rls_policies.sql
# 3. supabase/migrations/20260814000003_rpc_functions.sql
# 4. supabase/migrations/20260814000004_seed_data.sql
```

### Step 3: Verify Schema

```bash
# Check all tables
supabase db dump --schema-only --linked | grep "CREATE TABLE"

# Or via SQL:
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
```

Expected 19 tables: `profiles`, `events`, `projects`, `booths`, `schedule_items`,
`announcements`, `award_categories`, `award_winners`, `lecturer_assignments`,
`student_project_visits`, `feedback_entries`, `imports`, `import_schedule_candidates`,
`import_award_candidates`, `import_validation_issues`, `import_privacy_skips`,
`import_review_decisions`, `settings`, `audit_logs`.

### Step 4: Create First Admin User

```bash
# In Supabase Studio → Authentication → Users, create a new user
# Then run:
```

```sql
INSERT INTO public.profiles (id, email, display_name, role, is_active)
VALUES ('<user-uuid>', 'admin@yourorg.edu', 'Admin', 'admin', true);
```

### Step 5: Build Flutter Web

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://siedglubjcedkbrpdzgi.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

### Step 6: Deploy (Free Options)

| Platform | Command |
|----------|---------|
| Firebase Hosting (Spark/free) | `firebase deploy --only hosting` |
| Netlify | Drag `build/web/` into Netlify dashboard |
| GitHub Pages | Push `build/web/` to `gh-pages` branch |
| Cloudflare Pages | Connect repo, set build output to `build/web` |

## Rollback Plan

If you need to revert:

1. **Database**: Use Supabase's built-in backup/restore in the dashboard
2. **Application**: Switch `pubspec.yaml` back to Firebase dependencies
3. **Auth**: Recreate Firebase Auth users from Supabase backup
4. See `rollback_plan.md` for detailed steps

## Cost Summary

| Service | Tier | Cost |
|---------|------|------|
| Supabase PostgreSQL | Free (500 MB) | $0 |
| Supabase Auth | Free (50k MAU) | $0 |
| Supabase Storage | Free (1 GB) | $0 |
| Supabase Realtime | Free (200 concurrent) | $0 |
| Hosting | Firebase Spark / Netlify / GitHub Pages | $0 |
| **Total** | | **$0** |
