-- =============================================================================
-- One current exhibition, many past ones (backlog S6, S7)
--
-- The app hard-wired one event ('fskm-fyp-2026'); a new exhibition could only
-- be made by overwriting it. Now:
--   * events.is_current marks the exhibition the public site and admin show
--     (unique: at most one). The existing 2026 event becomes current.
--   * create_exhibition_event (admin) adds a new exhibition without touching
--     the current one; set_current_event (admin) switches which one is live.
--     Past events keep their projects, booths, schedule and award winners
--     and stay browsable in the public archive.
-- =============================================================================

alter table public.events add column if not exists is_current boolean not null default false;

update public.events set is_current = true
where slug = 'fskm-fyp-2026' and not exists (select 1 from public.events where is_current);

create unique index if not exists events_one_current on public.events ((true)) where is_current;

create or replace function public.create_exhibition_event(
  p_slug text,
  p_title text,
  p_start_at timestamptz,
  p_end_at timestamptz,
  p_venue text default null
)
returns public.events
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_slug text := lower(btrim(coalesce(p_slug, '')));
  v_result public.events%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.is_admin() then
    raise exception 'permission-denied: Only administrators create exhibitions.' using errcode = '42501';
  end if;
  if v_slug !~ '^[a-z0-9][a-z0-9-]{2,59}$' then
    raise exception 'invalid-argument: Use a slug like fskm-fyp-2027 (lower-case letters, digits and -).' using errcode = '22023';
  end if;
  if nullif(btrim(p_title), '') is null then
    raise exception 'invalid-argument: A title is required.' using errcode = '22023';
  end if;
  if p_start_at is null or p_end_at is null or p_end_at <= p_start_at then
    raise exception 'invalid-argument: The exhibition must end after it starts.' using errcode = '22023';
  end if;
  if exists (select 1 from public.events where slug = v_slug) then
    raise exception 'already-exists: An exhibition with slug % already exists.', v_slug using errcode = '23505';
  end if;

  insert into public.events (slug, title, start_at, end_at, venue, status, publication_status, is_current, created_at, updated_at, updated_by)
  values (v_slug, btrim(p_title), p_start_at, p_end_at, nullif(btrim(p_venue), ''), 'upcoming', 'published', false, v_now, v_now, v_uid)
  returning * into v_result;

  insert into public.audit_logs (actor_uid, actor_role, action, target_type, target_id, event_id, metadata_safe, source, created_at)
  values (v_uid, 'admin', 'event_created', 'events', v_result.id, v_result.id,
          jsonb_build_object('slug', v_slug), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.create_exhibition_event(text, text, timestamptz, timestamptz, text) from public, anon;
grant execute on function public.create_exhibition_event(text, text, timestamptz, timestamptz, text) to authenticated;

create or replace function public.set_current_event(p_event_id uuid)
returns public.events
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_previous uuid;
  v_result public.events%rowtype;
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if not public.is_admin() then
    raise exception 'permission-denied: Only administrators switch the current exhibition.' using errcode = '42501';
  end if;
  if not exists (select 1 from public.events where id = p_event_id and publication_status = 'published') then
    raise exception 'not-found: Published exhibition not found.' using errcode = 'P0002';
  end if;

  select id into v_previous from public.events where is_current;
  update public.events set is_current = false, updated_at = v_now where is_current and id <> p_event_id;
  update public.events set is_current = true, updated_at = v_now, updated_by = v_uid
  where id = p_event_id
  returning * into v_result;

  insert into public.audit_logs (actor_uid, actor_role, action, target_type, target_id, event_id, metadata_safe, source, created_at)
  values (v_uid, 'admin', 'current_event_changed', 'events', p_event_id, p_event_id,
          jsonb_build_object('previous_event_id', v_previous), 'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.set_current_event(uuid) from public, anon;
grant execute on function public.set_current_event(uuid) to authenticated;
