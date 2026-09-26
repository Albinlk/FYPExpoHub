-- =============================================================================
-- Supervisor change requests and PU approval of nominations (textbook R11,
-- A22 / A27)
--
-- 1. Supervisor change. The textbook discourages it; per the F1 terms it is
--    possible only through the coordinator. There was no flow at all.
--      fyp_supervisor_change_requests
--      request_supervisor_change   the record owner (or its supervisor), with
--                                  a reason and optionally a proposed new
--                                  supervisor; one pending request per record
--      decide_supervisor_change    coordinator; approval reassigns through
--                                  assign_supervisor_to_fyp_record (same
--                                  one-holder and not-the-examiner rules)
-- 2. PU approval. The Programme Unit (PU) head approves or rejects the
--    supervisor / examiner nominations. New academic role `programme_head`
--    (scoped by programme_code; '' = every programme). While a programme has
--    no PU configured nothing changes. Once one exists, a new or re-activated
--    nomination for that programme is `pending` (it still works) until the
--    PU decides; a rejection deactivates it so the coordinator nominates
--    someone else.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- PU role
-- ---------------------------------------------------------------------------
alter table public.profile_academic_roles drop constraint if exists profile_academic_roles_role_code_check;
alter table public.profile_academic_roles add constraint profile_academic_roles_role_code_check
  check (role_code in (
    'student', 'supervisor', 'co_supervisor', 'examiner',
    'csp600_lecturer', 'csp650_lecturer', 'fyp_coordinator', 'programme_head'
  ));

-- Active PU for the programme (a role with programme_code '' covers all).
create or replace function public.is_programme_head(p_programme_code text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_admin() or exists (
    select 1 from public.profile_academic_roles r
    join public.profiles p on p.id = r.profile_id
    where r.profile_id = auth.uid() and r.role_code = 'programme_head' and r.is_active and p.is_active
      and (r.programme_code = '' or upper(r.programme_code) = upper(coalesce(p_programme_code, '')))
  );
$$;

create or replace function public.programme_has_pu(p_programme_code text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profile_academic_roles r
    join public.profiles p on p.id = r.profile_id
    where r.role_code = 'programme_head' and r.is_active and p.is_active
      and (r.programme_code = '' or upper(r.programme_code) = upper(coalesce(p_programme_code, '')))
  );
$$;

revoke execute on function public.is_programme_head(text) from public, anon;
grant execute on function public.is_programme_head(text) to authenticated;
revoke execute on function public.programme_has_pu(text) from public, anon;
grant execute on function public.programme_has_pu(text) to authenticated;

-- ---------------------------------------------------------------------------
-- PU approval on nominations
-- ---------------------------------------------------------------------------
alter table public.fyp_record_assignments
  add column if not exists pu_status text not null default 'approved'
    check (pu_status in ('pending', 'approved', 'rejected')),
  add column if not exists pu_decided_by uuid references public.profiles(id) on delete set null,
  add column if not exists pu_decided_at timestamptz,
  add column if not exists pu_comment text;

create or replace function public.fyp_assignment_pu_pending()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Only a nomination that becomes active (new, re-activated, or a different
  -- lecturer) waits for the PU, and only where a PU is configured.
  if new.is_active and (
    tg_op = 'INSERT' or not old.is_active or old.lecturer_id is distinct from new.lecturer_id
  ) and public.programme_has_pu((select programme_code from public.fyp_records where id = new.fyp_record_id)) then
    new.pu_status := 'pending';
    new.pu_decided_by := null;
    new.pu_decided_at := null;
    new.pu_comment := null;
  end if;
  return new;
end;
$$;

drop trigger if exists fyp_assignment_pu_pending on public.fyp_record_assignments;
create trigger fyp_assignment_pu_pending
  before insert or update of is_active, lecturer_id on public.fyp_record_assignments
  for each row execute function public.fyp_assignment_pu_pending();

-- Pending nominations in the caller's programmes.
create or replace function public.list_pending_nominations()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'assignment_id', a.id,
    'fyp_record_id', r.id,
    'academic_role', a.academic_role,
    'lecturer_id', a.lecturer_id,
    'lecturer_name', lp.display_name,
    'student_name', sp.display_name,
    'matric_id', r.matric_id,
    'programme_code', r.programme_code,
    'course_code', r.current_course_code,
    'project_title', r.project_title,
    'assigned_at', a.assigned_at
  ) order by a.assigned_at), '[]'::jsonb)
  from public.fyp_record_assignments a
  join public.fyp_records r on r.id = a.fyp_record_id
  left join public.profiles lp on lp.id = a.lecturer_id
  left join public.profiles sp on sp.id = r.student_id
  where a.is_active and a.pu_status = 'pending'
    and public.is_programme_head(r.programme_code);
$$;

revoke execute on function public.list_pending_nominations() from public, anon;
grant execute on function public.list_pending_nominations() to authenticated;

create or replace function public.decide_nomination(
  p_assignment_id uuid,
  p_decision text,
  p_comment text default null
)
returns public.fyp_record_assignments
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_a public.fyp_record_assignments%rowtype;
  v_record public.fyp_records%rowtype;
  v_comment text := nullif(btrim(p_comment), '');
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if p_decision not in ('approved', 'rejected') then
    raise exception 'invalid-argument: Decision must be approved or rejected.' using errcode = '22023';
  end if;

  select * into v_a from public.fyp_record_assignments where id = p_assignment_id for update;
  if not found then
    raise exception 'not-found: Nomination not found.' using errcode = 'P0002';
  end if;
  select * into v_record from public.fyp_records where id = v_a.fyp_record_id;

  if not public.is_programme_head(v_record.programme_code) then
    raise exception 'permission-denied: Only the programme''s PU can approve nominations.' using errcode = '42501';
  end if;
  if not v_a.is_active or v_a.pu_status <> 'pending' then
    raise exception 'failed-precondition: This nomination is not awaiting approval.' using errcode = '55000';
  end if;
  if p_decision = 'rejected' and v_comment is null then
    raise exception 'invalid-argument: Give the coordinator a reason when rejecting.' using errcode = '22023';
  end if;

  update public.fyp_record_assignments
  set pu_status = p_decision,
      pu_decided_by = v_uid,
      pu_decided_at = v_now,
      pu_comment = v_comment,
      is_active = case when p_decision = 'rejected' then false else is_active end,
      updated_at = v_now
  where id = p_assignment_id
  returning * into v_a;

  -- A rejected nominee no longer holds the role on the record.
  if p_decision = 'rejected' then
    update public.fyp_records
    set main_supervisor_id = case when v_a.academic_role = 'supervisor' and main_supervisor_id = v_a.lecturer_id then null else main_supervisor_id end,
        co_supervisor_id = case when v_a.academic_role = 'co_supervisor' and co_supervisor_id = v_a.lecturer_id then null else co_supervisor_id end,
        examiner_id = case when v_a.academic_role = 'examiner' and examiner_id = v_a.lecturer_id then null else examiner_id end,
        updated_at = v_now
    where id = v_a.fyp_record_id;
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'nomination_' || p_decision, 'fyp_record_assignments', p_assignment_id,
    jsonb_build_object('fyp_record_id', v_a.fyp_record_id, 'academic_role', v_a.academic_role,
                       'lecturer_id', v_a.lecturer_id, 'comment', v_comment),
    'database_rpc', v_now);
  return v_a;
end;
$$;

revoke execute on function public.decide_nomination(uuid, text, text) from public, anon;
grant execute on function public.decide_nomination(uuid, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Supervisor change requests
-- ---------------------------------------------------------------------------
create table if not exists public.fyp_supervisor_change_requests (
  id uuid primary key default gen_random_uuid(),
  fyp_record_id uuid not null references public.fyp_records(id) on delete cascade,
  requested_by uuid not null references public.profiles(id),
  current_supervisor_id uuid references public.profiles(id) on delete set null,
  proposed_supervisor_id uuid references public.profiles(id) on delete set null,
  reason text not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  decided_by uuid references public.profiles(id) on delete set null,
  decided_at timestamptz,
  decision_comment text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists fyp_supervisor_change_one_pending
  on public.fyp_supervisor_change_requests (fyp_record_id) where status = 'pending';

alter table public.fyp_supervisor_change_requests enable row level security;
drop policy if exists "Supervisor changes read by record participants" on public.fyp_supervisor_change_requests;
create policy "Supervisor changes read by record participants"
  on public.fyp_supervisor_change_requests for select
  to authenticated
  using (public.can_read_fyp_record(fyp_record_id));
revoke all on public.fyp_supervisor_change_requests from anon;
revoke insert, update, delete, truncate on public.fyp_supervisor_change_requests from authenticated;
grant select on public.fyp_supervisor_change_requests to authenticated;

create or replace function public.request_supervisor_change(
  p_fyp_record_id uuid,
  p_reason text,
  p_proposed_supervisor_id uuid default null
)
returns public.fyp_supervisor_change_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_record public.fyp_records%rowtype;
  v_result public.fyp_supervisor_change_requests%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  select * into v_record from public.fyp_records where id = p_fyp_record_id for update;
  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;
  if not (public.is_active_fyp_student(p_fyp_record_id) or v_record.main_supervisor_id = v_uid) then
    raise exception 'permission-denied: Only the student or the current supervisor can ask for a change.' using errcode = '42501';
  end if;
  if v_record.main_supervisor_id is null then
    raise exception 'failed-precondition: There is no supervisor to change yet.' using errcode = '55000';
  end if;
  if nullif(btrim(p_reason), '') is null or length(btrim(p_reason)) < 20 then
    raise exception 'invalid-argument: Explain the reason (at least 20 characters).' using errcode = '22023';
  end if;
  if p_proposed_supervisor_id is not null and (
    p_proposed_supervisor_id = v_record.main_supervisor_id
    or p_proposed_supervisor_id = v_record.examiner_id
    or not exists (
      select 1 from public.profile_academic_roles r join public.profiles p on p.id = r.profile_id
      where r.profile_id = p_proposed_supervisor_id and r.role_code = 'supervisor' and r.is_active and p.is_active
    )
  ) then
    raise exception 'invalid-argument: Propose an active supervisor other than the current supervisor and examiner.' using errcode = '22023';
  end if;
  if exists (select 1 from public.fyp_supervisor_change_requests where fyp_record_id = p_fyp_record_id and status = 'pending') then
    raise exception 'already-exists: A supervisor change request is already pending.' using errcode = '23505';
  end if;

  insert into public.fyp_supervisor_change_requests (
    fyp_record_id, requested_by, current_supervisor_id, proposed_supervisor_id, reason, created_at, updated_at
  ) values (
    p_fyp_record_id, v_uid, v_record.main_supervisor_id, p_proposed_supervisor_id, btrim(p_reason), v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'supervisor_change_requested', 'fyp_supervisor_change_requests', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'proposed_supervisor_id', p_proposed_supervisor_id),
    'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.request_supervisor_change(uuid, text, uuid) from public, anon;
grant execute on function public.request_supervisor_change(uuid, text, uuid) to authenticated;

create or replace function public.decide_supervisor_change(
  p_request_id uuid,
  p_decision text,
  p_comment text default null,
  p_new_supervisor_id uuid default null
)
returns public.fyp_supervisor_change_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_req public.fyp_supervisor_change_requests%rowtype;
  v_new uuid;
  v_comment text := nullif(btrim(p_comment), '');
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the coordinator decides supervisor changes.' using errcode = '42501';
  end if;
  if p_decision not in ('approved', 'rejected') then
    raise exception 'invalid-argument: Decision must be approved or rejected.' using errcode = '22023';
  end if;

  select * into v_req from public.fyp_supervisor_change_requests where id = p_request_id for update;
  if not found then
    raise exception 'not-found: Supervisor change request not found.' using errcode = 'P0002';
  end if;
  if v_req.status <> 'pending' then
    raise exception 'failed-precondition: This request has already been %.', v_req.status using errcode = '55000';
  end if;

  if p_decision = 'rejected' then
    if v_comment is null then
      raise exception 'invalid-argument: Give a reason when rejecting.' using errcode = '22023';
    end if;
  else
    v_new := coalesce(p_new_supervisor_id, v_req.proposed_supervisor_id);
    if v_new is null then
      raise exception 'invalid-argument: Choose the new supervisor.' using errcode = '22023';
    end if;
    -- Same rules as any assignment (active staff, one holder, not the examiner).
    perform public.assign_supervisor_to_fyp_record(v_req.fyp_record_id, v_new, 'supervisor');
  end if;

  update public.fyp_supervisor_change_requests
  set status = p_decision,
      proposed_supervisor_id = coalesce(v_new, proposed_supervisor_id),
      decided_by = v_uid,
      decided_at = v_now,
      decision_comment = v_comment,
      updated_at = v_now
  where id = p_request_id
  returning * into v_req;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'supervisor_change_' || p_decision, 'fyp_supervisor_change_requests', p_request_id,
    jsonb_build_object('fyp_record_id', v_req.fyp_record_id, 'new_supervisor_id', v_new),
    'database_rpc', v_now);
  return v_req;
end;
$$;

revoke execute on function public.decide_supervisor_change(uuid, text, text, uuid) from public, anon;
grant execute on function public.decide_supervisor_change(uuid, text, text, uuid) to authenticated;
