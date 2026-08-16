# Testing — FYP Expo Hub

## Test Suite

The project includes Flutter unit and widget tests in `test/`.

### Running Tests

```bash
# Ensure dependencies are installed
flutter pub get

# Run all tests
flutter test

# Run a specific test file
flutter test test/path/to/test.dart

# Run with verbose output
flutter test --verbose

# Run with coverage
flutter test --coverage
```

### Static Analysis

```bash
flutter analyze
```

Treats new errors as blocking. Existing deprecation warnings are informational.

## Test Organization

```
test/
├── unit/
│   ├── models/          # freezed model tests
│   ├── providers/       # Riverpod provider tests
│   └── utils/           # Utility function tests
├── widget/
│   ├── public/          # Public page widget tests
│   ├── admin/           # Admin CMS widget tests
│   └── lecturer/        # Lecturer portal widget tests
└── integration/
    └── app_test.dart    # End-to-end integration tests
```

## Expected Test Count

15 tests total (as per the release checklist).

## Test Coverage Requirements

| Feature Area | Target Coverage |
|---|---|
| Models (fromJson/toJson) | 100% |
| Providers (state transitions) | 100% |
| Public pages (anonymous) | 100% |
| Lecturer pages (authenticated) | 100% |
| Admin pages (authenticated) | 100% |
| Offline fallback logic | 100% |

## Manual Testing Checklist

### Public Site (Anonymous)
- [ ] Home page loads with event info
- [ ] Projects list displays
- [ ] Project detail page shows matric ID
- [ ] Schedule page loads
- [ ] Booths page loads
- [ ] Announcements display
- [ ] Awards page loads
- [ ] FAQ/Privacy pages load
- [ ] Offline fallback: disconnect network, verify seed data renders

### Lecturer Site
- [ ] Sign in with lecturer account
- [ ] My Visits dashboard shows assigned projects
- [ ] Mark project as visited (verify success)
- [ ] Cancel/void visit (verify required reason)
- [ ] Visit appears in audit log

### Admin Site
- [ ] Sign in with admin account
- [ ] All CMS pages load
- [ ] Create/edit project
- [ ] Toggle publication status
- [ ] Import master file
- [ ] Data matching dashboard works
- [ ] Publish import changes
- [ ] Visit monitoring dashboard
- [ ] Export CSV from visits
- [ ] Void visit with reason

### Offline/Paused Project
- [ ] Simulate Supabase paused (no network)
- [ ] Verify maintenance dialog appears
- [ ] Verify offline seed data renders on public pages

## CI Configuration

GitHub Actions workflow (`.github/workflows/deploy.yml`):
1. Checkout code
2. Setup Flutter
3. `flutter pub get`
4. `flutter analyze`
5. `flutter build web --release` with `--dart-define` credentials
6. Deploy to GitHub Pages

## Supabase Database Testing

Test the Supabase connection and schema:

```bash
# Using the Supabase CLI
supabase login
supabase db diff

# Manual API test (via scripts)
node -e "const {supabaseSelect} = require('./scripts/lib/firebase_api'); supabaseSelect('events','select=id,slug,title,status').then(r => console.log(r))"
```

Expected output:
```
[{data: [{id: "1977e782-430c-5f3f-a6c7-359f74650691", slug: "fskm-fyp-2026", title: "FSKM FYP Expo Hub 2026", status: "active"}], error: null}]
```
