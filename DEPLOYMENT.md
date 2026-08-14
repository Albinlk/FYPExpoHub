# Deployment — FYP Expo Hub

## Overview

The FYP Expo Hub is deployed as a **Flutter Web** application on **GitHub Pages**.
The backend is **Supabase** (PostgreSQL with Auth, Realtime, and Row Level Security).

- **Public site**: https://fskmjasinfypexhibition.site (GitHub Pages)
- **Admin CMS**: https://admin.fskmjasinfypexhibition.site (same GitHub Pages deployment)
- **Backend**: Supabase project `siedglubjcedkbrpdzgi`

## CI/CD Pipeline

### GitHub Actions Workflow

File: `.github/workflows/deploy.yml`

The workflow triggers on every push to `main` and performs:

1. **Checkout** code from the repository
2. **Setup Flutter** SDK (web toolchain)
3. **Cache** pub cache and build output
4. **`flutter pub get`** — install dependencies
5. **`flutter build web --release`** — build the web app with `--dart-define` credentials
6. **Copy `index.html` → `404.html`** — SPA fallback for deep links
7. **Deploy to GitHub Pages** via `peaceiris/actions-gh-pages` action

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `SUPABASE_URL` | The Supabase project URL: `https://siedglubjcedkbrpdzgi.supabase.co` |
| `SUPABASE_ANON_KEY` | The Supabase anon/public key |

To add secrets: GitHub Repo → Settings → Secrets and variables → Actions → New repository secret

### Build Command

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL='https://siedglubjcedkbrpdzgi.supabase.co' \
  --dart-define=SUPABASE_ANON_KEY='<your-anon-key>' \
  --base-href '/'
```

## Environment Configuration

### Production (CI/CD)
Credentials are injected at build time via GitHub Actions secrets.
No `.env` file is needed in CI.

### Local Development
Create a local `.env` file (gitignored):
```env
SUPABASE_URL=https://siedglubjcedkbrpdzgi.supabase.co
SUPABASE_ANON_KEY=<your-anon-key-from-supabase-studio>
```

Run locally:
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL='https://siedglubjcedkbrpdzgi.supabase.co' \
  --dart-define=SUPABASE_ANON_KEY='<your-anon-key>'
```

## Supabase Configuration

### Project Settings
- **Project**: `siedglubjcedkbrpdzgi` (My Project)
- **Region**: Default (Free Tier)
- **Auth**: Email/password provider enabled
- **Database**: PostgreSQL with all migrations applied

### Migrations

Migrations live in `supabase/migrations/`:
```
01_initial_schema.sql       — 19 tables, indexes, constraints
02_rls_policies.sql         — RLS policies, helper functions
03_rpc_functions.sql        — RPC functions (SECURITY DEFINER)
04_seed_data.sql            — Seed data (settings, events)
```

To apply migrations locally:
```bash
supabase db push
```

### TypeScript Types

Generated types are in `supabase/types.ts`:
```bash
npx supabase gen types typescript --project-id siedglubjcedkbrpdzgi
```

## Domain Configuration

### Custom Domain
- **Public**: `fskmjasinfypexhibition.site` (managed via GitHub Pages, CNAME)
- **Admin**: `admin.fskmjasinfypexhibition.site` (managed via GitHub Pages, CNAME)

### SPA Handling
- `404.html` is copied from `index.html` to handle client-side routing
- `go_router` handles all route matching client-side

## Rollback Procedure

### Rolling Back a Deployment
1. Revert the git commit / PR
2. GitHub Actions will rebuild and redeploy automatically
3. Or manually deploy a previous build:
   ```bash
   git checkout <previous-commit>
   flutter build web --release
   # Upload build/web to GitHub Pages
   ```

### Rolling Back the Database
1. Restore from a Supabase database backup (available in Supabase Studio)
2. Or re-run migrations from a specific point
3. See `MIGRATION_REPORT.md` for details

## Health Checks

### Post-Deployment
- [ ] Public site loads: https://fskmjasinfypexhibition.site
- [ ] Admin sign-in works: https://admin.fskmjasinfypexhibition.site/admin/sign-in
- [ ] Supabase Realtime is connected (check browser dev tools → Network → WebSocket)
- [ ] Project data renders on the public site
- [ ] Schedule data renders

### Monitoring
- Supabase Studio: https://supabase.com/project/siedglubjcedkbrpdzgi
- Check for errors in the browser console
- Monitor Supabase log explorer for slow queries or auth errors

## Paused Project Handling

Free-tier Supabase projects are paused after 7 days of inactivity. When paused:
- The Flutter app shows a maintenance dialog (not a crash)
- Public pages still render from offline seed data
- Admin/lecturer features are unavailable until the project is resumed

To resume: Supabase Studio → Project Settings → Resume project
