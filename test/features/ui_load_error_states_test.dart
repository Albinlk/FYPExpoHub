import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/admin_assignments/presentation/pages/admin_assignments_page.dart';
import 'package:fyp_expo_hub/features/admin_settings/presentation/pages/admin_settings_page.dart';
import 'package:fyp_expo_hub/features/admin_visits/presentation/pages/admin_visits_page.dart';

class _FailingDb extends SupabaseDatabaseService {
  _FailingDb()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  int reads = 0;
  bool fail = true;

  @override
  Future<Map<String, dynamic>?> getSettingStrict(String key) async {
    reads++;
    if (fail) throw Exception('ClientException: Failed to fetch');
    return null;
  }
}

Future<void> _pump(WidgetTester tester, Widget page, List<Override> overrides) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: Scaffold(body: page)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('settings: a failed load shows an error with retry, not defaults', (tester) async {
    final db = _FailingDb();
    await _pump(tester, const AdminSettingsPage(), [supabaseDbServiceProvider.overrideWithValue(db)]);

    expect(find.text("Couldn't load settings."), findsOneWidget);
    expect(find.textContaining('Check your connection'), findsOneWidget);
    expect(find.text('Save Configuration'), findsNothing, reason: 'defaults must not be saveable');

    db.fail = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(db.reads, greaterThan(2));
    expect(find.text('Save Configuration'), findsOneWidget);
  });

  testWidgets('visits: failed load shows retry instead of zeros', (tester) async {
    await _pump(tester, const AdminVisitsPage(), [
      allAssignmentsProvider.overrideWith((ref) async => throw Exception('boom')),
      allVisitsProvider.overrideWith((ref) async => []),
    ]);
    expect(find.text("Couldn't load student visits."), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('assignments: failed load shows retry, not an empty match panel', (tester) async {
    await _pump(tester, const AdminAssignmentsPage(), [
      allAssignmentsProvider.overrideWith((ref) async => []),
      allLecturersProvider.overrideWith((ref) async => throw Exception('boom')),
    ]);
    expect(find.text("Couldn't load lecturer assignments."), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });
}
