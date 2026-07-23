# STITCH_IMPLEMENTATION.md - Flutter UI Implementation Tracker

This document tracks the status of all screens and routes, mapping them directly to Stitch assets and tracing their backend integration progress.

| Stitch Screen ID | Screen Title | Flutter Route | Implementation Status | Backend Integration | Responsive Status | Notes / Adaptation |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `6dca3b84b49a4fe7bdcfd4604d4df84f` | Utama (Desktop) | `/` | ⏳ Pending | ⏳ Pending | 🟢 Fluid 12-column | Main landing page |
| `41c591865ba24f838657160365a7d4fb` | Utama (Mobile) | `/` | ⏳ Pending | ⏳ Pending | 🟢 Fluid 4-column | Bottom navigation bar active |
| `1bae2efeba164c2abe50d8794c4abfa0` | Maklumat Pameran | `/info` | ⏳ Pending | ⏳ Pending | 🟢 Fluid | Dynamic info page from Firestore |
| `6591c7d1ad254d699702d93fed3e3e59` | Tentatif (Desktop) | `/schedule` | ⏳ Pending | ⏳ Pending | 🟢 Responsive grid| Interactive timeline filter |
| `4a33cffca60e43588d29ef0cb0b3252e` | Tentatif (Mobile) | `/schedule` | ⏳ Pending | ⏳ Pending | 🟢 Stacked card list| Vertical mobile timeline view |
| `da3172db56234688b1a298ea43de3ada` | Katalog Projek (Desktop) | `/projects` | ⏳ Pending | ⏳ Pending | 🟢 3-4 Column Grid | Grid of projects with filter/search |
| `3902bb28115c437e9de0757773720ac8` | Katalog Projek (Mobile) | `/projects` | ⏳ Pending | ⏳ Pending | 🟢 1-Column List | Responsive stacked list, side drawer |
| `6264ae26c2d1465e94598a9455d48295` | Maklumat Projek (Deskt) | `/projects/:slug` | ⏳ Pending | ⏳ Pending | 🟢 Two-column layout| Details + public links + sidebar |
| `4722e2dae7d54023ad01b4ef3774d8e5` | Maklumat Projek (Mobil) | `/projects/:slug` | ⏳ Pending | ⏳ Pending | 🟢 Stacked columns | Fullscreen project image on top |
| `b4f6be1cf9154951869f69a338e80ad9` | Cari Booth (Desktop) | `/booths` | ⏳ Pending | ⏳ Pending | 🟢 Two-column list | Interactive list + booth search |
| `bc18d1e840e3488cb04a503286fabd62` | Cari Booth (Mobile) | `/booths` | ⏳ Pending | ⏳ Pending | 🟢 Stacked search | Single-column search & list |
| `f2c389228ffd4ada8941e0428b0ac2c1` | Pengumuman (Desktop) | `/announcements` | ⏳ Pending | ⏳ Pending | 🟢 Grid layout | Card listings, pinned announcements |
| `457163eb5a344e0293fe9560845fbeac` | Pengumuman (Mobile) | `/announcements` | ⏳ Pending | ⏳ Pending | 🟢 Stacked | Full-width announcement details |
| *Extended* | Pemenang Anugerah (Deskt) | `/awards` | ⏳ Pending | ⏳ Pending | 🟢 Grid | Gold-themed awards winner listing |
| *Extended* | FAQ & Privacy | `/faq`, `/privacy` | ⏳ Pending | ⏳ Pending | 🟢 Fluid | Informational text, simple layouts |
| `95b41ae033f448f4b6deb5fe3c5d4dd0` | Overview (Desktop) | `/admin` | ⏳ Pending | ⏳ Pending | 🟢 Sidebar Layout | Admin Home statistics panel |
| `d30387703e6446c7977bd85d676df8a4` | Overview (Mobile) | `/admin` | ⏳ Pending | ⏳ Pending | 🟢 Stacked | Compressed statistics cards |
| `de958c7fc8af4c8fa67bb9812214e240` | Kemaskini Maklumat | `/admin/event` | ⏳ Pending | ⏳ Pending | 🟢 Two-column | Input form with tabs and text fields |
| `86d9205b43994d32a97e15ec1d617c99` | Pengurusan Tentatif | `/admin/schedule` | ⏳ Pending | ⏳ Pending | 🟢 Data-table | Interactive table with CRUD popups |
| `bf0b04e366884ea5964a28f7a36b4dda` | Import Master File | `/admin/imports` | ⏳ Pending | ⏳ Pending | 🟢 Center drop-zone| Drag-and-drop / selector panel |
| `910da16e09d242bfb0266ed4edb9bde8` | Padanan Data | `/admin/imports/:id`| ⏳ Pending | ⏳ Pending | 🟢 Multi-tab grid | Complex staging data manager |
| *Extended* | Admin Projects | `/admin/projects` | ⏳ Pending | ⏳ Pending | 🟢 Data-table | Manual projects manager |
| *Extended* | Admin Booths | `/admin/booths` | ⏳ Pending | ⏳ Pending | 🟢 Grid list | Booth layout & project linkage |
| *Extended* | Admin Announcements | `/admin/announcements`| ⏳ Pending | ⏳ Pending | 🟢 List | Pinned and expiration manager |
| *Extended* | Admin Awards | `/admin/awards` | ⏳ Pending | ⏳ Pending | 🟢 Multi-tab | Award categories & winners manager |
| *Extended* | Admin Sign-In | `/admin/sign-in` | ⏳ Pending | ⏳ Pending | 🟢 Centered box | Auth and administrative entrance |
| *Extended* | Admin Settings | `/admin/settings` | ⏳ Pending | ⏳ Pending | 🟢 Fluid form | Configurations panel |

---

## Technical Baseline Compliance
- **Flutter Framework:** Stable channel v3.44.0.
- **Routing:** GoRouter with Admin claim guards.
- **State Management:** Riverpod.
- **Design Alignment:** Strictly maps colors, borders, shadows, and typography to Stitch tokens.
