# Developer documentation

These pages stay in the repository; only [overview.md](overview.md) is
published in the handbook.

**Start**

| Document | What it covers |
|---|---|
| [overview.md](overview.md) | Stack, repository map, tutorials: run locally, make a change, change the database |
| [architecture.md](architecture.md) | System context and code-layer diagrams, state, data flow, design decisions |
| [hosts-and-auth.md](hosts-and-auth.md) | Two hosts, route guards, post-login routing, roles, MFA, shared sign-in, password reset |

**Backend**

| Document | What it covers |
|---|---|
| [database.md](database.md) | Tables, ER diagrams, workflow states, storage buckets |
| [rpc-reference.md](rpc-reference.md) | Every database function, its gate and purpose |
| [rls-and-security.md](rls-and-security.md) | Security policy, hardening log, accepted risks |
| [rls-policies.md](rls-policies.md) | RLS policy matrix |
| [import-pipeline.md](import-pipeline.md) | Master Excel import, client-side parsing, staging, publish |
| [free-tier.md](free-tier.md) | Supabase free-tier limits and how the app copes |

**Build, test, ship**

| Document | What it covers |
|---|---|
| [deployment.md](deployment.md) | CI/CD diagram, secrets, both hosts, the handbook, rollback |
| [testing.md](testing.md) | Test layout, how to run, manual checklists |
| [release-checklist.md](release-checklist.md) | Before a release |
| [qa-runbook.md](qa-runbook.md) | End-to-end FYPMS QA by role |
| [design-system.md](design-system.md) | "Scholar + Lab" tokens and components (Google Stitch ready) |

**Planning**

| Document | What it covers |
|---|---|
| [requirements.md](requirements.md) | Full requirements specification |
| [backlog.md](backlog.md) | Backlog and what shipped in which PR |
| [history/](history/) | Superseded reports kept for the record |
