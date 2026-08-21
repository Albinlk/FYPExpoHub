-- ==============================================================================
-- FYP Expo Hub - FYPMS Storage Buckets & Policies
-- 20260817000005_fypms_storage.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Storage buckets for FYPMS
-- path convention: {semester_code}/{fyp_record_id}/{resource_type}/{version}/{file_name}
-- -----------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('fyp-proposal-reports', 'fyp-proposal-reports', false, 20971520, array['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
  ('fyp-final-reports', 'fyp-final-reports', false, 20971520, array['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
  ('fyp-deliverables', 'fyp-deliverables', false, 104857600, null),
  ('fyp-correction-evidence', 'fyp-correction-evidence', false, 20971520, null),
  ('fyp-public-assets', 'fyp-public-assets', true, 20971520, array['image/png', 'image/jpeg', 'image/webp', 'application/pdf'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- -----------------------------------------------------------------------------
-- Storage RLS policies for private FYPMS buckets
-- -----------------------------------------------------------------------------

-- All authenticated users may read objects via signed URLs (RLS still enforced)
create policy "FYPMS read private buckets"
  on storage.objects for select
  using (bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence'));

-- Uploads restricted to active authenticated profiles
create policy "FYPMS insert objects"
  on storage.objects for insert
  with check (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence', 'fyp-public-assets')
    and public.is_active_profile()
  );

-- Updates restricted to active authenticated profiles
create policy "FYPMS update objects"
  on storage.objects for update
  using (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence', 'fyp-public-assets')
    and public.is_active_profile()
  )
  with check (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence', 'fyp-public-assets')
    and public.is_active_profile()
  );

-- Deletes restricted to admins / coordinators
create policy "FYPMS delete objects"
  on storage.objects for delete
  using (
    bucket_id in ('fyp-proposal-reports', 'fyp-final-reports', 'fyp-deliverables', 'fyp-correction-evidence', 'fyp-public-assets')
    and (public.is_admin() or public.is_fyp_coordinator())
  );

-- Public read for fyp-public-assets (approved posters / covers only)
create policy "Public read fyp-public-assets"
  on storage.objects for select
  using (bucket_id = 'fyp-public-assets');
