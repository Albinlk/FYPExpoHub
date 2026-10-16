# FYPMS vs *Essentials of Computing Sciences: Project Administration* (4th Edition)

| Item | Value |
|---|---|
| Reference | *Essentials of Computing Sciences: Project Administration*, 4th Edition, eds. Norjansalika Janom & Zolidah Kasiran, FSKM UiTM, 2022 (ISBN 978-967-0171-50-0) — "FYP Text Book" |
| Compared against | FYPMS on `main` @ `f7dae99c` (migrations, RPCs, `lib/features/fypms/`) — original audit; statuses below updated for `main` @ `3b9e6c95` |
| Date | 2026-09-26 (audit) · 2026-09-27 (status update: R1–R11 implemented and live in production) |
| Verdict | **Aligned in 25 of 28 areas** after R1–R11. Rubrics, marks weighting, who-evaluates-what, F1, F5, F6, F10, F14, deliverables, report minimums, REC, PU approval, supervisor change and RES export now follow the textbook. Three areas remain partially aligned (A19 examiner assignment UI, A20 presentation session types, A26 workflow states). *Original verdict (2026-09-26): partially aligned.* |

The textbook is summarised and paraphrased here; weights and percentages are quoted as facts for implementation.

---

## 1. What the textbook specifies

### 1.1 Roles

| Textbook role | Responsibilities (summary) | FYPMS role |
|---|---|---|
| Student | Registers, finds a supervisor, submits F1–F6, F13, presents, corrects report | `student` |
| Main supervisor | Primary contact; approves title, scope and methodology; signs F1, F5, F6 endorsement, F12, Supervisor Approval page; evaluates F7, F8, F10, F11, F13 | `supervisor` |
| Co-supervisor | Feedback on drafts; attends ≥ 2 supervision meetings per semester; covers for the main supervisor ("60/40" split, main supervisor leads decisions) | `co_supervisor` |
| Examiner | Evaluates F7, F8, F10, F11; signs F12 | `examiner` |
| Project Formulation lecturer (CSP600) | Runs the course; evaluates F2, F3, F4 and F7; signs F5; assigns examiners; records marks in RES | `csp600_lecturer` |
| Project lecturer (CSP650) | Runs the course; evaluates F9 and F13; distributes F10/F11; collects deliverables; records marks in RES | `csp650_lecturer` |
| FYP coordinator / resource person | Plans the exhibition and briefs students; may evaluate F9; handles supervisor changes | `fyp_coordinator` |
| Pengurus Utama (PU) programme | Approves or rejects supervisor/examiner nominations; issues appointment letters | `programme_head` (since R11 / PR #37; appointment letters are not generated) |

### 1.2 Forms and who completes them

| Form | Name | Stage | Completed by | Evaluated / signed by |
|---|---|---|---|---|
| F1 | Mutual Acceptance Form | CSP600 | Student | Supervisor (+ co-supervisor) sign |
| F2 | Project Motivation Evaluation | CSP600 | Student with supervisor | CSP600 lecturer |
| F3 | Literature Review Evaluation | CSP600 | Student | CSP600 lecturer |
| F4 | Methodology Evaluation | CSP600 | Student | CSP600 lecturer |
| F5 | Proposal/Project In-Progress (per consultation) | Both | Student | Supervisor / co-supervisor signs each entry |
| F6(a) | Project Formulation Report Submission | CSP600 | Student | Supervisor endorses similarity index (≤ 30 %) |
| F6(b) | Project Report Submission | CSP650 | Student | Supervisor endorses similarity index (≤ 30 %) |
| F7 | Project Formulation Presentation | CSP600 | — | CSP600 lecturer, supervisor, examiner |
| F8 | Project Formulation Report Evaluation | CSP600 | — | Supervisor, examiner |
| F9 | Progress Project Presentation | CSP650 | — | CSP650 lecturer / coordinator |
| F10 | Final Project Presentation (incl. poster, at exhibition) | CSP650 | — | Supervisor, examiner |
| F11 | Project Report Evaluation | CSP650 | — | Supervisor, examiner |
| F12 | Confirmation of Report Correction | CSP650 | — | Supervisor / examiner signs |
| F13 | Lean Canvas Model Evaluation | CSP650 | Student submits LMC | CSP650 lecturer (and supervisor) |
| F14 | Special Evaluation Qualification | CSP650 | — | Lecturer checks eligibility |
| F15 | Special Evaluation Presentation | CSP650 | — | Supervisor, examiner |
| F16 | Special Evaluation Report Evaluation | CSP650 | — | Supervisor, examiner |

### 1.3 Rubrics

All rubrics score each criterion **0–10** (Excellent 8–10, Good 6–7, Satisfactory 5, Poor 1–4, 0 = no evidence), and **Marks = Weight × Score**.

| Form | Criteria (weight) | Σ weight | Contribution to course grade |
|---|---|---|---|
| F2 | Problem identification (3), Evidences (5), Solutions (2) | 10 | not stated |
| F3 | Relevance and context (2), Knowledge of the field/sources (4), Writing (4) | 10 | not stated |
| F4 | Design of the methodology (3), Description (3), Model/Technique/Method (4) | 10 | not stated |
| F7 | Depth of knowledge (3), Overall organisation (2), Quality of presentation materials (2), Delivery skills (3) | 10 | CSP600 lecturer **10 %**, supervisor **10 %**, examiner **5 %** |
| F8 | Background & problem (3), Objectives (2), Significance (1), Literature review (5), Methodology (6), Presentation of report (3), Progress evaluation — supervisor only (2) | 22 | Supervisor **30 %**, examiner **15 %** |
| F9 | Depth of knowledge (3), Overall organisation (1), Progress vs Gantt/milestones (4), Delivery skills (2) | 10 | **10 %** (per F14) |
| F10 | Depth of knowledge (3), Organisation (1), Poster organisation (1), Complexity (2), Completeness (2), Delivery (1) | 10 | Supervisor **15 %**, examiner **15 %** |
| F11 — CLO 1 | Abstract (1), Introduction (1), Literature review (1), Methodology (2), Conclusion & recommendations (2), Report presentation (1), References & citations (2), Progress evaluation — supervisor only (1) | 11 | Supervisor **25 %**, examiner **20 %** |
| F11 — CLO 4 | Development (5), Findings/discussion (5) | 10 | Supervisor **5 %**, examiner **5 %** |
| F13 | Problem (2), Solution, Key metrics, UVP, Unfair advantage, Channels, Customer segments, Cost structure, Revenue streams (1 each) | 10 | **5 %** (per F14) |
| F15 | Same criteria and weights as F10 | 10 | Supervisor 15 %, examiner 15 % |
| F16 | Same criteria and weights as F11 (CLO 1 + CLO 4) | 11 + 10 | Supervisor 25 % + 5 %, examiner 20 % + 5 % |

CSP650 therefore sums to 100 %: F9 10 + F13 5 + F10 30 + F11 CLO1 45 + F11 CLO4 10. CSP600 states 70 % (F7 25 + F8 45); the remaining 30 % (F2–F4) is not allocated in the book.

### 1.4 Rules

| Rule | Textbook value |
|---|---|
| Maximum similarity index (F6a / F6b) | **30 %**, with the original plagiarism report attached and supervisor endorsement |
| Minimum academic references | Proposal **15**, final report **30**; at least half academic sources |
| Minimum report length | Proposal **30** pages, final report **50** pages |
| Consultation attendance | **80 %** required |
| Co-supervisor involvement | At least **2** supervision meetings per semester |
| F14 eligibility (special evaluation) | Continuous assessment ≥ 50 % — Progress (10 %) + LMC (5 %) ≥ 7.5 %; complete chapters 1–5 submitted; presented at the exhibition; in final semester with all other courses passed |
| Hardbound report | Only after F12 is signed |
| Missing the exhibition | Grade **F** |
| Incomplete (TL) | Agreed by supervisor and examiner when the project is half complete |
| Deliverables to CSP650 lecturer | Report (.pdf **and** .doc, with abstract and appendices), presentation slides, poster, raw data*, system with test data*, setup instructions, .apk/.exe* (*if relevant) |
| Ethics | REC forms submitted with the proposal where human subjects are involved |
| Supervisor changes | Discouraged; per F1 terms, only after the formulation phase, via the coordinator |

---

## 2. Alignment matrix

| # | Area | Textbook | FYPMS today | Status |
|---|---|---|---|---|
| A1 | Two-course lifecycle | CSP600 (formulation) → CSP650 (project) | `academic_courses` CSP600/CSP650; CSP650 record must continue the student's CSP600 record (lineage trigger) | **Aligned** |
| A2 | Form catalogue | F1–F16 incl. F6(a)/F6(b) | `form_code` CHECK allows exactly F1–F5, F6a, F6b, F7–F16 | **Aligned** |
| A3 | F14–F16 special evaluation | Only for qualifying students | F14 decided per student in `fyp_special_evaluations`; F15/F16 open only for a qualified record (R8, PR #27) | **Aligned** |
| A4 | Lean Model Canvas | 9 blocks, evaluated with F13 | 9 blocks, versioned (`save_lean_canvas`) | **Aligned** (the textbook's sub-boxes — existing alternatives, high-level concept, early adopters — are not captured) |
| A5 | F12 correction confirmation | SV/EX sign after amendments | Correction items → evidence → staff confirm | **Aligned** (FYPMS is more granular) |
| A6 | F5 in-progress log | One entry **per consultation**: meeting date, completed activity, next activity/comment, SV/co-SV signature | One log **per meeting date** (unique record + meeting date), completed / next activity, SV validates; attendance shown against the 80 % rule (R7, PR #22) | **Aligned** |
| A7 | F1 mutual acceptance | Supervisor accepts and signs; captures co-supervisor, project area and title | The named preferred supervisor accepts or rejects; request carries co-supervisor, project area and title; approval assigns them (R5, PR #19) | **Aligned** |
| A8 | F2 / F3 / F4 | Student submits; **CSP600 lecturer** evaluates with rubric | Student submits; the course (CSP600) lecturer evaluates with the textbook rubric (R1 PR #15, R2 PR #16) | **Aligned** |
| A9 | F7 | **Presentation** rubric (depth, organisation, materials, delivery; 3/2/2/3); lecturer 10 %, SV 10 %, EX 5 % | Textbook presentation rubric (3/2/2/3), shares lecturer 10 / SV 10 / EX 5 (R1, PR #15); lecturer may evaluate (R2) | **Aligned** |
| A10 | F8 | **Report** rubric, 7 criteria (3/2/1/5/6/3/2), progress item supervisor-only; SV 30 %, EX 15 % | Textbook report rubric, 7 criteria, progress item supervisor-only, SV 30 / EX 15 (R1, PR #15) | **Aligned** |
| A11 | F9, F10, F11, F13, F15, F16 rubrics | Defined (see 1.3) | All seeded from the textbook (R1, PR #15); v1 rubrics retired but kept for history | **Aligned** |
| A12 | Score scale | 0–10 per criterion × weight | Every criterion 0–10 × weight, out-of-range scores rejected (R1); the scoring dialog renders one 0–10 input per criterion with live Marks = W × S (R3, PR #17) | **Aligned** |
| A13 | Supervisor-only criteria | F8 #7 and F11 #8 are scored by the supervisor only | `supervisor_only` criteria are left out of an examiner's score (R1, PR #15) | **Aligned** |
| A14 | Evaluator ↔ form mapping | Each form has named evaluators (1.2) | `submit_form_evaluation` enforces the textbook evaluators per form and stores the evaluator's role (R2, PR #16) | **Aligned** |
| A15 | Course marks | Weighted per form and evaluator (1.3); CSP650 = 100 % | CSP600/CSP650 totals computed from the evaluations × evaluator shares, grade from UiTM bands; F2–F4 default 10 % each (FSKM decision, coordinator may re-split) (R4, PR #18) | **Aligned** |
| A16 | Similarity index | Recorded on F6(a)/F6(b), ≤ 30 %, supervisor endorsement | Similarity % and plagiarism report required, > 30 % blocked, supervisor endorse/return step (R6, PR #20) | **Aligned** |
| A17 | Report file formats | Final report in .pdf **and** .doc | Final report delivered as two required deliverables, `final_report_pdf` and `final_report_doc` (R10, PR #23) | **Aligned** |
| A18 | Deliverables checklist | Report, slides, poster, raw data*, system + test data*, setup instructions, .apk/.exe* | Textbook types only; report (.pdf + .doc), slides and poster required with real uploads to `fyp-deliverables`; the "if relevant" items may be an https link (R10, PR #23) | **Aligned** |
| A19 | Examiner assignment | By CSP600 lecturer | Coordinator (UI); CSP lecturer via RLS/RPC (no CSP UI) | Partially |
| A20 | Presentations | F7 session (CSP600), F9 progress presentation, F10 at exhibition | Sessions `defence` / `expo`; lecturers create sessions via the audited `create_presentation_session` (G-25, PR #29); slots scheduled by coordinator; F10 scored from the exhibition visit (R9) | Partially — no separate F9 progress-presentation session type |
| A21 | F14 eligibility | Four checks incl. Progress + LMC ≥ 7.5 % | Check 1 computed from F9 + F13 evaluations; checks 2–3 suggested from the final report and exhibition visits; lecturer confirms 2–4 per student (R8, PR #27) | **Aligned** |
| A22 | PU approval of nominations | PU approves/rejects supervisor & examiner nominations | `programme_head` role scoped by programme; once a PU is configured, new nominations stay `pending` until the PU approves, and a rejection deactivates them (R11, PR #37) | **Aligned** (appointment letters not generated) |
| A23 | Research ethics (REC) | REC forms with proposal when needed | A proposal that involves human subjects must attach the REC form (R11, PR #35) | **Aligned** |
| A24 | Report quality thresholds | ≥ 15/30 references, ≥ 30/50 pages | Page, reference and academic-reference counts captured on F6; proposal ≥ 30 pages / 15 refs, final ≥ 50 / 30, at least half academic enforced by `submit_report_version` (R11, PR #35) | **Aligned** |
| A25 | Exhibition assessment | SV & EX evaluate presentation, report **and poster** with F10 at the exhibition | SV/EX score F10 (or F15 when qualified) from the Expo visit page via `get_exhibition_evaluation` (R9, PR #28) | **Aligned** |
| A26 | Workflow states | Proposal submitted → presented → amended → marks → CSP650 → report → exhibition → corrections → approval | 17 statuses exist; only 6 are set by any RPC | Partially |
| A27 | Supervisor change / termination | Allowed after formulation, via coordinator | Student or current supervisor requests a change with a reason; the coordinator approves (reassigns) or rejects (R11, PR #37) | **Aligned** (timing left to the coordinator; termination — `withdrawn` — still not set by any RPC) |
| A28 | RES / archive | Marks uploaded to RES; reports archived by Academic Affairs | CSV export of finalized marks (matric, programme, course, total, grade) for RES on the CSP marks page (R11, PR #36); archiving stays with Academic Affairs | **Aligned** |

**Totals (28 areas, 2026-09-27):** 25 aligned, 3 partially aligned (A19, A20, A26), 0 misaligned or missing, 0 open opportunities. *(Original audit, 2026-09-26: 4 aligned, 8 partially aligned, 15 misaligned or missing, 1 opportunity.)*

---

## 3. Recommended changes (priority order)

| # | Change | Fixes | Effort | Status |
|---|---|---|---|---|
| R1 | **Replace the seeded rubrics** with textbook rubrics for F2, F3, F4, F7, F8, F9, F10, F11 (CLO1 + CLO4), F13, F15, F16 — weights as in 1.3, `max: 10` per criterion, `supervisor_only` flag on F8 #7 and F11 #8, and each form's evaluator shares (e.g. F7 `{lecturer:10, supervisor:10, examiner:5}`). New migration; bump `version` so history is kept. | A9–A13 | S | Done — PR #15 (`20260926000001`) |
| R2 | **Evaluator-to-form mapping** in `submit_form_evaluation`: allow the course CSP lecturer for F2, F3, F4, F7, F9, F13, F14; SV/EX for F7, F8, F10, F11, F15, F16; reject supervisor-only criteria from examiners. | A8, A14 | M | Done — PR #16 (`20260926000002`) |
| R3 | **Rubric-driven evaluation UI**: load the rubric, render one 0–10 input per criterion with the band descriptors, compute Marks = W × S live — replace the raw-JSON score box. | A12 | M | Done — PR #17 |
| R4 | **Course marks from evaluations**: compute CSP600/CSP650 totals as Σ (form score ÷ max × evaluator share) using R1's shares; keep manual override with reason; derive the grade from UiTM bands. | A15 | M | Done — PR #18 (`20260926000003`) |
| R5 | **F1 acceptance by the preferred supervisor**: let the named `preferred_supervisor_id` approve/reject; add co-supervisor, project area and project title fields. | A7 | S | Done — PR #19 (`20260926000004`) |
| R6 | **F6 similarity index**: require a similarity % and plagiarism-report file on proposal/final submission, block > 30 %, add a supervisor "endorse" step. | A16 | S | Done — PR #20 (`20260926000005`) |
| R7 | **F5 per consultation**: drop the one-per-week uniqueness in favour of meeting date; store completed activity / next activity; show attendance % against the 80 % rule. | A6 | S | Done — PR #22 (`20260926000006`) |
| R8 | **F14 eligibility check**: compute Progress (F9) + LMC (F13) ≥ 7.5 % and the other three checks per student; enable F15/F16 per eligible student instead of the global flag. | A3, A21 | M | Done — PR #27 (`20260926000010`) |
| R9 | **F10 at the exhibition**: let SV/EX score F10 from the Expo visit detail page (the visit already identifies project, lecturer and role). | A25 | M | Done — PR #28 (`20260926000011`) |
| R10 | **Deliverables list** to match the textbook (report .pdf + .doc, slides, poster, raw data, system + test data, setup instructions, executable) with real uploads to `fyp-deliverables`. | A17, A18 | S | Done — PR #23 (`20260926000007`) |
| R11 | Model PU approval, REC ethics forms, supervisor change, report thresholds (references/pages) and RES export. | A22–A24, A27, A28 | L | Done — report minimums + REC PR #35 (`20260927000002`); RES export PR #36; supervisor change + PU approval PR #37 (`20260927000003`) |

S = under a day, M = 1–3 days, L = a week or more. All eleven recommendations are implemented and live in production (2026-09-27).
