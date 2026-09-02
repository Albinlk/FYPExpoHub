-- ==============================================================================
-- FYP Expo Hub - Student correction evidence RPC
-- 20260901000004_student_correction_evidence.sql
--
-- The correction lifecycle is: open -> in_progress -> evidence_submitted ->
-- confirmed -> closed. DEF-4 restricted confirm_fyp_corrections to staff only
-- (correct), but no student-facing action remained, so the student corrections
-- page's Confirm button called a function that now always raises 42501.
--
-- This adds submit_correction_evidence(item_id, note, file_url): the student
-- owner of the record acknowledges a correction and moves the item to
-- 'evidence_submitted' for staff review. It mirrors the confirm_* audit + gate
-- conventions:
--   Gate: record owner (student) / coordinator / admin (is_active_fyp_student)
--   Valid transitions: open|in_progress -> evidence_submitted
--   Writes fyp_audit_logs with source='database_rpc'
-- ==============================================================================

create or replace function public.submit_correction_evidence(
  p_correction_item_id uuid,
  p_note text default null,
  p_file_url text default null
)
returns public.fyp_correction_items
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_item public.fyp_correction_items%rowtype;
  v_previous_status text;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_item from public.fyp_correction_items
  where id = p_correction_item_id;
  if not found then
    raise exception 'not-found: Correction item not found.'
      using errcode = 'P0002';
  end if;

  -- Gate: the record's student owner (or coordinator/admin for support).
  if not public.is_active_fyp_student(v_item.fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit correction evidence.'
      using errcode = '42501';
  end if;

  v_previous_status := v_item.status;
  if v_previous_status not in ('open', 'in_progress') then
    raise exception 'failed-precondition: Evidence can only be submitted for open or in-progress corrections.'
      using errcode = '55000';
  end if;

  update public.fyp_correction_items
  set status = 'evidence_submitted',
      updated_at = v_now
  where id = p_correction_item_id
  returning * into v_item;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'correction_evidence_submitted', 'fyp_correction_items', v_item.id,
    jsonb_build_object(
      'correction_item_id', p_correction_item_id,
      'previous_status', v_previous_status,
      'note', left(coalesce(p_note, ''), 500),
      'has_file', p_file_url is not null
    ),
    'database_rpc', v_now
  );

  return v_item;
end;
$$;

revoke execute on function public.submit_correction_evidence(uuid, text, text) from public, anon;
