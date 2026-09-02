-- ==============================================================================
-- FYP Expo Hub - Security Hardening Part 3
-- 20260901000003_security_hardening_3.sql
--
-- Revokes on helper functions inherited from the migration that created them.
--
-- KEEPS anon grants (intentionally) for policy-referenced read-only helpers:
--   is_csp_lecturer(), is_fyp_coordinator(), can_read_fyp_record(),
--   is_active_fyp_student(), is_assigned_to_fyp_record() — RLS policies
--   referencing these functions are evaluated as the querying role (incl.
--   anon); removing EXECUTE would turn empty-result denials into
--   "permission denied for function" errors. These functions return booleans
--   only (false for anon) and cannot leak data.
--
-- REVOKES anon for helpers that are only called *inside* SECURITY DEFINER
--   RPCs / other functions (never referenced directly by a policy), or that
--   return data:
--     can_read_fyp_storage_path / can_write_fyp_storage_path — referenced by
--       storage.objects policies TO authenticated only, so anon never needs
--       them.
--     can_edit_fyp_record, can_manage_fyp_offering,
--       can_publish_fyp_record_to_expo, is_active_profile,
--       has_academic_role_for_programme — never referenced by TO-public
--       policies; called only inside SECURITY DEFINER functions (which
--       execute as postgres).
--   get_content_filtered / get_dashboard_stats / publish_scheduled_content /
--     cleanup_oauth_states — belong to an UNRELATED content-scheduler template
--     sharing this Supabase project (tables: users, content, channels,
--     activities, processing_jobs, schedules, telemetry, site_settings,
--     oauth_states — none used by FYP Expo Hub). publish_scheduled_content is
--     a SECURITY DEFINER state-changer that must not be anon-invocable.
-- ==============================================================================

revoke execute on function public.can_read_fyp_storage_path(text) from public, anon;
revoke execute on function public.can_write_fyp_storage_path(text) from public, anon;
revoke execute on function public.can_edit_fyp_record(uuid) from public, anon;
revoke execute on function public.can_manage_fyp_offering(uuid) from public, anon;
revoke execute on function public.can_publish_fyp_record_to_expo(uuid) from public, anon;
revoke execute on function public.is_active_profile() from public, anon;
revoke execute on function public.has_academic_role_for_programme(text, text) from public, anon;

-- Unrelated content-scheduler template leftovers (see header).
revoke execute on function public.get_content_filtered(uuid, text, integer) from public, anon;
revoke execute on function public.get_dashboard_stats(uuid) from public, anon;
revoke execute on function public.publish_scheduled_content() from public, anon;
revoke execute on function public.cleanup_oauth_states() from public, anon;
