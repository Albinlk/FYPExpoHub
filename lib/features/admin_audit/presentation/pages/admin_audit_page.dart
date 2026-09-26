import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/state_providers.dart';
import '../../../../core/supabase/supabase_client_provider.dart';

/// One `audit_logs` row as shown to admins.
class AuditEntry {
  const AuditEntry({
    required this.createdAt,
    required this.action,
    required this.targetType,
    this.actorUid,
    this.actorRole,
    this.targetId,
    this.metadata = const {},
  });

  factory AuditEntry.fromRow(Map<String, dynamic> m) => AuditEntry(
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime(1970),
        action: m['action'] as String? ?? '',
        targetType: m['target_type'] as String? ?? '',
        actorUid: m['actor_uid'] as String?,
        actorRole: m['actor_role'] as String?,
        targetId: m['target_id'] as String?,
        metadata: m['metadata_safe'] is Map ? Map<String, dynamic>.from(m['metadata_safe'] as Map) : const {},
      );

  final DateTime createdAt;
  final String action;
  final String targetType;
  final String? actorUid;
  final String? actorRole;
  final String? targetId;
  final Map<String, dynamic> metadata;

  /// Lower-cased text the search box matches against.
  String get haystack => '$action $targetType ${actorRole ?? ''} ${jsonEncode(metadata)}'.toLowerCase();
}

/// The latest Expo audit events (admin RLS: "Admins read audit logs").
final adminAuditLogsProvider = FutureProvider<List<AuditEntry>>((ref) async {
  ref.watch(currentAuthUserProvider.select((u) => u?.id));
  final rows = await ref.read(supabaseDbServiceProvider).getAuditLogsOnce(limit: 300);
  return rows.map(AuditEntry.fromRow).toList();
});

/// Malaysia time, e.g. "26 Sep 2026 14:05".
String formatAuditTime(DateTime t) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final m = t.toUtc().add(const Duration(hours: 8));
  String two(int v) => v.toString().padLeft(2, '0');
  return '${m.day} ${months[m.month - 1]} ${m.year} ${two(m.hour)}:${two(m.minute)}';
}

/// "visit_marked" → "Visit marked".
String humanizeAction(String action) {
  final s = action.replaceAll('_', ' ').trim();
  return s.isEmpty ? '—' : s[0].toUpperCase() + s.substring(1);
}

/// G-07: admins can see who changed what (visits, imports, publishing,
/// event edits…) without database access.
class AdminAuditPage extends ConsumerStatefulWidget {
  const AdminAuditPage({super.key});

  @override
  ConsumerState<AdminAuditPage> createState() => _AdminAuditPageState();
}

class _AdminAuditPageState extends ConsumerState<AdminAuditPage> {
  final _search = TextEditingController();
  String _action = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(adminAuditLogsProvider);
    // Lecturer uid → name, so actors read as people rather than ids.
    final names = <String, String>{
      for (final l in ref.watch(allLecturersProvider).value ?? const <Map<String, dynamic>>[])
        if (l['id'] is String) l['id'] as String: (l['display_name'] ?? l['displayName'] ?? '') as String,
    };

    return Scaffold(
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load the audit log: $e')),
        data: (all) {
          final actions = ['All', ...{for (final e in all) e.action}.toList()..sort()];
          final q = _search.text.trim().toLowerCase();
          final shown = [
            for (final e in all)
              if ((_action == 'All' || e.action == _action) && (q.isEmpty || e.haystack.contains(q))) e,
          ];
          return RefreshIndicator(
            onRefresh: () => ref.refresh(adminAuditLogsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(DesignSystem.spaceLg),
              children: [
                Text('Audit Log', style: DesignSystem.h2Mobile.copyWith(color: DesignSystem.primary)),
                const SizedBox(height: 4),
                Text(
                  'The latest ${all.length} recorded actions, newest first (Malaysia time).',
                  style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant),
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                Wrap(
                  spacing: DesignSystem.spaceSm,
                  runSpacing: DesignSystem.spaceSm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      child: TextField(
                        key: const Key('audit-search'),
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search action, target, details',
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        key: const Key('audit-action'),
                        initialValue: actions.contains(_action) ? _action : 'All',
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Action', isDense: true),
                        items: [
                          for (final a in actions)
                            DropdownMenuItem(
                              value: a,
                              child: Text(a == 'All' ? 'All actions' : humanizeAction(a), overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (v) => setState(() => _action = v ?? 'All'),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(adminAuditLogsProvider),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spaceMd),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceXl),
                    child: Center(
                      child: Text(
                        all.isEmpty ? 'No actions have been recorded yet.' : 'No entries match these filters.',
                        style: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  for (final e in shown)
                    Card(
                      margin: const EdgeInsets.only(bottom: DesignSystem.spaceXs),
                      child: ExpansionTile(
                        leading: const Icon(Icons.history, color: DesignSystem.primary),
                        title: Text(humanizeAction(e.action), style: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${formatAuditTime(e.createdAt)} · '
                          '${names[e.actorUid] ?? e.actorRole ?? 'system'} · ${e.targetType}',
                          style: DesignSystem.bodySm,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        expandedAlignment: Alignment.centerLeft,
                        children: [
                          SelectableText(
                            const JsonEncoder.withIndent('  ').convert({
                              if (e.targetId != null) 'target_id': e.targetId,
                              if (e.actorUid != null) 'actor_uid': e.actorUid,
                              ...e.metadata,
                            }),
                            style: DesignSystem.bodySm.copyWith(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
