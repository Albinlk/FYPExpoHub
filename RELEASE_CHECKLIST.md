# Release Checklist — FYP Expo Hub (v2, September 2026)

Supersedes the August 2026 migration checklist. The migration from Firebase
to Supabase is complete; this checklist covers the current combined
Expo Hub + FYPMS release.

## Pre-Release Verification

### 1. Database Schema
- [ ] All migrations in `supabase/migrations/` applied (Expo `20260814*`,
      FYPMS `20260817*`–`20260822*`, security hardening `20260901*`)
- [ ] All **42 tables** exist with RLS enabled (19 Expo + 23 FYPMS)
- [ ] ~55 functions present: policy helpers + ~30 SECURITY DEFINER RPCs
- [ ] All SECURITY DEFINER functions pin `search_path`
- [ ] Storage buckets exist: 4 private FYPMS + `fyp-public-assets`, with
      path-scoped policies (`can_read/write_fyp_storage_path`)

### 2. Security
- [ ] `exec_sql_batch` dropped (arbitrary-SQL backdoor removed)
- [ ] Anon EXECUTE revoked on all mutating RPCs
- [ ] Student direct-UPDATE policies removed (RPC-only edits)
- [ ] `list_fyp_*` helpers gated to coordinator/CSP/admin
- [ ] `finalize_marks` cross-checks the record's course code
- [ ] F14–F16 server-side feature flag verified
- [ ] **All 11 `@fypms.test` demo accounts disabled or password-rotated**
      (see SECURITY.md accepted-risk register — REQUIRED before production)
- [ ] Production anon key rotated

### 3. Application Configuration
- [ ] `pubspec.yaml` — no Firebase dependencies
- [ ] `lib/main.dart` — `Supabase.initialize()` with `--dart-define` creds
- [ ] Build passes: `flutter analyze` (0 errors) + `flutter test` (132 tests)

### 4. CI/CD
- [ ] `.github/workflows/deploy.yml` runs analyze + test gates before build
- [ ] Repo secrets set: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- [ ] Deploy to Pages succeeds; `404.html` SPA fallback present

### 5. Functional Smoke Tests
- [ ] Public site renders offline fallback (Supabase paused)
- [ ] Admin sign-in → CMS pages load
- [ ] Lecturer sign-in → My Visits list + mark/void visit round-trip
- [ ] FYPMS: student record → form submission → supervisor evaluation
- [ ] FYPMS: coordinator expo publication → appears on public `/projects`
- [ ] Excel import → staging → selective publish round-trip

### 6. Privacy & Security (PDPA)
- [ ] `matricId` classified as approved public exhibition metadata
- [ ] Student emails never exposed anonymously (verify with anon-key REST probe)
- [ ] Private report buckets not listable by unauthenticated users
