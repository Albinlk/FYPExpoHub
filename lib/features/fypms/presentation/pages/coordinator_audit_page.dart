import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/state/fypms_state_providers.dart';
import '../widgets/fypms_loading_widget.dart';

class CoordinatorAuditPage extends ConsumerWidget {
  const CoordinatorAuditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(fypAuditLogsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.primary,
        title: Text(
          'Audit Logs',
          style: DesignSystem.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: logs.when(
        loading: () => const FypmsLoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No audit log entries yet.'));
          }
          return ListView(
            padding: const EdgeInsets.all(DesignSystem.gutter),
            children: [
              for (final log in list)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spaceSm),
                  shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusLg),
                  color: DesignSystem.surfaceContainerLowest,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceMd,
                      vertical: DesignSystem.spaceXs,
                    ),
                    leading: Icon(
                      _iconForAction(log.action),
                      color: DesignSystem.primary,
                    ),
                    title: Text(
                      log.action.replaceAll('_', ' '),
                      style: DesignSystem.bodySm.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${_formatDate(log.createdAt)} | ${log.actorRole ?? '—'} | ${log.targetType}',
                      style: DesignSystem.bodySm,
                    ),
                    trailing: log.targetId != null
                        ? Text(
                            log.targetId!.substring(0, 8),
                            style: DesignSystem.bodySm.copyWith(
                              color: DesignSystem.onSurfaceVariant,
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _iconForAction(String action) {
    if (action.contains('published')) return Icons.public;
    if (action.contains('created')) return Icons.add;
    if (action.contains('updated') || action.contains('edited')) return Icons.edit;
    if (action.contains('submitted')) return Icons.upload;
    if (action.contains('decided') || action.contains('approved') || action.contains('rejected')) {
      return Icons.gavel;
    }
    return Icons.history;
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(local.day)}-${two(local.month)}-${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
