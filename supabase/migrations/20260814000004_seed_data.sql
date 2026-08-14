-- ==============================================================================
-- FYP Expo Hub - Seed Data & Initial Settings Configuration
-- 20260814000004_seed_data.sql
-- ==============================================================================

-- -----------------------------------------------------------------------------
-- Default Settings
-- -----------------------------------------------------------------------------
insert into public.settings (key, value, updated_at)
values
  (
    'visit_tracker',
    '{
      "visitsEnabled": true,
      "allowVisitsBeforeEvent": false,
      "allowVisitsAfterEvent": false,
      "visitOpenAt": null,
      "visitCloseAt": null,
      "lecturerUndoWindowMinutes": 30
    }'::jsonb,
    now()
  ),
  (
    'excel_import',
    '{
      "maxFileSize": "10 MB",
      "mandatoryWorksheets": "SCHEDULE, AWARD WINNERS, COMMITTEE"
    }'::jsonb,
    now()
  )
on conflict (key) do update set
  value = excluded.value,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- Default Event
-- -----------------------------------------------------------------------------
insert into public.events (
  id,
  slug,
  title,
  session_label,
  start_at,
  end_at,
  daily_hours,
  venue,
  location_details,
  map_url,
  description,
  objectives,
  status,
  publication_status,
  hero_image_url,
  poster_url,
  public_contact_email,
  faq_items,
  created_at,
  updated_at
) values (
  '1977e782-430c-5f3f-a6c7-359f74650691'::uuid,
  'fskm-fyp-2026',
  'FSKM FYP Expo Hub 2026',
  'Semester March - August 2026',
  '2026-08-06 09:00:00+08',
  '2026-08-07 17:00:00+08',
  '9:00 AM - 5:00 PM',
  'Lecture Block, FSKM',
  'Seminar Hall & Lecture Rooms, Faculty of Computer and Mathematical Sciences (FSKM)',
  'https://maps.google.com/?q=FSKM+UiTM',
  'The Final Year Project Exhibition (FYP Expo) FSKM is a bi-annual event showcasing the dedication, innovation, and technical expertise developed by final-semester students of the Faculty of Computer and Mathematical Sciences (FSKM). This exhibition serves as a vital bridge connecting academic research with industry partners.',
  '[
    "Showcase the creativity and system design innovations of FSKM students.",
    "Provide a professional platform for presenting and defending project research outcomes.",
    "Foster strong collaboration networks among students, faculty, and industry leaders.",
    "Recognize outstanding achievements through best project award categories."
  ]'::jsonb,
  'active',
  'published',
  'assets/images/banner.jpg',
  'assets/images/poster.jpg',
  'fskmfypexpo@uitm.edu.my',
  '[
    {
      "question": "What is FYP Expo Hub?",
      "answer": "It is the official web portal for the Final Year Project Exhibition of the Faculty of Computer and Mathematical Sciences (FSKM)."
    },
    {
      "question": "Who can attend the exhibition?",
      "answer": "The exhibition is open to all UiTM students, faculty members, and external industry visitors who are interested in final year student innovations."
    },
    {
      "question": "Are there awards given to the projects?",
      "answer": "Projects are evaluated by a panel of industry and academic juries, and awards like Gold, Silver, Bronze, and Best Innovative Project are presented."
    }
  ]'::jsonb,
  now(),
  now()
)
on conflict (slug) do nothing;
