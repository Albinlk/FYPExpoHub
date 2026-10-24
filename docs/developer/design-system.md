# Design system: FYP Expo Hub, "Scholar + Lab"

FSKM UiTM Jasin Final Year Project platform. Two sites, one design language. This file is written so it can be fed to Google Stitch as-is; the source of truth for values is `DesignSystem` in `lib/app/theme/theme.dart`.

- **Exhibition site** (public), `fskmjasinfypexhibition.site`: the FYP Exhibition (projects, booths, schedule, awards, announcements) and the Past Projects Guide. The exhibition home is the default homepage.
- **FYP Workspace** (sign-in only), today at `/fypms`, later `fyp.fskmjasinfypexhibition.site`: CSP600 Project Formulation and CSP650 Final Year Project, for students, supervisors, examiners, course lecturers, the coordinator and the Programme Unit.

## 1. Visual theme and atmosphere

Academic, but catchy. Modern, but simple.

The site should look like a university research journal crossed with a computing lab notebook. Serif headlines give it scholarly weight. Monospace labels for codes and numbers say "computing faculty". A faint graph-paper grid behind the hero sections suggests engineering paper.

- Mood: confident, calm, precise, a little playful in the details (numbered sections, code-style tags).
- Density: airy on public pages, compact and data-first in the Workspace.
- Light theme only. Warm paper background, never pure white pages, never pure black text.
- One accent colour (terracotta). Everything else is ink and paper.
- Avoid: purple/blue "AI gradients", glassmorphism, neon, stock photos of people, emoji, three identical feature cards in a row.

## 2. Colour palette and roles

| Role | Name | Hex | Use |
|---|---|---|---|
| primary | Aubergine Ink | #2A1838 | Headlines, nav text, primary structural elements, dark sections |
| primary-container | Plum | #3D2A52 | Dark panels, Workspace sidebar |
| on-primary | White | #FFFFFF | Text on ink |
| on-primary-container | Lilac | #C2AEDD | Secondary text on plum |
| secondary (accent) | Terracotta | #9A3A12 | The single accent: primary buttons, links, active states, section numbers |
| secondary-container | Apricot | #F6B48A | Winner badges, highlighted chips |
| on-secondary-container | Burnt Umber | #6E2609 | Text on apricot |
| tertiary | Deep Verdigris | #0B2A26 | Status only (done, approved, visited) |
| tertiary-container | Verdigris | #12423B | Status chip background |
| on-tertiary-container | Sage Mint | #84CDB8 | Status text on verdigris |
| background / surface | Warm Paper | #FAF7F2 | Page background |
| surface-container-lowest | White | #FFFFFF | Cards, inputs, dialogs |
| surface-container-low | Parchment | #F3EEE7 | Alternate sections, highlighted (public) card, code tags |
| surface-container | Sand | #ECE5DB | Dividers |
| outline-variant / rule | Rule | #CFC5BA | Hairline rules, card borders, input borders |
| on-background | Ink Black | #1E1A20 | Body text |
| on-surface-variant | Muted Ink | #4E4652 | Secondary text, icons |
| grid-line | Ink 6% | #2A1838 at 6% opacity | Graph-paper lines only |
| error | Red | #BA1A1A | Errors (container #FFDAD6, text #93000A) |

All text/background pairs above meet WCAG AA (4.5:1); `test/app/theme_contrast_test.dart` checks them, including text sitting on a graph-paper line. Terracotta is the only accent; verdigris is reserved for status.

## 3. Typography

Three families, each with one job:

- **Fraunces** (serif, 72pt optical size): display and page headlines. Academic and characterful.
- **Inter** (sans): body, UI, buttons, card titles.
- **JetBrains Mono** (mono): codes and numbers: booth codes (BK1-07), programme codes (CS266), form codes (F6b), matric numbers, kickers, statistics, section numbers.

| Style | Family | Size (desktop / mobile) | Weight | Line height | Tracking | Use |
|---|---|---|---|---|---|---|
| display | Fraunces | 56 / 40 | 700 | 1.05 | -0.02em | Hero headline only |
| h1 | Fraunces | 40 / 32 (28 for page titles) | 700 | 1.15 | -0.02em | Page titles |
| h2 | Fraunces | 30 / 24 | 600 | 1.2 | -0.01em | Section titles |
| h3 | Inter | 20 / 18 | 600 | 1.3 | 0 | Card titles, panel headings |
| body-lg | Inter | 18 / 16 | 400 | 1.6 | 0 | Intros, hero sub-line |
| body | Inter | 16 | 400 | 1.5 | 0 | Paragraphs, inputs |
| body-sm | Inter | 14 | 400 | 1.5 | 0 | Notes, meta |
| kicker | JetBrains Mono | 12 | 500 | 1.2 | +0.08em, uppercase | Eyebrows above headlines ("FSKM · UiTM JASIN") |
| code | JetBrains Mono | 13 | 500 | 1.2 | 0 | Code tags (BK1-07, CS266, F9) |
| stat | JetBrains Mono | 32 / 26 | 500 | 1.0 | -0.01em | Big numbers in stat blocks |
| button | Inter | 15 | 600 | 1.0 | 0 | Buttons |

Rules:
- Paragraphs at most about 65 characters wide.
- Title Case for buttons and page titles; sentence case for body copy.
- No all-caps except mono kickers.

Font files: the bundled `.ttf` files in `assets/fonts/` are subsets (Latin,
punctuation, arrows, maths and a few symbols; every weight kept), 0.75 MB
instead of 1.85 MB. Regenerate them from the upstream files with
`python tool/subset_fonts.py <originals-dir>` after adding text in another
script. A missing glyph still shows, through Flutter's Noto fallback.

## 4. Component styles

- **Navigation (exhibition)**: 64px Warm Paper bar with a hairline bottom rule. Left: wordmark, serif "FYP" plus small mono "EXPO·HUB". Centre: text links in Inter; the active link is ink and bold with a 2px underline. Right: "Sign In" ink pill button. Narrow desktops move extra links into a "More" menu (all links from 1312px, five from 1024px, three below). Mobile: bottom tab bar (Home, Booths, Guide, Staff, Menu), white with 12px top corners.
- **Navigation (Workspace)**: left sidebar 260px in Aubergine Ink with Lilac text. Wordmark with the subtitle "Workspace · CSP600 · CSP650". Main canvas on Warm Paper with white cards.
- **Hero (public home)**: light Warm Paper hero over a 24px graph-paper grid (grid-line colour), left-aligned, never centred.
  - Order: mono kicker "FSKM · UiTM JASIN", then the display headline "Final Year Project Exhibition 2026", then a mono meta line "6 AUG 2026 · DEWAN · 9:00".
  - Then a terracotta primary button "Explore Projects →" and a search field.
  - On the right, a stat card: three stat blocks (Projects, Programmes, Booths) with mono numbers and mono labels, separated by hairline rules.
  - The countdown is one compact mono line ("02d 14h 05m to opening"), not boxes.
- **Section header**: mono number in terracotta ("01"), serif h2 title, a hairline rule filling the rest of the line, and an optional text link on the right ("View All →"). Home-page sections: 01 Featured projects, 02 Award winners, 03 Past Projects Guide, 04 Plan your visit.
- **Project card**: white, 1px rule border, 8px radius, no shadow. A 3px left stripe in a palette colour by category. Cover image 16:9 on top (fallback: ink pattern with the project initials). Inter h3 title (2 lines max). Team names in body-sm muted. Footer row of code tags (booth, programme).
- **Code tag**: JetBrains Mono 13, 4px radius, Parchment fill, ink text, 1px rule border. Winner variant: Apricot fill with Burnt Umber text and a trophy icon.
- **Stat block**: mono uppercase label (12, muted) above a mono number (32, ink).
- **Buttons**:
  - Primary: terracotta fill, white text, 8px radius, 48px tall, trailing arrow on calls to action.
  - Secondary: ink 1px outline, ink text.
  - Tertiary: text link in terracotta.
  - 200ms transitions; visible focus ring.
- **Inputs**: white, 1px rule border, 8px radius, 48px tall; focus border 2px ink; inline error text in red below the field.
- **Status chips (Workspace)**: verdigris container with Sage Mint text (done or approved); Apricot (awaiting); red container (rejected or overdue); Parchment (not started).
- **Dialogs**: white, 12px radius, max 480px wide, actions right-aligned (text Cancel plus primary).
- **Workspace band (public home footer)**: Parchment strip with a mono kicker "FYP WORKSPACE", the line "CSP600 Project Formulation and CSP650 Final Year Project", and an "Open FYP Workspace →" button. This is the only place the public site advertises the Workspace.

## 5. Layout principles

- 8px spacing scale: 4, 8, 16, 24, 32, 48, 64. Section spacing 64 desktop, 40 mobile.
- Content max width 1200px, centred, with 48px side margins (16px on mobile).
- Heroes split 7 / 5 (headline / stat card) on desktop.
- Asymmetry over symmetry: left-aligned headlines, no centred hero.
- Buttons pinned to the bottom of cards in a row; titles, meta and tags align across cards.
- Graph paper only behind heroes and empty states, never behind body text.

## 6. Depth and elevation

Flat and editorial. Hierarchy comes from rules, paper tones and spacing, not shadows.
- Level 0: Warm Paper page.
- Level 1: white card with a 1px rule border, no shadow.
- Level 2 (menus, dialogs only): soft ink-tinted shadow.

## 7. Motion

Subtle, purposeful, respects reduced motion.
- Sections fade in with a 12px lift, 260ms, staggered 45ms (`StaggeredEntrance`).
- The cover image morphs from the project card into the detail page.
- No parallax, no autoplay carousels.

## 8. Responsive behaviour

| Width | Behaviour |
|---|---|
| < 768 | Bottom tab bar; hero stacks (headline, then stats as a 3-column strip); cards in 1 column |
| 768–1023 | Top bar with 3 links plus More; cards in 2 columns |
| 1024–1311 | 5 links plus More; cards in 3 columns |
| ≥ 1312 | All links; cards in 3–4 columns within the 1200px container |

## 9. Do's and don'ts

**Do:**
- Use mono for every code and number.
- Number home-page sections.
- Keep one accent colour.
- Write plain, specific copy ("Find your booth", "Submit F6(b)").

**Don't:**
- Use gradients on buttons or text.
- Use more than one accent.
- Centre long paragraphs.
- Write "Elevate", "Seamless" or "Unleash".
- Add exclamation marks in messages.
- Use the UiTM logo without permission (use the wordmark).

## 10. Screens to generate

Public, exhibition site:
1. **Home (exhibition)**, desktop and mobile: graph-paper hero with stat card; 01 Featured projects; 02 Award winners; 03 Past Projects Guide teaser; 04 Plan your visit (date, venue, schedule link, booth finder link); Workspace band.
2. **Project catalogue**: search plus filter chips (programme, category, booth zone) and a project-card grid.
3. **Project detail**: large cover, serif title, code tags (booth, programme), team and supervisor, abstract, "Find this booth" button.
4. **Booth finder**: search by booth code or name; zone tabs (BK1, BK2…); list of code-tag rows.
5. **Schedule**: day tabs; timeline rows with mono times.
6. **Award winners**: category section headers; winner cards with the Apricot tag.
7. **Past Projects Guide**: filter by programme and semester; compact rows (title, programme code, year); "similar projects" clusters.
8. **Sign In**: centred white card on graph paper; wordmark; email and password; the note "Students and lecturers use one account".

Sign-in only, FYP Workspace:
9. **Student dashboard (CSP600)**: sidebar; course chip; progress strip of forms F1–F8 as code tags with status; next deadline; supervisor card.
10. **Student dashboard (CSP650)**: forms F5, F6b, F9–F16; "My Exhibition" card (booth code, day, publication status); final report approval status.
11. **Supervisor dashboard**: assigned students table (matric in mono, course chip, status chips, next action).
12. **Course lecturer, CSP600 "Examiners & Handover"**: table with an assign-examiner action and a "Hand over to CSP650" button.
13. **PU nominations**: nomination cards with "View CV", the declaration line, and Approve / Reject.

---

## Appendix: earlier patterns still in use

These describe screens built before "Scholar + Lab". They keep working; restyle them with the tokens above when they are next touched.

### A1. Admin portal shell
- Split layout: Fixed left sidebar (`260px` wide) using Aubergine Ink (`#2A1838`) for structural navigation, and a fluid main canvas utilizing White (`#FFFFFF`) surfaces on top of a Warm Paper (`#FAF7F2`) background.
- Clean typography and data-focused layout with standard 1px borders in `#ECE5DB`.

#### Master file import review (data matching)
- Layout uses a Multi-Tab view:
  1. **Event Info** - Form-style fields comparing candidate values with option to accept/edit/skip.
  2. **Schedule** - Data table showing candidates with classification labels (publicCandidate, internal, needsReview, invalid). Includes actionable buttons per row (Publish, Save Draft, Mark Internal, Skip).
  3. **Awards** - List of parsed categories and winners.
  4. **Privacy Skips** - Summarized, non-sensitive counts.
  5. **Validation Warnings** - Visual list of warnings (overlap, format issues, unparsed sheets).
  6. **Change Comparison** - Color-coded indicators showing new vs updated vs unchanged items.


### A2. Visit tracker patterns

#### Lecturer Visit Page (`/lecturer/visits`)
- **Progress Cards**: Two side-by-side cards showing SV and EX completion counts with progress bars. SV uses Aubergine Ink (`#2A1838`, primary), EX uses Deep Verdigris (`#0B2A26`, tertiary).
- **Filter Bar**: Role filter (All/SV/EX) and status filter (All/Not Yet Visited/Visited/Voided) using `ChoiceChip`. Search field with prefix icon.
- **Visit Project Cards**: Compact horizontal card with cover thumbnail (80x60), project title, student names, role chip (SV/EX), booth number, and status chip. Status chips: green check for "Visited", red for "Voided", grey for "Not Yet".
- **Sign-in Prompt**: When not authenticated, shows centered login icon with CTA button leading to `/lecturer/sign-in`.
- **Empty State**: Search icon with "No projects found" or check icon with "All projects have been visited!".

#### Lecturer Sign-in (`/lecturer/sign-in`)
- **Auth Card**: Centered form card (max 400px) with lecturer name badge, email/password fields, and "Sign In" primary button.

#### Lecturer Visit Detail (`/lecturer/visits/:projectId`)
- **Project Info Card**: Cover image (180px), title, students, programme, booth number.
- **Visit Section**: Per-role (SV/EX) card showing:
  - Status chip (Visited/Voided/Not Yet Visited)
  - Visit timestamp and note (if visited)
  - "Mark as Visited" primary button (if unvisited)
  - "Cancel Visit" outline error button with 30-min undo window
- **Mark as Visited Dialog**: Bottom sheet with project info, role, optional note field, confirm button.
- **Undo Dialog**: Alert with mandatory reason field.

#### Admin Visit Page (`/admin/visits`)
- **Summary Cards**: Row of stat cards showing total, completed, pending, percentage, SV/EX breakdown, today's visits, and voided count. Responsive: 4 per row on desktop, 2 per row on mobile.
- **Tabs**: Overview (data table), By Lecturer (grouped list), By Project (grouped list), Visit Log (chronological feed).
- **Data Table**: Desktop uses `DataTable` with columns: Lecturer, Role, Student, Project, Booth, Status, Time, Actions. Mobile uses card list.
- **Filters**: Role filter, status filter, search field, export CSV button.
- **Void Dialog**: Admin-only void action with mandatory reason.

#### Status Chips (Visit-specific)
- **Visited (Completed)**: Verdigris container with check icon, Sage Mint `#84CDB8` text.
- **Voided**: Error container with red text, `#93000A`.
- **Not Yet (Pending)**: Grey container with muted text, `#4E4652`.

### A3. Other documented UI
- **Awards Page (`/awards`):** Recreates the standard Project Card grid with a modified "Winner" Apricot badge in `#F6B48A` (secondary-container) showing the category name and a trophy icon.
- **Sign-in Page (`/sign-in`):** Uses a centered, card-based login modal matching the typography and color scheme (Aubergine Ink primary button, Fraunces title, 8px rounded container).
- **Error/Empty States:** Illustrated using thin-line icons (stroke 2px) in muted `#4E4652`, labelled in English using `body-md` and `body-sm`.
