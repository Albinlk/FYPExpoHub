-- =============================================================================
-- F6 report thresholds and REC ethics forms (textbook R11, A23 / A24)
--
-- The FSKM FYP Text Book (4th ed.) sets minimums the report submission never
-- captured:
--   proposal  >= 30 pages, >= 15 references
--   final     >= 50 pages, >= 30 references
--   at least half of the references academic (journals, proceedings, books)
-- and requires the Research Ethics Committee (REC) forms with the proposal
-- when the project involves human subjects.
--
--   * fyp_report_submissions gains page_count, reference_count,
--     academic_reference_count, involves_human_subjects, ethics_form_url.
--   * submit_report_version takes them and enforces the minimums; a proposal
--     that involves human subjects must attach the REC form (same record
--     folder rule as the other files). The old 5-argument version is dropped.
--   * Submitted REC forms get the same no-overwrite storage lock.
-- =============================================================================

alter table public.fyp_report_submissions
  add column if not exists page_count integer check (page_count is null or page_count > 0),
  add column if not exists reference_count integer check (reference_count is null or reference_count >= 0),
  add column if not exists academic_reference_count integer
    check (academic_reference_count is null or academic_reference_count >= 0),
  add column if not exists involves_human_subjects boolean not null default false,
  add column if not exists ethics_form_url text;

drop function if exists public.submit_report_version(uuid, text, text, numeric, text);

create or replace function public.submit_report_version(
  p_fyp_record_id uuid,
  p_report_type text,
  p_file_url text,
  p_similarity_index numeric,
  p_plagiarism_report_url text,
  p_page_count integer,
  p_reference_count integer,
  p_academic_reference_count integer,
  p_involves_human_subjects boolean default false,
  p_ethics_form_url text default null
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
  v_min_pages integer;
  v_min_refs integer;
  v_ethics text := nullif(trim(p_ethics_form_url), '');
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

  -- Textbook minimums.
  v_min_pages := case p_report_type when 'proposal' then 30 else 50 end;
  v_min_refs := case p_report_type when 'proposal' then 15 else 30 end;
  if p_page_count is null or p_page_count < v_min_pages then
    raise exception 'invalid-argument: A % needs at least % pages.',
      case p_report_type when 'final' then 'final report' else 'proposal' end, v_min_pages using errcode = '22023';
  end if;
  if p_reference_count is null or p_reference_count < v_min_refs then
    raise exception 'invalid-argument: A % needs at least % references.', p_report_type, v_min_refs using errcode = '22023';
  end if;
  if p_academic_reference_count is null or p_academic_reference_count > p_reference_count then
    raise exception 'invalid-argument: Academic references cannot exceed the total.' using errcode = '22023';
  end if;
  if p_academic_reference_count * 2 < p_reference_count then
    raise exception 'invalid-argument: At least half of the references must be academic (% of %).',
      p_academic_reference_count, p_reference_count using errcode = '22023';
  end if;

  -- REC forms go with the proposal when human subjects are involved.
  if p_report_type = 'proposal' and coalesce(p_involves_human_subjects, false) and v_ethics is null then
    raise exception 'invalid-argument: Attach the Research Ethics Committee (REC) form — this project involves human subjects.'
      using errcode = '22023';
  end if;

  if p_file_url not like v_folder or p_plagiarism_report_url not like v_folder
     or (v_ethics is not null and v_ethics not like v_folder) then
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
    page_count, reference_count, academic_reference_count, involves_human_subjects, ethics_form_url,
    status, submitted_by, submitted_at, created_at, updated_at
  ) values (
    p_fyp_record_id, p_report_type, v_next, p_file_url, p_plagiarism_report_url, p_similarity_index,
    p_page_count, p_reference_count, p_academic_reference_count,
    coalesce(p_involves_human_subjects, false), v_ethics,
    'submitted', v_uid, v_now, v_now, v_now
  )
  returning * into v_result;

  insert into public.fyp_audit_logs (actor_uid, actor_role, action, target_type, target_id, metadata_safe, source, created_at)
  values (v_uid, (select role from public.profiles where id = v_uid),
    'report_version_submitted', 'fyp_report_submissions', v_result.id,
    jsonb_build_object('fyp_record_id', p_fyp_record_id, 'report_type', p_report_type,
                       'version', v_next, 'similarity_index', p_similarity_index,
                       'page_count', p_page_count, 'reference_count', p_reference_count,
                       'academic_reference_count', p_academic_reference_count,
                       'involves_human_subjects', coalesce(p_involves_human_subjects, false)),
    'database_rpc', v_now);
  return v_result;
end;
$$;

revoke execute on function public.submit_report_version(uuid, text, text, numeric, text, integer, integer, integer, boolean, text) from public, anon;
grant execute on function public.submit_report_version(uuid, text, text, numeric, text, integer, integer, integer, boolean, text) to authenticated;

-- Submitted REC forms can't be overwritten either.
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
       or s.ethics_form_url = p_path or s.ethics_form_url like '%/' || p_path
  ) or exists (
    select 1 from public.fyp_deliverables d
    where d.file_url = p_path or d.file_url like '%/' || p_path
  ) or exists (
    select 1 from public.fyp_correction_items c
    where c.evidence_url = p_path or c.evidence_url like '%/' || p_path
  );
$$;
