-- ==============================================================================
-- FYP Expo Hub - Security Hardening Part 2
-- 20260901000002_security_hardening_2.sql
--
--   1. CRITICAL Drop exec_sql_batch: leftover from populate_projects scratch
--            migrations. SECURITY DEFINER + EXECUTEs ARBITRARY SQL chunks with
--            NO auth check, NO search_path, and executable by anon -> full
--            database takeover vector. (The 20260822 cleanup dropped exec_sql
--            but missed this one.) App never calls it.
--   2. MED   Revoke anon EXECUTE on pre-existing mutating expo RPCs (each
--            still raises 28000 on null auth.uid()).
--
-- IMPORTANT — functions referenced by RLS policies KEEP their anon grants:
--   RLS policy expressions are evaluated as the *querying role* (including
--   anon for TO PUBLIC policies). If anon lacks EXECUTE on a helper referenced
--   by a policy, queries fail with "permission denied for function" instead
--   of returning an empty result. The following read-only boolean helpers are
--   policy-referenced and are therefore left executable by anon:
--     is_admin(), is_lecturer(), is_editor(), current_user_role(),
--     current_event_is_public(), can_read_assignment(), can_read_project(),
--     is_csp_lecturer(), is_fyp_coordinator(), has_academic_role(),
--     can_read_fyp_record(), is_active_fyp_student(),
--     is_assigned_to_fyp_record()
--   All of them only read the caller's own profiles row / published rows and
--   return a boolean; for anon (auth.uid() = null) they always return false.
-- ==============================================================================

-- 1. Drop the arbitrary-SQL execution backdoor.
drop function if exists public.exec_sql_batch(text[]);

-- 2. Pre-existing mutating/listing expo RPCs: revoke anon.
revoke execute on function public.mark_student_project_visited(uuid, text) from public, anon;
revoke execute on function public.void_student_project_visit(uuid, text) from public, anon;
revoke execute on function public.publish_approved_import_changes(uuid) from public, anon;
revoke execute on function public.create_lecturer_account_profile(uuid, text, text) from public, anon;
revoke execute on function public.update_event_configuration(uuid, jsonb) from public, anon;
revoke execute on function public.review_progress_log(uuid, text, text) from public, anon;
