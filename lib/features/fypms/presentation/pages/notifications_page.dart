import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/supabase/supabase_client_provider.dart';
import '../../../../core/utils/fypms_format.dart';

/// One in-app notification (`fyp_notifications`, backlog F1).
class FypNotification {
  const FypNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.createdAt,
    this.body,
    this.link,
    this.readAt,
  });

  factory FypNotification.fromJson(Map<String, dynamic> m) => FypNotification(
        id: m['id'] as String? ?? '',
        kind: m['kind'] as String? ?? '',
        title: m['title'] as String? ?? '',
        body: m['body'] as String?,
        link: m['link'] as String?,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime(1970),
        readAt: DateTime.tryParse(m['read_at'] as String? ?? ''),
      );

  final String id;
  final String kind;
  final String title;
  final String? body;

  /// In-app route to open, e.g. /fypms/student/reports.
  final String? link;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;
}

/// The signed-in user's latest notifications (RLS: own rows only).
final fypNotificationsProvider = FutureProvider<List<FypNotification>>((ref) async {
  final uid = ref.watch(currentAuthUserProvider.select((u) => u?.id));
  if (uid == null) return const [];
  try {
    final rows = await ref
        .read(supabaseClientProvider)
        .from('fyp_notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return [for (final m in rows) FypNotification.fromJson(Map<String, dynamic>.from(m))];
  } on PostgrestException {
    return const [];
  }
});

final fypUnreadCountProvider = Provider<int>(
  (ref) => (ref.watch(fypNotificationsProvider).value ?? const []).where((n) => n.isUnread).length,
);

/// Marks [ids] (or everything) read.
final markNotificationsReadProvider = Provider<Future<void> Function([List<String>? ids])>((ref) {
  return ([ids]) async {
    await ref.read(supabaseClientProvider).rpc<dynamic>('mark_notifications_read', params: {'p_ids': ids});
    ref.invalidate(fypNotificationsProvider);
  };
});

/// App-bar bell with the unread count; opens the notifications page.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(fypUnreadCountProvider);
    return IconButton(
      key: const Key('notification-bell'),
      tooltip: unread == 0 ? 'Notifications' : '$unread unread notifications',
      onPressed: () => context.go('/fypms/notifications'),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: Icon(Icons.notifications_outlined, color: color),
      ),
    );
  }
}

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(fypNotificationsProvider);
    final unread = ref.watch(fypUnreadCountProvider);
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text('Notifications', style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(fypNotificationsProvider),
          ),
          if (unread > 0)
            TextButton(
              onPressed: () => ref.read(markNotificationsReadProvider)(),
              child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load notifications: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Nothing new. You will see requests, decisions and results here.'))
            : ListView.separated(
                padding: const EdgeInsets.all(DesignSystem.gutter),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return ListTile(
                    leading: Icon(
                      n.isUnread ? Icons.circle : Icons.circle_outlined,
                      size: 12,
                      color: n.isUnread ? DesignSystem.secondary : DesignSystem.outlineVariant,
                    ),
                    title: Text(n.title, style: DesignSystem.bodyMd.copyWith(fontWeight: n.isUnread ? FontWeight.w600 : FontWeight.w400)),
                    subtitle: Text('${n.body == null || n.body!.isEmpty ? '' : '${n.body}\n'}${formatFypDateTime(n.createdAt)}'),
                    isThreeLine: n.body != null && n.body!.isNotEmpty,
                    onTap: () async {
                      if (n.isUnread) await ref.read(markNotificationsReadProvider)([n.id]);
                      if (n.link != null && context.mounted) context.go(n.link!);
                    },
                  );
                },
              ),
      ),
    );
  }
}
