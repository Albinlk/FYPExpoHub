# Offline fallback dataset — provenance

`assets/data/offline_fallback.json` (387 projects, 221 booths, 8 schedule
items) is the offline dataset for the public site, originally generated from
`StudentListName.xlsx` (Aug 2026 bulk import).

History: the data was first embedded in the app bundle as
`lib/core/data/excel_data.dart` (14,853 lines, ~600KB), then converted to this
JSON asset so it can be lazy-loaded only when needed (see
`lib/core/data/offline_fallback.dart`) — keeping it out of the initial JS
payload.

**Regenerating** (e.g. for a new semester): the source ExcelData class was
deleted after conversion; restore it from git history
(`git show HEAD~1:lib/core/data/excel_data.dart`) or re-derive from the
master `.xlsx`, then emit JSON with:
- keys: `projects`, `booths`, `scheduleItems`
- rows shaped like live Supabase rows: snake_case keys, ISO-8601 date strings
  (the runtime `normalizeKeys` + `fromJson` pipeline handles both paths)
