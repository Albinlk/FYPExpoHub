# Deployment — FYP Expo Hub

## Overview

The FYP Expo Hub is deployed as a **Flutter Web** application on **GitHub Pages**.
The backend is **Supabase** (PostgreSQL with Auth, Realtime, and Row Level Security).

- **Public site**: https://fskmjasinfypexhibition.site (GitHub Pages)
- **Admin CMS**: https://fskmjasinfypexhibition.site/admin — `admin.fskmjasinfypexhibition.site` is a Cloudflare redirect (302) to it
- **Backend**: Supabase project `siedglubjcedkbrpdzgi`

## CI/CD Pipeline

### GitHub Actions Workflow

File: `.github/workflows/deploy.yml`

The workflow triggers on every push to `main` (permissions `contents: read`,
`pages: write`, `id-token: write`; concurrency group `pages` cancels an
in-progress deploy). Third-party actions are pinned to commit SHAs. It
performs:

| # | Step | What it does |
|---|------|--------------|
| 1 | **Checkout** | `actions/checkout` (v4) |
| 2 | **Setup Flutter** | `subosito/flutter-action` (v2), stable channel pinned to Flutter `3.44.7` |
| 3 | **`flutter pub get`** | Install dependencies |
| 4 | **`flutter analyze`** | Gate — strict, any issue fails the deploy |
| 5 | **`flutter test`** | Gate — the full suite must pass |
| 6 | **Build Web** | `flutter build web --release --wasm --base-href "/"` with `--dart-define` credentials from secrets; copies `index.html` → `404.html` (SPA fallback for deep links); stamps the first 12 chars of the commit SHA into `{{BUILD_VERSION}}` in `sw.js` and `flutter_bootstrap.js` so each release gets a fresh service-worker cache |
| 7 | **Upload Artifacts** | `actions/upload-pages-artifact` (v3) with `build/web` |
| 8 | **Deploy to GitHub Pages** | `actions/deploy-pages` (v4) into the `github-pages` environment |

Pull requests to `main` run the same analyze + test gates and a Wasm
smoke build (no credentials, no deploy) in `.github/workflows/ci.yml`, so
web-only breakage is caught before merge.

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `SUPABASE_URL` | The Supabase project URL: `https://siedglubjcedkbrpdzgi.supabase.co` |
| `SUPABASE_ANON_KEY` | The Supabase anon/public key |

To add secrets: GitHub Repo → Settings → Secrets and variables → Actions → New repository secret

### Build Command

```bash
flutter build web --release --wasm \
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

### Supabase Auth settings

The password-reset flow (G-32) emails a recovery link that returns to
`<current origin>/reset-password` (`passwordResetRedirectUrl()` in
`lib/features/admin_auth/password_reset.dart`). Supabase only redirects to
allow-listed URLs, so under **Authentication → URL Configuration →
Redirect URLs** add:

| Redirect URL | Used by |
|---|---|
| `https://fskmjasinfypexhibition.site/reset-password` | "Forgot password?" on `/admin/sign-in` (the shared sign-in page) |
| `https://admin.fskmjasinfypexhibition.site/reset-password` | Admin domain (kept in case the link is built from that origin) |

Without these entries the reset email falls back to the Site URL and the
user never reaches the "set a new password" page. There is no account
lockout or MFA; brute-force protection relies on Supabase Auth's built-in
rate limits.

### Migrations

Migrations live in `supabase/migrations/` (timestamp-prefixed, applied in
order):

```
20260814000001..04  Expo Hub: schema, RLS, RPCs, seed
20260817000001..07  FYPMS: core tables, helpers, RLS, RPCs, storage, seed
20260818/19*        FYPMS: student slice, workflow RPCs, seeds, realtime
20260820000001/02   FYPMS demo seed + realtime publication
20260821*           (live-only populate_projects bulk-import series)
20260822*           Defect fixes (DEF-1..7), auth policies, co-supervisor seed
20260901*           Security hardening (storage path-scoping, RPC gates,
                    exec_sql_batch removal, F14-F16 flag, evidence RPC)
20260902*           Staff directory + roles
20260925*           Audit 2 hardening, published demo accounts disabled
20260926000001..09  Textbook alignment R1-R7/R10 (rubrics, evaluators,
                    course marks, F1, F6, F5, deliverables), workflow
                    fixes, DB hardening
20260926000010..12  R8 F14 special evaluation, R9 exhibition F10, G-25
                    extensions/sessions
20260927000001      G-06 import Replace + staged checks
20260927000002/03   R11 report minimums + REC ethics, supervisor change +
                    PU approval
```

To apply migrations:
```bash
supabase db push
```

> The live project also contains a historical `populate_projects` /
> `exec_sql` migration series applied during the initial bulk import; it has
> been cleaned up (`exec_sql`/`exec_sql_batch` dropped) and is not part of
> the repo's migration set.

### TypeScript Types

Generated types are in `supabase/types.ts`:
```bash
npx supabase gen types typescript --project-id siedglubjcedkbrpdzgi
```

## Domain Configuration

### Custom Domain
- **Public**: `fskmjasinfypexhibition.site` (managed via GitHub Pages, CNAME)
- **Admin**: `admin.fskmjasinfypexhibition.site` — Cloudflare **Redirect Rule** (Hostname equals `admin.fskmjasinfypexhibition.site` → 302 to `https://fskmjasinfypexhibition.site/admin`). It is **not** a GitHub Pages site: a repo's Pages site serves one custom domain, and this repo's is the apex. (Until 2026-09 it pointed at a separate, stale 6 Aug build that never received deploys.)

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
   flutter build web --release --wasm
   # Or re-run the "Deploy Flutter Web to GitHub Pages" workflow for that commit
   ```

### Rolling Back the Database
1. Restore from a Supabase database backup (available in Supabase Studio)
2. Or re-run migrations from a specific point
3. See `MIGRATION_REPORT.md` for details

## Health Checks

### Post-Deployment
- [ ] Public site loads: https://fskmjasinfypexhibition.site
- [ ] Admin sign-in works: https://fskmjasinfypexhibition.site/admin/sign-in (and https://admin.fskmjasinfypexhibition.site redirects there)
- [ ] Supabase Realtime is connected (check browser dev tools → Network → WebSocket)
- [ ] Project data renders on the public site
- [ ] Schedule data renders

### Monitoring
- Supabase Studio: https://supabase.com/project/siedglubjcedkbrpdzgi
- Check for errors in the browser console
- Monitor Supabase log explorer for slow queries or auth errors

## Paused Project Handling

Free-tier Supabase projects are paused after 7 days of inactivity. When paused:
- The Flutter app does not crash: public datasets report `offline` (or
  `failed` if nothing is bundled for them) and show an offline banner or an
  error with Retry
- Public pages still render from the bundled `assets/data/offline_fallback.json`
  (387 projects, 221 booths, 8 schedule items)
- Admin/lecturer features are unavailable until the project is resumed

To resume: Supabase Studio → Project Settings → Resume project
