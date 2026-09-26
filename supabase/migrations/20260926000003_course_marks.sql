-- =============================================================================
-- FYPMS course marks from textbook evaluations
--
-- finalize_marks summed whatever component numbers the lecturer typed and never
-- set a grade. Course marks now come from the rubric evaluations:
--
--   contribution = evaluator share (fyp_rubric_templates.evaluator_shares)
--                  x that role's average evaluation percentage / 100
--
--   CSP600 = F2 + F3 + F4 (course lecturer; default 10 each, coordinator-set)
--          + F7 (lecturer 10, supervisor 10, examiner 5)
--          + F8 (supervisor 30, examiner 15)                      = 100
--   CSP650 = F9 (lecturer 10) + F13 (lecturer 5)
--          + F10 (supervisor 15, examiner 15)
--          + F11 (CLO1: supervisor 25, examiner 20; CLO4: 5 + 5)  = 100
--          F15 / F16 replace F10 / F11 when a special evaluation exists.
--
-- The textbook leaves F2-F4 unallocated (only F7 + F8 = 70 %); per the FSKM
-- decision they default to 10 % each and the coordinator may re-split the 30 %.
-- Grades use the UiTM standard bands.
-- =============================================================================

-- F2-F4 default shares (course lecturer, 10 % each).
update public.fyp_rubric_templates
set evaluator_shares = '{"lecturer": 10}'::jsonb, updated_at = now()
where form_code in ('F2', 'F3', 'F4') and is_active = true;

-- UiTM grade for a 0-100 total.
create or replace function public.fyp_grade_for(p_total numeric)
returns text
language sql
immutable
set search_path = public
as $$
  select case
    when p_total is null then null
    when p_total >= 90 then 'A+'
    when p_total >= 80 then 'A'
    when p_total >= 75 then 'A-'
    when p_total >= 70 then 'B+'
    when p_total >= 65 then 'B'
    when p_total >= 60 then 'B-'
    when p_total >= 55 then 'C+'
    when p_total >= 50 then 'C'
    when p_total >= 47 then 'C-'
    when p_total >= 44 then 'D+'
    when p_total >= 40 then 'D'
    when p_total >= 30 then 'E'
    else 'F'
  end;
$$;

-- An evaluation's percentage over the criteria a role scores, optionally for
-- one CLO group only (same formula as submit_form_evaluation).
create or replace function public.fyp_evaluation_percent(
  p_criteria jsonb,
  p_scores jsonb,
  p_role text,
  p_clo text default null
)
returns numeric
language sql
immutable
set search_path = public
as $$
  select case when coalesce(sum(w * mx), 0) = 0 then null else 100 * sum(w * s) / sum(w * mx) end
  from (
    select
      coalesce((c->>'weight')::numeric, 0) as w,
      coalesce((c->>'max')::numeric, 10) as mx,
      coalesce((p_scores->>(c->>'key'))::numeric, 0) as s
    from jsonb_array_elements(coalesce(p_criteria, '[]'::jsonb)) as c
    where (p_clo is null or c->>'clo' = p_clo)
      and (not coalesce((c->>'supervisor_only')::boolean, false) or p_role = 'supervisor')
  ) as x;
$$;

-- Breakdown of a record's course marks from its evaluations.
create or replace function public.compute_fyp_course_marks(p_fyp_record_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_record public.fyp_records%rowtype;
  v_forms text[];
  v_form text;
  v_special text;
  v_rubric public.fyp_rubric_templates%rowtype;
  v_submission_id uuid;
  v_share record;
  v_pct numeric;
  v_n integer;
  v_contribution numeric;
  v_total numeric := 0;
  v_allocated numeric := 0;
  v_components jsonb := '[]'::jsonb;
  v_missing jsonb := '[]'::jsonb;
begin
  if auth.uid() is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  if not (public.is_csp_lecturer(v_record.current_course_code) or public.is_fyp_coordinator()) then
    raise exception 'permission-denied: Only the course lecturer or coordinator can view course marks.'
      using errcode = '42501';
  end if;

  v_forms := case v_record.current_course_code
    when 'CSP600' then array['F2', 'F3', 'F4', 'F7', 'F8']
    when 'CSP650' then array['F9', 'F10', 'F11', 'F13']
    else array[]::text[]
  end;

  foreach v_form in array v_forms loop
    -- Special evaluation (F15/F16) replaces the final presentation/report.
    v_special := case v_form when 'F10' then 'F15' when 'F11' then 'F16' end;
    if v_special is not null and exists (
      select 1
      from public.fyp_form_submissions s
      join public.fyp_form_evaluations e on e.form_submission_id = s.id
      where s.fyp_record_id = p_fyp_record_id and s.form_code = v_special
    ) then
      v_form := v_special;
    end if;

    select * into v_rubric
    from public.fyp_rubric_templates
    where form_code = v_form and is_active = true
    order by version desc
    limit 1;
    if not found then
      continue;
    end if;

    -- Only the latest version of the form counts.
    select id into v_submission_id
    from public.fyp_form_submissions
    where fyp_record_id = p_fyp_record_id and form_code = v_form
    order by form_version desc, created_at desc
    limit 1;

    for v_share in
      select null::text as clo, s.key as role, s.value::numeric as share
      from jsonb_each(v_rubric.evaluator_shares) as s
      where jsonb_typeof(s.value) = 'number'
      union all
      select g.key, r.key, r.value::numeric
      from jsonb_each(v_rubric.evaluator_shares) as g,
           jsonb_each(g.value) as r
      where jsonb_typeof(g.value) = 'object'
      order by 1 nulls first, 2
    loop
      v_allocated := v_allocated + v_share.share;

      select avg(public.fyp_evaluation_percent(t.criteria, e.scores, e.evaluator_role, v_share.clo)),
             count(*)
      into v_pct, v_n
      from public.fyp_form_evaluations e
      join public.fyp_rubric_templates t on t.id = e.rubric_template_id
      where v_submission_id is not null
        and e.form_submission_id = v_submission_id
        and e.evaluator_role = v_share.role
        and e.status = 'submitted';

      if v_n = 0 or v_pct is null then
        v_missing := v_missing || jsonb_build_object(
          'form_code', v_form, 'role', v_share.role, 'clo', v_share.clo, 'share', v_share.share,
          'reason', case when v_submission_id is null then 'no_submission' else 'not_evaluated' end
        );
      else
        v_contribution := round(v_share.share * v_pct / 100, 2);
        v_total := v_total + v_contribution;
        v_components := v_components || jsonb_build_object(
          'form_code', v_form, 'role', v_share.role, 'clo', v_share.clo, 'share', v_share.share,
          'percent', round(v_pct, 2), 'evaluations', v_n, 'contribution', v_contribution
        );
      end if;
    end loop;
  end loop;

  return jsonb_build_object(
    'fyp_record_id', p_fyp_record_id,
    'course_code', v_record.current_course_code,
    'total', round(v_total, 2),
    'allocated', v_allocated,
    'grade', public.fyp_grade_for(round(v_total, 2)),
    'complete', jsonb_array_length(v_missing) = 0,
    'components', v_components,
    'missing', v_missing
  );
end;
$$;

-- Finalize a record's course marks from its evaluations (course lecturer).
create or replace function public.finalize_fyp_course_marks(p_fyp_record_id uuid)
returns public.fyp_marks_summaries
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_record public.fyp_records%rowtype;
  v_marks jsonb;
  v_flat jsonb := '{}'::jsonb;
  v_component jsonb;
  v_result public.fyp_marks_summaries%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  select * into v_record from public.fyp_records where id = p_fyp_record_id;
  if not found then
    raise exception 'not-found: FYP record not found.'
      using errcode = 'P0002';
  end if;

  if not public.is_csp_lecturer(v_record.current_course_code) then
    raise exception 'permission-denied: Only the course lecturer can finalize marks.'
      using errcode = '42501';
  end if;

  if exists (
    select 1 from public.fyp_marks_summaries
    where fyp_record_id = p_fyp_record_id
      and academic_semester_id = v_record.academic_semester_id
      and course_code = v_record.current_course_code
      and is_finalized = true
  ) then
    raise exception 'failed-precondition: Marks are already finalized for this course.'
      using errcode = '55000';
  end if;

  v_marks := public.compute_fyp_course_marks(p_fyp_record_id);
  if not (v_marks->>'complete')::boolean then
    raise exception 'failed-precondition: % evaluation(s) still missing before marks can be finalized.',
      jsonb_array_length(v_marks->'missing')
      using errcode = '55000';
  end if;

  -- marks: "F11 CLO1 supervisor" -> contribution, for display; the full
  -- breakdown is kept in export_payload.
  for v_component in select * from jsonb_array_elements(v_marks->'components') loop
    v_flat := v_flat || jsonb_build_object(
      concat_ws(' ', v_component->>'form_code', v_component->>'clo', v_component->>'role'),
      (v_component->>'contribution')::numeric
    );
  end loop;

  insert into public.fyp_marks_summaries (
    fyp_record_id, academic_semester_id, course_code, marks, weighted_total, grade,
    is_finalized, finalized_by, finalized_at, export_payload, created_at, updated_at
  ) values (
    p_fyp_record_id, v_record.academic_semester_id, v_record.current_course_code,
    v_flat, (v_marks->>'total')::numeric, v_marks->>'grade',
    true, v_uid, v_now, v_marks || jsonb_build_object('exported_at', v_now),
    v_now, v_now
  )
  on conflict (fyp_record_id, academic_semester_id, course_code)
  do update set
    marks = excluded.marks,
    weighted_total = excluded.weighted_total,
    grade = excluded.grade,
    is_finalized = true,
    finalized_by = v_uid,
    finalized_at = v_now,
    export_payload = excluded.export_payload,
    updated_at = v_now
  returning * into v_result;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'course_marks_finalized', 'fyp_marks_summaries', v_result.id,
    jsonb_build_object(
      'course_code', v_record.current_course_code,
      'weighted_total', v_result.weighted_total,
      'grade', v_result.grade,
      'source', 'evaluations'
    ),
    'database_rpc', v_now
  );

  return v_result;
end;
$$;

-- Coordinator re-splits the CSP600 formulation 30 % across F2 / F3 / F4.
create or replace function public.set_csp600_formulation_shares(
  p_f2 numeric,
  p_f3 numeric,
  p_f4 numeric
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.'
      using errcode = '28000';
  end if;

  if not public.is_fyp_coordinator() then
    raise exception 'permission-denied: Only the FYP coordinator can change mark shares.'
      using errcode = '42501';
  end if;

  if p_f2 is null or p_f3 is null or p_f4 is null
     or least(p_f2, p_f3, p_f4) < 0
     or p_f2 + p_f3 + p_f4 <> 30 then
    raise exception 'invalid-argument: F2, F3 and F4 must be 0 or more and add up to 30 (CSP600 = 100 %%).'
      using errcode = '22023';
  end if;

  update public.fyp_rubric_templates
  set evaluator_shares = jsonb_build_object('lecturer', case form_code when 'F2' then p_f2 when 'F3' then p_f3 else p_f4 end),
      updated_at = v_now
  where form_code in ('F2', 'F3', 'F4') and is_active = true;

  insert into public.fyp_audit_logs (
    actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at
  ) values (
    v_uid, (select role from public.profiles where id = v_uid),
    'mark_shares_updated', 'fyp_rubric_templates', null,
    jsonb_build_object('F2', p_f2, 'F3', p_f3, 'F4', p_f4),
    'database_rpc', v_now
  );

  return jsonb_build_object('F2', p_f2, 'F3', p_f3, 'F4', p_f4);
end;
$$;

revoke execute on function public.fyp_grade_for(numeric) from public, anon;
revoke execute on function public.fyp_evaluation_percent(jsonb, jsonb, text, text) from public, anon;
revoke execute on function public.compute_fyp_course_marks(uuid) from public, anon;
revoke execute on function public.finalize_fyp_course_marks(uuid) from public, anon;
revoke execute on function public.set_csp600_formulation_shares(numeric, numeric, numeric) from public, anon;
grant execute on function public.fyp_grade_for(numeric) to authenticated;
grant execute on function public.fyp_evaluation_percent(jsonb, jsonb, text, text) to authenticated;
grant execute on function public.compute_fyp_course_marks(uuid) to authenticated;
grant execute on function public.finalize_fyp_course_marks(uuid) to authenticated;
grant execute on function public.set_csp600_formulation_shares(numeric, numeric, numeric) to authenticated;
