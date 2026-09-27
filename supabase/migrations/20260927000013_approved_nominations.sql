-- =============================================================================
-- Approved nominations for appointment letters (backlog F7)
--
-- list_approved_nominations: supervisor / examiner appointments the PU has
-- approved (active, pu_status approved with a decision time) for the
-- programmes the caller heads, or every programme for the coordinator. The
-- CMS turns each into a printable appointment letter.
-- =============================================================================

create or replace function public.list_approved_nominations()
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
    'lecturer_email', lp.email,
    'student_name', sp.display_name,
    'matric_id', r.matric_id,
    'programme_code', r.programme_code,
    'course_code', r.current_course_code,
    'project_title', r.project_title,
    'semester_label', s.label,
    'assigned_at', a.assigned_at,
    'decided_at', a.pu_decided_at,
    'decided_by_name', dp.display_name
  ) order by a.pu_decided_at desc), '[]'::jsonb)
  from public.fyp_record_assignments a
  join public.fyp_records r on r.id = a.fyp_record_id
  left join public.academic_semesters s on s.id = r.academic_semester_id
  left join public.profiles lp on lp.id = a.lecturer_id
  left join public.profiles sp on sp.id = r.student_id
  left join public.profiles dp on dp.id = a.pu_decided_by
  where a.is_active and a.pu_status = 'approved' and a.pu_decided_at is not null
    and (public.is_fyp_coordinator() or public.is_programme_head(r.programme_code));
$$;

revoke execute on function public.list_approved_nominations() from public, anon;
grant execute on function public.list_approved_nominations() to authenticated;
