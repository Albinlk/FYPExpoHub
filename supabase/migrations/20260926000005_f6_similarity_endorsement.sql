-- =============================================================================
-- F6(a) / F6(b) report submission (FSKM FYP Text Book, 4th ed.)
--
-- The textbook's F6 carries the plagiarism similarity index (maximum 30 %),
-- the original plagiarism report, and the supervisor's endorsement that the
-- report was screened. FYPMS stored a similarity_index column the app never
-- filled, had no plagiarism report and no endorsement step.
--
--   * fyp_report_submissions gains plagiarism_report_url, endorsed_by,
--     endorsed_at; similarity_index must be 0-100.
--   * submit_report_version requires the similarity index (<= 30 %) and the
--     plagiarism report, and both files must sit in the record's own storage
--     folder ({semester}/{record}/...).
--   * endorse_report_submission: the assigned supervisor / co-supervisor (or
--     coordinator) endorses a submitted report (-> under_review) or returns
--     it with a comment (-> rejected).
--   * Submitted plagiarism reports get the same no-overwrite protection as
--     the reports themselves.
-- =============================================================================

alter table public.fyp_report_submissions
  add column if not exists plagiarism_report_url text,
  add column if not exists endorsed_by uuid references public.profiles(id) on delete set null,
  add column if not exists endorsed_at timestamptz;

alter table public.fyp_report_submissions
  drop constraint if exists fyp_report_submissions_similarity_range;
alter table public.fyp_report_submissions
  add constraint fyp_report_submissions_similarity_range
  check (similarity_index is null or similarity_index between 0 and 100);

drop function if exists public.submit_report_version(uuid, text, text, numeric);

create function public.submit_report_version(
  p_fyp_record_id uuid,
  p_report_type text,
  p_file_url text,
  p_similarity_index numeric default null,
  p_plagiarism_report_url text default null
)
returns public.fyp_report_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_result public.fyp_report_submissions%rowtype;
  v_now timestamptz := clock_timestamp();
  v_next integer;
  v_folder text := '%/' || p_fyp_record_id::text || '/%';
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if p_report_type not in ('proposal', 'final') then
    raise exception 'invalid-argument: Report type must be proposal or final.' using errcode = '22023';
  end if;
  if not public.is_active_fyp_student(p_fyp_record_id) then
    raise exception 'permission-denied: Only the record owner can submit report versions.' using errcode = '42501';
  end if;

  if p_similarity_index is null then
    raise exception 'invalid-argument: Enter the similarity index from the plagiarism report.' using errcode = '22023';
  end if;
  if p_similarity_index < 0 or p_similarity_index > 100 then
    raise exception 'invalid-argument: The similarity index must be between 0 and 100 %%.' using errcode = '22023';
  end if;
  if p_similarity_index > 30 then
    raise exception 'invalid-argument: Similarity index % %% is above the 30 %% limit; revise the report before submitting.',
      p_similarity_index using errcode = '22023';
  end if;
  if nullif(trim(p_file_url), '') is null or nullif(trim(p_plagiarism_report_url), '') is null then
    raise exception 'invalid-argument: Attach both the report and the original plagiarism report.' using errcode = '22023';
  end if;
  if p_file_url not like v_folder or p_plagiarism_report_url not like v_folder then
    raise exception 'invalid-argument: Files must be uploaded to this record''s folder.' using errcode = '22023';
  end if;

  perform 1 from public.fyp_records where id = p_fyp_record_id for update;
  if not found then
    raise exception 'not-found: FYP record not found.' using errcode = 'P0002';
  end if;

  select coalesce(max(version), 0) + 1 into v_next
  from public.fyp_report_submissions
  where fyp_record_id = p_fyp_record_id and report_type = p_report_type;

  insert into public.fyp_report_submissions (
    fyp_record_id, report_type, version, file_url, plagiarism_report_url, similarity_index,
    status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_report_type, v_next, p_file_url, p_plagiarism_report_url, p_similarity_index,
    'submitted', v_uid, v_now, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'report_version_submitted', 'fyp_report_submissions', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'report_type', p_report_type,
                       'version', v_next, 'similarity_index', p_similarity_index),
    'database_rpc', v_now);
  return v_result;
end;
$$;

-- Supervisor endorsement of F6 (textbook: "Endorsed by: Supervisor").
create or replace function public.endorse_report_submission(
  p_report_id uuid,
  p_decision text,
  p_comment text default null
)
returns public.fyp_report_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_report public.fyp_report_submissions%rowtype;
  v_result public.fyp_report_submissions%rowtype;
  v_comment text := nullif(trim(p_comment), '');
  v_now timestamptz := clock_timestamp();
begin
  if v_uid is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  if p_decision not in ('endorsed', 'returned') then
    raise exception 'invalid-argument: Decision must be endorsed or returned.' using errcode = '22023';
  end if;

  select * into v_report from public.fyp_report_submissions where id = p_report_id for update;
  if not found then
    raise exception 'not-found: Report submission not found.' using errcode = 'P0002';
  end if;

  if not (
    public.is_assigned_to_fyp_record(v_report.fyp_record_id, 'supervisor')
    or public.is_assigned_to_fyp_record(v_report.fyp_record_id, 'co_supervisor')
    or public.is_fyp_coordinator()
  ) then
    raise exception 'permission-denied: Only the supervisor can endorse this report.' using errcode = '42501';
  end if;

  if v_report.status <> 'submitted' then
    raise exception 'failed-precondition: Only a newly submitted report can be endorsed or returned.' using errcode = '55000';
  end if;

  if p_decision = 'returned' and v_comment is null then
    raise exception 'invalid-argument: Say why the report is returned.' using errcode = '22023';
  end if;

  if p_decision = 'endorsed' then
    update public.fyp_report_submissions
    set status = 'under_review', endorsed_by = v_uid, endorsed_at = v_now,
        review_comment = coalesce(v_comment, review_comment), updated_at = v_now
    where id = p_report_id
    returning * into v_result;
  else
    update public.fyp_report_submissions
    set status = 'rejected', reviewed_by = v_uid, reviewed_at = v_now,
        review_comment = v_comment, updated_at = v_now
    where id = p_report_id
    returning * into v_result;
  end if;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'report_' || p_decision, 'fyp_report_submissions', p_report_id,
    jsonb_build_object('fyp_record_id', v_report.fyp_record_id, 'report_type', v_report.report_type,
                       'version', v_report.version, 'similarity_index', v_report.similarity_index),
    'database_rpc', v_now);

  return v_result;
end;
$$;

-- Submitted plagiarism reports can't be overwritten or deleted by students.
create or replace function public.fyp_storage_object_is_submitted(p_path text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.fyp_report_submissions s
    where s.file_url = p_path or s.file_url like '%/' || p_path
       or s.plagiarism_report_url = p_path or s.plagiarism_report_url like '%/' || p_path
  ) or exists (
    select 1 from public.fyp_deliverables d
    where d.file_url = p_path or d.file_url like '%/' || p_path
  );
$$;

revoke execute on function public.submit_report_version(uuid, text, text, numeric, text) from public, anon;
revoke execute on function public.endorse_report_submission(uuid, text, text) from public, anon;
revoke execute on function public.fyp_storage_object_is_submitted(text) from public, anon;
grant execute on function public.submit_report_version(uuid, text, text, numeric, text) to authenticated;
grant execute on function public.endorse_report_submission(uuid, text, text) to authenticated;
grant execute on function public.fyp_storage_object_is_submitted(text) to authenticated;
