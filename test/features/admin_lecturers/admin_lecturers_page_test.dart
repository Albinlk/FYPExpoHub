import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_rpc_service.dart';
import 'package:fyp_expo_hub/features/admin_lecturers/presentation/pages/admin_lecturers_page.dart';

/// Admin lecturer management: permanently deletes profiles and bulk-edits
/// assignments, so both paths are pinned here.
class _Db extends SupabaseDatabaseService {
  _Db()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final deleted = <String>[];
  final bulkUpserts = <List<Map<String, dynamic>>>[];
  int singleUpserts = 0;

  @override
  Future<List<Map<String, dynamic>>> getLecturersOnce() async => [
        {'id': 'lec-1', 'email': 'aminah@uitm.edu.my', 'display_name': 'DR. AMINAH'},
        {'id': 'lec-2', 'email': 'badrul@uitm.edu.my', 'display_name': 'EN. BADRUL'},
      ];

  @override
  Future<List<Map<String, dynamic>>> getAssignmentsOnce() async => [
        // needs its lecturer_id filled in by name
        {'id': 'a1', 'lecturer_id': null, 'lecturer_display_name': 'dr. aminah', 'role': 'supervisor'},
        {'id': 'a2', 'lecturer_id': null, 'lecturer_display_name': 'EN. BADRUL', 'role': 'examiner'},
        // already linked: skipped
        {'id': 'a3', 'lecturer_id': 'lec-1', 'lecturer_display_name': 'DR. AMINAH', 'role': 'examiner'},
        // nobody by that name: skipped
        {'id': 'a4', 'lecturer_id': null, 'lecturer_display_name': 'PROF. UNKNOWN', 'role': 'supervisor'},
      ];

  @override
  Future<void> setAssignments(List<Map<String, dynamic>> rows) async => bulkUpserts.add(rows);

  @override
  Future<void> setAssignment(String id, Map<String, dynamic> data) async => singleUpserts++;

  @override
  Future<void> deleteLecturer(String uid) async => deleted.add(uid);

  /// Accounts that exist in Supabase Auth (and so have a profile).
  final accounts = {'new.lecturer@uitm.edu.my': 'auth-uid-9'};

  @override
  Future<String?> findProfileIdByEmail(String email) async => accounts[email];
}

class _Rpc extends SupabaseRpcService {
  _Rpc()
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final promoted = <String>[];

  @override
  Future<Map<String, dynamic>> createLecturerAccountProfile({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    promoted.add('$userId|$email|$displayName');
    return {'id': userId};
  }
}

Future<void> _pump(WidgetTester tester, _Db db, [_Rpc? rpc]) async {
  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      supabaseDbServiceProvider.overrideWithValue(db),
      supabaseRpcServiceProvider.overrideWithValue(rpc ?? _Rpc()),
      currentAuthUserProvider.overrideWith((ref) => null),
    ],
    child: const MaterialApp(home: AdminLecturersPage()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists lecturers from profiles (no hardcoded entries)', (tester) async {
    await _pump(tester, _Db());
    expect(find.text('DR. AMINAH'), findsOneWidget);
    expect(find.text('EN. BADRUL'), findsOneWidget);
    expect(find.text('DEFAULT'), findsNothing);
  });

  testWidgets('delete asks first and only deletes on confirm', (tester) async {
    final db = _Db();
    await _pump(tester, db);

    await tester.tap(find.byTooltip('Delete lecturer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(db.deleted, isEmpty);

    await tester.tap(find.byTooltip('Delete lecturer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(db.deleted, ['lec-1']);
  });

  Future<void> addLecturer(WidgetTester tester, String email) async {
    await tester.tap(find.text('Add Lecturer').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'UiTM Email'), email);
    await tester.enterText(find.widgetWithText(TextField, 'Full Name'), 'dr. new');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();
  }

  testWidgets('add lecturer promotes the existing account by its real id', (tester) async {
    final rpc = _Rpc();
    await _pump(tester, _Db(), rpc);

    await addLecturer(tester, 'New.Lecturer@uitm.edu.my ');

    expect(rpc.promoted, ['auth-uid-9|new.lecturer@uitm.edu.my|DR. NEW']);
    expect(find.text('Lecturer DR. NEW added.'), findsOneWidget);
  });

  testWidgets('add lecturer refuses an email with no account', (tester) async {
    final rpc = _Rpc();
    await _pump(tester, _Db(), rpc);

    await addLecturer(tester, 'nobody@uitm.edu.my');

    expect(rpc.promoted, isEmpty);
    expect(find.textContaining('No account found for nobody@uitm.edu.my'), findsOneWidget);
  });

  testWidgets('backfill links assignments by name in ONE bulk upsert', (tester) async {
    final db = _Db();
    await _pump(tester, db);

    await tester.tap(find.text('Backfill Lecturer IDs').first);
    await tester.pumpAndSettle();
    // Bulk change: confirm first.
    expect(find.text('Backfill lecturer IDs?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Backfill'));
    await tester.pumpAndSettle();
    // The result snackbar queues behind the "Updating..." one.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(db.singleUpserts, 0, reason: 'no per-row round trips');
    final rows = db.bulkUpserts.single;
    expect({for (final r in rows) r['id']: r['lecturer_id']}, {'a1': 'lec-1', 'a2': 'lec-2'});
    expect(find.textContaining('2 assignments updated, 2 skipped'), findsOneWidget);
  });
}
