import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/domain/models/fypms/fyp_supervision_request.dart';
import '../../../../core/state/fypms_state_providers.dart';

/// One F1 Mutual Acceptance request: project title and area, the chosen
/// supervisor and co-supervisor, the student's rationale and, when [canDecide],
/// Accept / Decline with an optional reason.
class SupervisionRequestCard extends ConsumerStatefulWidget {
  const SupervisionRequestCard({
    super.key,
    required this.request,
    this.subtitle,
    this.fallbackTitle,
    this.canDecide = false,
    this.approveLabel = 'Approve',
    this.rejectLabel = 'Reject',
  });

  final FypSupervisionRequest request;

  /// e.g. "STUDENT NAME · CSP600 · CS266"
  final String? subtitle;

  /// Shown when the request has no F1 title (requests made before F1 fields).
  final String? fallbackTitle;
  final bool canDecide;
  final String approveLabel;
  final String rejectLabel;

  @override
  ConsumerState<SupervisionRequestCard> createState() => _SupervisionRequestCardState();
}

class _SupervisionRequestCardState extends ConsumerState<SupervisionRequestCard> {
  // Kept in state: realtime invalidation rebuilds the list and would otherwise
  // discard a half-typed reason.
  final _reason = TextEditingController();
  bool _deciding = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _decide(String decision) async {
    setState(() => _deciding = true);
    final reason = _reason.text.trim();
    try {
      await ref.read(decideSupervisionRequestProvider)(
        widget.request.id,
        decision,
        reason.isEmpty ? null : reason,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decision == 'approved' ? 'Supervision accepted.' : 'Request declined.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deciding = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final directory = ref.watch(supervisorsDirectoryProvider).value ?? const [];
    String nameOf(String? id) {
      if (id == null) return 'not specified';
      final match = directory.where((s) => s['id'] == id).firstOrNull;
      return (match?['display_name'] as String?) ?? 'Staff member';
    }

    final pending = r.status == 'pending';
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: DesignSystem.spaceMd),
      shape: RoundedRectangleBorder(borderRadius: DesignSystem.radiusXl),
      color: DesignSystem.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    (r.projectTitle?.isNotEmpty ?? false)
                        ? r.projectTitle!
                        : ((widget.fallbackTitle?.isNotEmpty ?? false) ? widget.fallbackTitle! : 'Untitled Project'),
                    style: DesignSystem.bodyLg.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!pending) _StatusChip(status: r.status),
              ],
            ),
            if (widget.subtitle != null) Text(widget.subtitle!, style: DesignSystem.bodySm),
            if (r.projectArea?.isNotEmpty ?? false)
              Text('Area: ${r.projectArea}', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            const SizedBox(height: DesignSystem.spaceSm),
            Text('Supervisor: ${nameOf(r.preferredSupervisorId)}', style: DesignSystem.bodySm),
            if (r.preferredCoSupervisorId != null)
              Text('Co-supervisor: ${nameOf(r.preferredCoSupervisorId)}', style: DesignSystem.bodySm),
            if (r.rationale?.isNotEmpty ?? false) ...[
              const SizedBox(height: DesignSystem.spaceXs),
              Text('Rationale: ${r.rationale}', style: DesignSystem.bodySm),
            ],
            if (!pending && (r.decisionReason?.isNotEmpty ?? false))
              Text('Reason: ${r.decisionReason}', style: DesignSystem.bodySm.copyWith(color: DesignSystem.onSurfaceVariant)),
            if (widget.canDecide && pending) ...[
              const SizedBox(height: DesignSystem.spaceSm),
              TextField(
                controller: _reason,
                decoration: const InputDecoration(labelText: 'Reason (optional)'),
              ),
              const SizedBox(height: DesignSystem.spaceMd),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: DesignSystem.spaceSm,
                runSpacing: DesignSystem.spaceSm,
                children: [
                  OutlinedButton(
                    onPressed: _deciding ? null : () => _decide('rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignSystem.error,
                      side: const BorderSide(color: DesignSystem.error),
                    ),
                    child: Text(widget.rejectLabel),
                  ),
                  FilledButton(
                    onPressed: _deciding ? null : () => _decide('approved'),
                    child: Text(widget.approveLabel),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (approved ? DesignSystem.tertiary : DesignSystem.error).withValues(alpha: 0.12),
        borderRadius: DesignSystem.radiusSm,
      ),
      child: Text(
        approved ? 'Accepted' : (status == 'rejected' ? 'Declined' : status),
        style: DesignSystem.bodySm.copyWith(
          color: approved ? DesignSystem.tertiary : DesignSystem.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
