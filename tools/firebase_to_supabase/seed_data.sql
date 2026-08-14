-- Auto-generated Supabase Seed Migration from Firebase Data
-- Generated on: 2026-08-14T10:38:23.780Z
-- Source: undefined

INSERT INTO public.events (id, slug, title, session_label, start_at, end_at, daily_hours, venue, location_details, map_url, description, status, publication_status, created_at, updated_at) VALUES ('1977e782-430c-5f3f-a6c7-359f74650691', 'fskm-fyp-2026', 'FSKM FYP Expo Hub 2026', 'Semester March - August 2026', '2026-08-06 09:00:00+08', '2026-08-07 17:00:00+08', '9:00 AM - 5:00 PM', 'Lecture Block, FSKM', NULL, NULL, NULL, 'active', 'published', NOW(), NOW()) ON CONFLICT (slug) DO NOTHING;
