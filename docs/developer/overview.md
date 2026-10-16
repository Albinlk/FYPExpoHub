# Developer overview

FYP Expo Hub is one **Flutter Web** app on **Supabase** with two products:

| Product | Where | For |
|---|---|---|
| **Exhibition** | `fskmjasinfypexhibition.site` | Public project catalogue, booths, schedule, awards, Past Projects Guide; lecturer booth visits; admin CMS at `/admin` |
| **FYP Workspace (FYPMS)** | `fyp.fskmjasinfypexhibition.site` | CSP600 / CSP650 semester workflow: supervision, forms F1–F16, progress logs, reports, corrections, marks, presentations, expo publication |

The same build is deployed to both hosts; the app decides at runtime which
site it is, and one sign-in works on both.

!!! note "Full developer documentation"
    This page is the public summary. The full developer docs (architecture,
    database, security, RPCs, deployment, testing, runbooks) live in the
    repository under
    [`docs/developer/`](https://github.com/Albinlk/FYPExpoHub/tree/main/docs/developer).

## Stack

| Layer | Technology |
|---|---|
| UI | Flutter (Dart `^3.11`), Flutter Web compiled to Wasm, Material 3 with "Scholar + Lab" tokens (Fraunces, Inter, JetBrains Mono) |
| State | `flutter_riverpod` 3 (Notifier, FutureProvider) |
| Routing | `go_router` with role- and host-aware redirect guards |
| Models | `freezed` + `json_serializable` |
| Backend | Supabase Auth (email + password, PKCE, optional TOTP MFA), Postgres with RLS, Storage, Realtime, one Edge Function |
| Hosting | GitHub Pages (exhibition), Cloudflare Pages (Workspace), both built by GitHub Actions |
| Handbook | MkDocs Material, built into `/handbook/` on both hosts |

## Repository map

```
.
├── lib/
│   ├── main.dart            Supabase init, shared session storage, runApp
│   ├── app/                 router, guards, site_hosts, shells, theme
│   ├── core/                state/ providers, domain/ models + rules,
│   │                        supabase/ services + RPC wrappers, widgets/
│   └── features/            one folder per area: public_*, admin_*,
│                            lecturer_visits, junior_project_guide, fypms
├── supabase/
│   ├── migrations/          every schema change, in order
│   └── functions/           enroll-students Edge Function
├── test/                    unit, widget and route tests
├── web/                     index.html, service worker, fonts, icons
├── docs/                    this handbook (guides/) + developer docs
├── mkdocs.yml               handbook site config
└── .github/workflows/       ci.yml, deploy.yml, uptime-monitor.yml
```

## Tutorial: run it locally

1. Install the Flutter SDK (the version in `.github/workflows/ci.yml`) and
   run `flutter pub get`.
2. Get the Supabase URL and anon key from a maintainer. Never commit them.
3. Run the app:

    ```bash
    flutter run -d chrome --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon-key>
    ```

4. Without the keys the public site still renders from the bundled offline
   dataset (`assets/data/offline_fallback.json`).
5. After changing a `freezed` model, regenerate code:

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

## Tutorial: make a change

1. Branch from `main`.
2. Change the code and add a test next to the closest existing one in `test/`.
3. Check locally:

    ```bash
    flutter analyze
    flutter test
    ```

4. Open a pull request. `ci.yml` runs analyze, tests, a Wasm build and the
   handbook build.
5. Merge (squash). `deploy.yml` deploys both hosts and the handbook.

## Tutorial: change the database

1. Add a new file in `supabase/migrations/` named
   `YYYYMMDDHHMMSS_short_name.sql`. Never edit an applied migration.
2. Put every write behind a `SECURITY DEFINER` function that checks
   `auth.uid()`, the caller's role and the record's state, pins
   `search_path`, and writes an audit row.
3. Enable RLS on any new table and add policies using the existing helpers
   (`can_read_fyp_record`, `is_admin`, `is_fyp_coordinator`, ...).
4. Add a Dart wrapper in `lib/core/supabase/` and a provider in
   `lib/core/state/`.
5. Apply the migration to the live project only after review, then run the
   Supabase security advisor.

## Where to read next

| Topic | Document (repository) |
|---|---|
| How the app is built | [architecture.md](https://github.com/Albinlk/FYPExpoHub/blob/main/docs/developer/architecture.md) |
| Two hosts, guards, sign-in, shared session | [hosts-and-auth.md](https://github.com/Albinlk/FYPExpoHub/blob/main/docs/developer/hosts-and-auth.md) |
| Tables, ER diagrams, buckets, workflow states | [database.md](https://github.com/Albinlk/FYPExpoHub/blob/main/docs/developer/database.md) |
| Every RPC | [rpc-reference.md](https://github.com/Albinlk/FYPExpoHub/blob/main/docs/developer/rpc-reference.md) |
| Deploying and rolling back | [deployment.md](https://github.com/Albinlk/FYPExpoHub/blob/main/docs/developer/deployment.md) |
| Tests | [testing.md](https://github.com/Albinlk/FYPExpoHub/blob/main/docs/developer/testing.md) |
| Design tokens | [design-system.md](https://github.com/Albinlk/FYPExpoHub/blob/main/docs/developer/design-system.md) |
