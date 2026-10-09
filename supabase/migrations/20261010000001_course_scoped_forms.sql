-- Course-scoped forms (portal plan P1).
--
-- The FSKM handbook (Essentials of Computing Sciences: Project Administration,
-- 4th ed., 2022) splits the forms between the two courses:
--   CSP600 Project Formulation: F1, F2, F3, F4, F5, F6a, F7, F8
--   CSP650 Project:             F5, F6b, F9, F10, F11, F12, F13, F14, F15, F16
-- submit_fyp_form accepted any supported code on any record, so a CSP650
-- student could submit F2 (a CSP600 evaluation) and vice versa. This adds the
-- course check; nothing already submitted is changed.
--
-- Keep in sync with fypmsCourseForms in lib/core/state/fypms/roles_providers.dart
-- (a test compares the two lists).

create or replace function public.fyp_form_course(p_form_code text)
returns text
language sql
immutable
set search_path = public
as $$
  select case
    when p_form_code in ('F1', 'F2', 'F3', 'F4', 'F6a', 'F7', 'F8') then 'CSP600'
    when p_form_code in ('F6b', 'F9', 'F10', 'F11', 'F12', 'F13', 'F14', 'F15', 'F16') then 'CSP650'
    else null -- F5 (consultation log) belongs to both courses
  end
$$;

create or replace function public.submit_fyp_form(
  p_fyp_record_id uuid,
  p_form_code text,
  p_payload jsonb,
  p_file_url text default null,
  p_similarity_index numeric default null
)
returns public.fyp_form_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_form public.fyp_form_submissions%rowtype;
  v_version integer;
  v_special_eval_enabled boolean;
  v_record_course text;
  v_form_course text;
  v_now timestamptz := clock_timestamp();
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if p_form_code not in ('F2', 'F3', 'F4', 'F6a', 'F7', 'F8', 'F9', 'F10', 'F11', 'F13', 'F14', 'F15', 'F16') then
    raise exception 'invalid-argument: Unsupported form code.'
      using errcode = '22023';
  end if;

  -- New: a form may only be submitted on a record of its own course.
  select r.current_course_code into v_record_course
    from public.fyp_records r
    where r.id = p_fyp_record_id;
  v_form_course := public.fyp_form_course(p_form_code);
  if v_form_course is not null and v_record_course is not null and v_form_course <> v_record_course then
    raise exception 'failed-precondition: % is a % form; this record is in %.',
      p_form_code, v_form_course, v_record_course
      using errcode = '55000';
  end if;

  if p_form_code = 'F14' then
    select coalesce((s.value ->> 'special_evaluation_enabled')::boolean, false)
      into v_special_eval_enabled
      from public.settings s
      where s.key = 'fypms_features';
    if not coalesce(v_special_eval_enabled, false) then
      raise exception 'permission-denied: Special evaluation applications (F14) are not open.'
        using errcode = '42501';
    end if;
  end if;

  if p_form_code in ('F15', 'F16') and not public.fyp_is_special_evaluation_eligible(p_fyp_record_id) then
    raise exception 'failed-precondition: You have not qualified for special evaluation (F14).'
      using errcode = '55000';
  end if;

  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit forms.'
      using errcode = '42501';
  end if;

  select coalesce(max(form_version), 0) + 1 into v_version
  from public.fyp_form_submissions
  where fyp_record_id = p_fyp_record_id and form_code = p_form_code;

  insert into public.fyp_form_submissions (
    fyp_record_id, form_code, form_version, payload, status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_form_code, v_version, coalesce(p_payload, '{}'::jsonb), 'submitted',
    v_uid, v_now, v_now, v_now
  )
  returning * into v_form;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'fyp_form_submitted', 'fyp_form_submissions', v_form.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'form_code', p_form_code, 'form_version', v_version, 'file_url', p_file_url),
    'database_rpc', v_now
  );

  return v_form;
end;
$$;
