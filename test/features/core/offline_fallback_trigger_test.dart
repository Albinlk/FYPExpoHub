import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/data/offline_fallback.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';

/// R6: the bundled offline dataset (a ~640 KB HTTP fetch on the web) is
/// read only when the live request fails, answers empty, or is slower than
/// [OfflineFallback.slowLiveTimeout].

typedef _Rows = List<Map<String, dynamic>>;

/// One real row of each collection from the bundled file, so both the
/// stubbed fallback and the "live" rows parse through the real mappers.
final Map<String, dynamic> _bundled =
    jsonDecode(File('assets/data/offline_fallback.json').readAsStringSync()) as Map<String, dynamic>;
Map<String, dynamic> _first(String key) =>
    Map<String, dynamic>.from((_bundled[key] as List).first as Map);

final _fallbackJson = jsonEncode({
  'projects': [_first('projects')],
  'booths': [_first('booths')],
  'scheduleItems': [_first('scheduleItems')],
});

_Rows _live(String key) => [
      {..._first(key), 'id': 'live-$key'},
    ];

/// Each read returns whatever [answer] produces (rows, an error, or a
/// future that hasn't completed yet).
class _Db extends SupabaseDatabaseService {
  _Db(this.answer)
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final Future<_Rows> Function(String key) answer;

  @override
  Future<_Rows> getProjectsOnce({bool publishedOnly = false, int? limit, int? offset}) =>
      answer('projects');

  @override
  Future<_Rows> getBoothsOnce({bool publishedOnly = false}) => answer('booths');

  @override
  Future<_Rows> getScheduleOnce({bool publishedOnly = false}) => answer('scheduleItems');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  var assetReads = 0;

  setUp(() {
    OfflineFallback.resetForTests();
    assetReads = 0;
    OfflineFallback.readAsset = (path) async {
      assetReads++;
      return _fallbackJson;
    };
    OfflineFallback.slowLiveTimeout = const Duration(milliseconds: 60);
  });
  tearDown(OfflineFallback.resetForTests);

  ProviderContainer containerFor(_Db db) {
    final container = ProviderContainer(overrides: [supabaseDbServiceProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    container
      ..listen(publicProjectsProvider, (_, _) {})
      ..listen(publicBoothsProvider, (_, _) {})
      ..listen(publicScheduleProvider, (_, _) {});
    return container;
  }

  List<String> ids(ProviderContainer c) => [
        ...c.read(publicProjectsProvider).map((p) => p.id),
        ...c.read(publicBoothsProvider).map((b) => b.id),
        ...c.read(publicScheduleProvider).map((s) => s.id),
      ];

  List<DataLoadStatus> statuses(ProviderContainer c) => [
        for (final d in [PublicDataset.projects, PublicDataset.booths, PublicDataset.schedule])
          c.read(publicLoadStatusProvider(d)),
      ];

  final fallbackIds = [
    _first('projects')['id'],
    _first('booths')['id'],
    _first('scheduleItems')['id'],
  ];
  const liveIds = ['live-projects', 'live-booths', 'live-scheduleItems'];

  Future<void> settle([int ms = 200]) => Future<void>.delayed(Duration(milliseconds: ms));

  test('live success: the bundled asset is never read', () async {
    final c = containerFor(_Db((key) async => _live(key)));
    // Well past the slow-request timeout: a fast answer cancelled it.
    await settle();
    expect(ids(c), liveIds);
    expect(statuses(c), everyElement(DataLoadStatus.live));
    expect(assetReads, 0, reason: 'a normal visit must not download offline_fallback.json');
  });

  test('live error: the bundled copy shows and the status is offline', () async {
    final c = containerFor(_Db((key) async => throw Exception('Supabase paused')));
    await settle();
    expect(ids(c), fallbackIds);
    expect(statuses(c), everyElement(DataLoadStatus.offline));
    expect(assetReads, 1, reason: 'one shared read for all three datasets');
  });

  test('live slower than the timeout: bundled copy first, then live rows replace it', () async {
    final pending = Completer<void>();
    final c = containerFor(_Db((key) async {
      await pending.future;
      return _live(key);
    }));

    await settle();
    expect(ids(c), fallbackIds, reason: 'fallback fills the list while the request hangs');
    expect(statuses(c), everyElement(DataLoadStatus.loading));
    expect(assetReads, 1);

    pending.complete();
    await settle(20);
    expect(ids(c), liveIds);
    expect(statuses(c), everyElement(DataLoadStatus.live));
  });

  test('live slower than the timeout and then failing: offline with the bundled copy', () async {
    final pending = Completer<void>();
    final c = containerFor(_Db((key) async {
      await pending.future;
      throw Exception('timed out');
    }));
    await settle();
    expect(ids(c), fallbackIds);

    pending.complete();
    await settle(20);
    expect(ids(c), fallbackIds);
    expect(statuses(c), everyElement(DataLoadStatus.offline));
    expect(assetReads, 1);
  });

  test('an empty live answer still shows the bundled copy (status live)', () async {
    final c = containerFor(_Db((key) async => const []));
    await settle();
    expect(ids(c), fallbackIds);
    expect(statuses(c), everyElement(DataLoadStatus.live));
  });

  test('admin lists never read the bundled asset, even when the request fails', () async {
    final container = ProviderContainer(overrides: [
      supabaseDbServiceProvider.overrideWithValue(_Db((key) async => throw Exception('down'))),
    ]);
    addTearDown(container.dispose);
    container
      ..listen(projectsProvider, (_, _) {})
      ..listen(boothsProvider, (_, _) {})
      ..listen(scheduleProvider, (_, _) {});
    await settle();
    expect(container.read(projectsProvider), isEmpty);
    expect(assetReads, 0);
  });

  test('a list disposed before the timeout never reads the asset', () async {
    final pending = Completer<void>();
    final container = ProviderContainer(overrides: [
      supabaseDbServiceProvider.overrideWithValue(_Db((key) async {
        await pending.future;
        return _live(key);
      })),
    ]);
    container.listen(publicProjectsProvider, (_, _) {});
    container.dispose();
    await settle();
    // The request is left hanging: the disposed list must not touch state.
    expect(assetReads, 0);
    expect(pending.isCompleted, isFalse);
  });
}
