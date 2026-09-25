import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/domain/models/award.dart';
import 'package:fyp_expo_hub/core/domain/models/booth.dart';
import 'package:fyp_expo_hub/core/domain/models/feedback_entry.dart';
import 'package:fyp_expo_hub/core/domain/models/schedule_item.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_client_provider.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_rpc_service.dart';

/// Covers the admin notifiers that previously had no tests (schedule,
/// booths, awards, feedback, event): every write sends real column names,
/// is awaited, and rolls back when the database refuses it.

const _eventUuid = '00000000-0000-4000-8000-00000000e001';
String _uuid(int n) => '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';
final _t = DateTime.utc(2026, 7, 1);

SupabaseClient _client() => SupabaseClient(
      'https://placeholder-project.supabase.co',
      'placeholder-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

class _Db extends SupabaseDatabaseService {
  _Db() : super(_client());

  bool failWrites = false;
  final writes = <(String, Map<String, dynamic>)>[];
  final inserts = <(String, Map<String, dynamic>)>[];

  void _write(String table, Map<String, dynamic> row) {
    if (failWrites) throw const PostgrestException(message: 'denied', code: '42501');
    writes.add((table, row));
  }

  @override
  Future<String> resolveEventId(String slugOrId) async => _eventUuid;

  // Reads return nothing, so the admin lists start empty.
  @override
  Future<List<Map<String, dynamic>>> getScheduleOnce({bool publishedOnly = false}) async => [];
  @override
  Future<List<Map<String, dynamic>>> getBoothsOnce({bool publishedOnly = false}) async => [];
  @override
  Future<List<Map<String, dynamic>>> getAwardWinnersOnce({bool publishedOnly = false}) async => [];
  @override
  Future<List<Map<String, dynamic>>> getFeedbackEntriesOnce() async => [];
  @override
  Future<Map<String, dynamic>?> getEvent(String slugOrId) async => null;

  @override
  Future<void> setScheduleItem(String id, Map<String, dynamic> data) async => _write('schedule_items', data);
  @override
  Future<void> deleteScheduleItem(String id) async => _write('schedule_items:delete', {'id': id});
  @override
  Future<void> setBooth(String id, Map<String, dynamic> data) async => _write('booths', data);
  @override
  Future<void> setAwardWinner(String id, Map<String, dynamic> data) async => _write('award_winners', data);
  @override
  Future<void> setFeedbackEntry(String id, Map<String, dynamic> data) async => _write('feedback_entries', data);
  @override
  Future<void> submitFeedbackEntry(Map<String, dynamic> data) async {
    if (failWrites) throw const PostgrestException(message: 'rate-limited', code: '53400');
    inserts.add(('feedback_entries', data));
  }
}

class _Rpc extends SupabaseRpcService {
  _Rpc() : super(_client());

  bool fail = false;
  Map<String, dynamic>? lastPayload;
  String? lastEventId;

  @override
  Future<Map<String, dynamic>> updateEventConfiguration({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    if (fail) throw const PostgrestException(message: 'permission-denied', code: '42501');
    lastEventId = eventId;
    lastPayload = payload;
    return {
      ...payload,
      'id': eventId,
      'slug': 'fskm-fyp-2026',
      'updated_at': _t.toIso8601String(),
    };
  }
}

ProviderContainer _container(_Db db, [_Rpc? rpc]) => ProviderContainer(
      overrides: [
        supabaseDbServiceProvider.overrideWithValue(db),
        supabaseRpcServiceProvider.overrideWithValue(rpc ?? _Rpc()),
        currentAuthUserProvider.overrideWith((ref) => null),
      ],
    );

ScheduleItem _slot(String id) => ScheduleItem(
      id: id,
      eventId: 'fskm-fyp-2026',
      date: DateTime(2026, 8, 6),
      startAt: '01:00 PM',
      endAt: '02:30 PM',
      title: 'Jury briefing',
      venue: 'Hall',
      audience: 'Jury',
      visibility: 'internal',
      publicationStatus: 'draft',
      createdAt: _t,
      updatedAt: _t,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScheduleNotifier', () {
    test('writes event_date + MYT timestamps + access_type', () async {
      final db = _Db();
      final c = _container(db);
      addTearDown(c.dispose);
      final n = c.read(scheduleProvider.notifier);
      await pumpEventQueue();

      await n.addScheduleItem(_slot(_uuid(1)));

      final (table, row) = db.writes.single;
      expect(table, 'schedule_items');
      expect(row['event_id'], _eventUuid);
      expect(row['event_date'], '2026-08-06');
      expect(row['start_at'], '2026-08-06T13:00:00+08:00');
      expect(row['end_at'], '2026-08-06T14:30:00+08:00');
      expect(row['access_type'], 'internal');
      expect(row.keys, isNot(contains('visibility')));
    });

    test('an end time before the start is refused without a write', () async {
      final db = _Db();
      final c = _container(db);
      addTearDown(c.dispose);
      final n = c.read(scheduleProvider.notifier);
      await pumpEventQueue();

      await expectLater(
        n.addScheduleItem(_slot(_uuid(2)).copyWith(endAt: '12:00 PM')),
        throwsA(anything),
      );
      expect(db.writes, isEmpty);
      expect(c.read(scheduleProvider), isEmpty, reason: 'rolled back');
    });

    test('a refused delete puts the slot back', () async {
      final db = _Db();
      final c = _container(db);
      addTearDown(c.dispose);
      final n = c.read(scheduleProvider.notifier);
      await pumpEventQueue();
      await n.addScheduleItem(_slot(_uuid(3)));

      db.failWrites = true;
      await expectLater(n.deleteScheduleItem(_uuid(3)), throwsA(isA<PostgrestException>()));
      expect(c.read(scheduleProvider).map((s) => s.id), [_uuid(3)]);
    });
  });

  group('BoothsNotifier / AwardsNotifier', () {
    test('booth links a project only by a real uuid', () async {
      final db = _Db();
      final c = _container(db);
      addTearDown(c.dispose);
      final n = c.read(boothsProvider.notifier);
      await pumpEventQueue();

      await n.addBooth(Booth(
        id: _uuid(4),
        eventId: 'fskm-fyp-2026',
        boothNumber: 'B1',
        zone: 'A',
        locationNote: '',
        projectId: _uuid(9),
        publicationStatus: 'published',
        createdAt: _t,
        updatedAt: _t,
      ));
      final row = db.writes.single.$2;
      expect(row['linked_project_id'], _uuid(9));
      expect(row['zone'], 'A');
    });

    test('award title goes to the title column', () async {
      final db = _Db();
      final c = _container(db);
      addTearDown(c.dispose);
      final n = c.read(awardsProvider.notifier);
      await pumpEventQueue();

      await n.addWinner(PublishedAwardWinner(
        id: _uuid(5),
        eventId: 'fskm-fyp-2026',
        awardCategoryId: 'cat-manual',
        projectTitle: 'Gold Innovation Award',
        publicationStatus: 'published',
        createdAt: _t,
        updatedAt: _t,
      ));
      final row = db.writes.single.$2;
      expect(row['title'], 'Gold Innovation Award');
      expect(row['category_id'], isNull, reason: 'not a uuid');
    });
  });

  group('FeedbackEntriesNotifier', () {
    FeedbackEntry entry() => FeedbackEntry(
          id: _uuid(6),
          eventId: 'fskm-fyp-2026',
          subject: 'Great expo',
          message: 'Loved it',
          rating: 5,
          createdAt: _t,
          updatedAt: _t,
        );

    test('a visitor submission is a plain insert without moderation fields',
        () async {
      final db = _Db();
      final c = _container(db);
      addTearDown(c.dispose);

      await c.read(feedbackEntriesProvider.notifier).submit(entry());

      final row = db.inserts.single.$2;
      expect(row['event_id'], _eventUuid);
      expect(row.keys, isNot(contains('status')));
      expect(row.keys, isNot(contains('admin_note')));
      expect(db.writes, isEmpty, reason: 'no upsert');
    });

    test('a refused submission surfaces the error to the form', () async {
      final db = _Db()..failWrites = true;
      final c = _container(db);
      addTearDown(c.dispose);

      await expectLater(
        c.read(feedbackEntriesProvider.notifier).submit(entry()),
        throwsA(isA<PostgrestException>()),
      );
    });
  });

  group('EventNotifier', () {
    test('saves through the RPC with the resolved uuid and snake_case payload',
        () async {
      final db = _Db();
      final rpc = _Rpc();
      final c = _container(db, rpc);
      addTearDown(c.dispose);
      await pumpEventQueue();

      final current = c.read(eventProvider);
      await c.read(eventProvider.notifier).updateEvent(current.copyWith(venue: 'Dewan Besar'));

      expect(rpc.lastEventId, _eventUuid);
      expect(rpc.lastPayload!['venue'], 'Dewan Besar');
      expect(rpc.lastPayload!.keys, contains('session_label'));
      expect(c.read(eventProvider).venue, 'Dewan Besar');
    });

    test('a refused save restores the previous event', () async {
      final db = _Db();
      final rpc = _Rpc()..fail = true;
      final c = _container(db, rpc);
      addTearDown(c.dispose);
      await pumpEventQueue();

      final before = c.read(eventProvider).venue;
      await expectLater(
        c.read(eventProvider.notifier).updateEvent(c.read(eventProvider).copyWith(venue: 'Nowhere')),
        throwsA(isA<PostgrestException>()),
      );
      expect(c.read(eventProvider).venue, before);
    });
  });
}
