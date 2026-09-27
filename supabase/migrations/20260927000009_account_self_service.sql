-- =============================================================================
-- Account self-service (backlog F2)
--
-- Signed-in users change their own display name here (profiles has no client
-- update policy, so role / active flags stay out of reach). Password changes
-- go through Supabase Auth (auth.updateUser) from the My Account dialog.
-- =============================================================================

create or replace function public.update_my_display_name(p_display_name text)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_name text := regexp_replace(btrim(coalesce(p_display_name, '')), '\s+', ' ', 'g');
  v_old text;
  v_result public.profiles%rowtype;
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if char_length(v_name) < 2 or char_length(v_name) > 80 then
    raise exception 'invalid-argument: Use a name of 2–80 characters.' using errcode = '22023';
  end if;

  select display_name into v_old from public.profiles where id = v_uid;
  if not found then
    raise exception 'not-found: Your profile was not found.' using errcode = 'P0002';
  end if;

  update public.profiles set display_name = v_name, updated_at = now()
  where id = v_uid
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, v_result.role, 'display_name_changed', 'profiles', v_uid,
          jsonb_build_object('from', v_old, 'to', v_name), 'database_rpc', clock_timestamp());
  return v_result;
end;
$$;

revoke execute on function public.update_my_display_name(text) from public, anon;
grant execute on function public.update_my_display_name(text) to authenticated;
