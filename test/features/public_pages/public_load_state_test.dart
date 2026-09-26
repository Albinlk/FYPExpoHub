import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fyp_expo_hub/core/state/state_providers.dart';
import 'package:fyp_expo_hub/core/supabase/supabase_database_service.dart';
import 'package:fyp_expo_hub/core/widgets/public_load_state.dart';

class _Db extends SupabaseDatabaseService {
  _Db({this.fail = false})
      : super(SupabaseClient(
          'https://placeholder-project.supabase.co',
          'placeholder-anon-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));

  final bool fail;

  @override
  Future<List<Map<String, dynamic>>> getAnnouncementsOnce({bool publishedOnly = false}) async {
    if (fail) throw Exception('network down');
    return const [];
  }
}

Widget _host(Widget child, {List<dynamic> overrides = const []}) => ProviderScope(
      overrides: [...overrides.cast()],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  test('a failed load with offline rows is "offline", without rows "failed"', () {
    expect(loadOutcome(remoteFailed: false, hasRows: false), DataLoadStatus.live);
    expect(loadOutcome(remoteFailed: true, hasRows: true), DataLoadStatus.offline);
    expect(loadOutcome(remoteFailed: true, hasRows: false), DataLoadStatus.failed);
  });

  test('G-31 an unreachable server marks public announcements failed', () async {
    final container = ProviderContainer(overrides: [supabaseDbServiceProvider.overrideWithValue(_Db(fail: true))]);
    addTearDown(container.dispose);
    container.listen(publicAnnouncementsProvider, (_, _) {});
    expect(container.read(publicLoadStatusProvider(PublicDataset.announcements)), DataLoadStatus.loading);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(publicLoadStatusProvider(PublicDataset.announcements)), DataLoadStatus.failed);
  });

  test('G-31 an empty but reachable server is "live" (a genuine empty list)', () async {
    final container = ProviderContainer(overrides: [supabaseDbServiceProvider.overrideWithValue(_Db())]);
    addTearDown(container.dispose);
    container.listen(publicAnnouncementsProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(publicLoadStatusProvider(PublicDataset.announcements)), DataLoadStatus.live);
  });

  testWidgets('G-31 placeholder: spinner, then error with Retry, then the empty text', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_host(PublicListPlaceholder(
      dataset: PublicDataset.awards,
      what: 'award winners',
      onRetry: () => retried++,
      empty: const Text('Nothing yet'),
    )));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Loading award winners'), findsOneWidget);

    final element = tester.element(find.byType(PublicListPlaceholder));
    final container = ProviderScope.containerOf(element);
    container.read(publicLoadStatusProvider(PublicDataset.awards).notifier).set(DataLoadStatus.failed);
    await tester.pump();
    expect(find.textContaining("Couldn't load award winners"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried, 1);
    expect(container.read(publicLoadStatusProvider(PublicDataset.awards)), DataLoadStatus.loading);

    container.read(publicLoadStatusProvider(PublicDataset.awards).notifier).set(DataLoadStatus.live);
    await tester.pump();
    expect(find.text('Nothing yet'), findsOneWidget);
  });

  testWidgets('G-31 offline banner shows only while bundled data is showing', (tester) async {
    await tester.pumpWidget(_host(PublicOfflineBanner(dataset: PublicDataset.projects, onRetry: () {})));
    expect(find.byKey(const Key('public-offline-banner')), findsNothing);
    final container = ProviderScope.containerOf(tester.element(find.byType(PublicOfflineBanner)));
    container.read(publicLoadStatusProvider(PublicDataset.projects).notifier).set(DataLoadStatus.offline);
    await tester.pump();
    expect(find.byKey(const Key('public-offline-banner')), findsOneWidget);
  });
}
