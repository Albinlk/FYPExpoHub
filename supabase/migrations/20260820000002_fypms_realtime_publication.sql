-- ==============================================================================
-- FYP Expo Hub - FYPMS Realtime Publication Membership
-- 20260820000002_fypms_realtime_publication.sql
-- ==============================================================================
-- Makes the 5 active-workflow tables members of the `supabase_realtime`
-- publication so Postgres Changes events are emitted to the app's realtime
-- channels (`fypmsRealtimeProvider`). RLS SELECT policies already exist on all
-- of these tables, so event delivery is still filtered per-subscriber.
-- Idempotent; additive only (no table/function changes).
-- ==============================================================================

do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public'
        and tablename = 'fyp_supervision_requests'
    ) then
      alter publication supabase_realtime add table public.fyp_supervision_requests;
    end if;

    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public'
        and tablename = 'fyp_progress_logs'
    ) then
      alter publication supabase_realtime add table public.fyp_progress_logs;
    end if;

    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public'
        and tablename = 'fyp_form_submissions'
    ) then
      alter publication supabase_realtime add table public.fyp_form_submissions;
    end if;

    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public'
        and tablename = 'fyp_correction_items'
    ) then
      alter publication supabase_realtime add table public.fyp_correction_items;
    end if;

    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public'
        and tablename = 'fyp_expo_publications'
    ) then
      alter publication supabase_realtime add table public.fyp_expo_publications;
    end if;
  end if;
end;
$$;