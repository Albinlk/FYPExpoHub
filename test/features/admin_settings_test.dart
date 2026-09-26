import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/admin_settings/presentation/pages/admin_settings_page.dart';

class _Db extends SupabaseDatabaseService {
  _Db()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final saved = <String, Map<String, dynamic>>{};

  @override
  Future<Map<String, dynamic>?> getSetting(String key) async => switch (key) {
        'visit_tracker' => {
            'visitsEnabled': true,
            'allowVisitsBeforeEvent': false,
            'allowVisitsAfterEvent': false,
            'visitOpenAt': '2026-08-05T00:00:00+08:00',
            'visitCloseAt': null,
            'lecturerUndoWindowMinutes': 30,
          },
        _ => null,
      };

  @override
  Future<void> setSetting(String key, Map<String, dynamic> value) async => saved[key] = value;
}

void main() {
  testWidgets('G-30 visit window switches save; stored open/close times survive', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = _Db();
    await tester.pumpWidget(ProviderScope(
      overrides: [supabaseDbServiceProvider.overrideWithValue(db)],
      child: const MaterialApp(home: AdminSettingsPage()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Allow visits after the exhibition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Configuration'));
    await tester.pumpAndSettle();

    final visit = db.saved['visit_tracker']!;
    expect(visit['allowVisitsAfterEvent'], isTrue);
    expect(visit['allowVisitsBeforeEvent'], isFalse);
    expect(visit['visitOpenAt'], '2026-08-05T00:00:00+08:00', reason: 'not wiped on save');
  });
}
