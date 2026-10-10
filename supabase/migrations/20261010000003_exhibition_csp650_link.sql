-- Link the exhibition to CSP650 (portal plan P5 / P6).
--
-- FSKM handbook: the exhibition is the CSP650 final presentation (F10 is
-- scored there by the supervisor and examiner). Until now an exhibition was
-- not tied to any semester, any FYPMS record (even CSP600) could be
-- published, and booth-visit assignments had to be re-created by matching
-- lecturer names. This migration:
--   1. adds events.academic_semester_id (optional; admins pick it),
--   2. lets publish_fyp_record_to_expo publish CSP650 records only, and only
--      that semester's cohort when the exhibition has a semester,
--   3. creates the booth-visit assignments (lecturer_assignments) from the
--      record's approved supervisor(s) and examiner, and fills the project's
--      examiner name.

alter table public.events
  add column if not exists academic_semester_id uuid
    references public.academic_semesters(id) on delete set null;

comment on column public.events.academic_semester_id is
  'The semester whose CSP650 cohort exhibits at this event (optional).';

create or replace function public.publish_fyp_record_to_expo(
  p_publication_id uuid
)
returns public.fyp_expo_publications
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_pub public.fyp_expo_publications%rowtype;
  v_event public.events%rowtype;
  v_result public.fyp_expo_publications%rowtype;
  v_project_id uuid;
  v_record public.fyp_records%rowtype;
  v_examiner_name text;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_pub from public.fyp_expo_publications where id = p_publication_id;
  if not found then
    raise exception 'not-found: Publication record not found.'
      using errcode = 'P0002';
  end if;

  if not public.can_publish_fyp_record_to_expo(v_pub.fyp_record_id) then
    raise exception 'permission-denied: Only the coordinator or administrator can publish to the expo.'
      using errcode = '42501';
  end if;

  if v_pub.status <> 'ready' then
    raise exception 'failed-precondition: Publication must be in ready state before publishing.'
      using errcode = '55000';
  end if;

  select * into v_event from public.events where id = v_pub.event_id;
  if not found then
    raise exception 'not-found: Event not found.'
      using errcode = 'P0002';
  end if;

  -- New: the exhibition is part of CSP650 (FSKM handbook), and an exhibition
  -- linked to a semester only shows that semester's cohort.
  select * into v_record from public.fyp_records where id = v_pub.fyp_record_id;
  if v_record.current_course_code is distinct from 'CSP650' then
    raise exception 'failed-precondition: Only CSP650 projects are shown at the exhibition.'
      using errcode = '55000';
  end if;
  if v_event.academic_semester_id is not null
     and v_event.academic_semester_id is distinct from v_record.academic_semester_id then
    raise exception 'failed-precondition: This exhibition is for another semester''s CSP650 cohort.'
      using errcode = '55000';
  end if;

  select p.display_name into v_examiner_name
    from public.fyp_record_assignments a
    join public.profiles p on p.id = a.lecturer_id
    where a.fyp_record_id = v_record.id and a.academic_role = 'examiner'
      and a.is_active and a.pu_status = 'approved'
    order by a.assigned_at desc
    limit 1;

  insert into public.projects (
    event_id,
    slug,
    title,
    matric_id,
    programme_code,
    short_description,
    abstract,
    category,
    student_team,
    supervisor_display_name,
    examiner_display_name,
    publication_status,
    created_at,
    updated_at
  ) values (
    v_pub.event_id,
    lower(coalesce((v_pub.payload->>'matric_id')::text, 'fyp-record-' || substr(v_pub.fyp_record_id::text, 1, 8))),
    coalesce(v_pub.payload->>'title', 'Untitled Project'),
    v_pub.payload->>'matric_id',
    v_pub.payload->>'programme_code',
    v_pub.payload->>'short_description',
    v_pub.payload->>'abstract',
    v_pub.payload->>'category',
    coalesce(v_pub.payload->'student_team', '[]'::jsonb),
    v_pub.payload->>'supervisor_display_name',
    v_examiner_name,
    'published',
    v_now,
    v_now
  )
  on conflict (event_id, slug)
  do update set
    title = excluded.title,
    matric_id = excluded.matric_id,
    programme_code = excluded.programme_code,
    short_description = excluded.short_description,
    abstract = excluded.abstract,
    category = excluded.category,
    student_team = excluded.student_team,
    supervisor_display_name = excluded.supervisor_display_name,
    examiner_display_name = coalesce(excluded.examiner_display_name, public.projects.examiner_display_name),
    publication_status = 'published',
    updated_at = v_now
  returning id into v_project_id;

  -- New: booth-visit assignments come from the FYPMS supervisor(s) and
  -- examiner instead of matching names, so lecturers can mark visits and
  -- score F10 on the day without the admin re-assigning anyone.
  insert into public.lecturer_assignments (
    event_id, project_id, lecturer_id, lecturer_display_name, lecturer_email,
    role, status, assigned_at, assigned_by, updated_at
  )
  select v_pub.event_id, v_project_id, a.lecturer_id, p.display_name, p.email,
         case when a.academic_role = 'examiner' then 'examiner' else 'supervisor' end,
         'active', v_now, v_uid, v_now
    from public.fyp_record_assignments a
    join public.profiles p on p.id = a.lecturer_id
    where a.fyp_record_id = v_record.id and a.is_active and a.pu_status = 'approved'
  on conflict (event_id, project_id, lecturer_id, role)
  do update set status = 'active', lecturer_display_name = excluded.lecturer_display_name,
                lecturer_email = excluded.lecturer_email, updated_at = v_now;

  update public.fyp_expo_publications
  set status = 'published', published_project_id = v_project_id, published_by = v_uid,
      published_at = v_now, updated_at = v_now
  where id = p_publication_id
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'expo_publication_published', 'fyp_expo_publications', v_result.id,
    jsonb_build_object('project_id', v_project_id, 'event_id', v_pub.event_id),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;
