# DESIGN.md - FYP Expo Hub Design System

Based on the Google Stitch UI project "FYP Expo Hub", this document defines the visual system, style guide, tokens, and components for the Phase 1 Flutter Web implementation.

## 1. Project Identity
- **Project Name:** FYP Expo Hub
- **Theme Name:** Academic Excellence Hub
- **Aesthetic:** Corporate / Modern / Academic Prestige. It balances the stability of a traditional university with the kinetic energy of student innovation.
- **Brand Colors ("Ink & Terracotta", since PR #10):** Aubergine Ink (primary stability) contrasted with Terracotta/Apricot (accents, excellence/winners) and Deep Verdigris (success/status) on Warm Paper. This replaced the original Stitch navy/gold/teal palette role for role at the same lightness, so every text/background pair keeps its contrast.

---

## 2. Design Tokens

### Colors
| Token | Hex Value | Flutter Color Code | Usage |
| :--- | :--- | :--- | :--- |
| **primary** | `#2A1838` | `Color(0xFF2A1838)` | Aubergine Ink (App bars, primary structural headers, dark backgrounds) |
| **primary-container** | `#3D2A52` | `Color(0xFF3D2A52)` | Plum (Cards, sidebar background, containers) |
| **on-primary** | `#FFFFFF` | `Color(0xFFFFFFFF)` | Text on primary |
| **on-primary-container**| `#C2AEDD` | `Color(0xFFC2AEDD)` | Lilac (Secondary text on primary container) |
| **secondary** | `#9A3A12` | `Color(0xFF9A3A12)` | Terracotta (Accents, links, labels, category tags) |
| **secondary-container** | `#F6B48A` | `Color(0xFFF6B48A)` | Apricot (Highlight buttons, winner badge container) |
| **on-secondary-container**| `#6E2609` | `Color(0xFF6E2609)` | Burnt Umber (Text on apricot badges) |
| **tertiary** | `#0B2A26` | `Color(0xFF0B2A26)` | Deep Verdigris (Interactive states, technical badges) |
| **tertiary-container** | `#12423B` | `Color(0xFF12423B)` | Verdigris container |
| **on-tertiary-container**| `#84CDB8` | `Color(0xFF84CDB8)` | Sage Mint (Status text "Ongoing") |
| **background** | `#FAF7F2` | `Color(0xFFFAF7F2)` | Warm Paper (Canvas background) |
| **on-background** | `#1E1A20` | `Color(0xFF1E1A20)` | Ink Black (Primary text color) |
| **surface** | `#FAF7F2` | `Color(0xFFFAF7F2)` | Standard surfaces (Warm Paper) |
| **surface-container-lowest**| `#FFFFFF`| `Color(0xFFFFFFFF)` | White (Cards, inputs, dialogs background) |
| **surface-container-low**| `#F3EEE7` | `Color(0xFFF3EEE7)` | Parchment (Secondary background sections) |
| **surface-container**| `#ECE5DB` | `Color(0xFFECE5DB)` | Dividers, borders |
| **surface-container-highest**| `#E0D7CA`| `Color(0xFFE0D7CA)` | Outline, inactive elements, offline banner |
| **on-surface-variant** | `#4E4652` | `Color(0xFF4E4652)` | Muted body text, icons |
| **outline-variant** | `#CFC5BA` | `Color(0xFFCFC5BA)` | Input borders, separator lines |
| **error** | `#BA1A1A` | `Color(0xFFBA1A1A)` | Standard warning / error states |
| **error-container** | `#FFDAD6` | `Color(0xFFFFDAD6)` | Light Red (Alert background) |
| **on-error-container**| `#93000A` | `Color(0xFF93000A)` | Dark Red text |

Source of truth: `DesignSystem` in `lib/app/theme/theme.dart` — change colours there, then update this table.

**Contrast audit (G-34).** `test/app/theme_contrast_test.dart` checks 17 text/background pairs drawn from these tokens (body, muted, primary, secondary, tertiary and error text on page/card/parchment/offline banner; white on primary and secondary; each `on-*-container` on its container) and fails if any is below WCAG AA for body text (4.5 : 1). Decorative icons in `outline-variant` are exempt.

### Typography
- **Headlines:** `Montserrat` (Architectural, bold, authoritative)
- **Body & Labels:** `Inter` (Highly legible, clean sans-serif)

| Style | Font Family | Size | Weight | Line Height | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **h1** | Montserrat | `40px` | Bold (`700`) | `1.2` | Hero title (Desktop) |
| **h1-mobile**| Montserrat | `32px` | Bold (`700`) | `1.2` | Hero title (Mobile) |
| **h2** | Montserrat | `32px` | Semibold (`600`) | `1.3` | Section headings |
| **h3** | Montserrat | `24px` | Semibold (`600`) | `1.3` | Grid headers, card titles, app bar logo |
| **body-lg** | Inter | `18px` | Regular (`400`) | `1.6` | Hero body text, introduction |
| **body-md** | Inter | `16px` | Regular (`400`) | `1.5` | Standard body paragraphs, inputs |
| **body-sm** | Inter | `14px` | Regular (`400`) | `1.5` | Supporting notes, secondary descriptions |
| **label-caps**| Inter | `12px` | Semibold (`600`) | `1.0` (tracking: `0.05em`) | Badges, small metadata tags |
| **button** | Inter | `16px` | Medium (`500`) | `1.0` | Call to action text |

### Border Radius (Shapes)
- **sm (Default):** `4px` (`BorderRadius.circular(4)`) - Standard tags, small metadata chips, checkboxes.
- **lg:** `8px` (`BorderRadius.circular(8)`) - Standard buttons, input fields, project cards.
- **xl:** `12px` (`BorderRadius.circular(12)`) - Large panels, dialogs, Hero section.
- **full:** `9999px` - Pill-shaped buttons, status tags, main CTA.

### Spacing & Grid (8px Base Unit)
- **xs:** `4px`
- **sm:** `8px`
- **md:** `16px`
- **lg:** `24px`
- **xl:** `32px`
- **gutter:** `24px`
- **margin-mobile:** `16px`
- **margin-desktop:** `48px`

---

## 3. Screen Inventory & Route Mapping

| Screen ID | Title in Stitch | Flutter Web Route | Viewport | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `6dca3b84b49a4fe7bdcfd4604d4df84f` | Home | `/` | Desktop | Public homepage |
| `41c591865ba24f838657160365a7d4fb` | Home | `/` | Mobile | Public homepage |
| `1bae2efeba164c2abe50d8794c4abfa0` | Exhibition Info | `/info` | Desktop | Exhibition detailed info |
| `6591c7d1ad254d699702d93fed3e3e59` | Schedule | `/schedule` | Desktop | Public schedule |
| `4a33cffca60e43588d29ef0cb0b3252e` | Schedule | `/schedule` | Mobile | Public schedule |
| `da3172db56234688b1a298ea43de3ada` | Project Catalogue | `/projects` | Desktop | Projects list and directory |
| `3902bb28115c437e9de0757773720ac8` | Project Catalogue | `/projects` | Mobile | Projects list and directory |
| `6264ae26c2d1465e94598a9455d48295` | Project Details | `/projects/:slug` | Desktop | Detailed project page |
| `4722e2dae7d54023ad01b4ef3774d8e5` | Project Details | `/projects/:slug` | Mobile | Detailed project page |
| `b4f6be1cf9154951869f69a338e80ad9` | Find Booth | `/booths` | Desktop | Booth lookup |
| `bc18d1e840e3488cb04a503286fabd62` | Find Booth | `/booths` | Mobile | Booth lookup |
| `f2c389228ffd4ada8941e0428b0ac2c1` | Announcements | `/announcements` | Desktop | Public announcements |
| `457163eb5a344e0293fe9560845fbeac` | Announcements | `/announcements` | Mobile | Public announcements |
| `95b41ae033f448f4b6deb5fe3c5d4dd0` | Overview | `/admin` | Desktop | Admin CMS home / statistics |
| `d30387703e6446c7977bd85d676df8a4` | Overview | `/admin` | Mobile | Admin CMS home / statistics |
| `de958c7fc8af4c8fa67bb9812214e240` | Update Information | `/admin/event` | Desktop | Event information editor |
| `86d9205b43994d32a97e15ec1d617c99` | Schedule Management | `/admin/schedule` | Desktop | Schedule timeline manager |
| `bf0b04e366884ea5964a28f7a36b4dda` | Import Master File | `/admin/imports` | Desktop | Secure XLSX file import landing |
| `910da16e09d242bfb0266ed4edb9bde8` | Data Matching | `/admin/imports/:id` | Desktop | Excel parsing staging & review dashboard |

*Note: For routes with missing dedicated Stitch screens (like `/awards`, `/admin/awards`, `/admin/projects`, etc.), closest available Stitch components and page layouts will be extended as documented below.*

---

## 4. UI Patterns & Guidelines

### Public Navigation Layout
- **Desktop Navbar:** Top fixed 64px bar, background `#FAF7F2` (Warm Paper), left-aligned Bold "FYP Expo Hub" text, middle-aligned links (Home, Schedule, Projects, Booths) with hover states, right-aligned accent action button ("Register" or similar).
- **Mobile Navbar:** Top fixed 64px header + bottom navigation bar (height 56px, rounded top corners `12px`, subtle shadow), containing bottom tabs for quick access (Home, Projects, Booths, Menu).

### Admin Portal Shell
- Split layout: Fixed left sidebar (`260px` wide) using Aubergine Ink (`#2A1838`) for structural navigation, and a fluid main canvas utilizing White (`#FFFFFF`) surfaces on top of a Warm Paper (`#FAF7F2`) background.
- Clean typography and data-focused layout with standard 1px borders in `#ECE5DB`.

### Master File Import Review & Staging Area (Data Matching)
- Layout uses a Multi-Tab view:
  1. **Event Info** - Form-style fields comparing candidate values with option to accept/edit/skip.
  2. **Schedule** - Data table showing candidates with classification labels (publicCandidate, internal, needsReview, invalid). Includes actionable buttons per row (Publish, Save Draft, Mark Internal, Skip).
  3. **Awards** - List of parsed categories and winners.
  4. **Privacy Skips** - Summarized, non-sensitive counts.
  5. **Validation Warnings** - Visual list of warnings (overlap, format issues, unparsed sheets).
  6. **Change Comparison** - Color-coded indicators showing new vs updated vs unchanged items.

---

## 5. Visit Tracker UI Patterns (Extended Feature)

### Lecturer Visit Page (`/lecturer/visits`)
- **Progress Cards**: Two side-by-side cards showing SV and EX completion counts with progress bars. SV uses Aubergine Ink (`#2A1838`, primary), EX uses Deep Verdigris (`#0B2A26`, tertiary).
- **Filter Bar**: Role filter (All/SV/EX) and status filter (All/Not Yet Visited/Visited/Voided) using `ChoiceChip`. Search field with prefix icon.
- **Visit Project Cards**: Compact horizontal card with cover thumbnail (80x60), project title, student names, role chip (SV/EX), booth number, and status chip. Status chips: green check for "Visited", red for "Voided", grey for "Not Yet".
- **Sign-in Prompt**: When not authenticated, shows centered login icon with CTA button leading to `/lecturer/sign-in`.
- **Empty State**: Search icon with "No projects found" or check icon with "All projects have been visited!".

### Lecturer Sign-in (`/lecturer/sign-in`)
- **Auth Card**: Centered form card (max 400px) with lecturer name badge, email/password fields, and "Sign In" primary button.

### Lecturer Visit Detail (`/lecturer/visits/:projectId`)
- **Project Info Card**: Cover image (180px), title, students, programme, booth number.
- **Visit Section**: Per-role (SV/EX) card showing:
  - Status chip (Visited/Voided/Not Yet Visited)
  - Visit timestamp and note (if visited)
  - "Mark as Visited" primary button (if unvisited)
  - "Cancel Visit" outline error button with 30-min undo window
- **Mark as Visited Dialog**: Bottom sheet with project info, role, optional note field, confirm button.
- **Undo Dialog**: Alert with mandatory reason field.

### Admin Visit Page (`/admin/visits`)
- **Summary Cards**: Row of stat cards showing total, completed, pending, percentage, SV/EX breakdown, today's visits, and voided count. Responsive: 4 per row on desktop, 2 per row on mobile.
- **Tabs**: Overview (data table), By Lecturer (grouped list), By Project (grouped list), Visit Log (chronological feed).
- **Data Table**: Desktop uses `DataTable` with columns: Lecturer, Role, Student, Project, Booth, Status, Time, Actions. Mobile uses card list.
- **Filters**: Role filter, status filter, search field, export CSV button.
- **Void Dialog**: Admin-only void action with mandatory reason.

### Status Chips (Visit-specific)
- **Visited (Completed)**: Verdigris container with check icon, Sage Mint `#84CDB8` text.
- **Voided**: Error container with red text, `#93000A`.
- **Not Yet (Pending)**: Grey container with muted text, `#4E4652`.

## 6. Documented UI Extensions (Responsive & Missing States)
- **Awards Page (`/awards`):** Recreates the standard Project Card grid with a modified "Winner" Apricot badge in `#F6B48A` (secondary-container) showing the category name and a trophy icon.
- **Sign-in Page (`/admin/sign-in`):** Uses a centered, card-based login modal matching the typography and color scheme (Aubergine Ink primary button, Montserrat title, 8px rounded container).
- **Error/Empty States:** Illustrated using thin-line icons (stroke 2px) in muted `#4E4652`, labelled in English using `body-md` and `body-sm`.
