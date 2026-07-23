# DESIGN.md - FYP Expo Hub Design System

Based on the Google Stitch UI project "FYP Expo Hub", this document defines the visual system, style guide, tokens, and components for the Phase 1 Flutter Web implementation.

## 1. Project Identity
- **Project Name:** FYP Expo Hub
- **Theme Name:** Academic Excellence Hub
- **Aesthetic:** Corporate / Modern / Academic Prestige. It balances the stability of a traditional university with the kinetic energy of student innovation.
- **Brand Colors:** Deep Navy (primary stability) contrasted with Warm Gold/Amber (excellence/winners) and Teal (success/status).

---

## 2. Design Tokens

### Colors
| Token | Hex Value | Flutter Color Code | Usage |
| :--- | :--- | :--- | :--- |
| **primary** | `#031636` | `Color(0xFF031636)` | Deep Navy (App bars, primary structural headers, dark backgrounds) |
| **primary-container** | `#1a2b4c` | `Color(0xFF1A2B4C)` | Dark Navy (Cards, sidebar background, containers) |
| **on-primary** | `#ffffff` | `Color(0xFFFFFFFF)` | Text on primary |
| **on-primary-container**| `#8293ba` | `Color(0xFF8293BA)` | Secondary text on primary container |
| **secondary** | `#735c00` | `Color(0xFF735C00)` | Warm Gold/Amber (Accents, category tags) |
| **secondary-container** | `#fed65b` | `Color(0xFFFED65B)` | Bright Amber/Gold (Highlight buttons, winner badge container) |
| **on-secondary-container**| `#745c00` | `Color(0xFF745C00)` | Text on gold badges |
| **tertiary** | `#001b1b` | `Color(0xFF001B1B)` | Deep Teal (Interactive states, technical badges) |
| **tertiary-container** | `#003232` | `Color(0xFF003232)` | Teal Container |
| **on-tertiary-container**| `#3da2a1` | `Color(0xFF3DA2A1)` | Medium Teal (Status text "Sedang Berlangsung") |
| **background** | `#f6fafe` | `Color(0xFFF6FAFE)` | Warm Off-White (Canvas background) |
| **on-background** | `#171c1f` | `Color(0xFF171C1F)` | Primary text color |
| **surface** | `#f6fafe` | `Color(0xFFF6FAFE)` | Standard surfaces |
| **surface-container-lowest**| `#ffffff`| `Color(0xFFFFFFFF)` | White (Cards, inputs, dialogs background) |
| **surface-container-low**| `#f0f4f8` | `Color(0xFFF0F4F8)` | Very Light Grey-Blue (Secondary background sections) |
| **surface-container**| `#eaeef2` | `Color(0xFFEAEEF2)` | Light Grey-Blue (Dividers, borders) |
| **surface-container-highest**| `#dfe3e7`| `Color(0xFFDFE3E7)` | Outline, inactive elements |
| **on-surface-variant** | `#44474e` | `Color(0xFF44474E)` | Muted body text, icons |
| **outline-variant** | `#c5c6cf` | `Color(0xFFC5C6CF)` | Input borders, separator lines |
| **error** | `#ba1a1a` | `Color(0xFFBA1A1A)` | Standard warning / error states |
| **error-container** | `#ffdad6` | `Color(0xFFFFDAD6)` | Light Red (Alert background) |
| **on-error-container**| `#93000a` | `Color(0xFF93000A)` | Dark Red text |

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
| `6dca3b84b49a4fe7bdcfd4604d4df84f` | Utama | `/` | Desktop | Public homepage |
| `41c591865ba24f838657160365a7d4fb` | Utama | `/` | Mobile | Public homepage |
| `1bae2efeba164c2abe50d8794c4abfa0` | Maklumat Pameran | `/info` | Desktop | Exhibition detailed info |
| `6591c7d1ad254d699702d93fed3e3e59` | Tentatif | `/schedule` | Desktop | Public schedule |
| `4a33cffca60e43588d29ef0cb0b3252e` | Tentatif | `/schedule` | Mobile | Public schedule |
| `da3172db56234688b1a298ea43de3ada` | Katalog Projek | `/projects` | Desktop | Projects list and directory |
| `3902bb28115c437e9de0757773720ac8` | Katalog Projek | `/projects` | Mobile | Projects list and directory |
| `6264ae26c2d1465e94598a9455d48295` | Maklumat Projek | `/projects/:slug` | Desktop | Detailed project page |
| `4722e2dae7d54023ad01b4ef3774d8e5` | Maklumat Projek | `/projects/:slug` | Mobile | Detailed project page |
| `b4f6be1cf9154951869f69a338e80ad9` | Cari Booth | `/booths` | Desktop | Booth lookup |
| `bc18d1e840e3488cb04a503286fabd62` | Cari Booth | `/booths` | Mobile | Booth lookup |
| `f2c389228ffd4ada8941e0428b0ac2c1` | Pengumuman | `/announcements` | Desktop | Public announcements |
| `457163eb5a344e0293fe9560845fbeac` | Pengumuman | `/announcements` | Mobile | Public announcements |
| `95b41ae033f448f4b6deb5fe3c5d4dd0` | Overview | `/admin` | Desktop | Admin CMS home / statistics |
| `d30387703e6446c7977bd85d676df8a4` | Overview | `/admin` | Mobile | Admin CMS home / statistics |
| `de958c7fc8af4c8fa67bb9812214e240` | Kemaskini Maklumat | `/admin/event` | Desktop | Event information editor |
| `86d9205b43994d32a97e15ec1d617c99` | Pengurusan Tentatif| `/admin/schedule` | Desktop | Schedule timeline manager |
| `bf0b04e366884ea5964a28f7a36b4dda` | Import Master File| `/admin/imports` | Desktop | Secure XLSX file import landing |
| `910da16e09d242bfb0266ed4edb9bde8` | Padanan Data | `/admin/imports/:id` | Desktop | Excel parsing staging & review dashboard |

*Note: For routes with missing dedicated Stitch screens (like `/awards`, `/admin/awards`, `/admin/projects`, etc.), closest available Stitch components and page layouts will be extended as documented below.*

---

## 4. UI Patterns & Guidelines

### Public Navigation Layout
- **Desktop Navbar:** Top fixed 64px bar, background `#f6fafe`, left-aligned Bold "FYP Expo Hub" text, middle-aligned links (Utama, Tentatif, Projek, Booth) with hover states, right-aligned accent action button ("Daftar" or similar).
- **Mobile Navbar:** Top fixed 64px header + bottom navigation bar (height 56px, rounded top corners `12px`, subtle shadow), containing bottom tabs for quick access (Utama, Projek, Booth, Menu).

### Admin Portal Shell
- Split layout: Fixed left sidebar (`260px` wide) using Deep Navy (`#031636`) for structural navigation, and a fluid main canvas utilizing White (`#ffffff`) surfaces on top of a Warm Off-White (`#f6fafe`) background.
- Clean typography and data-focused layout with standard 1px borders in `#eaeef2`.

### Master File Import Review & Staging Area (Padanan Data)
- Layout uses a Multi-Tab view:
  1. **Event Info** - Form-style fields comparing candidate values with option to accept/edit/skip.
  2. **Schedule** - Data table showing candidates with classification labels (publicCandidate, internal, needsReview, invalid). Includes actionable buttons per row (Publish, Save Draft, Mark Internal, Skip).
  3. **Awards** - List of parsed categories and winners.
  4. **Privacy Skips** - Summarized, non-sensitive counts.
  5. **Validation Warnings** - Visual list of warnings (overlap, format issues, unparsed sheets).
  6. **Change Comparison** - Color-coded indicators showing new vs updated vs unchanged items.

---

## 5. Documented UI Extensions (Responsive & Missing States)
- **Awards Page (`/awards`):** Recreates the standard Project Card grid with a modified "Winner" gold badge in `#fed65b` showing the category name and a trophy icon.
- **Sign-in Page (`/admin/sign-in`):** Uses a centered, card-based login modal matching the typography and color scheme (Deep Navy primary button, Montserrat title, 8px rounded container).
- **Error/Empty States:** Illustrated using thin-line icons (stroke 2px) in muted `#44474e`, labeled in Bahasa Melayu and English using `body-md` and `body-sm`.
