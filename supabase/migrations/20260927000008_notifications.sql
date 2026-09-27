-- =============================================================================
-- In-app notifications (backlog F1)
--
-- Nobody was told when something needed them. fyp_notifications holds one
-- row per recipient; database triggers write them when:
--   * an F1 supervision request names a supervisor / is decided
--   * a report is submitted (supervisors) / endorsed or returned (student)
--   * a form is evaluated (student)
--   * a milestone extension is requested (course lecturer) / decided
--   * a supervisor change is requested (coordinators) / decided
--   * a lecturer is assigned to a record (lecturer; PU when pending)
--   * a correction item is raised (student) / evidence submitted (creator)
--   * course marks are finalized (student)
--   * the F14 special-evaluation decision is saved (student)
-- Recipients read their own rows and mark them read; nobody writes them
-- directly. (Email would need a custom SMTP provider; see DEPLOYMENT.md.)
-- =============================================================================

create table if not exists public.fyp_notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null,
  title text not null,
  body text,
  link text,
  fyp_record_id uuid references public.fyp_records(id) on delete cascade,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists fyp_notifications_recipient_idx
  on public.fyp_notifications (recipient_id, created_at desc);

alter table public.fyp_notifications enable row level security;
drop policy if exists "Notifications read by recipient" on public.fyp_notifications;
create policy "Notifications read by recipient"
  on public.fyp_notifications for select
  to authenticated
  using (recipient_id = auth.uid());
revoke all on public.fyp_notifications from anon;
revoke insert, update, delete, truncate on public.fyp_notifications from authenticated;
grant select on public.fyp_notifications to authenticated;

-- Internal: queue one notification (skips null recipients and the actor).
create or replace function public.fyp_notify(
  p_recipient uuid,
  p_kind text,
  p_title text,
  p_body text default null,
  p_link text default null,
  p_record uuid default null
)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.fyp_notifications (recipient_id, kind, title, body, link, fyp_record_id)
  select p_recipient, p_kind, p_title, p_body, p_link, p_record
  where p_recipient is not null
    and p_recipient is distinct from auth.uid()
    and exists (select 1 from public.profiles where id = p_recipient);
$$;

revoke execute on function public.fyp_notify(uuid, text, text, text, text, uuid) from public, anon, authenticated;

create or replace function public.mark_notifications_read(p_ids uuid[] default null)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_n integer;
begin
  if auth.uid() is null then
    raise exception 'unauthenticated: You must be signed in to perform this action.' using errcode = '28000';
  end if;
  update public.fyp_notifications set read_at = now()
  where recipient_id = auth.uid() and read_at is null and (p_ids is null or id = any(p_ids));
  get diagnostics v_n = row_count;
  return v_n;
end;
$$;

revoke execute on function public.mark_notifications_read(uuid[]) from public, anon;
grant execute on function public.mark_notifications_read(uuid[]) to authenticated;

-- A record's label for messages.
create or replace function public.fyp_record_label(p_record uuid)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(nullif(r.project_title, ''), 'your FYP') || coalesce(' (' || p.display_name || ')', '')
  from public.fyp_records r left join public.profiles p on p.id = r.student_id
  where r.id = p_record;
$$;

revoke execute on function public.fyp_record_label(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create or replace function public.fyp_notify_on_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_record public.fyp_records%rowtype;
  v_label text;
begin
  if tg_table_name = 'fyp_supervision_requests' then
    select * into v_record from public.fyp_records where id = new.fyp_record_id;
    v_label := public.fyp_record_label(new.fyp_record_id);
    if tg_op = 'INSERT' then
      perform public.fyp_notify(new.preferred_supervisor_id, 'supervision_request', 'New supervision request (F1)',
        v_label, '/fypms/supervisor/requests', new.fyp_record_id);
    elsif new.status is distinct from old.status and new.status in ('approved', 'rejected') then
      perform public.fyp_notify(v_record.student_id, 'supervision_decided', 'Supervision request ' || new.status,
        null, '/fypms/student/supervision', new.fyp_record_id);
    end if;

  elsif tg_table_name = 'fyp_report_submissions' then
    select * into v_record from public.fyp_records where id = new.fyp_record_id;
    v_label := public.fyp_record_label(new.fyp_record_id);
    if tg_op = 'INSERT' then
      perform public.fyp_notify(v_record.main_supervisor_id, 'report_submitted',
        initcap(new.report_type) || ' report submitted — please endorse', v_label, '/fypms/supervisor/reports', new.fyp_record_id);
      perform public.fyp_notify(v_record.co_supervisor_id, 'report_submitted',
        initcap(new.report_type) || ' report submitted', v_label, '/fypms/supervisor/reports', new.fyp_record_id);
    elsif new.status is distinct from old.status and new.status in ('under_review', 'rejected', 'approved') then
      perform public.fyp_notify(v_record.student_id, 'report_decided',
        initcap(new.report_type) || ' report ' || case new.status when 'under_review' then 'endorsed' when 'rejected' then 'returned' else 'approved' end,
        new.review_comment, '/fypms/student/reports', new.fyp_record_id);
    end if;

  elsif tg_table_name = 'fyp_form_evaluations' then
    select r.* into v_record from public.fyp_form_submissions s join public.fyp_records r on r.id = s.fyp_record_id
    where s.id = new.form_submission_id;
    perform public.fyp_notify(v_record.student_id, 'form_evaluated',
      (select form_code from public.fyp_form_submissions where id = new.form_submission_id) || ' has been evaluated',
      null, '/fypms/student/forms', v_record.id);

  elsif tg_table_name = 'fyp_milestone_extensions' then
    select r.* into v_record from public.fyp_milestones m join public.fyp_records r on r.id = m.fyp_record_id
    where m.id = new.milestone_id;
    if tg_op = 'INSERT' then
      perform public.fyp_notify(o.lecturer_id, 'extension_requested', 'Milestone extension requested',
        public.fyp_record_label(v_record.id), '/fypms/csp/milestones', v_record.id)
      from public.fyp_course_offerings o
      where o.academic_semester_id = v_record.academic_semester_id and o.course_code = v_record.current_course_code and o.is_active;
    elsif new.status is distinct from old.status and new.status in ('approved', 'rejected') then
      perform public.fyp_notify(new.requested_by, 'extension_decided', 'Milestone extension ' || new.status,
        new.decision_comment, '/fypms/student/milestones', v_record.id);
    end if;

  elsif tg_table_name = 'fyp_supervisor_change_requests' then
    if tg_op = 'INSERT' then
      perform public.fyp_notify(r.profile_id, 'supervisor_change_requested', 'Supervisor change requested',
        public.fyp_record_label(new.fyp_record_id), '/fypms/coordinator/requests', new.fyp_record_id)
      from public.profile_academic_roles r
      where r.role_code = 'fyp_coordinator' and r.is_active;
    elsif new.status is distinct from old.status and new.status in ('approved', 'rejected') then
      perform public.fyp_notify(new.requested_by, 'supervisor_change_decided', 'Supervisor change ' || new.status,
        new.decision_comment, '/fypms/student/supervision', new.fyp_record_id);
    end if;

  elsif tg_table_name = 'fyp_record_assignments' then
    if new.is_active and (tg_op = 'INSERT' or not old.is_active or old.lecturer_id is distinct from new.lecturer_id) then
      perform public.fyp_notify(new.lecturer_id, 'assigned',
        'You were assigned as ' || replace(new.academic_role, '_', '-'),
        public.fyp_record_label(new.fyp_record_id),
        case when new.academic_role = 'examiner' then '/fypms/examiner/records' else '/fypms/supervisor/records' end,
        new.fyp_record_id);
      if new.pu_status = 'pending' then
        perform public.fyp_notify(r.profile_id, 'nomination_pending', 'Nomination awaiting your approval',
          public.fyp_record_label(new.fyp_record_id), '/fypms/pu', new.fyp_record_id)
        from public.profile_academic_roles r
        where r.role_code = 'programme_head' and r.is_active
          and (r.programme_code = '' or upper(r.programme_code) =
               upper((select programme_code from public.fyp_records where id = new.fyp_record_id)));
      end if;
    end if;

  elsif tg_table_name = 'fyp_correction_items' then
    select * into v_record from public.fyp_records where id = new.fyp_record_id;
    if tg_op = 'INSERT' then
      perform public.fyp_notify(v_record.student_id, 'correction_raised', 'Correction to make: ' || new.item_code,
        left(new.description, 200), '/fypms/student/corrections', new.fyp_record_id);
    elsif new.status is distinct from old.status and new.status = 'evidence_submitted' then
      perform public.fyp_notify(new.created_by, 'correction_evidence', 'Correction evidence submitted: ' || new.item_code,
        public.fyp_record_label(new.fyp_record_id), '/fypms/supervisor/corrections', new.fyp_record_id);
    end if;

  elsif tg_table_name = 'fyp_marks_summaries' then
    if new.is_finalized and (tg_op = 'INSERT' or not old.is_finalized) then
      select * into v_record from public.fyp_records where id = new.fyp_record_id;
      perform public.fyp_notify(v_record.student_id, 'marks_finalized', new.course_code || ' marks finalized',
        coalesce('Grade ' || new.grade, null), '/fypms/student/marks', new.fyp_record_id);
    end if;

  elsif tg_table_name = 'fyp_special_evaluations' then
    select * into v_record from public.fyp_records where id = new.fyp_record_id;
    perform public.fyp_notify(v_record.student_id, 'special_evaluation',
      case when new.eligible then 'You qualified for special evaluation (F14)' else 'Special evaluation (F14): not qualified' end,
      new.note, '/fypms/student/forms', new.fyp_record_id);
  end if;
  return new;
end;
$$;

revoke execute on function public.fyp_notify_on_change() from public, anon, authenticated;

do $$
declare
  t text;
begin
  foreach t in array array[
    'fyp_supervision_requests', 'fyp_report_submissions', 'fyp_form_evaluations', 'fyp_milestone_extensions',
    'fyp_supervisor_change_requests', 'fyp_record_assignments', 'fyp_correction_items', 'fyp_marks_summaries',
    'fyp_special_evaluations'
  ] loop
    execute format('drop trigger if exists fyp_notify_on_change on public.%I', t);
    execute format('create trigger fyp_notify_on_change after insert or update on public.%I
                    for each row execute function public.fyp_notify_on_change()', t);
  end loop;
end;
$$;
