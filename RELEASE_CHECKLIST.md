# Release Checklist — FYP Expo Hub Supabase Migration

## Pre-Release Verification

### 1. Database Schema
- [ ] All 4 migrations applied in order: `20260814000001` → `20260814000004`
- [ ] Migration tracking table created: `supabase_migrations.schema_migrations`
- [ ] All 19 tables exist: profiles, events, projects, booths, schedule_items, announcements, award_categories, award_winners, lecturer_assignments, student_project_visits, feedback_entries, imports, import_schedule_candidates, import_award_candidates, import_validation_issues, import_privacy_skips, import_review_decisions, settings, audit_logs
- [ ] All 19 tables have RLS enabled
- [ ] All 6 helper functions exist (is_admin, is_lecturer, current_user_role, current_event_is_public, can_read_project, can_read_assignment)
- [ ] All 5 RPC functions exist (mark_student_project_visited, void_student_project_visit, publish_approved_import_changes, create_lecturer_account_profile, update_event_configuration)
- [ ] All RPC functions use `SECURITY DEFINER`
- [ ] All 33 RLS policies created (across all 19 tables)
- [ ] Seed data inserted: settings (2 rows), events (1 row with slug 'fskm-fyp-2026')

### 2. Application Configuration
- [ ] `pubspec.yaml` — `supabase_flutter: ^2.8.4` and `excel: ^4.0.6` present
- [ ] `pubspec.yaml` — no Firebase dependencies (firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_app_check, firebase_analytics)
- [ ] `lib/main.dart` — `Supabase.initialize()` with `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `--dart-define`
- [ ] `lib/core/supabase/` — 5 service files present
- [ ] `lib/core/state/state_providers.dart` — all 9 Riverpod notifiers refactored
- [ ] Firebase files deleted: `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `storage.rules`, `lib/core/firebase/`, `lib/firebase_options.dart`, `functions/`

### 3. Environment Variables
- [ ] `SUPABASE_URL=https://siedglubjcedkbrpdzgi.supabase.co`
- [ ] `SUPABASE_ANON_KEY` set from project API settings
- [ ] `SCRIPTS/.env` — updated with Supabase credentials (Firebase credentials redacted)

### 4. Privacy & Security
- [ ] `matricId` classified as approved public exhibition metadata
- [ ] Private fields (email, phone, marks, admin notes) protected by RLS
- [ ] No raw Excel files stored on Supabase Storage
- [ ] PDPA policy text updated in `faq_privacy_page.dart`

### 5. Testing
- [x] `flutter analyze` — 0 errors, 0 warnings (103 info-level lints remain: deprecated withOpacity/value, style)
- [x] `flutter test` — all tests pass (15/15)
- [x] `flutter build web --release` — builds successfully (verified with Supabase dart-defines)
- [ ] Web app loads and displays public content without authentication
- [ ] Admin login works with Supabase Auth
- [ ] Lecturer visit tracking (mark/void) works via RPC functions
- [ ] Excel import parses and previews correctly (browser-side)
- [ ] Paused-project error handling shows maintenance dialog

### 6. Documentation
- [ ] `README.md` — updated with Supabase references
- [ ] `SUPABASE_MIGRATION.md` — created with migration guide
- [ ] `SUPABASE_SCHEMA.md` — database schema reference
- [ ] `SUPABASE_RLS_POLICIES.md` — RLS policy documentation
- [ ] `DATABASE_FUNCTIONS.md` — RPC function documentation
- [ ] `FREE_TIER_LIMITS.md` — cost and limit analysis
- [ ] `MIGRATION_REPORT.md` — migration status report
- [ ] `RELEASE_CHECKLIST.md` — this file
- [ ] `DEPLOYMENT.md` — deployment instructions
- [ ] `ADMIN_GUIDE.md` — admin CMS usage guide
- [ ] `TESTING.md` — testing documentation
- [ ] `IMPORT_PIPELINE.md` — Excel import workflow
- [ ] `ARCHITECTURE.md` — system architecture overview

## Post-Release
- [ ] Verify public site: https://fskmjasinfypexhibition.site
- [ ] Verify admin CMS login works
- [ ] Verify lecturer visit tracking works
- [ ] Verify Excel import works with sample file
- [ ] Verify feedback form works (anonymous + authenticated)
- [ ] Check Supabase dashboard for API usage within free tier limits
