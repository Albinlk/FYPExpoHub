-- Supervisor approval of the final report (portal plan P12).
--
-- FSKM handbook, Table 2.1 #49-#50 / Table 2.3 #28-#29: after the examiner
-- confirms the corrections (F12), the main supervisor signs the "Supervisor
-- Approval" page before the final report is bound and deliverables are
-- collected. The system tracked F12 but not this approval. This adds the
-- approval (who and when) and an RPC the record's supervisor calls once every
-- correction item is confirmed or closed. It is recorded, not enforced as a
-- gate, so work already in progress is not blocked.

alter table public.fyp_records
  add column if not exists supervisor_approved_at timestamptz,
  add column if not exists supervisor_approved_by uuid references public.profiles(id);

create or replace function public.approve_final_report(p_fyp_record_id uuid)
returns public.fyp_records
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_record public.fyp_records%rowtype;
  v_open integer;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: Record not found.' using errcode = 'P0002';
  end if;

  if v_record.current_course_code is distinct from 'CSP650' then
    raise exception 'failed-precondition: Final report approval is a CSP650 step.' using errcode = '55000';
  end if;

  if not public.is_assigned_to_fyp_record(p_fyp_record_id, 'supervisor') then
    raise exception 'permission-denied: Only the student''s supervisor approves the final report.'
      using errcode = '42501';
  end if;

  select count(*) into v_open
    from public.fyp_correction_items c
    where c.fyp_record_id = p_fyp_record_id and c.status not in ('confirmed', 'closed');
  if v_open > 0 then
    raise exception 'failed-precondition: % correction item(s) are not confirmed yet (F12).', v_open
      using errcode = '55000';
  end if;

  update public.fyp_records
    set supervisor_approved_at = v_now, supervisor_approved_by = v_uid, updated_at = v_now
    where id = p_fyp_record_id
    returning * into v_record;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'final_report_approved', 'fyp_records', p_fyp_record_id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id), 'database_rpc', v_now
  );

  return v_record;
end;
$$;

revoke execute on function public.approve_final_report(uuid) from public, anon;
grant execute on function public.approve_final_report(uuid) to authenticated;
