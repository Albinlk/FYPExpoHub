import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/features/admin_projects/presentation/pages/admin_projects_page.dart';

const _projectId = '11111111-1111-4111-8111-111111111111';
const _eventId = '22222222-2222-4222-8222-222222222222';

/// Editing a project must not wipe the fields the dialog doesn't show.
class _Db extends SupabaseDatabaseService {
  _Db()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final saved = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> getProjectsOnce({
    bool publishedOnly = false,
    int? limit,
    int? offset,
  }) async =>
      [
        {
          'id': _projectId,
          'event_id': _eventId,
          'slug': 'smart-farm',
          'title': 'Smart Farm',
          'programme_code': 'CS251',
          'programme_name': 'Netcentric Computing',
          'short_description': 'IoT farm',
          'category': 'Computer Science',
          'tech_tags': ['IoT'],
          'student_team': ['ALI'],
          'supervisor_display_name': 'DR. A',
          'presentation_day': 'Day 2 - 07 Aug 2026',
          'video_url': 'https://youtu.be/x',
          'repository_url': 'https://github.com/a/b',
          'poster_url': 'https://example.com/p.png',
          'industry_candidate': true,
          'featured': false,
          'publication_status': 'published',
          'created_at': '2026-07-01T00:00:00Z',
          'updated_at': '2026-07-01T00:00:00Z',
          'published_at': '2026-07-02T00:00:00Z',
        },
      ];

  @override
  Future<void> setProject(String id, Map<String, dynamic> data) async => saved.add(data);
}

void main() {
  testWidgets('editing a project keeps presentation day, links and Industry Candidate',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = _Db();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        supabaseDbServiceProvider.overrideWithValue(db),
        currentAuthUserProvider.overrideWith((ref) => null),
      ],
      child: const MaterialApp(home: AdminProjectsPage()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit project'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Smart Farm'), 'Smart Farm v2');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    final row = db.saved.single;
    expect(row['title'], 'Smart Farm v2');
    expect(row['presentation_day'], 'Day 2 - 07 Aug 2026');
    expect(row['video_url'], 'https://youtu.be/x');
    expect(row['repository_url'], 'https://github.com/a/b');
    expect(row['industry_candidate'], isTrue);
  });
}
