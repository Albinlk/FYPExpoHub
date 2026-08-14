-- Rollback Plan: Undo FYP Expo Hub Firebase to Supabase Migration
-- Generated on: 2026-08-14T10:38:23.781Z

-- Re-run the original migration SQL to restore
-- DELETE FROM public.events WHERE slug = 'fskm-fyp-2026';
-- DROP TABLE IF EXISTS ... (list all dropped tables)

-- To fully reset, run:
-- supabase db reset --linked
-- supabase db push
