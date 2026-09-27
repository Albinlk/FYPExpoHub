-- =============================================================================
-- Import projects and booths from the Master File (backlog F5)
--
-- import_event_projects (admin) takes the rows the admin previewed in the
-- CMS (parsed from the Master File's project sheet or a CSV) and applies
-- them in one transaction:
--   * a row whose title (case / spacing ignored) or slug matches a project
--     already in the event is a duplicate: skipped, or updated when
--     p_on_duplicate = 'update';
--   * a booth number creates or reuses the event's booth and links it;
--     a booth already linked to a different project is left alone and
--     reported as a conflict;
--   * new projects are drafts unless p_publish.
-- Returns the counts and the per-row problems; audited.
-- =============================================================================

create or replace function public.import_event_projects(
  p_event_id uuid,
  p_rows jsonb,
  p_on_duplicate text default 'skip',
  p_publish boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_row jsonb;
  v_i integer := 0;
  v_title text;
  v_slug text;
  v_existing public.projects%rowtype;
  v_project_id uuid;
  v_booth public.booths%rowtype;
  v_booth_no text;
  v_inserted integer := 0;
  v_updated integer := 0;
  v_skipped integer := 0;
  v_booths integer := 0;
  v_problems jsonb := '[]'::jsonb;
  v_tags jsonb;
  v_team jsonb;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null or not public.is_admin() then
    raise exception 'permission-denied: Only administrators import projects.' using errcode = '42501';
  end if;
  if not exists (select 1 from public.events where id = p_event_id) then
    raise exception 'not-found: Exhibition not found.' using errcode = 'P0002';
  end if;
  if coalesce(p_on_duplicate, 'skip') not in ('skip', 'update') then
    raise exception 'invalid-argument: Duplicates are skipped or updated.' using errcode = '22023';
  end if;
  if jsonb_typeof(p_rows) <> 'array' or jsonb_array_length(p_rows) = 0 or jsonb_array_length(p_rows) > 2000 then
    raise exception 'invalid-argument: Import 1–2000 rows at a time.' using errcode = '22023';
  end if;

  for v_row in select * from jsonb_array_elements(p_rows) loop
    v_i := v_i + 1;
    v_title := regexp_replace(btrim(coalesce(v_row->>'title', '')), '\s+', ' ', 'g');
    if v_title = '' then
      v_problems := v_problems || jsonb_build_object('row', coalesce((v_row->>'row')::int, v_i), 'problem', 'No project title.');
      v_skipped := v_skipped + 1;
      continue;
    end if;
    v_slug := nullif(btrim(regexp_replace(lower(v_title), '[^a-z0-9]+', '-', 'g'), '-'), '');
    v_slug := left(coalesce(v_slug, 'project'), 120);

    v_tags := case jsonb_typeof(v_row->'tech_tags') when 'array' then v_row->'tech_tags' else '[]'::jsonb end;
    v_team := case jsonb_typeof(v_row->'student_team') when 'array' then v_row->'student_team' else '[]'::jsonb end;

    select * into v_existing from public.projects
    where event_id = p_event_id
      and (slug = v_slug or lower(regexp_replace(btrim(title), '\s+', ' ', 'g')) = lower(v_title))
    limit 1;

    if found then
      if coalesce(p_on_duplicate, 'skip') = 'skip' then
        v_skipped := v_skipped + 1;
        continue;
      end if;
      update public.projects set
        title = v_title,
        matric_id = coalesce(nullif(btrim(v_row->>'matric_id'), ''), matric_id),
        team_display_name = coalesce(nullif(btrim(v_row->>'team_display_name'), ''), team_display_name),
        programme_code = coalesce(nullif(upper(btrim(v_row->>'programme_code')), ''), programme_code),
        programme_name = coalesce(nullif(btrim(v_row->>'programme_name'), ''), programme_name),
        short_description = coalesce(nullif(btrim(v_row->>'short_description'), ''), short_description),
        category = coalesce(nullif(btrim(v_row->>'category'), ''), category),
        tech_tags = case when jsonb_array_length(v_tags) > 0 then v_tags else tech_tags end,
        student_team = case when jsonb_array_length(v_team) > 0 then v_team else student_team end,
        supervisor_display_name = coalesce(nullif(btrim(v_row->>'supervisor_display_name'), ''), supervisor_display_name),
        examiner_display_name = coalesce(nullif(btrim(v_row->>'examiner_display_name'), ''), examiner_display_name),
        presentation_day = coalesce(nullif(btrim(v_row->>'presentation_day'), ''), presentation_day),
        updated_at = v_now
      where id = v_existing.id;
      v_project_id := v_existing.id;
      v_updated := v_updated + 1;
    else
      insert into public.projects (
        event_id, slug, title, matric_id, team_display_name, programme_code, programme_name, short_description,
        category, tech_tags, student_team, supervisor_display_name, examiner_display_name, presentation_day,
        publication_status, created_at, updated_at
      ) values (
        p_event_id, v_slug, v_title, nullif(btrim(v_row->>'matric_id'), ''), nullif(btrim(v_row->>'team_display_name'), ''),
        nullif(upper(btrim(v_row->>'programme_code')), ''), nullif(btrim(v_row->>'programme_name'), ''),
        nullif(btrim(v_row->>'short_description'), ''), nullif(btrim(v_row->>'category'), ''), v_tags, v_team,
        nullif(btrim(v_row->>'supervisor_display_name'), ''), nullif(btrim(v_row->>'examiner_display_name'), ''),
        nullif(btrim(v_row->>'presentation_day'), ''),
        case when p_publish then 'published' else 'draft' end, v_now, v_now
      )
      returning id into v_project_id;
      v_inserted := v_inserted + 1;
    end if;

    v_booth_no := nullif(upper(btrim(coalesce(v_row->>'booth_number', ''))), '');
    if v_booth_no is not null then
      select * into v_booth from public.booths where event_id = p_event_id and booth_number = v_booth_no;
      if not found then
        insert into public.booths (event_id, booth_number, zone, linked_project_id, presentation_day, status, publication_status, created_at, updated_at)
        values (p_event_id, v_booth_no, nullif(btrim(v_row->>'booth_zone'), ''), v_project_id,
                nullif(btrim(v_row->>'presentation_day'), ''), 'active',
                case when p_publish then 'published' else 'draft' end, v_now, v_now)
        returning * into v_booth;
      elsif v_booth.linked_project_id is not null and v_booth.linked_project_id <> v_project_id then
        v_problems := v_problems || jsonb_build_object('row', coalesce((v_row->>'row')::int, v_i),
          'problem', format('Booth %s is already linked to another project; not changed.', v_booth_no));
        continue;
      else
        update public.booths set linked_project_id = v_project_id, status = 'active',
          zone = coalesce(nullif(btrim(v_row->>'booth_zone'), ''), zone), updated_at = v_now
        where id = v_booth.id
        returning * into v_booth;
      end if;
      update public.projects set booth_id = v_booth.id, booth_number = v_booth.booth_number, booth_zone = v_booth.zone, updated_at = v_now
      where id = v_project_id;
      v_booths := v_booths + 1;
    end if;
  end loop;

  insert into public.audit_logs (actor_uid, actor_role, action, target_type, target_id, event_id, metadata_safe, source, created_at)
  values (v_uid, 'admin', 'projects_imported', 'events', p_event_id, p_event_id,
          jsonb_build_object('rows', jsonb_array_length(p_rows), 'inserted', v_inserted, 'updated', v_updated,
                             'skipped', v_skipped, 'booths', v_booths, 'problems', jsonb_array_length(v_problems)),
          'database_rpc', v_now);

  return jsonb_build_object('inserted', v_inserted, 'updated', v_updated, 'skipped', v_skipped,
                            'booths_linked', v_booths, 'problems', v_problems);
end;
$$;

revoke execute on function public.import_event_projects(uuid, jsonb, text, boolean) from public, anon;
grant execute on function public.import_event_projects(uuid, jsonb, text, boolean) to authenticated;
