# FYP Expo Hub

The Final Year Project platform for FSKM, UiTM Jasin:

- **Exhibition** — https://fskmjasinfypexhibition.site — public catalogue of
  final-year projects, booths, schedule, awards and the Past Projects Guide;
  booth-visit marking for lecturers; an admin CMS at `/admin`.
- **FYP Workspace** — https://fyp.fskmjasinfypexhibition.site — the CSP600 /
  CSP650 semester workflow for students, supervisors, examiners, CSP
  lecturers, programme heads and the FYP coordinator.
- **Handbook** — https://fskmjasinfypexhibition.site/handbook/ — user guides
  for every role.

One Flutter Web build serves both sites, backed by Supabase. One account
signs in to both.

## Documentation

Everything lives in [`docs/`](docs/index.md).

| You are | Start here |
|---|---|
| Visitor | [Visitor guide](docs/guides/visitor.md) |
| Student | [Student guide](docs/guides/student.md) |
| Lecturer, examiner, CSP lecturer, PU head | [Lecturer guide](docs/guides/lecturer.md) |
| FYP coordinator | [Coordinator guide](docs/guides/coordinator.md) |
| Exhibition admin | [Exhibition admin guide](docs/guides/exhibition-admin.md) |
| Anyone with an account | [Accounts and sign-in](docs/guides/accounts.md) |
| Developer / maintainer | [Developer docs](docs/developer/README.md) |

## Quick start (developers)

```bash
flutter pub get
```

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

```bash
flutter analyze
```

```bash
flutter test
```

See [docs/developer/overview.md](docs/developer/overview.md) for the stack,
repository map and tutorials.
