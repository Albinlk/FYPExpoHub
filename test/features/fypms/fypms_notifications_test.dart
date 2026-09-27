import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fyp_expo_hub/features/fypms/presentation/pages/notifications_page.dart';

FypNotification _n(String id, {bool read = false, String? link = '/target'}) => FypNotification(
      id: id,
      kind: 'report_decided',
      title: 'Notice $id',
      body: 'Body $id',
      link: link,
      createdAt: DateTime(2026, 9, 27, 10),
      readAt: read ? DateTime(2026, 9, 27, 11) : null,
    );

void main() {
  test('F1 notification JSON parses and tracks unread', () {
    final n = FypNotification.fromJson({
      'id': 'a',
      'kind': 'marks_finalized',
      'title': 'CSP650 marks finalized',
      'body': 'Grade A',
      'link': '/fypms/student/marks',
      'created_at': '2026-09-27T02:00:00Z',
      'read_at': null,
    });
    expect(n.isUnread, isTrue);
    expect(n.link, '/fypms/student/marks');
  });

  testWidgets('F1 bell shows the unread count; tapping an item marks it read and follows the link', (tester) async {
    final marked = <List<String>?>[];
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: NotificationBell(color: Colors.black)),
      ),
      GoRoute(path: '/fypms/notifications', builder: (_, _) => const NotificationsPage()),
      GoRoute(path: '/target', builder: (_, _) => const Text('target page')),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        fypNotificationsProvider.overrideWith((ref) async => [_n('1'), _n('2'), _n('3', read: true)]),
        markNotificationsReadProvider.overrideWithValue(([ids]) async => marked.add(ids)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('notification-bell')));
    await tester.pumpAndSettle();
    expect(find.text('Notice 1'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);

    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    expect(marked.last, isNull);

    await tester.tap(find.text('Notice 2'));
    await tester.pumpAndSettle();
    expect(marked.last, ['2']);
    expect(find.text('target page'), findsOneWidget);
  });
}
