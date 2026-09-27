-- =============================================================================
-- Cohort report (backlog F6)
--
-- fyp_cohort_report (coordinator / admin): one semester's numbers (or every
-- semester when p_semester_id is null) for the Reports page:
--   records, status counts, per-course counts, finalized grade distribution
--   and average total, supervisor / co-supervisor / examiner workload per
--   lecturer, records with no supervisor, overdue milestones.
-- Aggregates only; no student names leave the database.
-- =============================================================================

create or replace function public.fyp_cohort_report(p_semester_id uuid default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_result jsonb;
begin
  if auth.uid() is null or not (public.is_fyp_coordinator() or public.is_admin()) then
    raise exception 'permission-denied: Only the FYP coordinator views cohort reports.' using errcode = '42501';
  end if;

  with recs as (
    select * from public.fyp_records
    where p_semester_id is null or academic_semester_id = p_semester_id
  ),
  marks as (
    select m.* from public.fyp_marks_summaries m join recs r on r.id = m.fyp_record_id
    where m.is_finalized and m.academic_semester_id = r.academic_semester_id
  ),
  load as (
    select a.lecturer_id, a.academic_role, count(*) as n
    from public.fyp_record_assignments a join recs r on r.id = a.fyp_record_id
    where a.is_active
    group by 1, 2
  )
  select jsonb_build_object(
    'semester_id', p_semester_id,
    'records', (select count(*) from recs),
    'status_counts', coalesce((select jsonb_object_agg(workflow_status, n) from
        (select workflow_status, count(*) n from recs group by 1) s), '{}'::jsonb),
    'course_counts', coalesce((select jsonb_object_agg(current_course_code, n) from
        (select current_course_code, count(*) n from recs group by 1) s), '{}'::jsonb),
    'finalized', coalesce((select jsonb_object_agg(course_code, jsonb_build_object(
          'count', n, 'average_total', avg_total)) from
        (select course_code, count(*) n, round(avg(weighted_total), 1) avg_total from marks group by 1) s), '{}'::jsonb),
    'grades', coalesce((select jsonb_agg(jsonb_build_object('course_code', course_code, 'grade', grade, 'count', n)
          order by course_code, grade) from
        (select course_code, coalesce(grade, '?') grade, count(*) n from marks group by 1, 2) s), '[]'::jsonb),
    'workload', coalesce((select jsonb_agg(w order by (w->>'total')::int desc, w->>'name') from (
        select jsonb_build_object(
          'lecturer_id', l.lecturer_id,
          'name', coalesce(p.display_name, p.email, 'Unknown'),
          'supervisor', coalesce(sum(l.n) filter (where l.academic_role = 'supervisor'), 0),
          'co_supervisor', coalesce(sum(l.n) filter (where l.academic_role = 'co_supervisor'), 0),
          'examiner', coalesce(sum(l.n) filter (where l.academic_role = 'examiner'), 0),
          'total', sum(l.n)) w
        from load l left join public.profiles p on p.id = l.lecturer_id
        group by l.lecturer_id, p.display_name, p.email) x), '[]'::jsonb),
    'without_supervisor', (select count(*) from recs where main_supervisor_id is null
        and workflow_status not in ('withdrawn', 'project_archived')),
    'overdue_milestones', (select count(*) from public.fyp_milestones m join recs r on r.id = m.fyp_record_id
        where m.status <> 'completed' and (m.status = 'overdue' or m.target_date < current_date))
  ) into v_result;
  return v_result;
end;
$$;

revoke execute on function public.fyp_cohort_report(uuid) from public, anon;
grant execute on function public.fyp_cohort_report(uuid) to authenticated;
