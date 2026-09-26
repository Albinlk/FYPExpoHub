-- =============================================================================
-- Hardening (known-gaps register G-27, G-30)
--
-- G-27  Several FYPMS tables still had staff INSERT / UPDATE policies with no
--       column restriction, so a signed-in lecturer could write rows directly
--       over PostgREST and skip the audited RPC that owns that change —
--       e.g. insert an evaluation with any score (bypassing the textbook
--       evaluator rules and server-side scoring), mark a log validated, or
--       endorse a report. The app writes all of these through RPCs, so the
--       direct-write policies are dropped. Reads, coordinator DELETE clean-up
--       and the assignment policies are unchanged.
-- G-30  visit_tracker.allowVisitsBeforeEvent / allowVisitsAfterEvent /
--       visitOpenAt / visitCloseAt were saved but never enforced. Lecturers
--       can now mark visits only inside that window (by default the
--       exhibition days in Malaysia time); admins are exempt.
-- =============================================================================

drop policy if exists "Corrections created by examiners" on public.fyp_correction_items;
drop policy if exists "Corrections updated by staff" on public.fyp_correction_items;
drop policy if exists "Evaluations created by evaluator" on public.fyp_form_evaluations;
drop policy if exists "Evaluations edited by evaluator" on public.fyp_form_evaluations;
drop policy if exists "Form submissions reviewed by assigned staff" on public.fyp_form_submissions;
drop policy if exists "Canvases edited by supervisor" on public.fyp_lean_canvases;
drop policy if exists "Extensions requested by owner or csp" on public.fyp_milestone_extensions;
drop policy if exists "Extensions decided by csp lecturer" on public.fyp_milestone_extensions;
drop policy if exists "Milestones created by csp lecturer" on public.fyp_milestones;
drop policy if exists "Milestones updated by coordinator or csp lecturer" on public.fyp_milestones;
drop policy if exists "Progress logs validated by supervisor" on public.fyp_progress_logs;
drop policy if exists "Reports reviewed by assigned staff" on public.fyp_report_submissions;
drop policy if exists "Requests decided by assigned supervisor" on public.fyp_supervision_requests;
drop policy if exists "Requests decided by csp lecturer" on public.fyp_supervision_requests;

create or replace function public.mark_student_project_visited(
  p_assignment_id uuid,
  p_visit_note text default null
)
returns public.student_project_visits
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_profile public.profiles%rowtype;
  v_assignment public.lecturer_assignments%rowtype;
  v_event public.events%rowtype;
  v_settings jsonb;
  v_open timestamptz;
  v_close timestamptz;
  v_existing public.student_project_visits%rowtype;
  v_result public.student_project_visits%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_profile from public.profiles where id = v_uid and is_active = true;
  if not found then
    raise exception 'permission-denied: Active user profile not found.'
      using errcode = '42501';
  end if;

  select * into v_assignment from public.lecturer_assignments
  where id = p_assignment_id and status = 'active';
  if not found then
    raise exception 'not-found: Active lecturer assignment not found.'
      using errcode = 'P0002';
  end if;

  if v_profile.role <> 'admin' and v_assignment.lecturer_id <> v_uid then
    raise exception 'permission-denied: You are not the assigned lecturer for this project.'
      using errcode = '42501';
  end if;

  select value into v_settings from public.settings where key = 'visit_tracker';
  if v_profile.role <> 'admin' and v_settings is not null then
    if not coalesce((v_settings->>'visitsEnabled')::boolean, true) then
      raise exception 'failed-precondition: Student project visits are currently disabled.'
        using errcode = '55000';
    end if;

    select * into v_event from public.events where id = v_assignment.event_id;
    -- Explicit open/close times win; otherwise the exhibition days
    -- (Malaysia time) unless visits before / after the event are allowed.
    v_open := coalesce(
      nullif(v_settings->>'visitOpenAt', '')::timestamptz,
      case when coalesce((v_settings->>'allowVisitsBeforeEvent')::boolean, false) or v_event.id is null then null
           else date_trunc('day', v_event.start_at at time zone 'Asia/Kuala_Lumpur') at time zone 'Asia/Kuala_Lumpur'
      end
    );
    v_close := coalesce(
      nullif(v_settings->>'visitCloseAt', '')::timestamptz,
      case when coalesce((v_settings->>'allowVisitsAfterEvent')::boolean, false) or v_event.id is null then null
           else (date_trunc('day', v_event.end_at at time zone 'Asia/Kuala_Lumpur') + interval '1 day') at time zone 'Asia/Kuala_Lumpur'
      end
    );
    if v_open is not null and v_now < v_open then
      raise exception 'failed-precondition: Visits open on %.', to_char(v_open at time zone 'Asia/Kuala_Lumpur', 'DD Mon YYYY HH24:MI')
        using errcode = '55000';
    end if;
    if v_close is not null and v_now >= v_close then
      raise exception 'failed-precondition: Visits closed on %.', to_char(v_close at time zone 'Asia/Kuala_Lumpur', 'DD Mon YYYY HH24:MI')
        using errcode = '55000';
    end if;
  end if;

  select * into v_existing from public.student_project_visits
  where event_id = v_assignment.event_id
    and project_id = v_assignment.project_id
    and lecturer_id = v_assignment.lecturer_id
    and visit_role = v_assignment.role;

  if found then
    if v_existing.status = 'completed' then
      raise exception 'already-exists: You have already marked this visit as completed.'
        using errcode = '23505';
    else
      update public.student_project_visits
      set status = 'completed',
          visited_at = v_now,
          visit_note = coalesce(p_visit_note, v_existing.visit_note),
          source = 'lecturer',
          voided_at = null,
          voided_by = null,
          voided_by_role = null,
          void_reason = null,
          updated_at = v_now
      where id = v_existing.id
      returning * into v_result;
    end if;
  else
    insert into public.student_project_visits (
      event_id, project_id, assignment_id, lecturer_id, visit_role, status,
      visited_at, visit_note, source, created_at, updated_at
    ) values (
      v_assignment.event_id, v_assignment.project_id, v_assignment.id, v_assignment.lecturer_id,
      v_assignment.role, 'completed', v_now, p_visit_note, 'lecturer', v_now, v_now
    )
    returning * into v_result;
  end if;

  insert into public.audit_logs (
    actor_uid, actor_role, action, target_type, target_id, event_id, metadata_safe, source, created_at
  ) values (
    v_uid, v_profile.role, 'visit_marked', 'student_project_visits', v_result.id, v_assignment.event_id,
    jsonb_build_object(
      'project_id', v_assignment.project_id,
      'assignment_id', v_assignment.id,
      'visit_role', v_assignment.role
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

revoke execute on function public.mark_student_project_visited(uuid, text) from public, anon;
grant execute on function public.mark_student_project_visited(uuid, text) to authenticated;
